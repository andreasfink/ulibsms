//
//  UMGSMCharacterTable.m
//  ulibsms
//
//  Created by Andreas Fink on 13.09.17.
//  Copyright © 2017 Andreas Fink (andreas@fink.org). All rights reserved.
//

#import <ulibsms/UMGSMCharacterTable.h>

@implementation UMGSMCharacterTable


- (UMGSMCharacterTable *)init
{
    self = [super init];
    if(self)
    {
        _entries = [[UMSynchronizedDictionary alloc]init];
        _singleShiftEntries = [[UMSynchronizedDictionary alloc]init];
        _lockingShiftEntries = [[UMSynchronizedDictionary alloc]init];
        [self setDefaultStandardEntries];
        [self setDefaultSingleShiftEntries];
        [self setDefaultLockingShiftEntries];
    }
    return self;
}

- (void)setDefaultStandardEntries
{
    _entries[@(0x00)] = @"@";
    _entries[@(0x01)] = @"£";
    _entries[@(0x02)] = @"$";
    _entries[@(0x03)] = @"¥";
    _entries[@(0x04)] = @"è";
    _entries[@(0x05)] = @"é";
    _entries[@(0x06)] = @"ù";
    _entries[@(0x07)] = @"ì";
    _entries[@(0x08)] = @"ò";
    _entries[@(0x09)] = @"Ç";
    _entries[@(0x0A)] = @"\n";
    _entries[@(0x0B)] = @"Ø";
    _entries[@(0x0C)] = @"ø";
    _entries[@(0x0D)] = @"\r";
    _entries[@(0x0E)] = @"Å";
    _entries[@(0x0F)] = @"å";
    _entries[@(0x10)] = @"Δ";
    _entries[@(0x11)] = @"_";
    _entries[@(0x12)] = @"Φ";
    _entries[@(0x13)] = @"Γ";
    _entries[@(0x14)] = @"Λ";
    _entries[@(0x15)] = @"Ω";
    _entries[@(0x16)] = @"Π";
    _entries[@(0x17)] = @"Ψ";
    _entries[@(0x18)] = @"Σ";
    _entries[@(0x19)] = @"Θ";
    _entries[@(0x1A)] = @"Ξ";
    //_entries[@(0x1B)] = /* ESCAPE */
    _entries[@(0x1C)] = @"Æ";
    _entries[@(0x1D)] = @"æ";
    _entries[@(0x1E)] = @"ß";
    _entries[@(0x1F)] = @"É";
    
    _entries[@(0x20)] = @" ";
    _entries[@(0x21)] = @"!";
    _entries[@(0x22)] = @"\"";
    _entries[@(0x23)] = @"#";
    _entries[@(0x24)] = @"¤";
    
    for (int i=0x25;i<= 0x3F;i++)
    {
        _entries[@(i)] = [NSString stringWithFormat:@"%c",i];
    }
    _entries[@(0x40)] = @"¡";
    
    for (int i=0x41;i<= 0x5A;i++)
    {
        _entries[@(i)] = [NSString stringWithFormat:@"%c",i];
    }
    _entries[@(0x5B)] = @"Ä";
    _entries[@(0x5C)] = @"Ö";
    _entries[@(0x5D)] = @"Ñ";
    _entries[@(0x5E)] = @"Ü";
    _entries[@(0x5F)] = @"§";
    _entries[@(0x60)] = @"¿";
    for (int i=0x61;i<= 0x7A;i++)
    {
        _entries[@(i)] = [NSString stringWithFormat:@"%c",i];
    }
    _entries[@(0x7B)] = @"ä";
    _entries[@(0x7C)] = @"ö";
    _entries[@(0x7D)] = @"ñ";
    _entries[@(0x7E)] = @"ü";
    _entries[@(0x7F)] = @"à";
}

