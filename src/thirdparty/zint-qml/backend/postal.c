/* postal.c - Handles POSTNET, PLANET, CEPNet, FIM. RM4SCC and Flattermarken */
/*
    libzint - the open source barcode library
    Copyright (C) 2008-2023 Robin Stuart <rstuart114@gmail.com>
    Including bug fixes by Bryan Hatton

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

#include <stdio.h>
#include "common.h"

static const char DAFTSET[] = "FADT";
static const char KRSET[] = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
static const char KASUTSET[] = "1234567890-abcdefgh";
static const char CHKASUTSET[] = "0123456789-abcdefgh";
#define SHKASUTSET_F (IS_NUM_F | IS_MNS_F | IS_UPR_F) /* SHKASUTSET "1234567890-ABCDEFGHIJKLMNOPQRSTUVWXYZ" */

/* PostNet number encoding table - In this table L is long as S is short */
static const char PNTable[10][5] = {
    {'L','L','S','S','S'}, {'S','S','S','L','L'}, {'S','S','L','S','L'}, {'S','S','L','L','S'}, {'S','L','S','S','L'},
    {'S','L','S','L','S'}, {'S','L','L','S','S'}, {'L','S','S','S','L'}, {'L','S','S','L','S'}, {'L','S','L','S','S'}
};

static const char PLTable[10][5] = {
    {'S','S','L','L','L'}, {'L','L','L','S','S'}, {'L','L','S','L','S'}, {'L','L','S','S','L'}, {'L','S','L','L','S'},
    {'L','S','L','S','L'}, {'L','S','S','L','L'}, {'S','L','L','L','S'}, {'S','L','L','S','L'}, {'S','L','S','L','L'}
};

static const char RoyalValues[36][2] = {
    { 1, 1 }, { 1, 2 }, { 1, 3 }, { 1, 4 }, { 1, 5 }, { 1, 0 }, { 2, 1 }, { 2, 2 }, { 2, 3 }, { 2, 4 },
    { 2, 5 }, { 2, 0 }, { 3, 1 }, { 3, 2 }, { 3, 3 }, { 3, 4 }, { 3, 5 }, { 3, 0 }, { 4, 1 }, { 4, 2 },
    { 4, 3 }, { 4, 4 }, { 4, 5 }, { 4, 0 }, { 5, 1 }, { 5, 2 }, { 5, 3 }, { 5, 4 }, { 5, 5 }, { 5, 0 },
    { 0, 1 }, { 0, 2 }, { 0, 3 }, { 0, 4 }, { 0, 5 }, { 0, 0 }
};

/* 0 = Full, 1 = Ascender, 2 = Descender, 3 = Tracker */
static const char RoyalTable[36][4] = {
    {'3','3','0','0'}, {'3','2','1','0'}, {'3','2','0','1'}, {'2','3','1','0'}, {'2','3','0','1'}, {'2','2','1','1'},
    {'3','1','2','0'}, {'3','0','3','0'}, {'3','0','2','1'}, {'2','1','3','0'}, {'2','1','2','1'}, {'2','0','3','1'},
    {'3','1','0','2'}, {'3','0','1','2'}, {'3','0','0','3'}, {'2','1','1','2'}, {'2','1','0','3'}, {'2','0','1','3'},
    {'1','3','2','0'}, {'1','2','3','0'}, {'1','2','2','1'}, {'0','3','3','0'}, {'0','3','2','1'}, {'0','2','3','1'},
    {'1','3','0','2'}, {'1','2','1','2'}, {'1','2','0','3'}, {'0','3','1','2'}, {'0','3','0','3'}, {'0','2','1','3'},
    {'1','1','2','2'}, {'1','0','3','2'}, {'1','0','2','3'}, {'0','1','3','2'}, {'0','1','2','3'}, {'0','0','3','3'}
};

