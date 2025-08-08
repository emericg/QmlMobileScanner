/* code128.c - Handles Code 128 and GS1-128 */
/*
    libzint - the open source barcode library
    Copyright (C) 2008-2025 Robin Stuart <rstuart114@gmail.com>
    Bugfixes thanks to Christian Sakowski and BogDan Vatra

    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions
    are met:

    1. Redistributions of source code must retain the above copyright
       notice, this list of conditions and the following disclaimer.
    2. Redistributions in binary form must reproduce the above copyright
       notice, this list of conditions and the following disclaimer in the
       documentation and/or other materials provided with the distribution.
    3. Neither the name of the project nor the names of its contributors
       may be used to endorse or promote products derived from this software
       without specific prior written permission.

    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
    ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
    IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
    ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
    FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
    DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
    OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
    HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
    LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
    OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
    SUCH DAMAGE.
 */
/* SPDX-License-Identifier: BSD-3-Clause */

#include <assert.h>
#include <stdio.h>
#include "common.h"
#include "code128.h"
#include "gs1.h"

#define C128_SYMBOL_MAX     102     /* 102 * 10 + 10 (check digit) + 13 (Stop) = 1043 */
#define C128_SYMBOL_MAX_S   "102"   /* String version of above */

#define C128_VALUES_MAX     (C128_SYMBOL_MAX + 2) /* Allow for debug/test check digit and Stop */

/* Code 128 tables checked against ISO/IEC 15417:2007 */

/* Code 128 character encodation - Table 1 (with final CODE16K-only character in place of Stop character) */
INTERNAL_DATA const char C128Table[107][6] = { /* Used by CODABLOCKF and CODE16K also */
    {'2','1','2','2','2','2'}, {'2','2','2','1','2','2'}, {'2','2','2','2','2','1'}, {'1','2','1','2','2','3'},
    {'1','2','1','3','2','2'}, {'1','3','1','2','2','2'}, {'1','2','2','2','1','3'}, {'1','2','2','3','1','2'},
    {'1','3','2','2','1','2'}, {'2','2','1','2','1','3'}, {'2','2','1','3','1','2'}, {'2','3','1','2','1','2'},
    {'1','1','2','2','3','2'}, {'1','2','2','1','3','2'}, {'1','2','2','2','3','1'}, {'1','1','3','2','2','2'},
    {'1','2','3','1','2','2'}, {'1','2','3','2','2','1'}, {'2','2','3','2','1','1'}, {'2','2','1','1','3','2'},
    {'2','2','1','2','3','1'}, {'2','1','3','2','1','2'}, {'2','2','3','1','1','2'}, {'3','1','2','1','3','1'},
    {'3','1','1','2','2','2'}, {'3','2','1','1','2','2'}, {'3','2','1','2','2','1'}, {'3','1','2','2','1','2'},
    {'3','2','2','1','1','2'}, {'3','2','2','2','1','1'}, {'2','1','2','1','2','3'}, {'2','1','2','3','2','1'},
    {'2','3','2','1','2','1'}, {'1','1','1','3','2','3'}, {'1','3','1','1','2','3'}, {'1','3','1','3','2','1'},
    {'1','1','2','3','1','3'}, {'1','3','2','1','1','3'}, {'1','3','2','3','1','1'}, {'2','1','1','3','1','3'},
    {'2','3','1','1','1','3'}, {'2','3','1','3','1','1'}, {'1','1','2','1','3','3'}, {'1','1','2','3','3','1'},
    {'1','3','2','1','3','1'}, {'1','1','3','1','2','3'}, {'1','1','3','3','2','1'}, {'1','3','3','1','2','1'},
    {'3','1','3','1','2','1'}, {'2','1','1','3','3','1'}, {'2','3','1','1','3','1'}, {'2','1','3','1','1','3'},
    {'2','1','3','3','1','1'}, {'2','1','3','1','3','1'}, {'3','1','1','1','2','3'}, {'3','1','1','3','2','1'},
    {'3','3','1','1','2','1'}, {'3','1','2','1','1','3'}, {'3','1','2','3','1','1'}, {'3','3','2','1','1','1'},
    {'3','1','4','1','1','1'}, {'2','2','1','4','1','1'}, {'4','3','1','1','1','1'}, {'1','1','1','2','2','4'},
    {'1','1','1','4','2','2'}, {'1','2','1','1','2','4'}, {'1','2','1','4','2','1'}, {'1','4','1','1','2','2'},
    {'1','4','1','2','2','1'}, {'1','1','2','2','1','4'}, {'1','1','2','4','1','2'}, {'1','2','2','1','1','4'},
    {'1','2','2','4','1','1'}, {'1','4','2','1','1','2'}, {'1','4','2','2','1','1'}, {'2','4','1','2','1','1'},
    {'2','2','1','1','1','4'}, {'4','1','3','1','1','1'}, {'2','4','1','1','1','2'}, {'1','3','4','1','1','1'},
    {'1','1','1','2','4','2'}, {'1','2','1','1','4','2'}, {'1','2','1','2','4','1'}, {'1','1','4','2','1','2'},
    {'1','2','4','1','1','2'}, {'1','2','4','2','1','1'}, {'4','1','1','2','1','2'}, {'4','2','1','1','1','2'},
    {'4','2','1','2','1','1'}, {'2','1','2','1','4','1'}, {'2','1','4','1','2','1'}, {'4','1','2','1','2','1'},
    {'1','1','1','1','4','3'}, {'1','1','1','3','4','1'}, {'1','3','1','1','4','1'}, {'1','1','4','1','1','3'},
    {'1','1','4','3','1','1'}, {'4','1','1','1','1','3'}, {'4','1','1','3','1','1'}, {'1','1','3','1','4','1'},
    {'1','1','4','1','3','1'}, {'3','1','1','1','4','1'}, {'4','1','1','1','3','1'}, {'2','1','1','4','1','2'},
    {'2','1','1','2','1','4'}, {'2','1','1','2','3','2'}, {/* Only used by CODE16K */ '2','1','1','1','3','3'}
};

