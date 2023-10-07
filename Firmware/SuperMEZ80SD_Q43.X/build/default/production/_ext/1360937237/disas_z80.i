# 1 "../src/disas_z80.c"
# 1 "<built-in>" 1
# 1 "<built-in>" 3
# 288 "<built-in>" 3
# 1 "<command line>" 1
# 1 "<built-in>" 2
# 1 "C:\\Program Files\\Microchip\\xc8\\v2.41\\pic\\include\\language_support.h" 1 3
# 2 "<built-in>" 2
# 1 "../src/disas_z80.c" 2
# 24 "../src/disas_z80.c"
# 1 "C:\\Program Files\\Microchip\\xc8\\v2.41\\pic\\include\\c99\\stdio.h" 1 3



# 1 "C:\\Program Files\\Microchip\\xc8\\v2.41\\pic\\include\\c99\\musl_xc8.h" 1 3
# 5 "C:\\Program Files\\Microchip\\xc8\\v2.41\\pic\\include\\c99\\stdio.h" 2 3





# 1 "C:\\Program Files\\Microchip\\xc8\\v2.41\\pic\\include\\c99\\features.h" 1 3
# 11 "C:\\Program Files\\Microchip\\xc8\\v2.41\\pic\\include\\c99\\stdio.h" 2 3
# 24 "C:\\Program Files\\Microchip\\xc8\\v2.41\\pic\\include\\c99\\stdio.h" 3
# 1 "C:\\Program Files\\Microchip\\xc8\\v2.41\\pic\\include\\c99\\bits/alltypes.h" 1 3





typedef void * va_list[1];




typedef void * __isoc_va_list[1];
# 122 "C:\\Program Files\\Microchip\\xc8\\v2.41\\pic\\include\\c99\\bits/alltypes.h" 3
typedef unsigned size_t;
# 137 "C:\\Program Files\\Microchip\\xc8\\v2.41\\pic\\include\\c99\\bits/alltypes.h" 3
typedef long ssize_t;
# 168 "C:\\Program Files\\Microchip\\xc8\\v2.41\\pic\\include\\c99\\bits/alltypes.h" 3
typedef __int24 int24_t;
# 204 "C:\\Program Files\\Microchip\\xc8\\v2.41\\pic\\include\\c99\\bits/alltypes.h" 3
typedef __uint24 uint24_t;
# 246 "C:\\Program Files\\Microchip\\xc8\\v2.41\\pic\\include\\c99\\bits/alltypes.h" 3
typedef long long off_t;
# 399 "C:\\Program Files\\Microchip\\xc8\\v2.41\\pic\\include\\c99\\bits/alltypes.h" 3
typedef struct _IO_FILE FILE;
# 25 "C:\\Program Files\\Microchip\\xc8\\v2.41\\pic\\include\\c99\\stdio.h" 2 3
# 52 "C:\\Program Files\\Microchip\\xc8\\v2.41\\pic\\include\\c99\\stdio.h" 3
typedef union _G_fpos64_t {
 char __opaque[16];
 double __align;
} fpos_t;

extern FILE *const stdin;
extern FILE *const stdout;
extern FILE *const stderr;





FILE *fopen(const char *restrict, const char *restrict);
FILE *freopen(const char *restrict, const char *restrict, FILE *restrict);
int fclose(FILE *);

int remove(const char *);
int rename(const char *, const char *);

int feof(FILE *);
int ferror(FILE *);
int fflush(FILE *);
void clearerr(FILE *);

int fseek(FILE *, long, int);
long ftell(FILE *);
void rewind(FILE *);

int fgetpos(FILE *restrict, fpos_t *restrict);
int fsetpos(FILE *, const fpos_t *);

size_t fread(void *restrict, size_t, size_t, FILE *restrict);
size_t fwrite(const void *restrict, size_t, size_t, FILE *restrict);

int fgetc(FILE *);
int getc(FILE *);
int getchar(void);
int ungetc(int, FILE *);
int getch(void);

int fputc(int, FILE *);
int putc(int, FILE *);
int putchar(int);
void putch(char);

char *fgets(char *restrict, int, FILE *restrict);

char *gets(char *);


int fputs(const char *restrict, FILE *restrict);
int puts(const char *);