static const char FlatTable[10][4] = {
    {'0','5','0','4'}, {     "18"      }, {'0','1','1','7'}, {'0','2','1','6'}, {'0','3','1','5'},
    {'0','4','1','4'}, {'0','5','1','3'}, {'0','6','1','2'}, {'0','7','1','1'}, {'0','8','1','0'}
};

static const char KoreaTable[10][10] = {
    {'1','3','1','3','1','5','0','6','1','3'}, {'0','7','1','3','1','3','1','3','1','3'},
    {'0','4','1','7','1','3','1','3','1','3'}, {'1','5','0','6','1','3','1','3','1','3'},
    {'0','4','1','3','1','7','1','3','1','3'}, {              "17171313"               },
    {'1','3','1','5','0','6','1','3','1','3'}, {'0','4','1','3','1','3','1','7','1','3'},
    {              "17131713"               }, {              "13171713"               }
};

static const char JapanTable[19][3] = {
    {'1','1','4'}, {'1','3','2'}, {'3','1','2'}, {'1','2','3'}, {'1','4','1'},
    {'3','2','1'}, {'2','1','3'}, {'2','3','1'}, {'4','1','1'}, {'1','4','4'},
    {'4','1','4'}, {'3','2','4'}, {'3','4','2'}, {'2','3','4'}, {'4','3','2'},
    {'2','4','3'}, {'4','2','3'}, {'4','4','1'}, {'1','1','1'}
};

/* Set height for POSTNET/PLANET/CEPNet codes, maintaining ratio */
static int usps_set_height(struct zint_symbol *symbol, const int no_errtxt) {
    /* USPS Domestic Mail Manual (USPS DMM 300) Jan 8, 2006 (updated 2011) 708.4.2.5 POSTNET Barcode Dimensions and
       Spacing
       http://web.archive.org/web/20061113174253/http://pe.usps.com/cpim/ftp/manuals/dmm300/full/mailingStandards.pdf
       Using bar pitch as X (1" / 43) ~ 0.023" based on 22 bars + 21 spaces per inch (bar width 0.015" - 0.025")
       Half bar height 0.05" +- 0.01;  0.040" (min) / 0.025" (X max) = 1.6 min, 0.060" (max) / 0.015" (X min) = 4 max
       Full bar height 0.125" +- 0.01; 0.115" (min) / 0.025" (X max) = 4.6 min, 0.135" (max) / 0.015" (X min) = 9 max
     */
     /* CEPNet e Código Bidimensional Datamatrix 2D (26/05/2021) 3.3.2 Arquitetura das barras - same as POSTNET */
    int error_number = 0;
    float h_ratio; /* Half ratio */

    /* No legacy for CEPNet as new */
    if ((symbol->output_options & COMPLIANT_HEIGHT) || symbol->symbology == BARCODE_CEPNET) {
        symbol->row_height[0] = stripf(0.075f * 43); /* 3.225 */
        symbol->row_height[1] = stripf(0.05f * 43); /* 2.15 */
    } else {
        symbol->row_height[0] = 6.0f;
        symbol->row_height[1] = 6.0f;
    }
    if (symbol->height) {
        h_ratio = symbol->row_height[1] / (symbol->row_height[0] + symbol->row_height[1]); /* 0.4 */
        symbol->row_height[1] = stripf(symbol->height * h_ratio);
        if (symbol->row_height[1] < 0.5f) { /* Absolute minimum */
            symbol->row_height[1] = 0.5f;
            symbol->row_height[0] = stripf(0.5f / h_ratio - 0.5f); /* 0.75 */
        } else {
            symbol->row_height[0] = stripf(symbol->height - symbol->row_height[1]);
        }
    }
    symbol->height = stripf(symbol->row_height[0] + symbol->row_height[1]);

    if (symbol->output_options & COMPLIANT_HEIGHT) {
        if (symbol->height < 4.6f || symbol->height > 9.0f) {
            error_number = ZINT_WARN_NONCOMPLIANT;
            if (!no_errtxt) {
                strcpy(symbol->errtxt, "498: Height not compliant with standards");
            }
        }
    }

    return error_number;
}