- (void)setDefaultLockingShiftEntries
{
    _lockingShiftEntries[@(0x00)] = @"@";
    _lockingShiftEntries[@(0x01)] = @"£";
    _lockingShiftEntries[@(0x02)] = @"$";
    _lockingShiftEntries[@(0x03)] = @"¥";
    _lockingShiftEntries[@(0x04)] = @"è";
    _lockingShiftEntries[@(0x05)] = @"é";
    _lockingShiftEntries[@(0x06)] = @"ù";
    _lockingShiftEntries[@(0x07)] = @"ì";
    _lockingShiftEntries[@(0x08)] = @"ò";
    _lockingShiftEntries[@(0x09)] = @"Ç";
    _lockingShiftEntries[@(0x0A)] = @"\n";
    _lockingShiftEntries[@(0x0B)] = @"Ø";
    _lockingShiftEntries[@(0x0C)] = @"ø";
    _lockingShiftEntries[@(0x0D)] = @"\r";
    _lockingShiftEntries[@(0x0E)] = @"Å";
    _lockingShiftEntries[@(0x0F)] = @"å";
    _lockingShiftEntries[@(0x10)] = @"Δ";
    _lockingShiftEntries[@(0x11)] = @"_";
    _lockingShiftEntries[@(0x12)] = @"Φ";
    _lockingShiftEntries[@(0x13)] = @"Γ";
    _lockingShiftEntries[@(0x14)] = @"Λ";
    _lockingShiftEntries[@(0x15)] = @"Ω";
    _lockingShiftEntries[@(0x16)] = @"Π";
    _lockingShiftEntries[@(0x17)] = @"Ψ";
    _lockingShiftEntries[@(0x18)] = @"Σ";
    _lockingShiftEntries[@(0x19)] = @"Θ";
    _lockingShiftEntries[@(0x1A)] = @"Ξ";
    //_lockingShiftEntries[@(0x1B)] = /* ESCAPE */
    _lockingShiftEntries[@(0x1C)] = @"Æ";
    _lockingShiftEntries[@(0x1D)] = @"æ";
    _lockingShiftEntries[@(0x1E)] = @"ß";
    _lockingShiftEntries[@(0x1F)] = @"É";
    _lockingShiftEntries[@(0x20)] = @" ";
    _lockingShiftEntries[@(0x21)] = @"!";
    _lockingShiftEntries[@(0x22)] = @"\"";
    _lockingShiftEntries[@(0x23)] = @"#";
    _lockingShiftEntries[@(0x24)] = @"¤";

    for (int i=0x25;i<= 0x3F;i++)
    {
        _lockingShiftEntries[@(i)] = [NSString stringWithFormat:@"%c",i];
    }
    _lockingShiftEntries[@(0x40)] = @"¡";
    
    for (int i=0x41;i<= 0x5A;i++)
    {
        _lockingShiftEntries[@(i)] = [NSString stringWithFormat:@"%c",i];
    }
    _lockingShiftEntries[@(0x5B)] = @"Ä";
    _lockingShiftEntries[@(0x5C)] = @"Ö";
    _lockingShiftEntries[@(0x5D)] = @"Ñ";
    _lockingShiftEntries[@(0x5E)] = @"Ü";
    _lockingShiftEntries[@(0x5F)] = @"§";
    _lockingShiftEntries[@(0x60)] = @"¿";
    for (int i=0x61;i<= 0x7A;i++)
    {
        _lockingShiftEntries[@(i)] = [NSString stringWithFormat:@"%c",i];
    }
    _lockingShiftEntries[@(0x7B)] = @"ä";
    _lockingShiftEntries[@(0x7C)] = @"ö";
    _lockingShiftEntries[@(0x7D)] = @"ñ";
    _lockingShiftEntries[@(0x7E)] = @"ü";
    _lockingShiftEntries[@(0x7F)] = @"à";
}

- (void) setDefaultSingleShiftEntries
{
    _singleShiftEntries[@(0x14)] = @"^";
    _singleShiftEntries[@(0x28)] = @"{";
    _singleShiftEntries[@(0x29)] = @"}";
    _singleShiftEntries[@(0x2F)] = @"\\";
    _singleShiftEntries[@(0x3C)] = @"[";
    _singleShiftEntries[@(0x3D)] = @"~";
    _singleShiftEntries[@(0x3E)] = @"]";
    _singleShiftEntries[@(0x40)] = @"|";
    _singleShiftEntries[@(0x65)] = @"€";
}

- (void) setTurkishShiftTable
{
    _singleShiftEntries[@(0x47)] = @"Ğ";
    _singleShiftEntries[@(0x49)] = @"İ";
    _singleShiftEntries[@(0x53)] = @"Ş";
    _singleShiftEntries[@(0x63)] = @"ç";
    _singleShiftEntries[@(0x67)] = @"ğ";
    _singleShiftEntries[@(0x69)] = @"ı";
    _singleShiftEntries[@(0x73)] = @"ş";
}


