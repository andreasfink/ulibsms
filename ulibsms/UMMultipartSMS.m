//
//  UMMultipartSMS.m
//  ulibsms
//
//  Created by Andreas Fink on 26.09.22.
//  Copyright © 2022 Andreas Fink (andreas@fink.org). All rights reserved.
//

#import "UMMultipartSMS.h"

@implementation UMMultipartSMS


- (void)addMultipart:(UMSMS *)sms
              number:(NSNumber *)pos
                 max:(NSNumber *)max
{
    if(pos.integerValue > max.integerValue)
    {
        max = @(pos.integerValue + 1);
    }
    _mulitpartsMaxCount = max;
    if(_multiparts == NULL)
    {
        _multiparts = [[UMSynchronizedArray alloc]init];
    }
    for(NSInteger i = _multiparts.count ; i < _mulitpartsMaxCount.integerValue;i++)
    {
        _multiparts[i] = [NSNull null];
    }
    _multiparts[pos.intValue] = sms;
}

- (BOOL)allPartsPresent
{
    if((_mulitpartsMaxCount == 0) || (_multiparts.count == 0))
    {
        return NO;
    }
    for(NSInteger i=0;i<_multiparts.count;i++)
    {
        if([_multiparts[i] isKindOfClass:[NSNull class]])
        {
            return NO;
        }
    }
    return YES;
}
- (void)combine
{
    for(NSInteger i=0;i<_multiparts.count;i++)
    {
        
    }
}

- (void)resplitByMaxSize:(NSInteger)maxSize
{
    [self combine];
    
}

- (UMSMS *)getMultipart:(NSInteger)index
{
    return NULL;
}


@end