/* Handles the POSTNET system used for Zip codes in the US */
/* Also handles Brazilian CEPNet - more information CEPNet e Código Bidimensional Datamatrix 2D (26/05/2021) at
 * https://www.correios.com.br/enviar/correspondencia/arquivos/nacional/guia-tecnico-cepnet-e-2d-triagem-enderecamento-27-04-2021.pdf/view
 */
static int postnet_enc(struct zint_symbol *symbol, const unsigned char source[], char *d, const int length) {
    int i, sum, check_digit;
    int error_number = 0;

    if (length > 38) {
        strcpy(symbol->errtxt, "480: Input too long (38 character maximum)");
        return ZINT_ERROR_TOO_LONG;
    }

    if (symbol->symbology == BARCODE_CEPNET) {
        if (length != 8) {
            strcpy(symbol->errtxt, "780: Input is wrong length (should be 8 digits)");
            error_number = ZINT_WARN_NONCOMPLIANT;
        }
    } else {
        if (length != 5 && length != 9 && length != 11) {
            strcpy(symbol->errtxt, "479: Input length is not standard (5, 9 or 11 characters)");
            error_number = ZINT_WARN_NONCOMPLIANT;
        }
    }
    if (!is_sane(NEON_F, source, length)) {
        strcpy(symbol->errtxt, "481: Invalid character in data (digits only)");
        return ZINT_ERROR_INVALID_DATA;
    }
    sum = 0;

    /* start character */
    *d++ = 'L';

    for (i = 0; i < length; i++, d += 5) {
        const int val = source[i] - '0';
        memcpy(d, PNTable[val], 5);
        sum += val;
    }

    check_digit = (10 - (sum % 10)) % 10;
    memcpy(d, PNTable[check_digit], 5);
    d += 5;

    if (symbol->debug & ZINT_DEBUG_PRINT) printf("Check digit: %d\n", check_digit);

    /* stop character */
    strcpy(d, "L");

    return error_number;
}

/* Puts POSTNET barcodes into the pattern matrix */
INTERNAL int postnet(struct zint_symbol *symbol, unsigned char source[], int length) {
    char height_pattern[256]; /* 5 + 38 * 5 + 5 + 5 + 1 = 206 */
    unsigned int loopey, h;
    int writer;
    int error_number, warn_number;

    error_number = postnet_enc(symbol, source, height_pattern, length);
    if (error_number >= ZINT_ERROR) {
        return error_number;
    }

    writer = 0;
    h = (int) strlen(height_pattern);
    for (loopey = 0; loopey < h; loopey++) {
        if (height_pattern[loopey] == 'L') {
            set_module(symbol, 0, writer);
        }
        set_module(symbol, 1, writer);
        writer += 2;
    }
    warn_number = usps_set_height(symbol, error_number /*no_errtxt*/);
    symbol->rows = 2;
    symbol->width = writer - 1;

    return error_number ? error_number : warn_number;
}

/* Handles the PLANET system used for item tracking in the US */
static int planet_enc(struct zint_symbol *symbol, const unsigned char source[], char *d, const int length) {
    int i, sum, check_digit;
    int error_number = 0;

    if (length > 38) {
        strcpy(symbol->errtxt, "482: Input too long (38 character maximum)");
        return ZINT_ERROR_TOO_LONG;
    }
    if (length != 11 && length != 13) {
        strcpy(symbol->errtxt, "478: Input length is not standard (11 or 13 characters)");
        error_number = ZINT_WARN_NONCOMPLIANT;
    }
    if (!is_sane(NEON_F, source, length)) {
        strcpy(symbol->errtxt, "483: Invalid character in data (digits only)");
        return ZINT_ERROR_INVALID_DATA;
    }
    sum = 0;

    /* start character */
    *d++ = 'L';

    for (i = 0; i < length; i++, d += 5) {
        const int val = source[i] - '0';
        memcpy(d, PLTable[val], 5);
        sum += val;
    }

    check_digit = (10 - (sum % 10)) % 10;
    memcpy(d, PLTable[check_digit], 5);
    d += 5;

    if (symbol->debug & ZINT_DEBUG_PRINT) printf("Check digit: %d\n", check_digit);

    /* stop character */
    strcpy(d, "L");

    return error_number;
}