- (void) setSpanishShiftTable
{
    _singleShiftEntries[@(0x09)] = @"ç";
    _singleShiftEntries[@(0x41)] = @"Á";
    _singleShiftEntries[@(0x49)] = @"Í";
    _singleShiftEntries[@(0x4F)] = @"Ó";
    _singleShiftEntries[@(0x55)] = @"Ú";
    _singleShiftEntries[@(0x61)] = @"á";
    _singleShiftEntries[@(0x69)] = @"í";
    _singleShiftEntries[@(0x6F)] = @"ó";
    _singleShiftEntries[@(0x73)] = @"ú";
}

- (void) setPortugueseShiftTable
{
    _singleShiftEntries[@(0x05)] = @"ê";
    _singleShiftEntries[@(0x09)] = @"ç";
    _singleShiftEntries[@(0x0B)] = @"Ô";
    _singleShiftEntries[@(0x0C)] = @"ô";
    _singleShiftEntries[@(0x0E)] = @"Á";
    _singleShiftEntries[@(0x0F)] = @"á";
    _singleShiftEntries[@(0x12)] = @"Φ";
    _singleShiftEntries[@(0x13)] = @"Γ";
    _singleShiftEntries[@(0x15)] = @"Ω";
    _singleShiftEntries[@(0x16)] = @"Π";
    _singleShiftEntries[@(0x17)] = @"Ψ";
    _singleShiftEntries[@(0x18)] = @"Σ";
    _singleShiftEntries[@(0x19)] = @"Θ";
    _singleShiftEntries[@(0x1F)] = @"Ê";
    _singleShiftEntries[@(0x41)] = @"À";
    _singleShiftEntries[@(0x49)] = @"Í";
    _singleShiftEntries[@(0x4F)] = @"Ó";
    _singleShiftEntries[@(0x55)] = @"Ú";
    _singleShiftEntries[@(0x5B)] = @"Ã";
    _singleShiftEntries[@(0x5C)] = @"Õ";
    _singleShiftEntries[@(0x61)] = @"Â";
    _singleShiftEntries[@(0x69)] = @"í";
    _singleShiftEntries[@(0x6F)] = @"ó";
    _singleShiftEntries[@(0x75)] = @"ú";
    _singleShiftEntries[@(0x7B)] = @"ã";
    _singleShiftEntries[@(0x7C)] = @"õ";
    _singleShiftEntries[@(0x7F)] = @"â";
}


- (void)setIndiaDefaults
{
    _singleShiftEntries = [[UMSynchronizedDictionary alloc]init];
    _singleShiftEntries[@(0x00)] = @"@";
    _singleShiftEntries[@(0x01)] = @"£";
    _singleShiftEntries[@(0x02)] = @"$";
    _singleShiftEntries[@(0x03)] = @"¥";
    _singleShiftEntries[@(0x04)] = @"¿";
    _singleShiftEntries[@(0x05)] = @"\"";
    _singleShiftEntries[@(0x06)] = @"¤";
    _singleShiftEntries[@(0x07)] = @"%";
    _singleShiftEntries[@(0x08)] = @"&";
    _singleShiftEntries[@(0x09)] = @"'";
    
    _singleShiftEntries[@(0x0B)] = @"*";
    _singleShiftEntries[@(0x0C)] = @"+";
    
    _singleShiftEntries[@(0x0E)] = @"-";
    _singleShiftEntries[@(0x0F)] = @"/";
    
    _singleShiftEntries[@(0x10)] = @"<";
    _singleShiftEntries[@(0x11)] = @"=";
    _singleShiftEntries[@(0x12)] = @">";
    _singleShiftEntries[@(0x13)] = @"¡";
    _singleShiftEntries[@(0x14)] = @"^";
    _singleShiftEntries[@(0x15)] = @"¡";
    
    _singleShiftEntries[@(0x16)] = @"_";
    _singleShiftEntries[@(0x17)] = @"#";
    _singleShiftEntries[@(0x18)] = @"*";
    
    _singleShiftEntries[@(0x28)] = @"{";
    _singleShiftEntries[@(0x29)] = @"}";
    
    _singleShiftEntries[@(0x2F)] = @"\\";
    
    _singleShiftEntries[@(0x3C)] = @"[";
    _singleShiftEntries[@(0x3D)] = @"~";
    _singleShiftEntries[@(0x3E)] = @"]";
    
    _singleShiftEntries[@(0x40)] = @"|";
    /* A...Z */
    for (int i=0x41;i<= 0x5A;i++)
    {
        _singleShiftEntries[@(i)] = [NSString stringWithFormat:@"%c",(i-0x41+'A')];
    }
    _singleShiftEntries[@(0x65)] = @"€";
    
}

