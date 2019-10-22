//
//  UMSATTokenInitVariable.m
//  decode-st
//
//  Created by Andreas Fink on 18.10.19.
//  Copyright © 2019 Andreas Fink (andreas@fink.org). All rights reserved.
//

#import "UMSATTokenInitVariable.h"

@implementation UMSATTokenInitVariable


- (void)decodePayload
{
    NSData *payload = _payload;
    NSMutableArray *tokens = [[NSMutableArray alloc]init];
    NSInteger len0 = payload.length;
    _varCount=0;
    while((len0>=2) && (_varCount < 256))
    {
        uint8_t *bytes = (uint8_t *)payload.bytes;
        int v = bytes[0];
        payload = [NSData dataWithBytes:&bytes[1] length:payload.length-1];
        UMSATToken *token = [[UMSATToken alloc]initWithData:payload];
        if(token)
        {
            _var [_varCount] = v;
            _val [_varCount++]= token;
        }
        else
        {
            break;
        }
        NSInteger len1 = 1 + token.len;
        len0 -= len1;
        if(len0>=2)
        {
            payload = [NSData dataWithBytes:&payload.bytes[len1-1] length:len0];
        }
    }
}

- (NSString *)descriptionWithPrefixMain:(NSString *)ident
{
    NSString *ident2 = [NSString stringWithFormat:@"%@    ",ident];
    NSMutableString *s = [[NSMutableString alloc]init];
    for(int i=0;i<_varCount;i++)
    {
        [s appendFormat:@"%@Variable[%d]:\n",ident,_var[i]];
        [s appendString:[_val[i] descriptionWithPrefix:ident2]];
    }
    return s;
}
@end
