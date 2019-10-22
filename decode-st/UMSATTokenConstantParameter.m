//
//  UMSATTokenConstantParameter.m
//  decode-st
//
//  Created by Andreas Fink on 18.10.19.
//  Copyright © 2019 Andreas Fink (andreas@fink.org). All rights reserved.
//

#import "UMSATTokenConstantParameter.h"

@implementation UMSATTokenConstantParameter

- (void)decodePayload
{
    [self lookForSubtokens];
    if(_subEntries.count >= 1)
    {
        _parameterA = _subEntries[0];
    }
    if(_subEntries.count >= 2)
    {
        _parameterB = _subEntries[0];
    }
    _subEntries = NULL;
}

- (NSString *)descriptionWithPrefixMain:(NSString *)ident
{
    NSString *ident2 = [NSString stringWithFormat:@"%@    ",ident];
    NSMutableString *s = [[NSMutableString alloc]init];
    [s appendFormat:@"%@ParameterA:\n",ident];
    [s appendString:[_parameterA descriptionWithPrefix:ident2]];
    [s appendFormat:@"%@ParameterB:\n",ident];
    [s appendString:[_parameterB descriptionWithPrefix:ident2]];
    return s;
}

@end

