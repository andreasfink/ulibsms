//
//  UMSATTokenConcatenate.m
//  decode-st
//
//  Created by Andreas Fink on 18.10.19.
//  Copyright © 2019 Andreas Fink (andreas@fink.org). All rights reserved.
//

#import "UMSATTokenConcatenate.h"

@implementation UMSATTokenConcatenate

- (void)decodePayload
{
    NSData *payload = _payload;
    NSMutableArray *tokens = [[NSMutableArray alloc]init];

    uint8_t *bytes = (uint8_t *)payload.bytes;
    _outputVariable = bytes[0];
    payload = [NSData dataWithBytes:&bytes[1] length:payload.length-1];

    NSInteger len0 = payload.length;
    while(len0>=2)
    {
        UMSATToken *token = [[UMSATToken alloc]initWithData:payload];
        if(token)
        {
            [tokens addObject:token];
        }
        else
        {
            break;
        }
        NSInteger len1 = token.len;
        len0 -= len1;
        if(len0>=2)
        {
            payload = [NSData dataWithBytes:&payload.bytes[len1] length:len0];
        }
    }
    _variables = tokens;
}

- (NSString *)descriptionWithPrefixMain:(NSString *)ident
{
    NSString *ident2 = [NSString stringWithFormat:@"%@    ",ident];
    NSMutableString *s = [[NSMutableString alloc]init];

    [s appendFormat:@"%@OutputVariable: %d\n",ident,_outputVariable];

    for(UMSATToken *token in _variables)
    {
        [s appendString:[token descriptionWithPrefix:ident2]];
    }
    return s;
}

@end