- (void) setBengaliShiftTable
{
    [self setIndiaDefaults];

    _singleShiftEntries[@(0x19)] = @"\u09E6";
    _singleShiftEntries[@(0x1A)] = @"\u09E7";
    
    _singleShiftEntries[@(0x1C)] = @"\u09E8";
    _singleShiftEntries[@(0x1D)] = @"\u09E9";
    _singleShiftEntries[@(0x1E)] = @"\u09EA";
    _singleShiftEntries[@(0x1F)] = @"\u09EB";
    

    _singleShiftEntries[@(0x20)] = @"\u09EC";
    _singleShiftEntries[@(0x21)] = @"\u09ED";
    _singleShiftEntries[@(0x22)] = @"\u09EE";
    _singleShiftEntries[@(0x23)] = @"\u09EF";
    _singleShiftEntries[@(0x24)] = @"\u09DF";
    _singleShiftEntries[@(0x25)] = @"\u09E0";
    _singleShiftEntries[@(0x26)] = @"\u09E1";
    _singleShiftEntries[@(0x27)] = @"\u09E2";
    _singleShiftEntries[@(0x2A)] = @"\u09E3";
    _singleShiftEntries[@(0x2B)] = @"\u09F2";
    _singleShiftEntries[@(0x2C)] = @"\u09F3";
    _singleShiftEntries[@(0x2D)] = @"\u09F4";
    _singleShiftEntries[@(0x2E)] = @"\u09F5";
    
    _singleShiftEntries[@(0x30)] = @"\u09F6";
    _singleShiftEntries[@(0x31)] = @"\u09F7";
    _singleShiftEntries[@(0x32)] = @"\u09F8";
    _singleShiftEntries[@(0x33)] = @"\u09F9";

}


- (void) setGujaratiShiftTable
{
    [self setIndiaDefaults];
    
    _singleShiftEntries[@(0x19)] = @"\u0964";
    _singleShiftEntries[@(0x1A)] = @"\u0965";
    
    _singleShiftEntries[@(0x1C)] = @"\u0AE6";
    _singleShiftEntries[@(0x1D)] = @"\u0AE7";
    _singleShiftEntries[@(0x1E)] = @"\u0AE8";
    _singleShiftEntries[@(0x1F)] = @"\u0AE9";
    
    
    _singleShiftEntries[@(0x20)] = @"\u0AEA";
    _singleShiftEntries[@(0x21)] = @"\u0AEB";
    _singleShiftEntries[@(0x22)] = @"\u0AEC";
    _singleShiftEntries[@(0x23)] = @"\u0AED";
    _singleShiftEntries[@(0x24)] = @"\u0AEE";
    _singleShiftEntries[@(0x25)] = @"\u0AEF";
    
}

- (void) setHindiShiftTable
{
    [self setIndiaDefaults];
    
    _singleShiftEntries[@(0x19)] = @"\u0964";
    _singleShiftEntries[@(0x1A)] = @"\u0965";
    
    _singleShiftEntries[@(0x1C)] = @"\u0966";
    _singleShiftEntries[@(0x1D)] = @"\u0967";
    _singleShiftEntries[@(0x1E)] = @"\u0968";
    _singleShiftEntries[@(0x1F)] = @"\u0969";
    
    
    _singleShiftEntries[@(0x20)] = @"\u096A";
    _singleShiftEntries[@(0x21)] = @"\u096B";
    _singleShiftEntries[@(0x22)] = @"\u096C";
    _singleShiftEntries[@(0x23)] = @"\u096D";
    _singleShiftEntries[@(0x24)] = @"\u096E";
    _singleShiftEntries[@(0x25)] = @"\u096F";
    _singleShiftEntries[@(0x26)] = @"\u0951";
    _singleShiftEntries[@(0x27)] = @"\u0952";
    _singleShiftEntries[@(0x2A)] = @"\u0953";
    _singleShiftEntries[@(0x2B)] = @"\u0954";
    _singleShiftEntries[@(0x2C)] = @"\u0958";
    _singleShiftEntries[@(0x2D)] = @"\u0959";
    _singleShiftEntries[@(0x2E)] = @"\u095A";
    
    _singleShiftEntries[@(0x30)] = @"\u095B";
    _singleShiftEntries[@(0x31)] = @"\u095C";
    _singleShiftEntries[@(0x32)] = @"\u095D";
    _singleShiftEntries[@(0x33)] = @"\u095E";
    _singleShiftEntries[@(0x34)] = @"\u095F";
    _singleShiftEntries[@(0x35)] = @"\u0960";
    _singleShiftEntries[@(0x36)] = @"\u0961";
    _singleShiftEntries[@(0x37)] = @"\u0962";
    _singleShiftEntries[@(0x38)] = @"\u0963";
    _singleShiftEntries[@(0x39)] = @"\u0970";
    _singleShiftEntries[@(0x3A)] = @"\u0971";
    
}