__attribute__((__format__(__printf__, 1, 2)))
int printf(const char *restrict, ...);
__attribute__((__format__(__printf__, 2, 3)))
int fprintf(FILE *restrict, const char *restrict, ...);
__attribute__((__format__(__printf__, 2, 3)))
int sprintf(char *restrict, const char *restrict, ...);
__attribute__((__format__(__printf__, 3, 4)))
int snprintf(char *restrict, size_t, const char *restrict, ...);

__attribute__((__format__(__printf__, 1, 0)))
int vprintf(const char *restrict, __isoc_va_list);
int vfprintf(FILE *restrict, const char *restrict, __isoc_va_list);
__attribute__((__format__(__printf__, 2, 0)))
int vsprintf(char *restrict, const char *restrict, __isoc_va_list);
__attribute__((__format__(__printf__, 3, 0)))
int vsnprintf(char *restrict, size_t, const char *restrict, __isoc_va_list);

__attribute__((__format__(__scanf__, 1, 2)))
int scanf(const char *restrict, ...);
__attribute__((__format__(__scanf__, 2, 3)))
int fscanf(FILE *restrict, const char *restrict, ...);
__attribute__((__format__(__scanf__, 2, 3)))
int sscanf(const char *restrict, const char *restrict, ...);

__attribute__((__format__(__scanf__, 1, 0)))
int vscanf(const char *restrict, __isoc_va_list);
int vfscanf(FILE *restrict, const char *restrict, __isoc_va_list);
__attribute__((__format__(__scanf__, 2, 0)))
int vsscanf(const char *restrict, const char *restrict, __isoc_va_list);

void perror(const char *);

int setvbuf(FILE *restrict, char *restrict, int, size_t);
void setbuf(FILE *restrict, char *restrict);

char *tmpnam(char *);
FILE *tmpfile(void);




FILE *fmemopen(void *restrict, size_t, const char *restrict);
FILE *open_memstream(char **, size_t *);
FILE *fdopen(int, const char *);
FILE *popen(const char *, const char *);
int pclose(FILE *);
int fileno(FILE *);
int fseeko(FILE *, off_t, int);
off_t ftello(FILE *);
int dprintf(int, const char *restrict, ...);
int vdprintf(int, const char *restrict, __isoc_va_list);
void flockfile(FILE *);
int ftrylockfile(FILE *);
void funlockfile(FILE *);
int getc_unlocked(FILE *);
int getchar_unlocked(void);
int putc_unlocked(int, FILE *);
int putchar_unlocked(int);
ssize_t getdelim(char **restrict, size_t *restrict, int, FILE *restrict);
ssize_t getline(char **restrict, size_t *restrict, FILE *restrict);
int renameat(int, const char *, int, const char *);
char *ctermid(char *);







char *tempnam(const char *, const char *);
# 25 "../src/disas_z80.c" 2
# 1 "../src/../src/disas_z80.h" 1
# 27 "../src/../src/disas_z80.h"
# 1 "../src/../src/disas.h" 1
# 27 "../src/../src/disas.h"
# 1 "C:\\Program Files\\Microchip\\xc8\\v2.41\\pic\\include\\c99\\stdint.h" 1 3
# 22 "C:\\Program Files\\Microchip\\xc8\\v2.41\\pic\\include\\c99\\stdint.h" 3
# 1 "C:\\Program Files\\Microchip\\xc8\\v2.41\\pic\\include\\c99\\bits/alltypes.h" 1 3
# 127 "C:\\Program Files\\Microchip\\xc8\\v2.41\\pic\\include\\c99\\bits/alltypes.h" 3
typedef unsigned long uintptr_t;
# 142 "C:\\Program Files\\Microchip\\xc8\\v2.41\\pic\\include\\c99\\bits/alltypes.h" 3
typedef long intptr_t;
# 158 "C:\\Program Files\\Microchip\\xc8\\v2.41\\pic\\include\\c99\\bits/alltypes.h" 3
typedef signed char int8_t;




typedef short int16_t;
# 173 "C:\\Program Files\\Microchip\\xc8\\v2.41\\pic\\include\\c99\\bits/alltypes.h" 3
typedef long int32_t;





typedef long long int64_t;
# 188 "C:\\Program Files\\Microchip\\xc8\\v2.41\\pic\\include\\c99\\bits/alltypes.h" 3
typedef long long intmax_t;





