//
//  UMSATTokenURLReference.m
//  decode-st
//
//  Created by Andreas Fink on 18.10.19.
//  Copyright © 2019 Andreas Fink (andreas@fink.org). All rights reserved.
//

#import "UMSATTokenURLReference.h"

@implementation UMSATTokenURLReference

- (void) decodePayload
{
    _usePost        = (_attributes & 0x40) ? YES : NO;
    _sendReferer    = (_attributes & 0x20) ? YES : NO;
    _forcedResident = (_attributes & 0x10) ? YES : NO;
    _doNotWait      = (_attributes & 0x02) ? YES : NO;

    [self lookForSubtokens];
    if(_subEntries.count > 0)
    {
        _addressReference = _subEntries[0];
        NSMutableArray *p = [[NSMutableArray alloc]init];
        for(int i=1;i<_subEntries.count;i++)
        {
            [p addObject:_subEntries[i]];
        }
        _parameters = p;
    }
    _subEntries =NULL;
}

- (void)appendAttributesToString:(NSMutableString *)s prefix:ident
{
    if(_usePost)
    {
        [s appendFormat:@"%@           b6=1 POST_REQ is used in pull request\n",ident];
    }
    else
    {
        [s appendFormat:@"%@           b6=0 GET_REQ is used in pull request\n",ident];
    }
    if(_sendReferer)
    {
        [s appendFormat:@"%@           b5=1 do send SendReferrer\n",ident];
    }
    else
    {
        [s appendFormat:@"%@           b5=0 do not send SendReferrer\n",ident];
    }
    if(_forcedResident)
    {
        [s appendFormat:@"%@           b4=1 Address reference presents resident deck\n",ident];
    }
    else
    {
        [s appendFormat:@"%@           b4=0 Address reference presents online deck\n",ident];
    }
    if(_doNotWait)
    {
        [s appendFormat:@"%@           b1=1 Do not enter waiting for Response state after sending pull request\n",ident];
    }
    else
    {
        [s appendFormat:@"%@           b1=0 Enter waiting for Response state after sending pull request\n",ident];
    }

    
}

- (NSString *)descriptionWithPrefixMain:(NSString *)ident1
{
    NSString *ident2 = [NSString stringWithFormat:@"%@    ",ident1];
    NSMutableString *s = [[NSMutableString alloc]init];
    [s appendFormat:@"%@Inline Value Content:   %@\n",ident1,[_payload hexString]];
    [s appendFormat:@"%@AddressReference:       \n",ident1];
    [s appendString:[_addressReference descriptionWithPrefix:ident2]];
    int i=0;
    for(UMSATToken *t in _parameters)
    {
        [s appendFormat:@"%@Parameter[%d]:          \n",ident1,i];
        [s appendString:[t descriptionWithPrefix:ident2]];
    }
    return s;
}


@end


