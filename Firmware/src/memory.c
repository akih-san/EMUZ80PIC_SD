/*
 * UART, disk I/O and monitor firmware for SuperMEZ80-SPI
 *
 * Based on main.c by Tetsuya Suzuki and emuz80_z80ram.c by Satoshi Okue
 * Modified by @hanyazou https://twitter.com/hanyazou
 */

#include "../src/supermez80.h"
#include <stdio.h>
#include <string.h>
#include <assert.h>

#include "../drivers/mcp23s08.h"
#include "../drivers/utils.h"

// MMU
int mmu_bank = 0;
int mmu_num_banks = 0;
uint32_t mmu_mem_size = 0;
void (*mmu_bank_select_callback)(int from, int to) = NULL;
void (*mmu_bank_config_callback)(void) = NULL;

void mem_init()
{
    unsigned int i;
    uint32_t addr;

#ifdef NO_MEMORY_CHECK
    mmu_mem_size = 0x40000;
    mmu_num_banks = (int)(mmu_mem_size / 0x10000);
    printf("Skipping memory test\r\n");
    printf("Memory XXX, %06lXH %d KB\r\n", addr, (int)(mmu_mem_size / 1024));
    return;
#endif

#ifdef CPM_MMU_EXERCISE
    mmu_mem_size = 0x80000;
    mmu_num_banks = (int)(mmu_mem_size / 0x10000);
    memset(tmp_buf[0], 0, TMP_BUF_SIZE * 2);
    for (addr = 0; addr < mmu_mem_size; addr += TMP_BUF_SIZE * 2) {
        dma_write_to_sram(addr, tmp_buf[0], TMP_BUF_SIZE * 2);
    }
#else
    // RAM check
    for (i = 0; i < TMP_BUF_SIZE; i += 2) {
        tmp_buf[0][i + 0] = 0xa5;
        tmp_buf[0][i + 1] = 0x5a;
    }
    for (addr = 0; addr < MAX_MEM_SIZE; addr += MEM_CHECK_UNIT) {
        #ifdef CPM_MMU_DEBUG
        printf("Memory %06lXH\r\n", addr);
        #else
        printf("Memory 000000 - %06lXH\r", addr);
        #endif
        tmp_buf[0][0] = (addr >>  0) & 0xff;
        tmp_buf[0][1] = (addr >>  8) & 0xff;
        tmp_buf[0][2] = (addr >> 16) & 0xff;
        dma_write_to_sram(addr, tmp_buf[0], TMP_BUF_SIZE);
        dma_read_from_sram(addr, tmp_buf[1], TMP_BUF_SIZE);
        if (memcmp(tmp_buf[0], tmp_buf[1], TMP_BUF_SIZE) != 0) {
            #ifdef CPM_MMU_DEBUG
            printf("\nMemory error at %06lXH\n\r", addr);
            util_addrdump("WR: ", addr, tmp_buf[0], TMP_BUF_SIZE);
            util_addrdump("RD: ", addr, tmp_buf[1], TMP_BUF_SIZE);
            #endif
            break;
        }
        if (addr == 0)
            continue;
        dma_read_from_sram(0, tmp_buf[1], TMP_BUF_SIZE);
        if (memcmp(tmp_buf[0], tmp_buf[1], TMP_BUF_SIZE) == 0) {
            // the page at addr is the same as the first page
            break;
        }
    }
    mmu_mem_size = addr;
    #ifdef CPM_MMU_DEBUG
    for (addr = 0; addr < mmu_mem_size; addr += MEM_CHECK_UNIT) {
        #ifdef CPM_MMU_DEBUG
        printf("Memory %06lXH\r\n", addr);
        #else
        printf("Memory 000000 - %06lXH\r", addr);
        #endif
        if (addr == 0 || (addr & 0xc000))
            continue;
        tmp_buf[0][0] = (addr >>  0) & 0xff;
        tmp_buf[0][1] = (addr >>  8) & 0xff;
        tmp_buf[0][2] = (addr >> 16) & 0xff;
        //dma_write_to_sram(addr, tmp_buf[0], TMP_BUF_SIZE);
        dma_read_from_sram(addr, tmp_buf[1], TMP_BUF_SIZE);
        if (memcmp(tmp_buf[0], tmp_buf[1], TMP_BUF_SIZE) != 0) {
            printf("\nMemory error at %06lXH\n\r", addr);
            util_addrdump("CA: ", addr, tmp_buf[0], TMP_BUF_SIZE);
            util_addrdump("RD: ", addr, tmp_buf[1], TMP_BUF_SIZE);
            while (1);
        }
    }
    for (i = 0; i < TMP_BUF_SIZE; i++)
        tmp_buf[1][i] = TMP_BUF_SIZE - i;
    for (addr = 0x0c000; addr < 0x10000; addr += TMP_BUF_SIZE) {
        for (i = 0; i < TMP_BUF_SIZE; i++)
            tmp_buf[0][i] = i;
        dma_write_to_sram(0x0c000, tmp_buf[0], TMP_BUF_SIZE);
        dma_write_to_sram(0x1c000, tmp_buf[1], TMP_BUF_SIZE);
        dma_read_from_sram(0x0c000, tmp_buf[0], TMP_BUF_SIZE);
        if (memcmp(tmp_buf[0], tmp_buf[1], TMP_BUF_SIZE) != 0) {
            printf("\nMemory error at %06lXH\n\r", addr);
            util_addrdump("EX: ", 0x0c000, tmp_buf[1], TMP_BUF_SIZE);
            util_addrdump("RD: ", 0x0c000, tmp_buf[0], TMP_BUF_SIZE);
            while (1);
        }
    }
    #endif  // CPM_MMU_DEBUG

    mmu_num_banks = (int)(mmu_mem_size / 0x10000);
    printf("Memory 000000 - %06lXH %d KB OK\r\n", addr, (int)(mmu_mem_size / 1024));
#endif  // !CPM_MMU_EXERCISE
}

