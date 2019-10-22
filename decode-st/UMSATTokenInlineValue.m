//
//  UMSATTokenInlineValue.m
//  decode-st
//
//  Created by Andreas Fink on 18.10.19.
//  Copyright © 2019 Andreas Fink (andreas@fink.org). All rights reserved.
//

#import "UMSATTokenInlineValue.h"

@implementation UMSATTokenInlineValue

- (void) decodePayload
{
    _dcs = (_attributes >> 5) & 0x03;
}

- (void)appendAttributesToString:(NSMutableString *)s prefix:ident
{
    switch(_dcs)
    {
        case 0:
            [s appendFormat:@"%@           b65 dcs: 00 DCS inherited from the current Deck DCS\n",ident];
            break;
        case 1:
            [s appendFormat:@"%@           b65 dcs: 01: SMS 7bit unpacked\n",ident];
            break;
        case 2:
            [s appendFormat:@"%@           b65 dcs: 10: UCS2\n",ident];
            break;
        case 3:
            [s appendFormat:@"%@           b65 dcs: 11: Binary\n",ident];
            break;
    }
}

- (NSString *)descriptionWithPrefixMain:(NSString *)ident
{
    NSMutableString *s = [[NSMutableString alloc]init];
    [s appendFormat:@"%@Inline Value Content:   %@\n",ident,[_payload hexString]];
    return s;
}

@end