/* Code Set states */
#define C128_A0     1
#define C128_B0     2
#define C128_A1     3
#define C128_B1     4
#define C128_C0     5
#define C128_C1     6
#define C128_STATES 7

/* Helpers to characterize Code Set states */
#define C128_A0B0(cset) ((cset) <= C128_B0)
#define C128_C0C1(cset) ((cset) >= C128_C0)
#define C128_A0A1(cset) ((cset) & 1) /* Assuming !C */
#define C128_AB(cset)   ((cset) >> ((cset) > C128_B0)) /* Assuming !C */

/* Code Set states are named A0, B0, A1, B1, C0 and C1. A, B, and C are the Code 128 Code Sets.
   0 is for ASCII and 1 is for extended ASCII range */
static const char c128_latch_seq[C128_STATES][C128_STATES][3] = {
    /* Current:  A0             B0             A1             B1             C0             C1         Prior */
    { {0}                                                                                           },
    { {0}, {     0     }, {100        }, {101,101    }, {100,100,100}, { 99        }, {101,101, 99} }, /* A0 */
    { {0}, {101        }, {     0     }, {101,101,101}, {100,100    }, { 99        }, {100,100, 99} }, /* B0 */
    { {0}, {101,101    }, {100,100,100}, {     0     }, {100        }, {101,101, 99}, { 99        } }, /* A1 */
    { {0}, {101,101,101}, {100,100    }, {101        }, {     0     }, {100,100, 99}, { 99        } }, /* B1 */
    { {0}, {101        }, {100        }, {101,101,101}, {100,100,100}, {     0     }, {     0     } }, /* C0 */
    { {0}, {101,101,101}, {100,100,100}, {101        }, {100        }, {     0     }, {     0     } }, /* C1 */
};
static const char c128_latch_len[C128_STATES][C128_STATES] = { /* Lengths of above */
    /* Current:  A0             B0             A1             B1             C0             C1         Prior */
    {   0                                                                                           },
    {   0,        0,             1,             2,             3,             1,             3      }, /* A0 */
    {   0,        1,             0,             3,             2,             1,             3      }, /* B0 */
    {   0,        2,             3,             0,             1,             3,             1      }, /* A1 */
    {   0,        3,             2,             1,             0,             3,             1      }, /* B1 */
    {   0,        1,             1,             3,             3,             0,            64      }, /* C0 */
    {   0,        3,             3,             1,             1,            64,             0      }, /* C1 */
};