/* Puts PLANET barcodes into the pattern matrix */
INTERNAL int planet(struct zint_symbol *symbol, unsigned char source[], int length) {
    char height_pattern[256]; /* 5 + 38 * 5 + 5 + 5 + 1 = 206 */
    unsigned int loopey, h;
    int writer;
    int error_number, warn_number;

    error_number = planet_enc(symbol, source, height_pattern, length);
    if (error_number >= ZINT_ERROR) {
        return error_number;
    }

    writer = 0;
    h = (int) strlen(height_pattern);
    for (loopey = 0; loopey < h; loopey++) {
        if (height_pattern[loopey] == 'L') {
            set_module(symbol, 0, writer);
        }
        set_module(symbol, 1, writer);
        writer += 2;
    }
    warn_number = usps_set_height(symbol, error_number /*no_errtxt*/);
    symbol->rows = 2;
    symbol->width = writer - 1;

    return error_number ? error_number : warn_number;
}

/* Korean Postal Authority */
INTERNAL int koreapost(struct zint_symbol *symbol, unsigned char source[], int length) {
    int total, loop, check, zeroes, error_number = 0;
    char localstr[8], dest[80];
    char *d = dest;
    int posns[6];

    if (length > 6) {
        strcpy(symbol->errtxt, "484: Input too long (6 character maximum)");
        return ZINT_ERROR_TOO_LONG;
    }
    if (!is_sane(NEON_F, source, length)) {
        strcpy(symbol->errtxt, "485: Invalid character in data (digits only)");
        return ZINT_ERROR_INVALID_DATA;
    }
    zeroes = 6 - length;
    memset(localstr, '0', zeroes);
    ustrcpy(localstr + zeroes, source);

    total = 0;
    for (loop = 0; loop < 6; loop++) {
        posns[loop] = ctoi(localstr[loop]);
        total += posns[loop];
    }
    check = 10 - (total % 10);
    if (check == 10) {
        check = 0;
    }
    localstr[6] = itoc(check);
    localstr[7] = '\0';

    for (loop = 5; loop >= 0; loop--) {
        const char *const entry = KoreaTable[posns[loop]];
        memcpy(d, entry, 10);
        d += entry[8] ? 10 : 8;
    }
    memcpy(d, KoreaTable[check], 10);
    d += KoreaTable[check][8] ? 10 : 8;

    expand(symbol, dest, d - dest);

    ustrcpy(symbol->text, localstr);

    /* TODO: Find documentation on BARCODE_KOREAPOST dimensions/height */

    return error_number;
}

/* The simplest barcode symbology ever! Supported by MS Word, so here it is!
    glyphs from http://en.wikipedia.org/wiki/Facing_Identification_Mark */
