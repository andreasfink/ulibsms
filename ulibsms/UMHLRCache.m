//
//  UMHLRCache.m
//  ulibsms
//
//  Copyright © 2017 Andreas Fink (andreas@fink.org). All rights reserved.
//
// This source is dual licensed either under the GNU GENERAL PUBLIC LICENSE
// Version 3 from 29 June 2007 and other commercial licenses available by
// the author.
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
    [_lock lock];
    @try
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
    @finally
    {
        [_lock unlock];
    }
}


- (void)expire
{
    [_lock lock];
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
   [_lock unlock];
}

- (UMHLRCacheEntry *)find:(NSString *)msisdn
{
    [_lock lock];
    UMHLRCacheEntry *entry = entries[msisdn];
    [_lock unlock];
    return entry;
}


@end