/* Start sequences for normal, GS1_MODE and READER_INIT (mutually exclusive) */
static const char c128_start_latch_seq[3][C128_STATES][4] = {
    /*        A0          B0            A1                 B1                C0      C1 (not used) */
    { {0}, {103    }, {104    }, {103,101,101    }, {104,100,100    }, {105       }     }, /* Normal */
    { {0}, {103,102}, {104,102}, {103,102,101,101}, {104,102,100,100}, {105,102   }     }, /* GS1_MODE */
    { {0}, {103, 96}, {104, 96}, {103, 96,101,101}, {104, 96,100,100}, {104, 96,99}     }, /* READER_INIT */
};
static const char c128_start_latch_len[3][C128_STATES] = { /* Lengths of above */
    /*        A0          B0            A1                 B1                C0      C1 (not used) */
    {   0,    1,         1,             3,                 3,                 1,     64 }, /* Normal */
    {   0,    2,         2,             4,                 4,                 2,     64 }, /* GS1_MODE */
    {   0,    2,         2,             4,                 4,                 3,     64 }, /* READER_INIT */
};

/* Output cost (length) for Code Sets A/B */
static int c128_cost_ab(const int cset, const unsigned char ch, int *p_mode) {
    const unsigned char mask_0x60 = ch & 0x60; /* 0 for (ch & 0x7F) < 32, 0x60 for (ch & 0x7F) >= 96 */
    const int ga = C128_A0A1(cset);
    int cost = 1;

    assert(!C128_C0C1(cset));

    /* SHIFT */
    if ((ga && mask_0x60 == 0x60) || (!ga && !mask_0x60)) { /* A and (ch & 0x7F) >= 96, or B and (ch & 0x7F) < 32 */
        cost++;
        *p_mode |= 0x10;
    }

    /* FNC4 */
    if (C128_A0B0(cset) == !z_isascii(ch)) { /* If A0/B0 and extended ASCII, or A1/B1 and ASCII */
        cost++;
        *p_mode |= 0x20;
    }

    return cost;
}

