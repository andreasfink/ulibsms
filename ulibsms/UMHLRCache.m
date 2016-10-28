//
//  UMHLRCache.m
//  ulibsms
//
//  Created by Andreas Fink on 06/07/15.
//  Copyright (c) 2016 Andreas Fink
//

#import "UMHLRCache.h"
#import "UMHLRCacheEntry.h"

@implementation UMHLRCache
@synthesize expiration_seconds;

- (UMHLRCache *)init
{
    self = [super init];
    if(self)
    {
        entries= [[UMSynchronizedDictionary alloc] init];
        expiration_seconds = 0;
    }
    return self;
}

- (void)addToCacheMSISDN:(NSString *)msisdn msc:(NSString *)msc imsi:(NSString *)imsi hlr:(NSString *)hlr
{
    if(expiration_seconds<1)
    {
        return;
    }
    @synchronized(self)
    {
        UMHLRCacheEntry *entry = entries[msisdn];
        if(entry==NULL)
        {
            time_t now;
            time(&now);
            
            entry = [[UMHLRCacheEntry alloc]init];
            entry.msisdn = msisdn;
            entry.imsi = imsi;
            entry.hlr = hlr;
            entry.msc = msc;
            entry.expires = now + expiration_seconds;
        }
        else
        {
            entry.imsi = imsi;
            entry.hlr = hlr;
            entry.msc = msc;
        }
        entries[msisdn] = entry;
    }
}

- (void)expire
{
    @synchronized(self)
    {
        /* expire the dict */
        time_t	cur;
        cur = time(&cur);
        NSArray *keys = [entries allKeys];
        for (NSString *key in keys)
        {
            UMHLRCacheEntry *entry = entries[key];
            if(entry.expires < cur)
            {
                [entries removeObjectForKey:key];
            }
        }
    }
}

- (UMHLRCacheEntry *)find:(NSString *)msisdn
{
    @synchronized(self)
    {
        UMHLRCacheEntry *entry = entries[msisdn];
        return entry;
    }
}


@end
