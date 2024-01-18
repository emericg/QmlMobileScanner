/*  emf.c - Support for Microsoft Enhanced Metafile Format */
/*
    libzint - the open source barcode library
    Copyright (C) 2016-2023 Robin Stuart <rstuart114@gmail.com>

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

/* Developed according to [MS-EMF] - v20160714, Released July 14, 2016
 * and [MS-WMF] - v20160714, Released July 14, 2016 */

#include <errno.h>
#include <stdio.h>
#include <assert.h>
#include <math.h>
#ifdef _MSC_VER
#include <io.h>
#include <fcntl.h>
#endif
#include "common.h"
#include "output.h"
#include "emf.h"

/* Multiply truncating to 3 decimal places (avoids rounding differences on various platforms) */
#define mul3dpf(m, arg) stripf(roundf((m) * (arg) * 1000.0f) / 1000.0f)

static int emf_count_rectangles(const struct zint_symbol *symbol) {
    int rectangles = 0;
    const struct zint_vector_rect *rect;

    rect = symbol->vector->rectangles;
    while (rect) {
        rectangles++;
        rect = rect->next;
    }

    return rectangles;
}

static int emf_count_circles(const struct zint_symbol *symbol) {
    int circles = 0;
    const struct zint_vector_circle *circ;

    circ = symbol->vector->circles;
    while (circ) {
        circles++;
        circ = circ->next;
    }

    /* Hack for MaxiCode */
    return symbol->symbology == BARCODE_MAXICODE ? circles * 2 : circles;
}

static int emf_count_hexagons(const struct zint_symbol *symbol) {
    int hexagons = 0;
    const struct zint_vector_hexagon *hex;

    hex = symbol->vector->hexagons;
    while (hex) {
        hexagons++;
        hex = hex->next;
    }

    return hexagons;
}

static int emf_count_strings(const struct zint_symbol *symbol, float *fsize, float *fsize2, int *halign_left,
            int *halign_right) {
    int strings = 0;
    const struct zint_vector_string *string;

    *fsize = *fsize2 = 0.0f;
    *halign_left = *halign_right = 0;

    string = symbol->vector->strings;
    while (string) {
        /* Allow 2 font sizes */
        if (*fsize == 0.0f) {
            *fsize = string->fsize;
        } else if (string->fsize != *fsize && *fsize2 == 0.0f) {
            *fsize2 = string->fsize;
        }
        /* Only 3 haligns possible and centre align always assumed used */
        if (string->halign) { /* Left or right align */
            if (string->halign == 1) { /* Left align */
                *halign_left = string->halign;
            } else { /* Right align */
                *halign_right = string->halign;
            }
        }
        strings++;
        string = string->next;
    }

    return strings;
}

/* Convert UTF-8 to UTF-16LE - only needs to handle characters <= U+00FF */
static void emf_utfle_copy(unsigned char *output, const unsigned char *input, const int length) {
    int i;
    int o;

    i = 0;
    o = 0;
    do {
        if (input[i] <= 0x7f) {
            /* 1 byte mode (7-bit ASCII) */
            output[o] = input[i];
            output[o + 1] = 0x00;
            o += 2;
            i++;
        } else {
            /* 2 byte mode */
            output[o] = ((input[i] & 0x1f) << 6) + (input[i + 1] & 0x3f);
            output[o + 1] = 0x00;
            o += 2;
            i += 2;
        }
    } while (i < length);
}

/* Strings length must be a multiple of 4 bytes */
static int emf_bump_up(const int input) {
    return (input + (input & 1)) << 1;
}

static int emf_utfle_length(const unsigned char *input, const int length) {
    int result = 0;
    int i;

    for (i = 0; i < length; i++) {
        result++;
        if (input[i] >= 0x80) { /* 2 byte UTF-8 counts as one UTF-16LE character */
            i++;
        }
    }

    return result;
}

