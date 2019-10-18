//
//  UMSATTokenCard.m
//  decode-st
//
//  Created by Andreas Fink on 18.10.19.
//  Copyright © 2019 Andreas Fink (andreas@fink.org). All rights reserved.
//

#import "UMSATTokenCard.h"

@implementation UMSATTokenCard

- (void)decodePayload
{
    [self lookForSubtokens];
}

- (void)appendAttributesToString:(NSMutableString *)s prefix:ident
{
    [s appendFormat:@"%@           b6 resetVar:%@\n",ident,((_attributes & 0x40) ? @"YES" : @"NO")];
    [s appendFormat:@"%@           b5 DoNotHistorize:%@\n",ident,((_attributes & 0x20) ? @"YES" : @"NO")];
    [s appendFormat:@"%@           b4 DoNotUseTemplate:%@\n",ident,((_attributes & 0x10) ? @"YES" : @"NO")];
    [s appendFormat:@"%@           b3 ChainNextCard:%@\n",ident,((_attributes & 0x80) ? @"YES" : @"NO")];
}

@end