- (void) setKannadaShiftTable
{
    [self setIndiaDefaults];
    
    _singleShiftEntries[@(0x19)] = @"\u0964";
    _singleShiftEntries[@(0x1A)] = @"\u0965";
    
    _singleShiftEntries[@(0x1C)] = @"\u0CE6";
    _singleShiftEntries[@(0x1D)] = @"\u0CE7";
    _singleShiftEntries[@(0x1E)] = @"\u0CE8";
    _singleShiftEntries[@(0x1F)] = @"\u0CE9";
    
    _singleShiftEntries[@(0x20)] = @"\u0CEA";
    _singleShiftEntries[@(0x21)] = @"\u0CEB";
    _singleShiftEntries[@(0x22)] = @"\u0CEC";
    _singleShiftEntries[@(0x23)] = @"\u0CED";
    _singleShiftEntries[@(0x24)] = @"\u0CEE";
    _singleShiftEntries[@(0x25)] = @"\u0CEF";
    _singleShiftEntries[@(0x26)] = @"\u0CDE";
    _singleShiftEntries[@(0x27)] = @"\u0CF1";
    _singleShiftEntries[@(0x2A)] = @"\u0CF2";
    
}


- (void) setMalayamShiftTable
{
    [self setIndiaDefaults];
    
    _singleShiftEntries[@(0x19)] = @"\u0964";
    _singleShiftEntries[@(0x1A)] = @"\u0965";
    _singleShiftEntries[@(0x1C)] = @"\u0D66";
    _singleShiftEntries[@(0x1D)] = @"\u0D67";
    _singleShiftEntries[@(0x1E)] = @"\u0D68";
    _singleShiftEntries[@(0x1F)] = @"\u0D69";
    
    
    _singleShiftEntries[@(0x20)] = @"\u0D6A";
    _singleShiftEntries[@(0x21)] = @"\u0D6B";
    _singleShiftEntries[@(0x22)] = @"\u0D6C";
    _singleShiftEntries[@(0x23)] = @"\u0D6D";
    _singleShiftEntries[@(0x24)] = @"\u0D6E";
    _singleShiftEntries[@(0x25)] = @"\u0D6F";
    _singleShiftEntries[@(0x26)] = @"\u0D70";
    _singleShiftEntries[@(0x27)] = @"\u0D71";
    _singleShiftEntries[@(0x2A)] = @"\u0D72";
    _singleShiftEntries[@(0x2B)] = @"\u0D73";
    _singleShiftEntries[@(0x2C)] = @"\u0D74";
    _singleShiftEntries[@(0x2C)] = @"\u0D75";
    _singleShiftEntries[@(0x2E)] = @"\u0D7A";
    
    
    _singleShiftEntries[@(0x30)] = @"\u0D7B";
    _singleShiftEntries[@(0x31)] = @"\u0D7C";
    _singleShiftEntries[@(0x32)] = @"\u0D7D";
    _singleShiftEntries[@(0x33)] = @"\u0D7E";
    _singleShiftEntries[@(0x34)] = @"\u0D7F";

}

