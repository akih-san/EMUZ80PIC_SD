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

#include <xc.h>
#include <stdio.h>
#include "../drivers/SPI.h"
#include "../drivers/mcp23s08.h"

#include "../src/picconfig.h"

// #define MCP23S08_DEBUG
#if defined(MCP23S08_DEBUG)
#define dprintf(args) do { printf args; } while(0)
#else
#define dprintf(args) do { } while(0)
#endif

static struct MCP23S08 {
    struct SPI *spi;
    int alive;
    int pending;
    uint8_t addr;
    uint8_t dir;
    uint8_t olat;
    uint8_t dir_pending;
    uint8_t olat_pending;
} mcp23s08_ctx_ = { 0 };
struct MCP23S08 *MCP23S08_ctx = &mcp23s08_ctx_;

#define REG_IODIR    0x00
#define REG_IPOL     0x01
#define REG_GPINTEN  0x02
#define REG_DEFVAL   0x03
#define REG_INTCON   0x04
#define REG_IOCON    0x05
#define REG_GPPU     0x06
#define REG_INTF     0x07
#define REG_INTCAP   0x08
#define REG_GPIO     0x09
#define REG_OLAT     0x0a

#ifdef MCP23S08_DEBUG
static const char *reg_names[] = {
    "IODIR",
    "IPOL",
    "GPINTEN",
    "DEFVAL",
    "INTCON",
    "IOCON",
    "GPPU",
    "INTF",
    "INTCAP",
    "GPIO",
    "OLAT" };
#endif

static uint8_t mcp23S08_reg_read(struct MCP23S08 *ctx, uint8_t reg)
{
    struct SPI *spi = ctx->spi;
    uint8_t buf[3];
    buf[0] = 0x41 | (uint8_t)((ctx->addr) << 1);  // read
    buf[1] = reg;
    SPI(begin_transaction)(spi);
    SPI(send)(spi, buf, 2);
    buf[2] = SPI(receive_byte)(spi);
    SPI(end_transaction)(spi);
    return buf[2];
}

static void mcp23S08_reg_write(struct MCP23S08 *ctx, uint8_t reg, uint8_t val)
{
    struct SPI *spi = ctx->spi;
    uint8_t buf[3];
    buf[0] = 0x40 | (uint8_t)((ctx->addr) << 1);  // write
    buf[1] = reg;
    buf[2] = val;
    SPI(begin_transaction)(spi);
    SPI(send)(spi, buf, 3);
    SPI(end_transaction)(spi);
}

void mcp23s08_init(struct MCP23S08 *ctx, int clock_speed, uint8_t addr)
{
    ctx->spi = SPI(ctx);
    ctx->addr = addr;
    ctx->dir = 0xff;  // all ports are setup as input
    ctx->olat = 0;
    dprintf(("\n\rMCP23S08: initialize ...\n\r"));

    SPI(begin)(ctx->spi);
    SPI(configure)(ctx->spi, clock_speed, SPI_MSBFIRST, SPI_MODE0);

    ctx->pending = 0;
    mcp23S08_reg_write(ctx, REG_IODIR, ctx->dir);
    mcp23S08_reg_write(ctx, REG_OLAT, ctx->olat);

    mcp23s08_dump_regs(ctx, "");

    ctx->alive = 1;
}

