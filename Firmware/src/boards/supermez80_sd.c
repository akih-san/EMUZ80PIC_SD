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

#include "../../src/supermez80.h"
#include <stdio.h>
#include "../../drivers/SDCard.h"
#include "../../drivers/mcp23s08.h"
#include "../../drivers/picregister.h"

#define SPI_PREFIX      SPI_SD
#define SPI_HW_INST     SPI1
#include "../../drivers/SPI.h"

#define Z80_DATA        C
#define Z80_ADDR_H      D
#define Z80_ADDR_L      B

#define Z80_IOREQ       A0
#define Z80_MEMRQ       A1
#define SRAM_WE         A2
#define Z80_CLK         A3
#define SRAM_OE         A4
#define Z80_RD          A5
// RA6 is used as UART TXD
// RA7 is used as UART RXD

// RD0~5 are used as address high A8~13
#define Z80_RFSH        D6
#define Z80_WAIT        D7

#define Z80_BUSRQ       E0
#define Z80_RESET       E1

// new try
////////////////////////////
#define Z80_A14         E2
#define SPI_SS          Z80_MEMRQ
////////////////////////////

#define SPI_SD_PICO     C0
#define SPI_SD_CLK      C1
#define SPI_SD_POCI     C2
#define SPI_SD_SS       SPI_SS

//A14=RE2, then PIC can 0-7FFFH
#define HIGH_ADDR_MASK  0xffff8000
#define LOW_ADDR_MASK   0x00007fff
#

#include "emuz80_common.c"

static char *emuz80_47q_name()
{
    return "EMUZ80PIC_SD for SuperMEZ80";
}

static void emuz80_47q_sys_init()
{
    emuz80_common_sys_init();

    // Address bus
    LAT(Z80_ADDR_H) = 0x00;
    TRIS(Z80_ADDR_H) = 0x40;    // Set as output except 6:/RFSH

    LAT(Z80_A14) = 0;     // init A14=0
    TRIS(Z80_A14) = 0;    // Set as output

    // RAM-CS2
    LAT(C7) = 1;                // Set as output
    TRIS(C7) = 0;               // Always active

   // SPI /CS init
// SPI /CS = /BUSREQ and /MEMRQ
// /BUSREQ is already set "L" at emuz80_common_sys_init()

    LAT(Z80_MEMRQ) = 1;
    TRIS(Z80_MEMRQ) = 0;          // Set as output
    PPS(Z80_MEMRQ) = 0x00;        //reset:output PPS is LATCH
	
    // /WE output pin
    LAT(SRAM_WE) = 1;
    TRIS(SRAM_WE) = 0;          // Set as output
    PPS(SRAM_WE) = 0x00;        //reset:output PPS is LATCH

    // /OE output pin
    LAT(SRAM_OE) = 1;
    TRIS(SRAM_OE) = 0;          // Set as output
    PPS(SRAM_OE) = 0x00;      //reset:output PPS is LATCH

    LAT(Z80_WAIT) = 1;
    PPS(Z80_WAIT) = 0x00;     //reset:output PPS is LATCH
	
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
//debug111
        if (SDCard_init(SPI_CLOCK_100KHZ, SPI_CLOCK_2MHZ, /* timeout */ 100) == SDCARD_SUCCESS)
//        if (SDCard_init(SPI_CLOCK_100KHZ, SPI_CLOCK_8MHZ, /* timeout */ 100) == SDCARD_SUCCESS)
            break;
        __delay_ms(200);
    }
}

static void emuz80_47q_bus_master(int enable)
{
    if (enable) {
        PPS(SRAM_OE) = 0x00;        // unbind CLC and /OE
        PPS(SRAM_WE) = 0x00;        // unbind CLC and /WE
        LAT(SRAM_OE) = 1;           // deactivate /OE
        LAT(SRAM_WE) = 1;           // deactivate /WE

        // Set address bus as output
        TRIS(Z80_ADDR_L) = 0x00;    // A7-A0
        TRIS(Z80_ADDR_H) = 0x40;    // A13-A8 except /RFSH(RD6)
        TRIS(Z80_A14) = 0;          // A14(RE2)

    	TRIS(Z80_RD) = 0;           // output

        LAT(Z80_MEMRQ) = 1;         // deactivate /SPI_SS
    	TRIS(Z80_MEMRQ) = 0;        // output A1(/MEMRQ) : use it for SPI_SS while BUS master
    } else {
        // Set address bus as input
        TRIS(Z80_ADDR_L) = 0xff;    // A7-A0
        TRIS(Z80_ADDR_H) = 0x7f;    // A13-A8 except /WAIT(RD7)
        TRIS(Z80_A14) = 1;          // A14(RE2)
        TRIS(Z80_DATA) = 0xff;      // D7-D0 pin

        // Set /RD and /WR /MEMRQ as input
        TRIS(Z80_RD) = 1;           // input
    	TRIS(Z80_MEMRQ) = 1;        // input

    	PPS(SRAM_OE) = 0x01;        // CLC1 -> /OE
        PPS(SRAM_WE) = 0x02;        // CLC2 -> /WE
    }
}

