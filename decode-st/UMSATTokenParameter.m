//
//  UMSATTokenParameter.m
//  decode-st
//
//  Created by Andreas Fink on 18.10.19.
//  Copyright © 2019 Andreas Fink (andreas@fink.org). All rights reserved.
//

#import "UMSATTokenParameter.h"

@implementation UMSATTokenParameter

- (void)decodePayload
{
    uint8_t *bytes = (uint8_t *)_payload.bytes;
    int len = (int)_payload.length;
    if(len > 0)
    {
        _varId = (int)bytes[0];
    }
    if(len > 1)
    {
        _parameterName = [NSData dataWithBytes:&bytes[1] length:(len-1)];
    }
}

- (NSString *)descriptionWithPrefixMain:(NSString *)ident
{
    NSMutableString *s = [[NSMutableString alloc]init];
    [s appendFormat:@"%@VariableId:      %d\n",ident,_varId];
    [s appendFormat:@"%@ParameterName:   %@\n",ident,[_parameterName hexString]];
    return s;
}

@end