int mcp23s08_probe(struct MCP23S08 *ctx, int clock_speed, uint8_t addr)
{
    int result;
    uint8_t saved_iodir, saved_gppu, saved_olat;
    static struct {
        uint8_t reg;
        uint8_t val;
    } test_vector[] = {
        { REG_IODIR, 0xff },  // All pins are configures as input
        { REG_GPPU, 0x00 },
        { REG_GPPU, 0xa5 },
        { REG_GPPU, 0x5a },
        { REG_GPPU, 0xff },
        { REG_OLAT, 0x00 },
        { REG_OLAT, 0xa5 },
        { REG_OLAT, 0x5a },
        { REG_OLAT, 0xff },
    };

    mcp23s08_init(ctx, clock_speed, addr);

    saved_iodir = mcp23S08_reg_read(ctx, REG_IODIR);
    saved_gppu = mcp23S08_reg_read(ctx, REG_GPPU);
    saved_olat = mcp23S08_reg_read(ctx, REG_OLAT);

    for (unsigned int i = 0; i < sizeof(test_vector)/sizeof(*test_vector); i++) {
        uint8_t reg = test_vector[i].reg;
        uint8_t val = test_vector[i].val;
        mcp23S08_reg_write(ctx, reg, val);
        uint8_t v = mcp23S08_reg_read(ctx, reg);
        dprintf(("MCP23S08: probe %8s: %02x %s %02x\n\r", reg_names[reg], val,
                 (v == val)?"==":"!=", v));
        if (v != val) {
            result = (int)(i + 1);
            goto done;
        }
    }

    result = 0;  // no error. probe succeeded.

 done:
    mcp23S08_reg_write(ctx, REG_OLAT, saved_olat);
    mcp23S08_reg_write(ctx, REG_GPPU, saved_gppu);
    mcp23S08_reg_write(ctx, REG_IODIR, saved_iodir);
    mcp23s08_dump_regs(ctx, "");

    if (result != 0)
        ctx->alive = 0;

    return result;
}

int mcp23s08_is_alive(struct MCP23S08 *ctx)
{
    return ctx->alive;
}

int mcp23s08_set_pending(struct MCP23S08 *ctx, int pending)
{
    int result = ctx->pending;
    if (!ctx->alive || ctx->pending == !!pending)
        return result;
    if (pending) {
        ctx->dir_pending = ctx->dir;
        ctx->olat_pending = ctx->olat;
    } else {
        if (ctx->dir_pending != ctx->dir) {
            ctx->dir = ctx->dir_pending;
            mcp23S08_reg_write(ctx, REG_IODIR, ctx->dir);
        }
        if (ctx->olat_pending != ctx->olat) {
            ctx->olat = ctx->olat_pending;
            mcp23S08_reg_write(ctx, REG_OLAT, ctx->olat);
        }
    }
    ctx->pending = !!pending;
    return result;
}

void mcp23s08_pinmode(struct MCP23S08 *ctx, int gpio, int mode)
{
    if (!ctx->alive)
        return;
    if (ctx->pending) {
        if (mode == MCP23S08_PINMODE_OUTPUT) {
            ctx->dir_pending &= ~(1UL<<gpio);
        } else {
            ctx->dir_pending |= (1UL<<gpio);
        }
        return;
    }
    if (mode == MCP23S08_PINMODE_OUTPUT) {
        ctx->dir &= ~(1UL<<gpio);
    } else {
        ctx->dir |= (1UL<<gpio);
    }
    mcp23S08_reg_write(ctx, REG_IODIR, ctx->dir);
}

void mcp23s08_write(struct MCP23S08 *ctx, int gpio, int val)
{
    if (!ctx->alive)
        return;
    if (ctx->pending) {
        if (val) {
            ctx->olat_pending |= (1UL<<gpio);
        } else {
            ctx->olat_pending &= ~(1UL<<gpio);
        }
        return;
    }
    if (val) {
        ctx->olat |= (1UL<<gpio);
    } else {
        ctx->olat &= ~(1UL<<gpio);
    }
    mcp23S08_reg_write(ctx, REG_OLAT, ctx->olat);
}

void mcp23s08_masked_write(struct MCP23S08 *ctx, uint32_t mask, uint32_t val)
{
    if (!ctx->alive || mask == 0)
        return;
    if (ctx->pending) {
        ctx->olat_pending = ((ctx->olat_pending & ~(uint8_t)mask) | (val & (uint8_t)mask));
        return;
    }
    ctx->olat = ((ctx->olat & ~(uint8_t)mask) | (val & (uint8_t)mask));
    mcp23S08_reg_write(ctx, REG_OLAT, ctx->olat);
}

void mcp23s08_dump_regs(struct MCP23S08 *ctx, const char *header)
{
    #ifdef MCP23S08_DEBUG
    for (unsigned int i = 0; i < sizeof(reg_names)/sizeof(*reg_names); i++) {
        uint8_t val;
        val = mcp23S08_reg_read(ctx, i);
        dprintf(("%sMCP23S08:%8s: %02x\n\r", header, reg_names[i], val));
    }
    #endif  // MCP23S08_DEBUG
}