- (void) setOriyaShiftTable
{
    [self setIndiaDefaults];
    
    _singleShiftEntries[@(0x19)] = @"\u0964";
    _singleShiftEntries[@(0x1A)] = @"\u0965";
    _singleShiftEntries[@(0x1C)] = @"\u0B66";
    _singleShiftEntries[@(0x1D)] = @"\u0B67";
    _singleShiftEntries[@(0x1E)] = @"\u0B68";
    _singleShiftEntries[@(0x1F)] = @"\u0B69";
    
    
    _singleShiftEntries[@(0x20)] = @"\u0B6A";
    _singleShiftEntries[@(0x21)] = @"\u0B6B";
    _singleShiftEntries[@(0x22)] = @"\u0B6C";
    _singleShiftEntries[@(0x23)] = @"\u0B6D";
    _singleShiftEntries[@(0x24)] = @"\u0B6E";
    _singleShiftEntries[@(0x25)] = @"\u0B6F";
    _singleShiftEntries[@(0x26)] = @"\u0B5C";
    _singleShiftEntries[@(0x27)] = @"\u0B5D";
    
    _singleShiftEntries[@(0x2A)] = @"\u0B5F";
    _singleShiftEntries[@(0x2B)] = @"\u0B70";
}

- (void) setPunjabiShiftTable
{
    [self setIndiaDefaults];
    
    _singleShiftEntries[@(0x19)] = @"\u0964";
    _singleShiftEntries[@(0x1A)] = @"\u0965";
    _singleShiftEntries[@(0x1C)] = @"\u0A66";
    _singleShiftEntries[@(0x1D)] = @"\u0A67";
    _singleShiftEntries[@(0x1E)] = @"\u0A68";
    _singleShiftEntries[@(0x1F)] = @"\u0A69";
    
    
    _singleShiftEntries[@(0x20)] = @"\u0A6A";
    _singleShiftEntries[@(0x21)] = @"\u0A6B";
    _singleShiftEntries[@(0x22)] = @"\u0A6C";
    _singleShiftEntries[@(0x23)] = @"\u0A6D";
    _singleShiftEntries[@(0x24)] = @"\u0A6E";
    _singleShiftEntries[@(0x25)] = @"\u0A6F";
    _singleShiftEntries[@(0x26)] = @"\u0A59";
    _singleShiftEntries[@(0x27)] = @"\u0A5A";
    
    _singleShiftEntries[@(0x2A)] = @"\u0A5B";
    _singleShiftEntries[@(0x2B)] = @"\u0A5C";
    _singleShiftEntries[@(0x2C)] = @"\u0A5E";
    _singleShiftEntries[@(0x2D)] = @"\u0A75";
}

- (void) setTamilShiftTable
{
    [self setIndiaDefaults];
    
    _singleShiftEntries[@(0x19)] = @"\u0964";
    _singleShiftEntries[@(0x1A)] = @"\u0965";
    _singleShiftEntries[@(0x1C)] = @"\u0BE6";
    _singleShiftEntries[@(0x1D)] = @"\u0BE7";
    _singleShiftEntries[@(0x1E)] = @"\u0BE8";
    _singleShiftEntries[@(0x1F)] = @"\u0BE9";
    
    
    _singleShiftEntries[@(0x20)] = @"\u0BEA";
    _singleShiftEntries[@(0x21)] = @"\u0BEB";
    _singleShiftEntries[@(0x22)] = @"\u0BEC";
    _singleShiftEntries[@(0x23)] = @"\u0BED";
    _singleShiftEntries[@(0x24)] = @"\u0BEE";
    _singleShiftEntries[@(0x25)] = @"\u0BEF";
    _singleShiftEntries[@(0x26)] = @"\u0BF3";
    _singleShiftEntries[@(0x27)] = @"\u0BF4";
    
    _singleShiftEntries[@(0x2A)] = @"\u0BF5";
    _singleShiftEntries[@(0x2B)] = @"\u0BF6";
    _singleShiftEntries[@(0x2C)] = @"\u0BF7";
    _singleShiftEntries[@(0x2D)] = @"\u0BF8";
    _singleShiftEntries[@(0x2E)] = @"\u0BFA";
}