INTERNAL int emf_plot(struct zint_symbol *symbol, int rotate_angle) {
    int i;
    FILE *emf_file;
    unsigned char fgred, fggrn, fgblu, bgred, bggrn, bgblu, bgalpha;
    int error_number = 0;
    int rectangle_count, this_rectangle;
    int circle_count, this_circle;
    int hexagon_count, this_hexagon;
    int string_count, this_text;
    int bytecount, recordcount;
    float previous_diameter;
    float radius, half_radius, half_sqrt3_radius;
    int colours_used = 0;
    int rectangle_bycolour[9] = {0};

    int width, height;
    int bounds_pxx, bounds_pxy; /* Pixels */
    int frame_cmmx, frame_cmmy; /* Hundredths of a mm, i.e. "centi-millimeters" */
    int device_pxx, device_pxy; /* Pixels */
    int mmx, mmy; /* Millimeters */
    int micronx, microny; /* Micrometers */
    const float dpmm = symbol->dpmm ? stripf(symbol->dpmm)
                                    : ZBarcode_XdimDp_From_Scale(symbol->symbology, symbol->scale,
                                        ZBarcode_Default_Xdim(symbol->symbology), "EMF");
    const int sideways = rotate_angle == 90 || rotate_angle == 270;

    int draw_background = 1;
    int bold;
    const int upcean = is_upcean(symbol->symbology);
    const int output_to_stdout = symbol->output_options & BARCODE_STDOUT;

    struct zint_vector_rect *rect;
    struct zint_vector_circle *circ;
    struct zint_vector_hexagon *hex;
    struct zint_vector_string *string;

    /* Allow for up to 6 strings (current max 3 for UPC/EAN) */
    unsigned char *this_string[6];
    emr_exttextoutw_t text[6];
    float text_fsizes[6];
    int text_haligns[6];

    emr_header_t emr_header;
    emr_eof_t emr_eof;
    emr_mapmode_t emr_mapmode;
    emr_setworldtransform_t emr_setworldtransform;
    emr_createbrushindirect_t emr_createbrushindirect_fg;
    emr_createbrushindirect_t emr_createbrushindirect_bg;
    emr_createbrushindirect_t emr_createbrushindirect_colour[9]; /* Used for colour symbols only */
    emr_selectobject_t emr_selectobject_fgbrush;
    emr_selectobject_t emr_selectobject_bgbrush;
    emr_selectobject_t emr_selectobject_colour[9]; /* Used for colour symbols only */
    emr_createpen_t emr_createpen;
    emr_selectobject_t emr_selectobject_pen;
    emr_rectangle_t background;
    emr_settextcolor_t emr_settextcolor;

    float fsize;
    emr_extcreatefontindirectw_t emr_extcreatefontindirectw;
    emr_selectobject_t emr_selectobject_font;
    float fsize2;
    emr_extcreatefontindirectw_t emr_extcreatefontindirectw2;
    emr_selectobject_t emr_selectobject_font2;
    emr_settextalign_t emr_settextalign_centre; /* Centre align */
    int halign_left; /* Set if left halign used */
    emr_settextalign_t emr_settextalign_left;
    int halign_right; /* Set if right halign used */
    emr_settextalign_t emr_settextalign_right;

    float current_fsize;
    int current_halign;

    emr_rectangle_t *rectangle;
    emr_ellipse_t *circle;
    emr_polygon_t *hexagon;

    const int ih_ultra_offset = symbol->symbology == BARCODE_ULTRA ? 8 : 0;

    if (symbol->vector == NULL) {
        strcpy(symbol->errtxt, "643: Vector header NULL");
        return ZINT_ERROR_INVALID_DATA;
    }

    (void) out_colour_get_rgb(symbol->fgcolour, &fgred, &fggrn, &fgblu, NULL /*alpha*/);
    (void) out_colour_get_rgb(symbol->bgcolour, &bgred, &bggrn, &bgblu, &bgalpha);
    if (bgalpha == 0) {
        draw_background = 0;
    }

    rectangle_count = emf_count_rectangles(symbol);
    circle_count = emf_count_circles(symbol);
    hexagon_count = emf_count_hexagons(symbol);
    string_count = emf_count_strings(symbol, &fsize, &fsize2, &halign_left, &halign_right);

    /* Avoid sanitize runtime error by making always non-zero */
    rectangle = (emr_rectangle_t *) z_alloca(sizeof(emr_rectangle_t) * (rectangle_count ? rectangle_count : 1));
    circle = (emr_ellipse_t *) z_alloca(sizeof(emr_ellipse_t) * (circle_count ? circle_count : 1));
    hexagon = (emr_polygon_t *) z_alloca(sizeof(emr_polygon_t) * (hexagon_count ? hexagon_count : 1));

    /* Calculate how many coloured rectangles */
    if (symbol->symbology == BARCODE_ULTRA) {

        rect = symbol->vector->rectangles;
        while (rect) {
            if (rect->colour == -1) { /* Foreground colour */
                if (rectangle_bycolour[0] == 0) {
                    colours_used++;
                    rectangle_bycolour[0] = 1;
                }
            } else {
                if (rectangle_bycolour[rect->colour] == 0) {
                    colours_used++;
                    rectangle_bycolour[rect->colour] = 1;
                }
            }
            rect = rect->next;
        }
    }

    width = (int) ceilf(symbol->vector->width);
    height = (int) ceilf(symbol->vector->height);

    bounds_pxx = width - 1; /* Following Inkscape, bounds "inclusive-inclusive", so size 1 less */
    bounds_pxy = height - 1;
    device_pxx = width; /* device */
    device_pxy = height;

    if (dpmm) {
        frame_cmmx = (int) roundf(stripf(width * 100.0f / dpmm)) - 1; /* frame also "inclusive-inclusive" */
        frame_cmmy = (int) roundf(stripf(height * 100.0f / dpmm)) - 1;
        mmx = (int) roundf(stripf(width / dpmm)); /* millimeters */
        mmy = (int) roundf(stripf(height / dpmm));
        micronx = (int) roundf(stripf(width * 1000.0f / dpmm)); /* micrometers */
        microny = (int) roundf(stripf(height * 1000.0f / dpmm));
    } else { /* Should only happen if `symbol->scale` zero. */
        frame_cmmx = (int) roundf(stripf(width * 100.0f)) - 1;
        frame_cmmy = (int) roundf(stripf(height * 100.0f)) - 1;
        mmx = (int) roundf(stripf(width));
        mmy = (int) roundf(stripf(height));
        micronx = (int) roundf(stripf(width * 1000.0f));
        microny = (int) roundf(stripf(height * 1000.0f));
    }

    /* Header */
    emr_header.type = 0x00000001; /* EMR_HEADER */
    emr_header.size = 108; /* Including extensions */
    emr_header.emf_header.bounds.left = emr_header.emf_header.bounds.top = 0;
    emr_header.emf_header.bounds.right = sideways ? bounds_pxy : bounds_pxx;
    emr_header.emf_header.bounds.bottom = sideways ? bounds_pxx : bounds_pxy;
    emr_header.emf_header.frame.left = emr_header.emf_header.frame.top = 0;
    emr_header.emf_header.frame.right = sideways ? frame_cmmy : frame_cmmx;
    emr_header.emf_header.frame.bottom = sideways ? frame_cmmx : frame_cmmy;
    emr_header.emf_header.record_signature = 0x464d4520; /* ENHMETA_SIGNATURE */
    emr_header.emf_header.version = 0x00010000;
    emr_header.emf_header.handles = (fsize2 != 0.0f ? 5 : 4) + ih_ultra_offset; /* Number of graphics objects */
    emr_header.emf_header.reserved = 0x0000;
    emr_header.emf_header.n_description = 0;
    emr_header.emf_header.off_description = 0;
    emr_header.emf_header.n_pal_entries = 0;
    emr_header.emf_header.device.cx = sideways ? device_pxy : device_pxx;
    emr_header.emf_header.device.cy = sideways ? device_pxx : device_pxy;
    emr_header.emf_header.millimeters.cx = sideways ? mmy : mmx;
    emr_header.emf_header.millimeters.cy = sideways ? mmx : mmy;
    /* HeaderExtension1 */
    emr_header.emf_header.cb_pixel_format = 0x0000; /* None set */
    emr_header.emf_header.off_pixel_format = 0x0000; /* None set */
    emr_header.emf_header.b_open_gl = 0x0000; /* OpenGL not present */
    /* HeaderExtension2 */
    emr_header.emf_header.micrometers.cx = sideways ? microny : micronx;
    emr_header.emf_header.micrometers.cy = sideways ? micronx : microny;
    bytecount = 108;
    recordcount = 1;

    emr_mapmode.type = 0x00000011; /* EMR_SETMAPMODE */
    emr_mapmode.size = 12;
    emr_mapmode.mapmode = 0x01; /* MM_TEXT */
    bytecount += 12;
    recordcount++;

    if (rotate_angle) {
        emr_setworldtransform.type = 0x00000023; /* EMR_SETWORLDTRANSFORM */
        emr_setworldtransform.size = 32;
        emr_setworldtransform.m11 = rotate_angle == 90 ? 0.0f : rotate_angle == 180 ? -1.0f : 0.0f;
        emr_setworldtransform.m12 = rotate_angle == 90 ? 1.0f : rotate_angle == 180 ? 0.0f : -1.0f;
        emr_setworldtransform.m21 = rotate_angle == 90 ? -1.0f : rotate_angle == 180 ? 0.0f : 1.0f;
        emr_setworldtransform.m22 = rotate_angle == 90 ? 0.0f : rotate_angle == 180 ? -1.0f : 0.0f;
        emr_setworldtransform.dx = rotate_angle == 90 ? height : rotate_angle == 180 ? width : 0.0f;
        emr_setworldtransform.dy = rotate_angle == 90 ? 0.0f : rotate_angle == 180 ? height : width;
        bytecount += 32;
        recordcount++;
    }

    /* Create Brushes */
    emr_createbrushindirect_bg.type = 0x00000027; /* EMR_CREATEBRUSHINDIRECT */
    emr_createbrushindirect_bg.size = 24;
    emr_createbrushindirect_bg.ih_brush = 0;
    emr_createbrushindirect_bg.log_brush.brush_style = 0x0000; /* BS_SOLID */
    emr_createbrushindirect_bg.log_brush.color.red = bgred;
    emr_createbrushindirect_bg.log_brush.color.green = bggrn;
    emr_createbrushindirect_bg.log_brush.color.blue = bgblu;
    emr_createbrushindirect_bg.log_brush.color.reserved = 0;
    emr_createbrushindirect_bg.log_brush.brush_hatch = 0x0006; /* HS_SOLIDCLR */
    bytecount += 24;
    recordcount++;

    if (symbol->symbology == BARCODE_ULTRA) {
        static const char ultra_chars[] = "0CBMRYGKW";
        for (i = 0; i < 9; i++) {
            emr_createbrushindirect_colour[i].type = 0x00000027; /* EMR_CREATEBRUSHINDIRECT */
            emr_createbrushindirect_colour[i].size = 24;
            emr_createbrushindirect_colour[i].ih_brush = 1 + i;
            emr_createbrushindirect_colour[i].log_brush.brush_style = 0x0000; /* BS_SOLID */
            if (i == 0) {
                emr_createbrushindirect_colour[i].log_brush.color.red = fgred;
                emr_createbrushindirect_colour[i].log_brush.color.green = fggrn;
                emr_createbrushindirect_colour[i].log_brush.color.blue = fgblu;
            } else {
                out_colour_char_to_rgb(ultra_chars[i],
                        &emr_createbrushindirect_colour[i].log_brush.color.red,
                        &emr_createbrushindirect_colour[i].log_brush.color.green,
                        &emr_createbrushindirect_colour[i].log_brush.color.blue);
            }
            emr_createbrushindirect_colour[i].log_brush.color.reserved = 0;
            emr_createbrushindirect_colour[i].log_brush.brush_hatch = 0x0006; /* HS_SOLIDCLR */
        }
        bytecount += colours_used * 24;
        recordcount += colours_used;
    } else {
        emr_createbrushindirect_fg.type = 0x00000027; /* EMR_CREATEBRUSHINDIRECT */
        emr_createbrushindirect_fg.size = 24;
        emr_createbrushindirect_fg.ih_brush = 1;
        emr_createbrushindirect_fg.log_brush.brush_style = 0x0000; /* BS_SOLID */
        emr_createbrushindirect_fg.log_brush.color.red = fgred;
        emr_createbrushindirect_fg.log_brush.color.green = fggrn;
        emr_createbrushindirect_fg.log_brush.color.blue = fgblu;
        emr_createbrushindirect_fg.log_brush.color.reserved = 0;
        emr_createbrushindirect_fg.log_brush.brush_hatch = 0x0006; /* HS_SOLIDCLR */
        bytecount += 24;
        recordcount++;
    }

    emr_selectobject_bgbrush.type = 0x00000025; /* EMR_SELECTOBJECT */
    emr_selectobject_bgbrush.size = 12;
    emr_selectobject_bgbrush.ih_object = emr_createbrushindirect_bg.ih_brush;
    bytecount += 12;
    recordcount++;

    if (symbol->symbology == BARCODE_ULTRA) {
        for (i = 0; i < 9; i++) {
            emr_selectobject_colour[i].type = 0x00000025; /* EMR_SELECTOBJECT */
            emr_selectobject_colour[i].size = 12;
            emr_selectobject_colour[i].ih_object = emr_createbrushindirect_colour[i].ih_brush;
        }
        bytecount += colours_used * 12;
        recordcount += colours_used;
    } else {
        emr_selectobject_fgbrush.type = 0x00000025; /* EMR_SELECTOBJECT */
        emr_selectobject_fgbrush.size = 12;
        emr_selectobject_fgbrush.ih_object = emr_createbrushindirect_fg.ih_brush;
        bytecount += 12;
        recordcount++;
    }

    /* Create Pens */
    emr_createpen.type = 0x00000026; /* EMR_CREATEPEN */
    emr_createpen.size = 28;
    emr_createpen.ih_pen = 2 + ih_ultra_offset;
    emr_createpen.log_pen.pen_style = 0x00000005; /* PS_NULL */
    emr_createpen.log_pen.width.x = 1;
    emr_createpen.log_pen.width.y = 0; /* ignored */
    emr_createpen.log_pen.color_ref.red = 0;
    emr_createpen.log_pen.color_ref.green = 0;
    emr_createpen.log_pen.color_ref.blue = 0;
    emr_createpen.log_pen.color_ref.reserved = 0;
    bytecount += 28;
    recordcount++;

    emr_selectobject_pen.type = 0x00000025; /* EMR_SELECTOBJECT */
    emr_selectobject_pen.size = 12;
    emr_selectobject_pen.ih_object = emr_createpen.ih_pen;
    bytecount += 12;
    recordcount++;

    if (draw_background) {
        /* Make background from a rectangle */
        background.type = 0x0000002b; /* EMR_RECTANGLE */
        background.size = 24;
        background.box.top = 0;
        background.box.left = 0;
        background.box.right = width;
        background.box.bottom = height;
        bytecount += 24;
        recordcount++;
    }

    /* Rectangles */
    rect = symbol->vector->rectangles;
    this_rectangle = 0;
    while (rect) {
        rectangle[this_rectangle].type = 0x0000002b; /* EMR_RECTANGLE */
        rectangle[this_rectangle].size = 24;
        rectangle[this_rectangle].box.top = (int32_t) rect->y;
        rectangle[this_rectangle].box.bottom = (int32_t) stripf(rect->y + rect->height);
        rectangle[this_rectangle].box.left = (int32_t) rect->x;
        rectangle[this_rectangle].box.right = (int32_t) stripf(rect->x + rect->width);
        this_rectangle++;
        bytecount += 24;
        recordcount++;
        rect = rect->next;
    }

    /* Circles */
    previous_diameter = radius = 0.0f;
    circ = symbol->vector->circles;
    this_circle = 0;
    while (circ) {
        /* Note using circle width the proper way, with a non-null pen of specified width and a null brush for fill,
           causes various different rendering issues for LibreOffice Draw and Inkscape, so using following hack */
        if (previous_diameter != circ->diameter + circ->width) { /* Drawing MaxiCode bullseye using overlayed discs */
            previous_diameter = circ->diameter + circ->width;
            radius = mul3dpf(0.5f, previous_diameter);
        }
        circle[this_circle].type = 0x0000002a; /* EMR_ELLIPSE */
        circle[this_circle].size = 24;
        circle[this_circle].box.top = (int32_t) stripf(circ->y - radius);
        circle[this_circle].box.bottom = (int32_t) stripf(circ->y + radius);
        circle[this_circle].box.left = (int32_t) stripf(circ->x - radius);
        circle[this_circle].box.right = (int32_t) stripf(circ->x + radius);
        this_circle++;
        bytecount += 24;
        recordcount++;

        if (symbol->symbology == BARCODE_MAXICODE) { /* Drawing MaxiCode bullseye using overlayed discs */
            float inner_radius = radius - circ->width;
            circle[this_circle].type = 0x0000002a; /* EMR_ELLIPSE */
            circle[this_circle].size = 24;
            circle[this_circle].box.top = (int32_t) stripf(circ->y - inner_radius);
            circle[this_circle].box.bottom = (int32_t) stripf(circ->y + inner_radius);
            circle[this_circle].box.left = (int32_t) stripf(circ->x - inner_radius);
            circle[this_circle].box.right = (int32_t) stripf(circ->x + inner_radius);
            this_circle++;
            bytecount += 24;
            recordcount++;
        }

        circ = circ->next;
    }

    /* Hexagons */
    previous_diameter = radius = half_radius = half_sqrt3_radius = 0.0f;
    hex = symbol->vector->hexagons;
    this_hexagon = 0;
    while (hex) {
        hexagon[this_hexagon].type = 0x00000003; /* EMR_POLYGON */
        hexagon[this_hexagon].size = 76;
        hexagon[this_hexagon].count = 6;

        if (previous_diameter != hex->diameter) {
            previous_diameter = hex->diameter;
            radius = mul3dpf(0.5f, previous_diameter);
            half_radius = mul3dpf(0.25f, previous_diameter);
            half_sqrt3_radius = mul3dpf(0.43301270189221932338f, previous_diameter);
        }

        /* Note rotation done via world transform */
        hexagon[this_hexagon].a_points_a.x = (int32_t) hex->x;
        hexagon[this_hexagon].a_points_a.y = (int32_t) stripf(hex->y + radius);
        hexagon[this_hexagon].a_points_b.x = (int32_t) stripf(hex->x + half_sqrt3_radius);
        hexagon[this_hexagon].a_points_b.y = (int32_t) stripf(hex->y + half_radius);
        hexagon[this_hexagon].a_points_c.x = (int32_t) stripf(hex->x + half_sqrt3_radius);
        hexagon[this_hexagon].a_points_c.y = (int32_t) stripf(hex->y - half_radius);
        hexagon[this_hexagon].a_points_d.x = (int32_t) hex->x;
        hexagon[this_hexagon].a_points_d.y = (int32_t) stripf(hex->y - radius);
        hexagon[this_hexagon].a_points_e.x = (int32_t) stripf(hex->x - half_sqrt3_radius);
        hexagon[this_hexagon].a_points_e.y = (int32_t) stripf(hex->y - half_radius);
        hexagon[this_hexagon].a_points_f.x = (int32_t) stripf(hex->x - half_sqrt3_radius);
        hexagon[this_hexagon].a_points_f.y = (int32_t) stripf(hex->y + half_radius);

        hexagon[this_hexagon].bounds.top = hexagon[this_hexagon].a_points_d.y;
        hexagon[this_hexagon].bounds.bottom = hexagon[this_hexagon].a_points_a.y;
        hexagon[this_hexagon].bounds.left = hexagon[this_hexagon].a_points_e.x;
        hexagon[this_hexagon].bounds.right = hexagon[this_hexagon].a_points_c.x;
        this_hexagon++;
        bytecount += 76;
        recordcount++;
        hex = hex->next;
    }

    /* Create font records, alignment records and text color */
    if (symbol->vector->strings) {
        bold = (symbol->output_options & BOLD_TEXT) && !is_upcean(symbol->symbology);
        memset(&emr_extcreatefontindirectw, 0, sizeof(emr_extcreatefontindirectw));
        emr_extcreatefontindirectw.type = 0x00000052; /* EMR_EXTCREATEFONTINDIRECTW */
        emr_extcreatefontindirectw.size = 104;
        emr_extcreatefontindirectw.ih_fonts = 3 + ih_ultra_offset;
        emr_extcreatefontindirectw.elw.height = (int32_t) fsize;
        emr_extcreatefontindirectw.elw.width = 0; /* automatic */
        emr_extcreatefontindirectw.elw.weight = bold ? 700 : 400;
        emr_extcreatefontindirectw.elw.char_set = 0x00; /* ANSI_CHARSET */
        emr_extcreatefontindirectw.elw.out_precision = 0x00; /* OUT_DEFAULT_PRECIS */
        emr_extcreatefontindirectw.elw.clip_precision = 0x00; /* CLIP_DEFAULT_PRECIS */
        emr_extcreatefontindirectw.elw.pitch_and_family = 0x02 | (0x02 << 6); /* FF_SWISS | VARIABLE_PITCH */
        emf_utfle_copy(emr_extcreatefontindirectw.elw.facename, (const unsigned char *) "sans-serif", 10);
        bytecount += 104;
        recordcount++;

        emr_selectobject_font.type = 0x00000025; /* EMR_SELECTOBJECT */
        emr_selectobject_font.size = 12;
        emr_selectobject_font.ih_object = emr_extcreatefontindirectw.ih_fonts;
        bytecount += 12;
        recordcount++;

        if (fsize2) {
            memcpy(&emr_extcreatefontindirectw2, &emr_extcreatefontindirectw, sizeof(emr_extcreatefontindirectw));
            emr_extcreatefontindirectw2.ih_fonts = 4 + ih_ultra_offset;
            emr_extcreatefontindirectw2.elw.height = (int32_t) fsize2;
            bytecount += 104;
            recordcount++;

            emr_selectobject_font2.type = 0x00000025; /* EMR_SELECTOBJECT */
            emr_selectobject_font2.size = 12;
            emr_selectobject_font2.ih_object = emr_extcreatefontindirectw2.ih_fonts;
            bytecount += 12;
            recordcount++;
        }

        /* Note select aligns counted below in strings loop */

        emr_settextalign_centre.type = 0x00000016; /* EMR_SETTEXTALIGN */
        emr_settextalign_centre.size = 12;
        emr_settextalign_centre.text_alignment_mode = 0x0006 | 0x0018; /* TA_CENTER | TA_BASELINE */
        if (halign_left) {
            emr_settextalign_left.type = 0x00000016; /* EMR_SETTEXTALIGN */
            emr_settextalign_left.size = 12;
            emr_settextalign_left.text_alignment_mode = 0x0000 | 0x0018; /* TA_LEFT | TA_BASELINE */
        }
        if (halign_right) {
            emr_settextalign_right.type = 0x00000016; /* EMR_SETTEXTALIGN */
            emr_settextalign_right.size = 12;
            emr_settextalign_right.text_alignment_mode = 0x0002 | 0x0018; /* TA_RIGHT | TA_BASELINE */
        }

        emr_settextcolor.type = 0x0000018; /* EMR_SETTEXTCOLOR */
        emr_settextcolor.size = 12;
        emr_settextcolor.color.red = fgred;
        emr_settextcolor.color.green = fggrn;
        emr_settextcolor.color.blue = fgblu;
        emr_settextcolor.color.reserved = 0;
        bytecount += 12;
        recordcount++;
    }

    /* Text */
    this_text = 0;
    /* Loop over font sizes so that they're grouped together, so only have to select font twice at most */
    for (i = 0, current_fsize = fsize; i < 2 && current_fsize; i++, current_fsize = fsize2) {
        string = symbol->vector->strings;
        current_halign = -1;
        while (string) {
            int utfle_len;
            int bumped_len;
            if (string->fsize != current_fsize) {
                string = string->next;
                continue;
            }
            text_fsizes[this_text] = string->fsize;
            text_haligns[this_text] = string->halign;
            if (text_haligns[this_text] != current_halign) {
                current_halign = text_haligns[this_text];
                bytecount += 12;
                recordcount++;
            }
            assert(string->length > 0);
            utfle_len = emf_utfle_length(string->text, string->length);
            bumped_len = emf_bump_up(utfle_len);
            if (!(this_string[this_text] = (unsigned char *) malloc(bumped_len))) {
                for (i = 0; i < this_text; i++) {
                    free(this_string[i]);
                }
                strcpy(symbol->errtxt, "641: Insufficient memory for EMF string buffer");
                return ZINT_ERROR_MEMORY;
            }
            memset(this_string[this_text], 0, bumped_len);
            text[this_text].type = 0x00000054; /* EMR_EXTTEXTOUTW */
            text[this_text].size = 76 + bumped_len;
            text[this_text].bounds.top = 0; /* ignored */
            text[this_text].bounds.left = 0; /* ignored */
            text[this_text].bounds.right = 0xffffffff; /* ignored */
            text[this_text].bounds.bottom = 0xffffffff; /* ignored */
            text[this_text].i_graphics_mode = 0x00000002; /* GM_ADVANCED */
            text[this_text].ex_scale = 1.0f;
            text[this_text].ey_scale = 1.0f;
            /* Unhack the guard whitespace `gws_left_fudge`/`gws_right_fudge` hack */
            if (upcean && string->halign == 1 && string->text[0] == '<') {
                const float gws_left_fudge = symbol->scale < 0.1f ? 0.1f : symbol->scale; /* 0.5 * 2 * scale */
                text[this_text].w_emr_text.reference.x = (int32_t) (string->x + gws_left_fudge);
            } else if (upcean && string->halign == 2 && string->text[0] == '>') {
                const float gws_right_fudge = symbol->scale < 0.1f ? 0.1f : symbol->scale; /* 0.5 * 2 * scale */
                text[this_text].w_emr_text.reference.x = (int32_t) (string->x - gws_right_fudge);
            } else {
                text[this_text].w_emr_text.reference.x = (int32_t) string->x;
            }
            text[this_text].w_emr_text.reference.y = (int32_t) string->y;
            text[this_text].w_emr_text.chars = utfle_len;
            text[this_text].w_emr_text.off_string = 76;
            text[this_text].w_emr_text.options = 0;
            text[this_text].w_emr_text.rectangle.top = 0;
            text[this_text].w_emr_text.rectangle.left = 0;
            text[this_text].w_emr_text.rectangle.right = 0xffffffff;
            text[this_text].w_emr_text.rectangle.bottom = 0xffffffff;
            text[this_text].w_emr_text.off_dx = 0;
            emf_utfle_copy(this_string[this_text], string->text, string->length);
            bytecount += 76 + bumped_len;
            recordcount++;

            this_text++;
            string = string->next;
        }
    }
    /* Suppress clang-tidy clang-analyzer-core.UndefinedBinaryOperatorResult warning */
    assert(this_text == string_count);

    /* Create EOF record */
    emr_eof.type = 0x0000000e; /* EMR_EOF */
    emr_eof.size = 20; /* Assuming no palette entries */
    emr_eof.n_pal_entries = 0;
    emr_eof.off_pal_entries = 0;
    emr_eof.size_last = emr_eof.size;
    bytecount += 20;
    recordcount++;

    if (symbol->symbology == BARCODE_MAXICODE) {
        bytecount += 5 * sizeof(emr_selectobject_t);
        recordcount += 5;
    }

    /* Put final counts in header */
    emr_header.emf_header.bytes = bytecount;
    emr_header.emf_header.records = recordcount;

    /* Send EMF data to file */
    if (output_to_stdout) {
#ifdef _MSC_VER
        if (-1 == _setmode(_fileno(stdout), _O_BINARY)) {
            sprintf(symbol->errtxt, "642: Could not set stdout to binary (%d: %.30s)", errno, strerror(errno));
            return ZINT_ERROR_FILE_ACCESS;
        }
#endif
        emf_file = stdout;
    } else {
        if (!(emf_file = out_fopen(symbol->outfile, "wb"))) {
            sprintf(symbol->errtxt, "640: Could not open output file (%d: %.30s)", errno, strerror(errno));
            return ZINT_ERROR_FILE_ACCESS;
        }
    }

    fwrite(&emr_header, sizeof(emr_header_t), 1, emf_file);

    fwrite(&emr_mapmode, sizeof(emr_mapmode_t), 1, emf_file);

    if (rotate_angle) {
        fwrite(&emr_setworldtransform, sizeof(emr_setworldtransform_t), 1, emf_file);
    }

    fwrite(&emr_createbrushindirect_bg, sizeof(emr_createbrushindirect_t), 1, emf_file);

    if (symbol->symbology == BARCODE_ULTRA) {
        for (i = 0; i < 9; i++) {
            if (rectangle_bycolour[i]) {
                fwrite(&emr_createbrushindirect_colour[i], sizeof(emr_createbrushindirect_t), 1, emf_file);
            }
        }
    } else {
        fwrite(&emr_createbrushindirect_fg, sizeof(emr_createbrushindirect_t), 1, emf_file);
    }

    fwrite(&emr_createpen, sizeof(emr_createpen_t), 1, emf_file);

    if (symbol->vector->strings) {
        fwrite(&emr_extcreatefontindirectw, sizeof(emr_extcreatefontindirectw_t), 1, emf_file);
        if (fsize2) {
            fwrite(&emr_extcreatefontindirectw2, sizeof(emr_extcreatefontindirectw_t), 1, emf_file);
        }
    }

    fwrite(&emr_selectobject_bgbrush, sizeof(emr_selectobject_t), 1, emf_file);
    fwrite(&emr_selectobject_pen, sizeof(emr_selectobject_t), 1, emf_file);
    if (draw_background) {
        fwrite(&background, sizeof(emr_rectangle_t), 1, emf_file);
    }

    if (symbol->symbology == BARCODE_ULTRA) {
        for (i = 0; i < 9; i++) {
            if (rectangle_bycolour[i]) {
                fwrite(&emr_selectobject_colour[i], sizeof(emr_selectobject_t), 1, emf_file);

                rect = symbol->vector->rectangles;
                this_rectangle = 0;
                while (rect) {
                    if ((i == 0 && rect->colour == -1) || rect->colour == i) {
                        fwrite(&rectangle[this_rectangle], sizeof(emr_rectangle_t), 1, emf_file);
                    }
                    this_rectangle++;
                    rect = rect->next;
                }
            }
        }
    } else {
        fwrite(&emr_selectobject_fgbrush, sizeof(emr_selectobject_t), 1, emf_file);

        /* Rectangles */
        for (i = 0; i < rectangle_count; i++) {
            fwrite(&rectangle[i], sizeof(emr_rectangle_t), 1, emf_file);
        }
    }

    /* Hexagons */
    for (i = 0; i < hexagon_count; i++) {
        fwrite(&hexagon[i], sizeof(emr_polygon_t), 1, emf_file);
    }

    /* Circles */
    if (symbol->symbology == BARCODE_MAXICODE) {
        /* Bullseye needed */
        for (i = 0; i < circle_count; i++) {
            fwrite(&circle[i], sizeof(emr_ellipse_t), 1, emf_file);
            if (i < circle_count - 1) {
                if (i % 2) {
                    fwrite(&emr_selectobject_fgbrush, sizeof(emr_selectobject_t), 1, emf_file);
                } else {
                    fwrite(&emr_selectobject_bgbrush, sizeof(emr_selectobject_t), 1, emf_file);
                }
            }
        }
    } else {
        for (i = 0; i < circle_count; i++) {
            fwrite(&circle[i], sizeof(emr_ellipse_t), 1, emf_file);
        }
    }

    /* Text */
    if (string_count > 0) {
        fwrite(&emr_selectobject_font, sizeof(emr_selectobject_t), 1, emf_file);
        fwrite(&emr_settextcolor, sizeof(emr_settextcolor_t), 1, emf_file);
    }

    current_fsize = fsize;
    current_halign = -1;
    for (i = 0; i < string_count; i++) {
        if (text_fsizes[i] != current_fsize) {
            current_fsize = text_fsizes[i];
            fwrite(&emr_selectobject_font2, sizeof(emr_selectobject_t), 1, emf_file);
        }
        if (text_haligns[i] != current_halign) {
            current_halign = text_haligns[i];
            if (current_halign == 0) {
                fwrite(&emr_settextalign_centre, sizeof(emr_settextalign_t), 1, emf_file);
            } else if (current_halign == 1) {
                fwrite(&emr_settextalign_left, sizeof(emr_settextalign_t), 1, emf_file);
            } else {
                fwrite(&emr_settextalign_right, sizeof(emr_settextalign_t), 1, emf_file);
            }
        }
        fwrite(&text[i], sizeof(emr_exttextoutw_t), 1, emf_file);
        fwrite(this_string[i], emf_bump_up(text[i].w_emr_text.chars), 1, emf_file);
        free(this_string[i]);
    }

    fwrite(&emr_eof, sizeof(emr_eof_t), 1, emf_file);

    if (ferror(emf_file)) {
        sprintf(symbol->errtxt, "644: Incomplete write to output (%d: %.30s)", errno, strerror(errno));
        if (!output_to_stdout) {
            (void) fclose(emf_file);
        }
        return ZINT_ERROR_FILE_WRITE;
    }

    if (output_to_stdout) {
        if (fflush(emf_file) != 0) {
            sprintf(symbol->errtxt, "940: Incomplete flush to output (%d: %.30s)", errno, strerror(errno));
            return ZINT_ERROR_FILE_WRITE;
        }
    } else {
        if (fclose(emf_file) != 0) {
            sprintf(symbol->errtxt, "941: Failure on closing output file (%d: %.30s)", errno, strerror(errno));
            return ZINT_ERROR_FILE_WRITE;
        }
    }
    return error_number;
}

/* vim: set ts=4 sw=4 et : */