/* Calculate the cost of encoding from `i` starting in Code Set `prior_cset` (see `c128_set_values()` below) */
static int c128_cost(const unsigned char source[], const int length, const int i, const int prior_cset,
            const int start_idx, const char priority[C128_STATES], const char fncs[C128_MAX],
            const char manuals[C128_MAX], short (*costs)[C128_STATES], char (*modes)[C128_STATES]) {

    const unsigned char ch = source[i];
    const char *const latch_len = prior_cset == 0 ? c128_start_latch_len[start_idx] : c128_latch_len[prior_cset];
    const int is_fnc1 = ch == '\x1D' && fncs[i];
    const int can_c = is_fnc1 || (z_isdigit(ch) && z_isdigit(source[i + 1])); /* Assumes source NUL-terminated */
    const int manual_c_fail = !can_c && manuals[i] == C128_C0; /* C requested but not doable */
    int min_cost = 999999; /* Max possible cost less than 2 * 256 */
    int min_mode = 0;
    int p;

    for (p = 0; priority[p]; p++) {
        const int cset = priority[p];
        if (C128_C0C1(cset)) {
            if (can_c && (!manuals[i] || manuals[i] == C128_C0)) {
                const int incr = 2 - is_fnc1;
                int mode = prior_cset;
                int cost = 1;
                if (prior_cset != cset) {
                    cost += latch_len[cset];
                    mode = cset;
                }
                if (i + incr < length) {
                    /* Check if memoized */
                    if (costs[i + incr][cset]) {
                        cost += costs[i + incr][cset];
                    } else {
                        cost += c128_cost(source, length, i + incr, cset, 0 /*start_idx*/, priority, fncs, manuals,
                                            costs, modes);
                    }
                }
                if (cost < min_cost) {
                    min_cost = cost;
                    min_mode = mode;
                }
            }
        } else {
            if (!manuals[i] || manuals[i] == C128_AB(cset) || manual_c_fail) {
                int mode = cset;
                int cost = is_fnc1 ? 1 : c128_cost_ab(cset, ch, &mode);
                if (prior_cset != cset) {
                    cost += latch_len[cset];
                }
                if (i + 1 < length) {
                    /* Check if memoized */
                    if (costs[i + 1][cset]) {
                        cost += costs[i + 1][cset];
                    } else {
                        cost += c128_cost(source, length, i + 1, cset, 0 /*start_idx*/, priority, fncs, manuals,
                                            costs, modes);
                    }
                }
                if (cost < min_cost) {
                    min_cost = cost;
                    min_mode = mode;
                }
            }
        }
    }
    assert(min_cost != 999999);

    costs[i][prior_cset] = min_cost;
    modes[i][prior_cset] = min_mode;

    return min_cost;
}

/* Minimal encoding using Divide-And-Conquer with Memoization by Alex Geller - see
   https://github.com/zxing/zxing/commit/94fb277607003c070ffd1413754a782f3f87cbcd
   Many ideas, especially enabling extended ASCII, taken from BWIPP minimal encoding by Bue Jensen - see
   https://github.com/bwipp/postscriptbarcode/pull/278 */
static int c128_set_values(const unsigned char source[], const int length, const int start_idx,
            const char priority[C128_STATES], const char fncs[C128_MAX], const char manuals[C128_MAX],
            int values[C128_VALUES_MAX], int *p_final_cset) {

    short (*costs)[C128_STATES] = (short (*)[C128_STATES]) z_alloca(sizeof(*costs) * length);
    char (*modes)[C128_STATES] = (char (*)[C128_STATES]) z_alloca(sizeof(*modes) * length);
    int glyph_count = 0;
    int cset = 0;
    int i;

    memset(costs, 0, sizeof(*costs) * length);

    assert(source[length] == '\0'); /* Terminating NUL required by `c128_cost()` */
    c128_cost(source, length, 0 /*i*/, 0 /*prior_cset*/, start_idx, priority, fncs, manuals, costs, modes);

    if (costs[0][0] > C128_SYMBOL_MAX) { /* Total minimal cost (glyph count) */
        return costs[0][0];
    }

    /* Output codewords into `values` */
    for (i = 0; i < length; i++) {
        const unsigned char ch = source[i];
        const int is_fnc1 = ch == '\x1D' && fncs[i];
        const int mode = modes[i][cset];
        const int prior_cset = cset;

        cset = mode & 0x0F;
        assert(cset);
        if (cset != prior_cset) {
            int j;
            if (prior_cset == 0) {
                assert(cset != C128_C1);
                for (j = 0; j < c128_start_latch_len[start_idx][cset]; j++) {
                    values[glyph_count++] = c128_start_latch_seq[start_idx][cset][j];
                }
            } else {
                for (j = 0; j < c128_latch_len[prior_cset][cset]; j++) {
                    values[glyph_count++] = c128_latch_seq[prior_cset][cset][j];
                }
            }
        }
        if (mode >= 0x30) {
            /* Extended Shift A/B */
            values[glyph_count++] = 100 + C128_A0A1(cset); /* FNC4 */
            values[glyph_count++] = 98; /* SHIFT */
        } else if (mode >= 0x20) {
            /* Extended A/B */
            values[glyph_count++] = 100 + C128_A0A1(cset); /* FNC4 */
        } else if (mode >= 0x10) {
            /* Shift A/B */
            values[glyph_count++] = 98; /* SHIFT */
        }
        if (is_fnc1) {
            values[glyph_count++] = 102; /* FNC1 */
        } else if (C128_C0C1(cset)) {
            assert(i + 1 < length); /* Guaranteed by algorithm */
            values[glyph_count++] = (ch - '0') * 10 + source[++i] - '0';
        } else {
            /* (ch & 0x7F) < 32 ? (ch & 0x7F) + 64 : (ch & 0x7F) - 32 */
            values[glyph_count++] = (ch & 0x7F) + 96 * !(ch & 0x60) - 32;
        }
    }
    assert(glyph_count == costs[0][0]);

    if (p_final_cset) {
        *p_final_cset = cset;
    }

    return glyph_count;
}