INTERNAL int fim(struct zint_symbol *symbol, unsigned char source[], int length) {
    int error_number = 0;

    if (length > 1) {
        strcpy(symbol->errtxt, "486: Input too long (1 character maximum)");
        return ZINT_ERROR_TOO_LONG;
    }

    switch ((char) source[0]) {
        case 'a':
        case 'A':
            expand(symbol, "111515111", 9);
            break;
        case 'b':
        case 'B':
            expand(symbol, "13111311131", 11);
            break;
        case 'c':
        case 'C':
            expand(symbol, "11131313111", 11);
            break;
        case 'd':
        case 'D':
            expand(symbol, "1111131311111", 13);
            break;
        case 'e':
        case 'E':
            expand(symbol, "1317131", 7);
            break;
        default:
            strcpy(symbol->errtxt, "487: Invalid character in data (\"A\", \"B\", \"C\", \"D\" or \"E\" only)");
            return ZINT_ERROR_INVALID_DATA;
            break;
    }

    if (symbol->output_options & COMPLIANT_HEIGHT) {
        /* USPS Domestic Mail Manual (USPS DMM 300) Jan 8, 2006 (updated 2011) 708.9.3
           X 0.03125" (1/32) +- 0.008" so X max 0.03925", height 0.625" (5/8) +- 0.125" (1/8) */
        error_number = set_height(symbol, stripf(0.5f / 0.03925f), 20.0f /*0.625 / 0.03125*/,
                        stripf(0.75f / 0.02415f), 0 /*no_errtxt*/);
    } else {
        (void) set_height(symbol, 0.0f, 50.0f, 0.0f, 1 /*no_errtxt*/);
    }

    return error_number;
}

/* Set height for DAFT-type codes, maintaining ratio. Expects row_height[0] & row_height[1] to be set */
/* Used by auspost.c also */
INTERNAL int daft_set_height(struct zint_symbol *symbol, const float min_height, const float max_height) {
    int error_number = 0;
    float t_ratio; /* Tracker ratio */

    if (symbol->height) {
        t_ratio = stripf(symbol->row_height[1] / stripf(symbol->row_height[0] * 2 + symbol->row_height[1]));
        symbol->row_height[1] = stripf(symbol->height * t_ratio);
        if (symbol->row_height[1] < 0.5f) { /* Absolute minimum */
            symbol->row_height[1] = 0.5f;
            symbol->row_height[0] = stripf(0.25f / t_ratio - 0.25f);
        } else {
            symbol->row_height[0] = stripf(stripf(symbol->height - symbol->row_height[1]) / 2.0f);
        }
        if (symbol->row_height[0] < 0.5f) {
            symbol->row_height[0] = 0.5f;
            symbol->row_height[1] = stripf(t_ratio / (1.0f - t_ratio));
        }
    }
    symbol->row_height[2] = symbol->row_height[0];
    symbol->height = stripf(stripf(symbol->row_height[0] + symbol->row_height[1]) + symbol->row_height[2]);

    if (symbol->output_options & COMPLIANT_HEIGHT) {
        if ((min_height && symbol->height < min_height) || (max_height && symbol->height > max_height)) {
            error_number = ZINT_WARN_NONCOMPLIANT;
            strcpy(symbol->errtxt, "499: Height not compliant with standards");
        }
    }

    return error_number;
}

/* Handles the 4 State barcodes used in the UK by Royal Mail */
static void rm4scc_enc(const struct zint_symbol *symbol, const int *posns, char *d, const int length) {
    int i;
    int top, bottom, row, column, check_digit;

    top = 0;
    bottom = 0;

    /* start character */
    *d++ = '1';

    for (i = 0; i < length; i++, d += 4) {
        const int p = posns[i];
        memcpy(d, RoyalTable[p], 4);
        top += RoyalValues[p][0];
        bottom += RoyalValues[p][1];
    }

    /* Calculate the check digit */
    row = (top % 6) - 1;
    column = (bottom % 6) - 1;
    if (row == -1) {
        row = 5;
    }
    if (column == -1) {
        column = 5;
    }
    check_digit = (6 * row) + column;
    memcpy(d, RoyalTable[check_digit], 4);
    d += 4;

    if (symbol->debug & ZINT_DEBUG_PRINT) printf("Check digit: %d\n", check_digit);

    /* stop character */
    strcpy(d, "0");
}

