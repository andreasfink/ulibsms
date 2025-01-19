//
//  UMMultipartRegistry.m
//  ulibsms
//
//  Created by Andreas Fink on 15.10.22.
//  Copyright © 2022 Andreas Fink (andreas@fink.org). All rights reserved.
//

#import <ulibsms/UMMultipartRegistry.h>
#import <ulibsms/UMSMS.h>
#import <ulibsms/UMMultipartSMS.h>

@implementation UMMultipartRegistry

- (UMMultipartRegistry *)init
{
    self = [super init];
    if(self)
    {
        _multipartByDestinationAndRef = [[UMSynchronizedDictionary alloc]init];
    }
    return self;
}

- (NSArray<UMSMS *>*)registerMultipartSMS:(UMSMS *)sms newMaxSize:(int)newMaxSize
{
    
    if(sms.multipart_ref==NULL)
    {
        return @[sms];
    }
    ummutex_lock(_lock);
    NSString *key = [NSString stringWithFormat:@"%@.%@",sms.tp_da.address,sms.multipart_ref];
    
    UMMultipartSMS *multi = _multipartByDestinationAndRef[key];
    if(multi)
    {
        [multi addMultipart:sms number:sms.multipart_current max:sms.multipart_max];
        if([multi allPartsPresent] == NO)
        {
            return @[];
        }
        [multi resplitByMaxSize:newMaxSize];
        NSMutableArray<UMSMS *>* a = [[NSMutableArray alloc]init];
        for(NSInteger i=0;i<multi.mulitpartsMaxCount.integerValue;i++)
        {
            UMSMS *sms = [multi getMultipart:i];
            [a addObject:sms];
        }
        ummutex_unlock(_lock);
        return a;
    }
    ummutex_unlock(_lock);
    return @[];
}

- (NSArray<UMSMS *>*)expiredMultiparts
{
    ummutex_lock(_lock);
    NSArray *keys = [_multipartByDestinationAndRef allKeys];
    NSMutableArray *expiredMultipartKeys = [[NSMutableArray alloc]init];
    NSMutableArray *expiredSMS = [[NSMutableArray alloc]init];
    for(id ref in keys)
    {
        UMMultipartSMS *multi = _multipartByDestinationAndRef[ref];
        if([multi isExpired])
        {
            [expiredMultipartKeys addObject:ref];
            for(UMSMS *sms in multi.multiparts)
            {
                [expiredSMS addObject:sms];
            }
        }
    }
    for(id key in expiredMultipartKeys)
    {
        [_multipartByDestinationAndRef removeObjectForKey:key];
    }
    ummutex_unlock(_lock);
    return expiredSMS;
}

@end