/* Helper to write out symbol, calculating check digit */
static void c128_expand(struct zint_symbol *symbol, int values[C128_VALUES_MAX], int glyph_count) {
    char dest[640]; /* (102 + 1 (check digit)) * 6 + 7 (Stop) = 625 */
    char *d = dest;
    int total_sum;
    int i;

    /* Destination setting and check digit calculation */
    memcpy(d, C128Table[values[0]], 6);
    d += 6;
    total_sum = values[0];

    for (i = 1; i < glyph_count; i++, d += 6) {
        memcpy(d, C128Table[values[i]], 6);
        total_sum += values[i] * i; /* Note can't overflow as 106 * C128_SYMBOL_MAX * C128_SYMBOL_MAX = 1102824 */
    }
    total_sum %= 103;
    memcpy(d, C128Table[total_sum], 6);
    d += 6;
    values[glyph_count++] = total_sum; /* For debug/test */

    /* Stop character */
    memcpy(d, "2331112", 7);
    d += 7;
    values[glyph_count++] = 106; /* For debug/test */

    if (symbol->debug & ZINT_DEBUG_PRINT) {
        fputs("Codewords:", stdout);
        for (i = 0; i < glyph_count; i++) {
            printf(" %d", values[i]);
        }
        printf(" (%d)\n", glyph_count);
        printf("Barspaces: %.*s\n", (int) (d - dest), dest);
        printf("Checksum:  %d\n", total_sum);
    }
#ifdef ZINT_TEST
    if (symbol->debug & ZINT_DEBUG_TEST) {
        debug_test_codeword_dump_int(symbol, values, glyph_count);
    }
#endif

    expand(symbol, dest, d - dest);
}

/* Helper to set `priority` array based on flags */
static void c128_set_priority(char priority[C128_STATES], const int have_a, const int have_b, const int have_c,
                const int have_extended) {
    int i = 0;
    if (have_c) {
        priority[i++] = C128_C0;
    }
    if (have_b || !have_a) {
        priority[i++] = C128_B0;
    }
    if (have_a) {
        priority[i++] = C128_A0;
    }
    if (have_extended) {
        if (have_c) {
            priority[i++] = C128_C1;
        }
        if (have_b || !have_a) {
            priority[i++] = C128_B1;
        }
        if (have_a) {
            priority[i++] = C128_A1;
        }
    }
    priority[i] = 0;
}