static void emuz80_47q_start_z80(void)
{
    emuz80_common_start_z80();

    //========== CLC pin assign ===========
    // 0,1,4,5 = Port A, C
    // 2,3,6,7 = Port B, D
    CLCIN0PPS = 0x01;           // RA1 <- /MREQ
    CLCIN1PPS = 0x00;           // RA0 <- /IORQ
    CLCIN2PPS = 0x1e;           // RD6 <- /RFSH
    #ifdef Z80_USE_M1_FOR_SRAM_OE
    CLCIN3PPS = 0x1d;           // RD5 <- /M1
    #endif
    CLCIN4PPS = 0x05;           // RA5 <- /RD

    // 1,2,5,6 = Port A, C
    // 3,4,7,8 = Port B, D
    PPS(SRAM_OE) = 0x01;        // CLC1 -> /OE
    PPS(SRAM_WE) = 0x02;        // CLC2 -> /WE
    PPS(Z80_WAIT) = 0x03;       // CLC3 -> /WAIT

    //========== CLC1 /OE ==========
    CLCSELECT = 0;       // CLC1 select

    #ifdef Z80_USE_M1_FOR_SRAM_OE
    CLCnSEL0 = 0;        // CLCIN0PPS <- /MREQ
    CLCnSEL1 = 4;        // CLCIN4PPS <- /RD
    CLCnSEL2 = 3;        // CLCIN3PPS <- /M1
    CLCnSEL3 = 127;      // NC

    CLCnGLS0 = 0x01;     // /MREQ inverted
    CLCnGLS1 = 0x04;     // /RD inverted
    CLCnGLS2 = 0x10;     // /M1 inverted
    CLCnGLS3 = 0x40;     // 1(0 inverted) for AND gate

    CLCnPOL = 0x80;      // inverted the CLC1 output
    CLCnCON = 0x80;      // AND-OR
    #else
    CLCnSEL0 = 0;        // CLCIN0PPS <- /MREQ
    CLCnSEL1 = 2;        // CLCIN2PPS <- /RFSH
    CLCnSEL2 = 4;        // CLCIN4PPS <- /RD
    CLCnSEL3 = 127;      // NC

    CLCnGLS0 = 0x01;     // /MREQ inverted
    CLCnGLS1 = 0x08;     // /RFSH noninverted
    CLCnGLS2 = 0x10;     // RD inverted
    CLCnGLS3 = 0x40;     // 1(0 inverted) for AND gate

    CLCnPOL = 0x80;      // inverted the CLC1 output
    CLCnCON = 0x82;      // 4 input AND
    #endif

    //========== CLC2 /WE ==========
    CLCSELECT = 1;       // CLC2 select

    CLCnSEL0 = 0;        // CLCIN0PPS <- /MREQ
    CLCnSEL1 = 2;        // CLCIN2PPS <- /RFSH
    CLCnSEL2 = 4;        // CLCIN4PPS <- /RD
    CLCnSEL3 = 127;      // NC

    CLCnGLS0 = 0x01;     // /MREQ inverted
    CLCnGLS1 = 0x08;     // /RFSH noninverted
    CLCnGLS2 = 0x20;     // /RD noninverted
    CLCnGLS3 = 0x40;     // 1(0 inverted) for AND gate

    CLCnPOL = 0x80;      // inverted the CLC2 output
    CLCnCON = 0x82;      // 4 input AND

    //========== CLC3 /WAIT ==========
    CLCSELECT = 2;       // CLC3 select

    CLCnSEL0 = 1;        // D-FF CLK <- /IORQ
    CLCnSEL1 = 127;      // D-FF D NC
    CLCnSEL2 = 127;      // D-FF S NC
    CLCnSEL3 = 127;      // D-FF R NC

    CLCnGLS0 = 0x1;      // LCG1D1N
    CLCnGLS1 = 0x0;      // Connect none
    CLCnGLS2 = 0x0;      // Connect none
    CLCnGLS3 = 0x0;      // Connect none

    CLCnPOL = 0x82;      // inverted the CLC3 output
    CLCnCON = 0x8c;      // Select D-FF, falling edge inturrupt

    CLCDATA = 0x0;       // Clear all CLC outs
    CLC3IF = 0;          // Clear the CLC interrupt flag
    CLC3IE = 0;          // NOTE: CLC3 interrupt is not enabled. This will be handled by polling.

    // Z80 start
    LAT(Z80_BUSRQ) = 1;  // /BUSREQ=1
    LAT(Z80_RESET) = 1;  // Release reset
}

static void emuz80_47q_set_wait_pin(uint8_t v)
{
    if (v == 1) {
        // Release wait (D-FF reset)
        G3POL = 1;
        G3POL = 0;
    } else {
        // not implemented
    }
}

static void emuz80_47q_set_bank_pins(uint32_t addr)
{
	if(((uint32_t)LOW_ADDR_MASK & addr) >=0x4000) {
		LAT(Z80_A14) = 1;
//debug111
//		printf("\n\rLAT(Z80_A14) = 1");
//
	}
	else {
		LAT(Z80_A14) = 0;
//debug111
//		printf("\n\rLAT(Z80_A14) = 0");
//
	}
}

static void emuz80_47q_setup_addrbus(uint32_t addr)
{
    set_bank_pins(addr);
}

static __bit emuz80_47q_io_event(void)
{
    return CLC3IF;
}

static void emuz80_47q_wait_io_event(void)
{
    while (!CLC3IF && !invoke_monitor);
}

static void emuz80_47q_clear_io_event(void)
{
    CLC3IF = 0;
}

void board_init()
{
    emuz80_common_init();

    board_name_hook = emuz80_47q_name;
    board_sys_init_hook = emuz80_47q_sys_init;
    board_bus_master_hook = emuz80_47q_bus_master;
    board_start_z80_hook = emuz80_47q_start_z80;
    board_set_bank_pins_hook = emuz80_47q_set_bank_pins;
    board_setup_addrbus_hook = emuz80_47q_setup_addrbus;
    board_io_event_hook = emuz80_47q_io_event;
    board_wait_io_event_hook = emuz80_47q_wait_io_event;
    board_clear_io_event_hook = emuz80_47q_clear_io_event;

    board_set_wait_pin_hook  = emuz80_47q_set_wait_pin;
}

#include "../../drivers/pic18f47q43_spi.c"
#include "../../drivers/SDCard.c"