/* Puts RM4SCC into the data matrix */
INTERNAL int rm4scc(struct zint_symbol *symbol, unsigned char source[], int length) {
    char height_pattern[210];
    int posns[50];
    int loopey, h;
    int writer;
    int error_number = 0;

    if (length > 50) {
        strcpy(symbol->errtxt, "488: Input too long (50 character maximum)");
        return ZINT_ERROR_TOO_LONG;
    }
    to_upper(source, length);
    if (!is_sane_lookup(KRSET, 36, source, length, posns)) {
        strcpy(symbol->errtxt, "489: Invalid character in data (alphanumerics only)");
        return ZINT_ERROR_INVALID_DATA;
    }
    rm4scc_enc(symbol, posns, height_pattern, length);

    writer = 0;
    h = (int) strlen(height_pattern);
    for (loopey = 0; loopey < h; loopey++) {
        if ((height_pattern[loopey] == '1') || (height_pattern[loopey] == '0')) {
            set_module(symbol, 0, writer);
        }
        set_module(symbol, 1, writer);
        if ((height_pattern[loopey] == '2') || (height_pattern[loopey] == '0')) {
            set_module(symbol, 2, writer);
        }
        writer += 2;
    }

    if (symbol->output_options & COMPLIANT_HEIGHT) {
        /* Royal Mail Know How User's Manual Appendix C: using CBC
           (https://web.archive.org/web/20120120060743/
            http://www.royalmail.com/sites/default/files/docs/pdf/Know How 2006 PIP vs 1.6a Accepted Changes.pdf)
           Bar pitch and min/maxes same as Mailmark, so using recommendations from
           Royal Mail Mailmark Barcode Definition Document (15 Sept 2015) Section 3.5.1
         */
        symbol->row_height[0] = stripf((1.9f * 42.3f) / 25.4f); /* ~3.16 */
        symbol->row_height[1] = stripf((1.3f * 42.3f) / 25.4f); /* ~2.16 */
        /* Note using max X for minimum and min X for maximum */
        error_number = daft_set_height(symbol, stripf((4.22f * 39) / 25.4f), stripf((5.84f * 47) / 25.4f));
    } else {
        symbol->row_height[0] = 3.0f;
        symbol->row_height[1] = 2.0f;
        (void) daft_set_height(symbol, 0.0f, 0.0f);
    }
    symbol->rows = 3;
    symbol->width = writer - 1;

    return error_number;
}

/* Handles Dutch Post TNT KIX symbols
   The same as RM4SCC but without check digit or stop/start chars
   Specification at http://www.tntpost.nl/zakelijk/klantenservice/downloads/kIX_code/download.aspx */
INTERNAL int kix(struct zint_symbol *symbol, unsigned char source[], int length) {
    char height_pattern[75];
    char *d = height_pattern;
    int posns[18];
    int loopey;
    int writer, i, h;
    int error_number = 0;

    if (length > 18) {
        strcpy(symbol->errtxt, "490: Input too long (18 character maximum)");
        return ZINT_ERROR_TOO_LONG;
    }
    to_upper(source, length);
    if (!is_sane_lookup(KRSET, 36, source, length, posns)) {
        strcpy(symbol->errtxt, "491: Invalid character in data (alphanumerics only)");
        return ZINT_ERROR_INVALID_DATA;
    }

    /* Encode data */
    for (i = 0; i < length; i++, d += 4) {
        memcpy(d, RoyalTable[posns[i]], 4);
    }

    writer = 0;
    h = d - height_pattern;
    for (loopey = 0; loopey < h; loopey++) {
        if ((height_pattern[loopey] == '1') || (height_pattern[loopey] == '0')) {
            set_module(symbol, 0, writer);
        }
        set_module(symbol, 1, writer);
        if ((height_pattern[loopey] == '2') || (height_pattern[loopey] == '0')) {
            set_module(symbol, 2, writer);
        }
        writer += 2;
    }

    if (symbol->output_options & COMPLIANT_HEIGHT) {
        /* Dimensions same as RM4SCC */
        symbol->row_height[0] = stripf((1.9f * 42.3f) / 25.4f); /* ~3.16 */
        symbol->row_height[1] = stripf((1.3f * 42.3f) / 25.4f); /* ~2.16 */
        /* Note using max X for minimum and min X for maximum */
        error_number = daft_set_height(symbol, stripf((4.22f * 39) / 25.4f), stripf((5.84f * 47) / 25.4f));
    } else {
        symbol->row_height[0] = 3.0f;
        symbol->row_height[1] = 2.0f;
        (void) daft_set_height(symbol, 0.0f, 0.0f);
    }
    symbol->rows = 3;
    symbol->width = writer - 1;

    return error_number;
}