static const unsigned char dma_helper_z80[] = {
        #include "../z80/dma_helper.inc"
};
#define memcpy_on_target_buf sizeof(dma_helper_z80)
#define memcpy_on_target_buf_size 0x80
static void __memcpy_on_target(uint16_t dest, uint16_t src, uint8_t *buf, unsigned int len,
                               int bank)
{
    struct dma_helper_param {
        uint16_t src_addr;
        uint16_t dest_addr;
        uint8_t length;
    } params;
    mem_region_t param_blocks[3] = {
        { (uint8_t *)dma_helper_z80, 0x0000, sizeof(dma_helper_z80) },
        { (uint8_t *)&params, 0x0004, sizeof(params) },
    };

    #ifdef CPM_MEMCPY_DEBUG
    printf("%22s: %04X to %04X, %u bytes\n\r", __func__, src, dest, len);
    #endif

    assert(sizeof(params) == 5);
    assert(len <= 256);
    params.src_addr = src;
    params.dest_addr = dest;
    params.length = (uint8_t)len;

    if (src == memcpy_on_target_buf) {
        param_blocks[2].addr = buf;
        param_blocks[2].offs = src;
        param_blocks[2].len = len;
        io_invoke_target_cpu(param_blocks, 3, NULL, 0, bank);
    } else {
        param_blocks[2].addr = buf;
        param_blocks[2].offs = dest;
        param_blocks[2].len = len;
        io_invoke_target_cpu(param_blocks, 2, &param_blocks[2], 1, bank);
    }
}

static void write_to_sram_low_addr(uint32_t dest, const void *buf, unsigned int len)
{
    uint16_t addr_gap_mask = ~board_low_addr_mask();
    uint16_t addr = (uint16_t)(dest & 0xffff);
    unsigned int n;
    int saved_io_status;
    int bank = phys_addr_bank(dest);

    #ifdef CPM_MEMCPY_DEBUG
    printf("%22s: addr=  %04X, len=%4u\n\r", __func__, addr, len);
    #endif

    if (!(addr & addr_gap_mask || (addr + len - 1) & addr_gap_mask)) {
        set_data_dir(0x00);     // Set as output to write to the SRAM
        board_write_to_sram(addr, (uint8_t*)buf, len);
        return;
    }
    io_invoke_target_cpu_prepare(&saved_io_status);
    while (0 < len) {
        n = UTIL_MIN(memcpy_on_target_buf_size, len);
        __memcpy_on_target(addr, memcpy_on_target_buf, (uint8_t*)buf, n, bank);
        len -= n;
        addr += n;
        buf += n;
    }
    io_invoke_target_cpu_teardown(&saved_io_status);
}

void dma_write_to_sram(uint32_t dest, const void *buf, unsigned int len)
{
    uint32_t high_addr_mask = board_high_addr_mask();
    uint16_t addr = (uint16_t)(dest & ~high_addr_mask);
    uint16_t second_half = 0;

    #ifdef CPM_MEMCPY_DEBUG
    printf("%22s: addr=%06lX, len=%4u\n\r", __func__, dest, len);
    #endif

    if ((uint32_t)~high_addr_mask + 1 < (uint32_t)addr + len)
        second_half = (uint16_t)(((uint32_t)addr + len) - ((uint32_t)~high_addr_mask + 1));

    board_setup_addrbus(dest);
//    write_to_sram_low_addr(dest, (uint8_t*)buf, len - second_half);
    write_to_sram_low_addr(addr, (uint8_t*)buf, len - second_half);

    if (0 < second_half) {
        board_setup_addrbus(dest + len - second_half);
//        write_to_sram_low_addr(dest, &((uint8_t*)buf)[len - second_half], second_half);
        write_to_sram_low_addr(addr, &((uint8_t*)buf)[len - second_half], second_half);
    }
}

