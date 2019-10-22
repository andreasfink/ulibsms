//
//  UMSATTokenVariableReferenceList.m
//  decode-st
//
//  Created by Andreas Fink on 18.10.19.
//  Copyright © 2019 Andreas Fink (andreas@fink.org). All rights reserved.
//

#import "UMSATTokenVariableReferenceList.h"

@implementation UMSATTokenVariableReferenceList


- (void) decodePayload
{
    uint8_t *bytes = (uint8_t *)_payload.bytes;
    NSUInteger len = _payload.length;
    _variableReferenceCount  = (int)len;
    for(int i=0;i<_variableReferenceCount;i++)
    {
        _variableReference[i] = bytes[i];
    }
}

- (NSString *)descriptionWithPrefixMain:(NSString *)ident
{
    NSMutableString *s = [[NSMutableString alloc]init];
    for(int i=0;i<_variableReferenceCount;i++)
    {
        [s appendFormat:@"%@VariableReference[03%d]:    0x%02X\n",ident,i,_variableReference[i]];
    }
    return s;
}

@end