/* Handles DAFT Code symbols */
INTERNAL int daft(struct zint_symbol *symbol, unsigned char source[], int length) {
    int posns[576];
    int loopey;
    int writer;

    if (length > 576) { /* 576 * 2 = 1152 */
        strcpy(symbol->errtxt, "492: Input too long (576 character maximum)");
        return ZINT_ERROR_TOO_LONG;
    }
    to_upper(source, length);

    if (!is_sane_lookup(DAFTSET, 4, source, length, posns)) {
        strcpy(symbol->errtxt, "493: Invalid character in data (\"D\", \"A\", \"F\" and \"T\" only)");
        return ZINT_ERROR_INVALID_DATA;
    }

    writer = 0;
    for (loopey = 0; loopey < length; loopey++) {
        if ((posns[loopey] == 1) || (posns[loopey] == 0)) {
            set_module(symbol, 0, writer);
        }
        set_module(symbol, 1, writer);
        if ((posns[loopey] == 2) || (posns[loopey] == 0)) {
            set_module(symbol, 2, writer);
        }
        writer += 2;
    }

    /* Allow ratio of tracker to be specified in thousandths */
    if (symbol->option_2 >= 50 && symbol->option_2 <= 900) {
        const float t_ratio = symbol->option_2 / 1000.0f;
        if (symbol->height < 0.5f) {
            symbol->height = 8.0f;
        }
        symbol->row_height[1] = stripf(symbol->height * t_ratio);
        symbol->row_height[0] = stripf((symbol->height - symbol->row_height[1]) / 2.0f);
    } else {
        symbol->row_height[0] = 3.0f;
        symbol->row_height[1] = 2.0f;
    }

    /* DAFT generic barcode so no dimensions/height specification */
    (void) daft_set_height(symbol, 0.0f, 0.0f);
    symbol->rows = 3;
    symbol->width = writer - 1;

    return 0;
}

/* Flattermarken - Not really a barcode symbology! */
INTERNAL int flat(struct zint_symbol *symbol, unsigned char source[], int length) {
    int loop, error_number = 0;
    char dest[512]; /* 128 * 4 = 512 */
    char *d = dest;

    if (length > 128) { /* 128 * 9 = 1152 */
        strcpy(symbol->errtxt, "494: Input too long (128 character maximum)");
        return ZINT_ERROR_TOO_LONG;
    }
    if (!is_sane(NEON_F, source, length)) {
        strcpy(symbol->errtxt, "495: Invalid character in data (digits only)");
        return ZINT_ERROR_INVALID_DATA;
    }

    for (loop = 0; loop < length; loop++) {
        const char *const entry = FlatTable[source[loop] - '0'];
        memcpy(d, entry, 4);
        d += entry[2] ? 4 : 2;
    }

    expand(symbol, dest, d - dest);

    /* TODO: Find documentation on BARCODE_FLAT dimensions/height */

    return error_number;
}