/* Handle Code 128, 128AB and HIBC 128 */
INTERNAL int code128(struct zint_symbol *symbol, unsigned char source[], int length) {
    int i;
    int error_number;
    char manuals[C128_MAX] = {0};
    char fncs[C128_MAX] = {0}; /* Manual FNC1 positions */
    int have_fnc1 = 0; /* Whether have at least 1 manual FNC1 */
    int have_a = 0, have_b = 0, have_c = 0, have_extended = 0;
    char priority[C128_STATES];
    int values[C128_VALUES_MAX] = {0};
    int glyph_count;
    unsigned char src_buf[C128_MAX + 1];
    unsigned char *src = source;
    const int ab_only = symbol->symbology == BARCODE_CODE128AB;
    const int start_idx = (symbol->output_options & READER_INIT) ? 2 : 0;

    if (length > C128_MAX) {
        /* This only blocks ridiculously long input - the actual length of the
           resulting barcode depends on the type of data, so this is trapped later */
        return errtxtf(ZINT_ERROR_TOO_LONG, symbol, 340, "Input length %d too long (maximum " C128_MAX_S ")", length);
    }

    /* Detect special Code Set escapes for Code 128 in extra escape mode only */
    if ((symbol->input_mode & EXTRA_ESCAPE_MODE) && symbol->symbology == BARCODE_CODE128) {
        char manual = 0;
        int j = 0;
        for (i = 0; i < length; i++) {
            if (source[i] == '\\' && i + 2 < length && source[i + 1] == '^'
                    && ((source[i + 2] >= '@' && source[i + 2] <= 'C') || source[i + 2] == '1'
                        || source[i + 2] == '^')) {
                if (source[i + 2] == '^') { /* Escape sequence '\^^' */
                    manuals[j] = manual;
                    src_buf[j++] = source[i++];
                    manuals[j] = manual;
                    src_buf[j++] = source[i++];
                    /* Drop second '^' */
                } else if (source[i + 2] == '1') { /* FNC1 */
                    i += 2;
                    fncs[j] = have_fnc1 = 1;
                    manuals[j] = manual;
                    src_buf[j++] = '\x1D'; /* Manual FNC1 dummy */
                } else { /* Manual mode A/B/C/@ */
                    i += 2;
                    manual = source[i] == 'C' ? C128_C0 : source[i] - '@'; /* Assuming A0 = 1, B0 = 2 */
                }
            } else {
                manuals[j] = manual;
                src_buf[j++] = source[i];
            }
        }
        if (j != length) {
            length = j;
            if (length == 0) {
                return errtxt(ZINT_ERROR_INVALID_DATA, symbol, 842, "No input data");
            }
            src = src_buf;
            src[length] = '\0';
            if (symbol->debug & ZINT_DEBUG_PRINT) {
                fputs("Manuals:   ", stdout);
                for (i = 0; i < length; i++) {
                    printf("%c", manuals[i] == C128_C0 ? 'C' : '@' + manuals[i]); /* Assuming A0 = 1, B0 = 2 */
                }
                fputc('\n', stdout);
            }
        }
    }

    /* Classify data to detect which Code Set states are needed */
    if (ab_only) {
        for (i = 0; i < length; i++) {
            const unsigned char ch = src[i];
            const unsigned char mask_0x60 = ch & 0x60; /* 0 for (ch & 0x7F) < 32, 0x60 for (ch & 0x7F) >= 96 */
            have_extended |= ch & 0x80;
            have_a |= !mask_0x60;
            have_b |= mask_0x60 == 0x60;
        }
    } else {
        int prev_digit, digit = 0;
        for (i = 0; i < length; i++) {
            const unsigned char ch = src[i];
            const int is_fnc1 = ch == '\x1D' && fncs[i];
            if (!is_fnc1) {
                const unsigned char mask_0x60 = ch & 0x60; /* 0 for (ch & 0x7F) < 32, 0x60 for (ch & 0x7F) >= 96 */
                const int manual = manuals[i];
                have_extended |= ch & 0x80;
                have_a |= !mask_0x60 || manual == C128_A0;
                have_b |= mask_0x60 == 0x60 || manual == C128_B0;
                prev_digit = digit;
                digit = z_isdigit(ch);
                have_c |= prev_digit && digit;
            }
        }
    }
    c128_set_priority(priority, have_a, have_b, have_c, have_extended);

    glyph_count = c128_set_values(src, length, start_idx, priority, fncs, manuals, values, NULL /*p_final_cset*/);

    if (symbol->debug & ZINT_DEBUG_PRINT) {
        printf("Data (%d): %.*s", length, length >= 100 ? 1 : length >= 10 ? 2 : 3, " ");
        debug_print_escape(src, length, NULL);
        printf("\nGlyphs:    %d\n", glyph_count);
    }

    /* Now we know how long the barcode is - stop it from being too long */
    if (glyph_count > C128_SYMBOL_MAX) {
        return errtxtf(ZINT_ERROR_TOO_LONG, symbol, 341,
                        "Input too long, requires %d symbol characters (maximum " C128_SYMBOL_MAX_S ")", glyph_count);
    }

    /* Now we can get on with it! */
    c128_expand(symbol, values, glyph_count);

    /* ISO/IEC 15417:2007 leaves dimensions/height as application specification */

    /* HRT */
    if (have_fnc1) {
        /* Remove any manual FNC1 dummies ('\x1D') */
        int j = 0;
        for (i = 0; i < length; i++) {
            if (!fncs[i]) {
                src[j++] = src[i];
            }
        }
        length = j;
    }
    error_number = hrt_cpy_iso8859_1(symbol, src, length);

    return error_number;
}