- (void) setTeluguShiftTable
{
    [self setIndiaDefaults];
    
    _singleShiftEntries[@(0x1C)] = @"\u0C66";
    _singleShiftEntries[@(0x1D)] = @"\u0C67";
    _singleShiftEntries[@(0x1E)] = @"\u0C68";
    _singleShiftEntries[@(0x1F)] = @"\u0C69";
    
    
    _singleShiftEntries[@(0x20)] = @"\u0C6A";
    _singleShiftEntries[@(0x21)] = @"\u0C6B";
    _singleShiftEntries[@(0x22)] = @"\u0C6C";
    _singleShiftEntries[@(0x23)] = @"\u0C6D";
    _singleShiftEntries[@(0x24)] = @"\u0C6E";
    _singleShiftEntries[@(0x25)] = @"\u0C6F";
    _singleShiftEntries[@(0x26)] = @"\u0C58";
    _singleShiftEntries[@(0x27)] = @"\u0C59";
    
    _singleShiftEntries[@(0x2A)] = @"\u0C78";
    _singleShiftEntries[@(0x2B)] = @"\u0C79";
    _singleShiftEntries[@(0x2C)] = @"\u0C7A";
    _singleShiftEntries[@(0x2D)] = @"\u0C7B";
    _singleShiftEntries[@(0x2E)] = @"\u0C7C";

    _singleShiftEntries[@(0x30)] = @"\u0C7D";
    _singleShiftEntries[@(0x31)] = @"\u0C7E";
    _singleShiftEntries[@(0x32)] = @"\u0C7F";
}

- (void) setUrduShiftTable
{
    [self setIndiaDefaults];

    _singleShiftEntries[@(0x19)] = @"\u0600";
    _singleShiftEntries[@(0x1A)] = @"\u0601";

    _singleShiftEntries[@(0x1C)] = @"\u06F0";
    _singleShiftEntries[@(0x1D)] = @"\u06F1";
    _singleShiftEntries[@(0x1E)] = @"\u06F2";
    _singleShiftEntries[@(0x1F)] = @"\u06F3";
    
    
    _singleShiftEntries[@(0x20)] = @"\u06F4";
    _singleShiftEntries[@(0x21)] = @"\u06F5";
    _singleShiftEntries[@(0x22)] = @"\u06F6";
    _singleShiftEntries[@(0x23)] = @"\u06F7";
    _singleShiftEntries[@(0x24)] = @"\u06F8";
    _singleShiftEntries[@(0x25)] = @"\u06F9";
    _singleShiftEntries[@(0x26)] = @"\u060C";
    _singleShiftEntries[@(0x27)] = @"\u060D";
    
    _singleShiftEntries[@(0x2A)] = @"\u060E";
    _singleShiftEntries[@(0x2B)] = @"\u060F";
    _singleShiftEntries[@(0x2C)] = @"\u0610";
    _singleShiftEntries[@(0x2D)] = @"\u0611";
    _singleShiftEntries[@(0x2E)] = @"\u0612";
    
    _singleShiftEntries[@(0x30)] = @"\u0613";
    _singleShiftEntries[@(0x31)] = @"\u0614";
    _singleShiftEntries[@(0x32)] = @"\u061B";
    _singleShiftEntries[@(0x33)] = @"\u061F";

    _singleShiftEntries[@(0x34)] = @"\u0640";
    _singleShiftEntries[@(0x35)] = @"\u0652";
    _singleShiftEntries[@(0x36)] = @"\u0658";
    _singleShiftEntries[@(0x37)] = @"\u066B";
    _singleShiftEntries[@(0x38)] = @"\u066C";
    _singleShiftEntries[@(0x39)] = @"\u0672";
    _singleShiftEntries[@(0x3A)] = @"\u0673";
    _singleShiftEntries[@(0x3B)] = @"\u06CD";
    _singleShiftEntries[@(0x3F)] = @"\u06D4";
}

- (void) setTurkishLockShiftTable
{
    [self setDefaultLockingShiftEntries];

    _lockingShiftEntries[@(0x04)] = @"€";
    _lockingShiftEntries[@(0x07)] = @"ı";
    _lockingShiftEntries[@(0x0B)] = @"Ğ";
    _lockingShiftEntries[@(0x0C)] = @"ğ";

    _lockingShiftEntries[@(0x1C)] = @"Ş";
    _lockingShiftEntries[@(0x1D)] = @"ş";

    _lockingShiftEntries[@(0x40)] = @"İ";

    _lockingShiftEntries[@(0x60)] = @"ç";
}