static void read_from_sram_low_addr(uint32_t src, void *buf, unsigned int len)
{
    uint16_t addr_gap_mask = ~board_low_addr_mask();
    uint16_t addr = (uint16_t)(src & 0xffff);
    unsigned int n;
    int saved_io_status;
    int bank = phys_addr_bank(src);

    #ifdef CPM_MEMCPY_DEBUG
    printf("%22s: addr=  %04X, len=%4u\n\r", __func__, addr, len);
    #endif

    if (!(addr & addr_gap_mask || (addr + len - 1) & addr_gap_mask)) {
        set_data_dir(0xff);     // Set as input to read from the SRAM
        board_read_from_sram(addr, (uint8_t*)buf, len);
        return;
    }
    io_invoke_target_cpu_prepare(&saved_io_status);
    while (0 < len) {
        n = UTIL_MIN(memcpy_on_target_buf_size, len);
        __memcpy_on_target(memcpy_on_target_buf, addr, (uint8_t*)buf, n, bank);
        len -= n;
        addr += n;
        buf += n;
    }
    io_invoke_target_cpu_teardown(&saved_io_status);
}

void dma_read_from_sram(uint32_t src, void *buf, unsigned int len)
{
    uint32_t high_addr_mask = board_high_addr_mask();
    uint16_t addr = (uint16_t)(src & ~high_addr_mask);
    uint16_t second_half = 0;

    #ifdef CPM_MEMCPY_DEBUG
    printf("%22s: addr=%06lX, len=%4u\n\r", __func__, src, len);
    #endif

    if ((uint32_t)~high_addr_mask + 1 < (uint32_t)addr + len)
        second_half = (uint16_t)(((uint32_t)addr + len) - ((uint32_t)~high_addr_mask + 1));

    board_setup_addrbus(src);
//    read_from_sram_low_addr(src, (uint8_t*)buf, len - second_half);
    read_from_sram_low_addr(addr, (uint8_t*)buf, len - second_half);

    if (0 < second_half) {
        board_setup_addrbus(src + len - second_half);
//        read_from_sram_low_addr(src, &((uint8_t*)buf)[len - second_half], second_half);
        read_from_sram_low_addr(addr, &((uint8_t*)buf)[len - second_half], second_half);
    }
}

void __write_to_sram(uint32_t dest, const void *buf, unsigned int len)
{
    board_setup_addrbus(dest);
    set_data_dir(0x00);     // Set as output to write to the SRAM
    board_write_to_sram(dest & 0xffff, (uint8_t*)buf, len);
}

void __write_sram_regions(const mem_region_t *regions, unsigned int n, int bank)
{
    int i;

    if (is_board_write_sram_reions_available()) {
        board_write_sram_regions(regions, n, bank);
        return;
    }

    set_data_dir(0x00);     // Set as output to write to the SRAM
    for (i = 0; i < n; i++) {
        board_setup_addrbus(bank_phys_addr(bank, regions[i].offs));
        board_write_to_sram(regions[i].offs, regions[i].addr, regions[i].len);
    }
}

void __read_from_sram(uint32_t src, const void *buf, unsigned int len)
{
    board_setup_addrbus(src);
    set_data_dir(0xff);     // Set as input to read from the SRAM
    board_read_from_sram(src & 0xffff, (uint8_t*)buf, len);
}


void __read_sram_regions(const mem_region_t *regions, unsigned int n, int bank)
{
    int i;

    if (is_board_read_sram_reions_available()) {
        board_read_sram_regions(regions, n, bank);
        return;
    }

    set_data_dir(0xff);     // Set as input to read from the SRAM
    for (i = 0; i < n; i++) {
        board_setup_addrbus(bank_phys_addr(bank, regions[i].offs));
        board_read_from_sram(regions[i].offs, regions[i].addr, regions[i].len);
    }
}

void mmu_bank_config(int nbanks)
{
    #ifdef CPM_MMU_DEBUG
    printf("mmu_bank_config: %d\n\r", nbanks);
    #endif
    if (mmu_num_banks < nbanks)
        printf("WARNING: too many banks requested. (request is %d)\n\r", nbanks);
    if (mmu_bank_config_callback)
        (*mmu_bank_config_callback)();
}

void mmu_bank_select(int bank)
{
    #ifdef CPM_MMU_DEBUG
    printf("mmu_bank_select: %d\n\r", bank);
    #endif
    if (mmu_bank == bank)
        return;
    if (mmu_num_banks <= bank) {
        static unsigned char first_time = 1;
        #if !defined(CPM_MMU_DEBUG)
        if (first_time)
        #endif
        {
            first_time = 0;
            printf("ERROR: bank %d is not available.\n\r", bank);
            invoke_monitor = 1;
        }
    }
    if (mmu_bank_select_callback)
        (*mmu_bank_select_callback)(mmu_bank, bank);
    mmu_bank = bank;
    set_bank_pins((uint32_t)mmu_bank << 16);
}