/* Japanese Postal Code (Kasutama Barcode) */
INTERNAL int japanpost(struct zint_symbol *symbol, unsigned char source[], int length) {
    int error_number = 0, h;
    char pattern[69];
    char *d = pattern;
    int writer, loopey, inter_posn, i, sum, check;
    char check_char;
    char inter[20 + 1];

    if (length > 20) {
        strcpy(symbol->errtxt, "496: Input too long (20 character maximum)");
        return ZINT_ERROR_TOO_LONG;
    }

    to_upper(source, length);

    if (!is_sane(SHKASUTSET_F, source, length)) {
        strcpy(symbol->errtxt, "497: Invalid character in data (alphanumerics and \"-\" only)");
        return ZINT_ERROR_INVALID_DATA;
    }
    memset(inter, 'd', 20); /* Pad character CC4 */
    inter[20] = '\0';

    i = 0;
    inter_posn = 0;
    do {
        if (z_isdigit(source[i]) || (source[i] == '-')) {
            inter[inter_posn] = source[i];
            inter_posn++;
        } else {
            if (source[i] <= 'J') {
                inter[inter_posn] = 'a';
                inter[inter_posn + 1] = source[i] - 'A' + '0';
            } else if (source[i] <= 'T') {
                inter[inter_posn] = 'b';
                inter[inter_posn + 1] = source[i] - 'K' + '0';
            } else { /* (source[i] >= 'U') && (source[i] <= 'Z') */
                inter[inter_posn] = 'c';
                inter[inter_posn + 1] = source[i] - 'U' + '0';
            }
            inter_posn += 2;
        }
        i++;
    } while ((i < length) && (inter_posn < 20));

    if (i != length || inter[20] != '\0') {
        strcpy(symbol->errtxt, "477: Input too long (20 symbol character maximum)");
        return ZINT_ERROR_TOO_LONG;
    }

    memcpy(d, "13", 2); /* Start */
    d += 2;

    sum = 0;
    for (i = 0; i < 20; i++, d += 3) {
        memcpy(d, JapanTable[posn(KASUTSET, inter[i])], 3);
        sum += posn(CHKASUTSET, inter[i]);
    }

    /* Calculate check digit */
    check = 19 - (sum % 19);
    if (check == 19) {
        check = 0;
    }
    if (check <= 9) {
        check_char = check + '0';
    } else if (check == 10) {
        check_char = '-';
    } else {
        check_char = (check - 11) + 'a';
    }
    memcpy(d, JapanTable[posn(KASUTSET, check_char)], 3);
    d += 3;

    if (symbol->debug & ZINT_DEBUG_PRINT) printf("Check: %d, char: %c\n", check, check_char);

    memcpy(d, "31", 2); /* Stop */
    d += 2;

    /* Resolve pattern to 4-state symbols */
    writer = 0;
    h = d - pattern;
    for (loopey = 0; loopey < h; loopey++) {
        if ((pattern[loopey] == '2') || (pattern[loopey] == '1')) {
            set_module(symbol, 0, writer);
        }
        set_module(symbol, 1, writer);
        if ((pattern[loopey] == '3') || (pattern[loopey] == '1')) {
            set_module(symbol, 2, writer);
        }
        writer += 2;
    }

    symbol->rows = 3;
    symbol->width = writer - 1;

    if (symbol->output_options & COMPLIANT_HEIGHT) {
        /* Japan Post Zip/Barcode Manual pp.11-12 https://www.post.japanpost.jp/zipcode/zipmanual/p11.html
           X 0.6mm (0.5mm - 0.7mm)
           Tracker height 1.2mm (1.05mm - 1.35mm) / 0.6mm = 2,
           Ascender/descender = 1.2mm (Full 3.6mm (3.4mm - 3.6mm, max preferred) less T divided by 2) / 0.6mm = 2 */
        symbol->row_height[0] = 2.0f;
        symbol->row_height[1] = 2.0f;
        error_number = daft_set_height(symbol, stripf(3.4f / 0.7f) /*~4.857*/, stripf(3.6f / 0.5f) /*7.2*/);
    } else {
        symbol->row_height[0] = 3.0f;
        symbol->row_height[1] = 2.0f;
        (void) daft_set_height(symbol, 0.0f, 0.0f);
    }

    return error_number;
}

/* vim: set ts=4 sw=4 et : */
