//
//  UMSATTokenVariableReference.m
//  decode-st
//
//  Created by Andreas Fink on 18.10.19.
//  Copyright © 2019 Andreas Fink (andreas@fink.org). All rights reserved.
//

#import "UMSATTokenVariableReference.h"

@implementation UMSATTokenVariableReference


- (void) decodePayload
{
    uint8_t *bytes = (uint8_t *)_payload.bytes;
    NSUInteger len = _payload.length;
    if(len>0)
    {
        _variableId  = bytes[0];
    }
}

- (NSString *)descriptionWithPrefixMain:(NSString *)ident
{
    NSMutableString *s = [[NSMutableString alloc]init];
    [s appendFormat:@"%@VariableID:         0x%02X\n",ident,_variableId];
    return s;
}

@end