/* Handle GS1-128 (formerly known as EAN-128), and composite version if `cc_mode` set */
INTERNAL int gs1_128_cc(struct zint_symbol *symbol, unsigned char source[], int length, const int cc_mode,
                const int cc_rows) {
    int i;
    int error_number;
    const char manuals[C128_MAX] = {0}; /* Dummy */
    char fncs[C128_MAX]; /* Dummy, set to all 1s */
    char priority[C128_STATES];
    int values[C128_VALUES_MAX] = {0};
    int glyph_count;
    int final_cset;
    int separator_row = 0;
    int reduced_length;
    unsigned char *reduced = (unsigned char *) z_alloca(length + 1);
    const int raw_text = symbol->output_options & BARCODE_RAW_TEXT;

    if (length > C128_MAX) {
        /* This only blocks ridiculously long input - the actual length of the
           resulting barcode depends on the type of data, so this is trapped later */
        return errtxtf(ZINT_ERROR_TOO_LONG, symbol, 342, "Input length %d too long (maximum " C128_MAX_S ")", length);
    }

    /* If part of a composite symbol make room for the separator pattern */
    if (symbol->symbology == BARCODE_GS1_128_CC) {
        separator_row = symbol->rows;
        symbol->row_height[symbol->rows] = 1;
        symbol->rows += 1;
    }

    error_number = gs1_verify(symbol, source, length, reduced, &reduced_length);
    if (error_number >= ZINT_ERROR) {
        return error_number;
    }

    memset(fncs, 1, reduced_length);

    /* Control and extended chars not allowed so only have B/C (+FNC1) */
    c128_set_priority(priority, 0 /*have_a*/, 1 /*have_b*/, 1 /*have_c*/, 0 /*have_extended*/);

    glyph_count = c128_set_values(reduced, reduced_length, 1 /*start_idx*/, priority, fncs, manuals, values,
                                    &final_cset);

    if (symbol->debug & ZINT_DEBUG_PRINT) {
        printf("Data (%d): %.*s", reduced_length, reduced_length >= 100 ? 1 : reduced_length >= 10 ? 2 : 3, " ");
        debug_print_escape(reduced, reduced_length, NULL);
        printf("\nGlyphs:    %d\n", glyph_count);
    }

    /* Now we can calculate how long the barcode is going to be - and stop it from
       being too long */
    if (glyph_count + (cc_mode != 0) > C128_SYMBOL_MAX) {
        return errtxtf(ZINT_ERROR_TOO_LONG, symbol, 344,
                        "Input too long, requires %d symbol characters (maximum " C128_SYMBOL_MAX_S ")",
                        glyph_count + (cc_mode != 0));
    }

    /* "...note that the linkage flag is an extra Code Set character between
       the last data character and the Symbol Check Character" (GS1 Specification) */

    /* Linkage flags in GS1-128 are determined by ISO/IEC 24723 section 7.4 */
    assert(final_cset == C128_B0 || final_cset == C128_C0);

    switch (cc_mode) {
        case 1:
        case 2:
            /* CC-A or CC-B 2D component */
            switch (final_cset) {
                case C128_B0:
                    values[glyph_count++] = 99;
                    break;
                case C128_C0:
                    values[glyph_count++] = 101;
                    break;
            }
            break;
        case 3:
            /* CC-C 2D component */
            switch (final_cset) {
                case C128_B0:
                    values[glyph_count++] = 101;
                    break;
                case C128_C0:
                    values[glyph_count++] = 100;
                    break;
            }
            break;
    }

    c128_expand(symbol, values, glyph_count);

    /* Add the separator pattern for composite symbols */
    if (symbol->symbology == BARCODE_GS1_128_CC) {
        for (i = 0; i < symbol->width; i++) {
            if (!(module_is_set(symbol, separator_row + 1, i))) {
                set_module(symbol, separator_row, i);
            }
        }
    }

    if (reduced_length > 48) { /* GS1 General Specifications 5.4.4.3 */
        if (error_number == 0) { /* Don't overwrite any `gs1_verify()` warning */
            error_number = errtxtf(ZINT_WARN_NONCOMPLIANT, symbol, 843,
                                    "Input too long, requires %d characters (maximum 48)", reduced_length);
        }
    }

    if (symbol->output_options & COMPLIANT_HEIGHT) {
        /* GS1 General Specifications 21.0.1 5.12.3.2 table 2, including footnote (**):
           same as ITF-14: "in case of further space constraints" height 5.8mm / 1.016mm (X max) ~ 5.7;
           default 31.75mm / 0.495mm ~ 64.14 */
        const float min_height = 5.70866156f; /* 5.8 / 1.016 */
        const float default_height = 64.1414108f; /* 31.75 / 0.495 */
        if (symbol->symbology == BARCODE_GS1_128_CC) {
            /* Pass back via temporary linear structure */
            symbol->height = symbol->height ? min_height : default_height;
        } else {
            if (error_number == 0) { /* Don't overwrite any `gs1_verify()` warning */
                error_number = set_height(symbol, min_height, default_height, 0.0f, 0 /*no_errtxt*/);
            } else {
                (void) set_height(symbol, min_height, default_height, 0.0f, 1 /*no_errtxt*/);
            }
        }
    } else {
        const float height = 50.0f;
        if (symbol->symbology == BARCODE_GS1_128_CC) {
            symbol->height = height - cc_rows * (cc_mode == 3 ? 3 : 2) - 1.0f;
        } else {
            (void) set_height(symbol, 0.0f, height, 0.0f, 1 /*no_errtxt*/);
        }
    }

    /* If no other warnings flag use of READER_INIT in GS1_MODE */
    if (error_number == 0 && (symbol->output_options & READER_INIT)) {
        error_number = errtxt(ZINT_WARN_INVALID_OPTION, symbol, 845,
                                "Cannot use Reader Initialisation in GS1 mode, ignoring");
    }

    /* Note won't overflow `text` buffer due to symbol character maximum restricted to C128_SYMBOL_MAX */
    if (raw_text) {
        hrt_cpy_nochk(symbol, reduced, reduced_length);
    } else {
        if (symbol->input_mode & GS1PARENS_MODE) {
            hrt_cpy_nochk(symbol, source, length);
        } else {
            hrt_conv_gs1_brackets_nochk(symbol, source, length);
        }
    }

    return error_number;
}

/* Handle GS1-128 (formerly known as EAN-128) */
INTERNAL int gs1_128(struct zint_symbol *symbol, unsigned char source[], int length) {
    return gs1_128_cc(symbol, source, length, 0 /*cc_mode*/, 0 /*cc_rows*/);
}

/* vim: set ts=4 sw=4 et : */
