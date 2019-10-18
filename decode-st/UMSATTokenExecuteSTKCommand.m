//
//  UMSATTokenExecuteSTKCommand.m
//  decode-st
//
//  Created by Andreas Fink on 18.10.19.
//  Copyright © 2019 Andreas Fink (andreas@fink.org). All rights reserved.
//

#import "UMSATTokenExecuteSTKCommand.h"

@implementation UMSATTokenExecuteSTKCommand

- (void) decodePayload
{
    uint8_t *bytes = (uint8_t *)_payload.bytes;
    NSUInteger len = _payload.length;
    if(len>=3)
    {
        _command_type  = bytes[0];
        _command_qualifier = bytes[1];
        _destination_device = bytes[2];
    }
    if(len>3)
    {
        NSData *d = [[NSData alloc]initWithBytes:&_payload.bytes[3] length:len-3];
        _varId = [d hexString];
    }
}

- (void)appendAttributesToString:(NSMutableString *)s prefix:ident
{
    [s appendFormat:@"%@           b6 tlvSequence:%@\n",ident,((_attributes & 0x40) ? @"YES" : @"NO")];
}


- (NSString *)descriptionWithPrefixMain:(NSString *)ident
{
    NSMutableString *s = [[NSMutableString alloc]init];

    [s appendFormat:@"%@Command-Type:       0x%02X\n",ident,_command_type];
    [s appendFormat:@"%@Command-Qualifier:  0x%02X\n",ident,_command_qualifier];
    [s appendFormat:@"%@Destination-Device: 0x%02X\n",ident,_destination_device];

    return s;
}

@end
