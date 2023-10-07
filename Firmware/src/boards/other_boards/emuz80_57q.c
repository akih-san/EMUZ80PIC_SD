/*
 * Copyright (c) 2023 @hanyazou
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#define BOARD_DEPENDENT_SOURCE

#include <supermez80.h>
#include <stdio.h>
#include <SDCard.h>
#include <mcp23s08.h>
#include <picregister.h>

#define SPI_PREFIX      SPI_SD
#define SPI_HW_INST     SPI1
#include <SPI.h>

#define Z80_IOREQ       A0
#define Z80_MEMRQ       A1
#define Z80_BUSRQ       E0
#define Z80_CLK         A3
#define Z80_WAIT        A4
#define Z80_RD          A5
// RA6 is used as UART TXD
// RA7 is used as UART RXD

#define Z80_ADDR_L      B
#define Z80_ADDR_H      D
#define Z80_DATA        F

#define SPI_SD_SS       C4
#define SPI_SD_PICO     C1
#define SPI_SD_CLK      C0
#define SPI_SD_POCI     C2

#define Z80_WR          C5
#define Z80_RESET       E1
#define Z80_INT         E2

#define SRAM_CE         Z80_MEMRQ
#define SRAM_OE         Z80_RD
#define SRAM_WE         Z80_WR

#define HIGH_ADDR_MASK  0xfff00000
#define LOW_ADDR_MASK   0x0000ffff

#include "emuz80_common.c"

static char *emuz80_57q_name()
{
    return "EMUZ80-57Q";
}

static void emuz80_57q_sys_init()
{
    emuz80_common_sys_init();

    // Address bus
    LAT(Z80_ADDR_H) = 0x00;
    TRIS(Z80_ADDR_H) = 0x00;    // Set as output

    // RAM-CS2
    LAT(C7) = 1;                // Set as output
    TRIS(C7) = 0;               // Always active

    // /CE
    LAT(SRAM_CE) = 1;
    TRIS(SRAM_CE) = 0;          // Set as output

    // /WE output pin
    LAT(SRAM_WE) = 1;
    TRIS(SRAM_WE) = 0;          // Set as output

    // /OE output pin
    LAT(SRAM_OE) = 1;
    TRIS(SRAM_OE) = 0;          // Set as output

    PPS(Z80_WAIT) = 0x00;       // unbind with CLC

    // SPI data and clock pins slew at maximum rate
    SLRCON(SPI_SD_PICO) = 0;
    SLRCON(SPI_SD_CLK) = 0;
    SLRCON(SPI_SD_POCI) = 0;

    emuz80_common_wait_for_programmer();

    // Initialize memory bank
    set_bank_pins(0x00000);

    //
    // Initialize SD Card
    //
    static int retry;
    for (retry = 0; 1; retry++) {
        if (20 <= retry) {
            printf("No SD Card?\n\r");
            while(1);
        }
        if (SDCard_init(SPI_CLOCK_100KHZ, SPI_CLOCK_8MHZ, /* timeout */ 100) == SDCARD_SUCCESS)
            break;
        __delay_ms(200);
    }
}

static void emuz80_57q_bus_master(int enable)
{
    if (enable) {
        // Set address bus as output
        TRIS(Z80_ADDR_L) = 0x00;    // A7-A0
        TRIS(Z80_ADDR_H) = 0x00;    // A15-A8

        // Set /MEMRQ, /RD and /WR as output
        LAT(Z80_MEMRQ) = 1;         // deactivate /MEMRQ
        LAT(Z80_RD) = 1;            // deactivate /RD
        LAT(Z80_WR) = 1;            // deactivate /WR
        TRIS(Z80_MEMRQ) = 0;        // output
        TRIS(Z80_RD) = 0;           // output
        TRIS(Z80_WR) = 0;           // output
    } else {
        // Set address bus as input
        TRIS(Z80_ADDR_L) = 0xff;    // A7-A0
        TRIS(Z80_ADDR_H) = 0xff;    // A15-A8
        TRIS(Z80_DATA) = 0xff;      // D7-D0 pin

        // Set /MEMRQ, /RD and /WR as input
        TRIS(Z80_MEMRQ) = 1;        // input
        TRIS(Z80_RD) = 1;           // input
        TRIS(Z80_WR) = 1;           // input
    }
}

static void emuz80_57q_start_z80(void)
{
    emuz80_common_start_z80();

    //
    // CLC1: /IOREQ -> /WAIT
    //
    CLCSELECT = 0;                  // Select CLC1
    CLCnCON = 0x00;                 // Disable CLC

    // input data selection
    CLCnSEL0 = 0;                   // /IORQ is connected to input 0
    CLCnSEL1 = 127;                 // NC
    CLCnSEL2 = 127;                 // NC
    CLCnSEL3 = 127;                 // NC

    // data gating
    CLCnGLS0 = 0x1;                 // Input 0 is inverted and gated into g1
    CLCnGLS1 = 0x0;                 // NC
    CLCnGLS2 = 0x0;                 // NC
    CLCnGLS3 = 0x0;                 // NC

    // select gate output polarities
    CLCnPOL = 0x82;                 // Inverted the CLC output
    CLCnCON = 0x8c;                 // Enable, 1-Input D FF with S and R, falling edge inturrupt

    CLCDATA = 0x0;                  // Clear all CLC outs
    CLC1IF = 0;                     // Clear the CLC interrupt flag
    CLC1IE = 0;                     // Interrupt is not enabled. This will be handled by polling.

    PPS(Z80_WAIT) = PPS_OUT_CLC1;   // CLC1 -> /WAIT

    // Z80 start
    LAT(Z80_BUSRQ) = 1;  // /BUSREQ=1
    LAT(Z80_RESET) = 1;  // Release reset
}

static void emuz80_57q_set_wait_pin(uint8_t v)
{
    if (v == 1) {
        // Release wait (D-FF reset)
        G3POL = 1;
        G3POL = 0;
    } else {
        // not implemented
    }
}

static void emuz80_57q_set_bank_pins(uint32_t addr)
{
}

static void emuz80_57q_setup_addrbus(uint32_t addr)
{
    set_bank_pins(addr);
}

static __bit emuz80_57q_io_event(void)
{
    return CLC1IF;
}

static void emuz80_57q_wait_io_event(void)
{
    while (!CLC1IF && !invoke_monitor);
}

static void emuz80_57q_clear_io_event(void)
{
    CLC1IF = 0;
}

void board_init()
{
    emuz80_common_init();

    board_name_hook = emuz80_57q_name;
    board_sys_init_hook = emuz80_57q_sys_init;
    board_bus_master_hook = emuz80_57q_bus_master;
    board_start_z80_hook = emuz80_57q_start_z80;
    board_set_bank_pins_hook = emuz80_57q_set_bank_pins;
    board_setup_addrbus_hook = emuz80_57q_setup_addrbus;
    board_io_event_hook = emuz80_57q_io_event;
    board_wait_io_event_hook = emuz80_57q_wait_io_event;
    board_clear_io_event_hook = emuz80_57q_clear_io_event;

    board_set_wait_pin_hook  = emuz80_57q_set_wait_pin;
}

#include <pic18f47q43_spi.c>
#include <SDCard.c>
