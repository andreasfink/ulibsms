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

#import <ulibsms/UMHLRCache.h>
#import <ulibsms/UMHLRCacheEntry.h>

@implementation UMHLRCache

- (UMHLRCache *)init
{
    self = [super init];
    if(self)
    {
        _entries= [[NSMutableDictionary alloc] init];
        _expiration_seconds = 0;
        _hlrCacheLock = [[UMMutex alloc]initWithName:@"UMHLRCache"];
    }
    return self;
}

- (void)addToCacheMSISDN:(NSString *)msisdn
                     msc:(NSString *)msc
                    imsi:(NSString *)imsi
                     hlr:(NSString *)hlr
{
    if(_expiration_seconds < 1)
    {
        return;
    }
    ummutex_lock(_hlrCacheLock);
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
    ummutex_unlock(_hlrCacheLock);
}

- (void)expire
{
    ummutex_lock(_hlrCacheLock);
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
   ummutex_unlock(_hlrCacheLock);
}

- (void)expireMSISDN:(NSString *)msisdn
{
    if(msisdn==NULL)
    {
        return;
    }
    ummutex_lock(_hlrCacheLock);
    [_entries removeObjectForKey:msisdn];
    ummutex_unlock(_hlrCacheLock);
}


- (UMHLRCacheEntry *)find:(NSString *)msisdn
{
    ummutex_lock(_hlrCacheLock);
    UMHLRCacheEntry *entry = _entries[msisdn];
    ummutex_unlock(_hlrCacheLock);
    return entry;
}

-(NSInteger)count
{
    NSInteger i;
    ummutex_lock(_hlrCacheLock);
    i = _entries.count;
    ummutex_unlock(_hlrCacheLock);
    return i;
}

@end
