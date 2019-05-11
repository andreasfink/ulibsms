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

- (UMHLRCache *)init
{
    self = [super init];
    if(self)
    {
        _entries= [[NSMutableDictionary alloc] init];
        _expiration_seconds = 0;
        _lock = [[UMMutex alloc]initWithName:@"UMHLRCache"];
    }
    return self;
}

- (void)addToCacheMSISDN:(NSString *)msisdn
                     msc:(NSString *)msc
                    imsi:(NSString *)imsi
                     hlr:(NSString *)hlr
{
    if(_expiration_seconds<1)
    {
        return;
    }
    [_lock lock];
    UMHLRCacheEntry *entry = _entries[msisdn];
    if(entry==NULL)
    {
        time_t now;
        time(&now);

        entry = [[UMHLRCacheEntry alloc]init];
        entry.msisdn = msisdn;
        entry.imsi = imsi;
        entry.hlr = hlr;
        entry.msc = msc;
        entry.expires = now + _expiration_seconds;
    }
    else
    {
        entry.imsi = imsi;
        entry.hlr = hlr;
        entry.msc = msc;
    }
    _entries[msisdn] = entry;
    [_lock unlock];
}


- (void)expire
{
    [_lock lock];
    /* expire the dict */
    time_t	cur;
    cur = time(&cur);
    NSArray *keys = [_entries allKeys];
    for (NSString *key in keys)
    {
        UMHLRCacheEntry *entry = _entries[key];
        if(entry.expires < cur)
        {
            [_entries removeObjectForKey:key];
        }
   }
   [_lock unlock];
}

- (UMHLRCacheEntry *)find:(NSString *)msisdn
{
    [_lock lock];
    UMHLRCacheEntry *entry = _entries[msisdn];
    [_lock unlock];
    return entry;
}

-(NSInteger)count
{
    NSInteger i;
    [_lock lock];
    i = _entries.count;
    [_lock unlock];
    return i;
}

@end