- (void) setPortugueseLockShiftTable
{
    [self setDefaultLockingShiftEntries];
    
    
    _lockingShiftEntries[@(0x04)] = @"ê";
    _lockingShiftEntries[@(0x06)] = @"ú";
    _lockingShiftEntries[@(0x07)] = @"í";
    _lockingShiftEntries[@(0x08)] = @"ó";
    _lockingShiftEntries[@(0x09)] = @"ç";
    _lockingShiftEntries[@(0x0B)] = @"Ô";
    _lockingShiftEntries[@(0x0C)] = @"ô";
    _lockingShiftEntries[@(0x0E)] = @"Á";
    _lockingShiftEntries[@(0x0F)] = @"á";
    
    _lockingShiftEntries[@(0x12)] = @"a"; /* underlined a ? */
    _lockingShiftEntries[@(0x13)] = @"Ç";
    _lockingShiftEntries[@(0x14)] = @"a";
    _lockingShiftEntries[@(0x15)] = @"∞";
    _lockingShiftEntries[@(0x16)] = @"^";
    _lockingShiftEntries[@(0x17)] = @"\\";
    _lockingShiftEntries[@(0x18)] = @"€";
    _lockingShiftEntries[@(0x19)] = @"Ó";
    _lockingShiftEntries[@(0x1A)] = @"|";
    //_lockingShiftEntries[@(0x1B)] = /* ESCAPE */
    _lockingShiftEntries[@(0x1C)] = @"Â";
    _lockingShiftEntries[@(0x1D)] = @"â";
    _lockingShiftEntries[@(0x1E)] = @"Ê";
    _lockingShiftEntries[@(0x1F)] = @"É";
    _lockingShiftEntries[@(0x20)] = @" ";
    _lockingShiftEntries[@(0x21)] = @"!";
    _lockingShiftEntries[@(0x22)] = @"\"";
    _lockingShiftEntries[@(0x23)] = @"#";
    _lockingShiftEntries[@(0x24)] = @"o"; /* underlined o ? */
    
    for (int i=0x25;i<= 0x3F;i++)
    {
        _lockingShiftEntries[@(i)] = [NSString stringWithFormat:@"%c",i];
    }
    _lockingShiftEntries[@(0x40)] = @"Í";
    
    for (int i=0x41;i<= 0x5A;i++)
    {
        _lockingShiftEntries[@(i)] = [NSString stringWithFormat:@"%c",i];
    }
    _lockingShiftEntries[@(0x5B)] = @"Ã";
    _lockingShiftEntries[@(0x5C)] = @"Õ";
    _lockingShiftEntries[@(0x5D)] = @"Ú";
    _lockingShiftEntries[@(0x5E)] = @"Ü";
    _lockingShiftEntries[@(0x5F)] = @"§";
    _lockingShiftEntries[@(0x60)] = @"~";
    for (int i=0x61;i<= 0x7A;i++)
    {
        _lockingShiftEntries[@(i)] = [NSString stringWithFormat:@"%c",i];
    }
    _lockingShiftEntries[@(0x7B)] = @"ã";
    _lockingShiftEntries[@(0x7C)] = @"õ";
    _lockingShiftEntries[@(0x7D)] = @"`";
    _lockingShiftEntries[@(0x7E)] = @"ü";
    _lockingShiftEntries[@(0x7F)] = @"à";
}

- (void) setBengaliLockShiftTable
{ /* FIXME: to be done */
}

- (void) setGujaratiLockShiftTable
{ /* FIXME: to be done */
}

- (void) setHindiLockShiftTable
{ /* FIXME: to be done */
}

- (void) setKannadaLockShiftTable
{ /* FIXME: to be done */
}

- (void) setMalayalamLockShiftTable
{ /* FIXME: to be done */
}

- (void) setOriyaLockShiftTable
{ /* FIXME: to be done */
}

- (void) setPunjabiLockShiftTable
{ /* FIXME: to be done */
}

- (void) setTamilLockShiftTable
{ /* FIXME: to be done */
}

- (void) setTeluguLockShiftTable
{ /* FIXME: to be done */
}

- (void) setUrduLockShiftTable
{ /* FIXME: to be done */
}

+ (UMGSMCharacterTable *)defaultGsmCharacterTable
{
    static UMGSMCharacterTable *_defaultGsmCharacterTable;
    
    if(_defaultGsmCharacterTable == NULL)
    {
        _defaultGsmCharacterTable = [[UMGSMCharacterTable alloc]init];
    }
    return _defaultGsmCharacterTable;
}

+ (UMGSMCharacterTable *)turkishGsmCharacterTable
{
    static UMGSMCharacterTable *_turkishGsmCharacterTable;
    
    if(_turkishGsmCharacterTable == NULL)
    {
        _turkishGsmCharacterTable = [[UMGSMCharacterTable alloc]init];
        [_turkishGsmCharacterTable setTurkishShiftTable];
    }
    return _turkishGsmCharacterTable;
}



@end
