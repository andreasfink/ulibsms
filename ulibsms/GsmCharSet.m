//
//  GsmCharSet.m
//  UniversalSMSUtilitites
//
//  Created by Andreas Fink on 27.02.09.
//  Copyright 2008-2014 Andreas Fink, Paradieshofstrasse 101, 4054 Basel, Switzerland
//

#import <ulibgsmmap/ulibgsmmap.h>
#import "GsmCharSet.h"

typedef enum GSM_CBSDataCodingScheme
{
    GSM_CBSDataCodingScheme_german      = 0b00000000,
    GSM_CBSDataCodingScheme_english     = 0b00000001,
    GSM_CBSDataCodingScheme_italian     = 0b00000010,
    GSM_CBSDataCodingScheme_french      = 0b00000011,
    GSM_CBSDataCodingScheme_spanish     = 0b00000100,
    GSM_CBSDataCodingScheme_dutch       = 0b00000101,
    GSM_CBSDataCodingScheme_swedish     = 0b00000110,
    GSM_CBSDataCodingScheme_danish      = 0b00000111,
    GSM_CBSDataCodingScheme_portuguese  = 0b00001000,
    GSM_CBSDataCodingScheme_finnish     = 0b00001001,
    GSM_CBSDataCodingScheme_norwegian   = 0b00001010,
    GSM_CBSDataCodingScheme_greek       = 0b00001011,
    GSM_CBSDataCodingScheme_turkish     = 0b00001100,
    GSM_CBSDataCodingScheme_hungarian   = 0b00001101,
    GSM_CBSDataCodingScheme_polish      = 0b00001110,
    GSM_CBSDataCodingScheme_unspecified = 0b00001111,
    
    GSM_CBSDataCodingScheme_gsm_default = 0b00010000,
    GSM_CBSDataCodingScheme_gsm_ucs2    = 0b00010001,
    
    GSM_CBSDataCodingScheme_czech       = 0b00100010,
    GSM_CBSDataCodingScheme_hebrew      = 0b00100011,
    GSM_CBSDataCodingScheme_arab        = 0b00100010,
    GSM_CBSDataCodingScheme_russian     = 0b00100011,
    GSM_CBSDataCodingScheme_icelandic   = 0b00100100,
    
} GSM_CBSDataCodingScheme;


const unichar smsGsmToUnicode[] =
{
/* 0 - 15 */
'@',
0xA3,		/* pound */
'$', 
0xA5,		/* YEN */
0xE8,		/* e grave */
0xE9,		/* e egue */
0xF9,		/* u grave */
0xEC,		/* i grave */
0xF2,		/* o grave */
0xC7,		/* C cedile */
10,			/* linefeed */
0xd8,		/* stroken O */
0xF8,		/* stroken o */
13,			/* carriage return */
0xC5,		/* A with circle */
0xE5,		/* a with circle */
/* 16 - 31 */
0x394,		/* GREEK CAPITAL LETTER DELTA */
'_',		/* UNDERSCORE */
0x3A6,		/* GREEK CAPITAL LETTER PHI */
0x393,		/* GREEK CAPITAL LETTER GAMMA */
0x39B,		/* GREEK CAPITAL LETTER LAMBDA */
0x3A9,		/* GREEK CAPITAL LETTER OMEGA */
0x3A0,		/* GREEK CAPITAL LETTER PI */
0x3A8,		/* GREEK CAPITAL LETTER PSI */
0x3A3,		/* GREEK CAPITAL LETTER SIGMA */
0x398,		/* GREEK CAPITAL LETTER THETA */
0x39E,		/* GREEK CAPITAL LETTER XI */
0x1B,		/* ESCAPE */
0xC6,		/* AE ligature */
0xE6,		/* ae ligature */
0xDF,		/* sharp S */
0xC9,		/* E EGUE */
/* 32 - 47 */
' ',   '!',   '"',   '#',  0xA4,   '%',   '&',  '\'',  
'(',   ')',   '*',   '+',   ',',   '-',   '.',   '/',
'0',   '1',   '2',   '3',   '4',   '5',   '6',   '7',  
'8',   '9',   ':',   ';',   '<',   '=',   '>',   '?', 
0xA1,  'A',   'B',   'C',   'D',   'E',   'F',   'G', 
'H',   'I',   'J',   'K',   'L',   'M',   'N',   'O', 
'P',   'Q',   'R',   'S',   'T',   'U',   'V',   'W',
'X',   'Y',   'Z',  0xC4,  0xD6,  0xD1,  0xDC,  0xA7,  /* XYZÄÖÑÜ§ */
0xBF,   'a',   'b',   'c',   'd',   'e',   'f',   'g',   
'h',   'i',   'j',   'k',   'l',   'm',   'n',   'o',   
'p',   'q',   'r',   's',   't',   'u',   'v',   'w',   
'x',   'y',   'z',  0xE4,  0xF6,  0xF1,  0xFC,  0xE0    /* äöñüà */
};

int smsGsmToUnicode_table_size = sizeof(smsGsmToUnicode);