typedef unsigned char uint8_t;




typedef unsigned short uint16_t;
# 209 "C:\\Program Files\\Microchip\\xc8\\v2.41\\pic\\include\\c99\\bits/alltypes.h" 3
typedef unsigned long uint32_t;





typedef unsigned long long uint64_t;
# 229 "C:\\Program Files\\Microchip\\xc8\\v2.41\\pic\\include\\c99\\bits/alltypes.h" 3
typedef unsigned long long uintmax_t;
# 23 "C:\\Program Files\\Microchip\\xc8\\v2.41\\pic\\include\\c99\\stdint.h" 2 3

typedef int8_t int_fast8_t;

typedef int64_t int_fast64_t;


typedef int8_t int_least8_t;
typedef int16_t int_least16_t;

typedef int24_t int_least24_t;
typedef int24_t int_fast24_t;

typedef int32_t int_least32_t;

typedef int64_t int_least64_t;


typedef uint8_t uint_fast8_t;

typedef uint64_t uint_fast64_t;


typedef uint8_t uint_least8_t;
typedef uint16_t uint_least16_t;

typedef uint24_t uint_least24_t;
typedef uint24_t uint_fast24_t;

typedef uint32_t uint_least32_t;

typedef uint64_t uint_least64_t;
# 144 "C:\\Program Files\\Microchip\\xc8\\v2.41\\pic\\include\\c99\\stdint.h" 3
# 1 "C:\\Program Files\\Microchip\\xc8\\v2.41\\pic\\include\\c99\\bits/stdint.h" 1 3
typedef int16_t int_fast16_t;
typedef int32_t int_fast32_t;
typedef uint16_t uint_fast16_t;
typedef uint32_t uint_fast32_t;
# 145 "C:\\Program Files\\Microchip\\xc8\\v2.41\\pic\\include\\c99\\stdint.h" 2 3
# 28 "../src/../src/disas.h" 2
# 37 "../src/../src/disas.h"
typedef struct disas_inst_desc {
    uint8_t attr;
    uint8_t op;
    void *ptr;
} disas_inst_desc_t;

unsigned int disas_op(const disas_inst_desc_t *ids, uint8_t *inst, unsigned int len, char *buf,
                      unsigned int buf_len);
unsigned int disas_ops(const disas_inst_desc_t *ids, uint32_t addr, uint8_t *insts,
                       unsigned int len, unsigned int nops, void (*func)(char *line));
# 28 "../src/../src/disas_z80.h" 2

extern const disas_inst_desc_t disas_z80[];
# 26 "../src/disas_z80.c" 2

