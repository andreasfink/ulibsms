//
//  UMGSMNationalLanguageIdentifier.h
//  ulibsms
//
//  Created by Andreas Fink on 13.09.17.
//  Copyright © 2017 Andreas Fink (andreas@fink.org). All rights reserved.
//


typedef enum UMGSMNationalLanguageIdentifier
{
    UMGSMNationalLanguageIdentifier_reserved     = 0b00000000,
    UMGSMNationalLanguageIdentifier_turkish      = 0b00000001,
    UMGSMNationalLanguageIdentifier_spanish      = 0b00000010,
    UMGSMNationalLanguageIdentifier_portuguese   = 0b00000011,
    UMGSMNationalLanguageIdentifier_bengali      = 0b00000100,
    UMGSMNationalLanguageIdentifier_gujarati     = 0b00000101,
    UMGSMNationalLanguageIdentifier_hindi        = 0b00000110,
    UMGSMNationalLanguageIdentifier_kannada      = 0b00000111,
    UMGSMNationalLanguageIdentifier_malayalam    = 0b00001000,
    UMGSMNationalLanguageIdentifier_oriya        = 0b00001001,
    UMGSMNationalLanguageIdentifier_punjabi      = 0b00001010,
    UMGSMNationalLanguageIdentifier_tamil        = 0b00001011,
    UMGSMNationalLanguageIdentifier_telugu       = 0b00001100,
    UMGSMNationalLanguageIdentifier_urdu         = 0b00001101,
} UMGSMNationalLanguageIdentifier;