const disas_inst_desc_t disas_z80[] = {
    { 0x00, 0x00, "NOP" },
    { 0x02, 0x01, "LD BC,%04XH" },
    { 0x00, 0x02, "LD BC,A" },
    { 0x00, 0x03, "INC BC" },
    { 0x00, 0x04, "INC B" },
    { 0x00, 0x05, "DEC B" },
    { 0x01, 0x06, "LD B,%02XH" },
    { 0x00, 0x07, "RLCA" },
    { 0x00, 0x08, "EX AF,AF'" },
    { 0x00, 0x09, "ADD HL,BC" },
    { 0x00, 0x0a, "LD A,(BC)" },
    { 0x00, 0x0b, "DEC BC" },
    { 0x00, 0x0c, "INC C" },
    { 0x00, 0x0d, "DEC C" },
    { 0x01, 0x0e, "LD C,%02X" },
    { 0x00, 0x0f, "RRCA" },

    { 0x01, 0x10, "DJNZ,%d" },
    { 0x02, 0x11, "LD DE,%04XH" },
    { 0x00, 0x12, "LD (DE),A" },
    { 0x00, 0x13, "INC DE" },
    { 0x00, 0x14, "INC D" },
    { 0x00, 0x15, "DEC D" },
    { 0x01, 0x16, "LD D,%02XH" },
    { 0x00, 0x17, "RLA" },
    { 0x01, 0x18, "JR %d" },
    { 0x00, 0x19, "ADD HL,DE" },
    { 0x00, 0x1a, "LD A,(DE)" },
    { 0x00, 0x1b, "DEC DE" },
    { 0x00, 0x1c, "INC E" },
    { 0x00, 0x1d, "DEC E" },
    { 0x01, 0x1e, "LD E,%02X" },
    { 0x00, 0x1f, "RRA" },

    { 0x01, 0x20, "JR NZ,%d" },
    { 0x02, 0x21, "LD HL,%04XH" },
    { 0x02, 0x22, "LD (%04XH),HL" },
    { 0x00, 0x23, "INC HL" },
    { 0x00, 0x24, "INC H" },
    { 0x00, 0x25, "DEC H" },
    { 0x01, 0x26, "LD H,%02XH" },
    { 0x00, 0x27, "DAA" },
    { 0x01, 0x28, "JR Z,%d" },
    { 0x00, 0x29, "ADD HL,HL" },
    { 0x02, 0x2a, "LD HL,(%04XH)" },
    { 0x00, 0x2b, "DEC HL" },
    { 0x00, 0x2c, "INC L" },
    { 0x00, 0x2d, "DEC L" },
    { 0x01, 0x2e, "LD L,%02X" },
    { 0x00, 0x2f, "CPL" },

    { 0x01, 0x30, "JR NC,%d" },
    { 0x02, 0x31, "LD SP,%04XH" },
    { 0x02, 0x32, "LD (%04XH),A" },
    { 0x00, 0x33, "INC SP" },
    { 0x00, 0x34, "INC (HL)" },
    { 0x00, 0x35, "DEC (HL)" },
    { 0x01, 0x36, "LD (HL),%02XH" },
    { 0x00, 0x37, "SCF" },
    { 0x01, 0x38, "JR C,%d" },
    { 0x00, 0x39, "ADD HL,SP" },
    { 0x02, 0x3a, "LD A,(%04XH)" },
    { 0x00, 0x3b, "DEC SP" },
    { 0x00, 0x3c, "INC A" },
    { 0x00, 0x3d, "DEC A" },
    { 0x01, 0x3e, "LD A,%02XH" },
    { 0x00, 0x3f, "CCF" },

    { 0x00, 0x40, "LD B,B" },
    { 0x00, 0x41, "LD B,C" },
    { 0x00, 0x42, "LD B,D" },
    { 0x00, 0x43, "LD B,E" },
    { 0x00, 0x44, "LD B,H" },
    { 0x00, 0x45, "LD B,L" },
    { 0x00, 0x46, "LD B,(HL)" },
    { 0x00, 0x47, "LD B,A" },
    { 0x00, 0x48, "LD C,B" },
    { 0x00, 0x49, "LD C,C" },
    { 0x00, 0x4a, "LD C,D" },
    { 0x00, 0x4b, "LD C,E" },
    { 0x00, 0x4c, "LD C,H" },
    { 0x00, 0x4d, "LD C,L" },
    { 0x00, 0x4e, "LD C,(HL)" },
    { 0x00, 0x4f, "LD C,A" },

    { 0x00, 0x50, "LD D,B" },
    { 0x00, 0x51, "LD D,C" },
    { 0x00, 0x52, "LD D,D" },
    { 0x00, 0x53, "LD D,E" },
    { 0x00, 0x54, "LD D,H" },
    { 0x00, 0x55, "LD D,L" },
    { 0x00, 0x56, "LD D,(HL)" },
    { 0x00, 0x57, "LD D,A" },
    { 0x00, 0x58, "LD E,B" },
    { 0x00, 0x59, "LD E,C" },
    { 0x00, 0x5a, "LD E,D" },
    { 0x00, 0x5b, "LD E,E" },
    { 0x00, 0x5c, "LD E,H" },
    { 0x00, 0x5d, "LD E,L" },
    { 0x00, 0x5e, "LD E,(HL)" },
    { 0x00, 0x5f, "LD E,A" },

    { 0x00, 0x60, "LD H,B" },
    { 0x00, 0x61, "LD H,C" },
    { 0x00, 0x62, "LD H,D" },
    { 0x00, 0x63, "LD H,E" },
    { 0x00, 0x64, "LD H,H" },
    { 0x00, 0x65, "LD H,L" },
    { 0x00, 0x66, "LD H,(HL)" },
    { 0x00, 0x67, "LD H,A" },
    { 0x00, 0x68, "LD L,B" },
    { 0x00, 0x69, "LD L,C" },
    { 0x00, 0x6a, "LD L,D" },
    { 0x00, 0x6b, "LD L,E" },
    { 0x00, 0x6c, "LD L,H" },
    { 0x00, 0x6d, "LD L,L" },
    { 0x00, 0x6e, "LD L,(HL)" },
    { 0x00, 0x6f, "LD L,A" },

    { 0x00, 0x70, "LD (HL),B" },
    { 0x00, 0x71, "LD (HL),C" },
    { 0x00, 0x72, "LD (HL),D" },
    { 0x00, 0x73, "LD (HL),E" },
    { 0x00, 0x74, "LD (HL),H" },
    { 0x00, 0x75, "LD (HL),L" },
    { 0x00, 0x76, "HALT" },
    { 0x00, 0x77, "LD (HL),A" },
    { 0x00, 0x78, "LD A,B" },
    { 0x00, 0x79, "LD A,C" },
    { 0x00, 0x7a, "LD A,D" },
    { 0x00, 0x7b, "LD A,E" },
    { 0x00, 0x7c, "LD A,H" },
    { 0x00, 0x7d, "LD A,L" },
    { 0x00, 0x7e, "LD A,(HL)" },
    { 0x00, 0x7f, "LD A,A" },

    { 0x00, 0x80, "ADD A,B" },
    { 0x00, 0x81, "ADD A,C" },
    { 0x00, 0x82, "ADD A,D" },
    { 0x00, 0x83, "ADD A,E" },
    { 0x00, 0x84, "ADD A,H" },
    { 0x00, 0x85, "ADD A,L" },
    { 0x00, 0x86, "ADD A,(HL)" },
    { 0x00, 0x87, "ADD A,A" },
    { 0x00, 0x88, "ADC A,B" },
    { 0x00, 0x89, "ADC A,C" },
    { 0x00, 0x8a, "ADC A,D" },
    { 0x00, 0x8b, "ADC A,E" },
    { 0x00, 0x8c, "ADC A,H" },
    { 0x00, 0x8d, "ADC A,L" },
    { 0x00, 0x8e, "ADC A,(HL)" },
    { 0x00, 0x8f, "ADC A,A" },

    { 0x00, 0x90, "SUB B" },
    { 0x00, 0x91, "SUB C" },
    { 0x00, 0x92, "SUB D" },
    { 0x00, 0x93, "SUB E" },
    { 0x00, 0x94, "SUB H" },
    { 0x00, 0x95, "SUB L" },
    { 0x00, 0x96, "SUB (HL)" },
    { 0x00, 0x97, "SUB A" },
    { 0x00, 0x98, "SBC A,B" },
    { 0x00, 0x99, "SBC A,C" },
    { 0x00, 0x9a, "SBC A,D" },
    { 0x00, 0x9b, "SBC A,E" },
    { 0x00, 0x9c, "SBC A,H" },
    { 0x00, 0x9d, "SBC A,L" },
    { 0x00, 0x9e, "SBC A,(HL)" },
    { 0x00, 0x9f, "SBC A,A" },

    { 0x00, 0xa0, "AND B" },
    { 0x00, 0xa1, "AND C" },
    { 0x00, 0xa2, "AND D" },
    { 0x00, 0xa3, "AND E" },
    { 0x00, 0xa4, "AND H" },
    { 0x00, 0xa5, "AND L" },
    { 0x00, 0xa6, "AND (HL)" },
    { 0x00, 0xa7, "AND A" },
    { 0x00, 0xa8, "XOR B" },
    { 0x00, 0xa9, "XOR C" },
    { 0x00, 0xaa, "XOR D" },
    { 0x00, 0xab, "XOR E" },
    { 0x00, 0xac, "XOR H" },
    { 0x00, 0xad, "XOR L" },
    { 0x00, 0xae, "XOR (HL)" },
    { 0x00, 0xaf, "XOR A" },

    { 0x00, 0xb0, "OR B" },
    { 0x00, 0xb1, "OR C" },
    { 0x00, 0xb2, "OR D" },
    { 0x00, 0xb3, "OR E" },
    { 0x00, 0xb4, "OR H" },
    { 0x00, 0xb5, "OR L" },
    { 0x00, 0xb6, "OR (HL)" },
    { 0x00, 0xb7, "OR A" },
    { 0x00, 0xb8, "CP B" },
    { 0x00, 0xb9, "CP C" },
    { 0x00, 0xba, "CP D" },
    { 0x00, 0xbb, "CP E" },
    { 0x00, 0xbc, "CP H" },
    { 0x00, 0xbd, "CP L" },
    { 0x00, 0xbe, "CP (HL)" },
    { 0x00, 0xbf, "CP A" },

    { 0x00, 0xc0, "RET NZ" },
    { 0x00, 0xc1, "POP BC" },
    { 0x02, 0xc2, "JP NZ,%04XH" },
    { 0x02, 0xc3, "JP %04XH" },
    { 0x02, 0xc4, "CALL NZ,%04XH" },
    { 0x00, 0xc5, "PUSH BC" },
    { 0x01, 0xc6, "ADD A,%02XH" },
    { 0x00, 0xc7, "RST 00H" },
    { 0x00, 0xc8, "RET Z" },
    { 0x00, 0xc9, "RET" },
    { 0x02, 0xca, "JP Z,%04XH" },
    { 0, 0xcb, ((void*)0) },
    { 0x02, 0xcc, "CALL Z,%04XH" },
    { 0x02, 0xcd, "CALL %04XH" },
    { 0x01, 0xce, "ADC A,%02XH" },
    { 0x00, 0xcf, "RST 08H" },

    { 0x00, 0xd0, "RET NC" },
    { 0x00, 0xd1, "POP DE" },
    { 0x02, 0xd2, "JP NC,%04XH" },
    { 0x01, 0xd3, "OUT (%02XH),A" },
    { 0x02, 0xd4, "CALL NC,%04XH" },
    { 0x00, 0xd5, "PUSH DE" },
    { 0x01, 0xd6, "SUB %02XH" },
    { 0x00, 0xd7, "RST 10H" },
    { 0x00, 0xd8, "RET C" },
    { 0x00, 0xd9, "EXX" },
    { 0x02, 0xda, "JP C,%04XH" },
    { 0x01, 0xdb, "IN A,(%02XH)" },
    { 0x02, 0xdc, "CALL X,%04XH" },
    { 0, 0xdd, ((void*)0) },
    { 0x01, 0xde, "SBC A,%02XH" },
    { 0x00, 0xdf, "RST 18H" },

    { 0x00, 0xe0, "RET PO" },
    { 0x00, 0xe1, "POP HL" },
    { 0x02, 0xe2, "JP PO,%04XH" },
    { 0x00, 0xe3, "EX (SP),HL" },
    { 0x02, 0xe4, "CALL PO,%04XH" },
    { 0x00, 0xe5, "PUSH HL" },
    { 0x01, 0xe6, "AND %02XH" },
    { 0x00, 0xe7, "RST 20H" },
    { 0x00, 0xe8, "RET PE" },
    { 0x00, 0xe9, "JP (HL)" },
    { 0x02, 0xea, "JP PE,%04XH" },
    { 0x00, 0xeb, "EX DE,HL" },
    { 0x02, 0xec, "CALL PE,%04XH" },
    { 0, 0xed, ((void*)0) },
    { 0x01, 0xee, "XOR %02XH" },
    { 0x00, 0xef, "RST 28H" },

    { 0x00, 0xf0, "RET P" },
    { 0x00, 0xf1, "POP AF" },
    { 0x02, 0xf2, "JP P,%04XH" },
    { 0x00, 0xf3, "DI" },
    { 0x02, 0xf4, "CALL P,%04XH" },
    { 0x00, 0xf5, "PUSH AF" },
    { 0x01, 0xf6, "OR %02XH" },
    { 0x00, 0xf7, "RST 30H" },
    { 0x00, 0xf8, "RET M" },
    { 0x00, 0xf9, "LD SP,HL" },
    { 0x02, 0xfa, "JP M,%04XH" },
    { 0x00, 0xfb, "EI" },
    { 0x02, 0xfc, "CALL M,%04XH" },
    { 0, 0xfd, ((void*)0) },
    { 0x01, 0xfe, "CP %02XH" },
    { 0x00, 0xff, "RST 38H" },

    { 0xf0 }
};
