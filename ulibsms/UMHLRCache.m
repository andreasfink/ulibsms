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
    UMMUTEX_LOCK(_hlrCacheLock);
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
    UMMUTEX_UNLOCK(_hlrCacheLock);
}

- (void)expire
{
    UMMUTEX_LOCK(_hlrCacheLock);
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
   UMMUTEX_UNLOCK(_hlrCacheLock);
}

- (void)expireMSISDN:(NSString *)msisdn
{
    if(msisdn==NULL)
    {
        return;
    }
    UMMUTEX_LOCK(_hlrCacheLock);
    [_entries removeObjectForKey:msisdn];
    UMMUTEX_UNLOCK(_hlrCacheLock);
}


- (UMHLRCacheEntry *)find:(NSString *)msisdn
{
    UMMUTEX_LOCK(_hlrCacheLock);
    UMHLRCacheEntry *entry = _entries[msisdn];
    UMMUTEX_UNLOCK(_hlrCacheLock);
    return entry;
}

-(NSInteger)count
{
    NSInteger i;
    UMMUTEX_LOCK(_hlrCacheLock);
    i = _entries.count;
    UMMUTEX_UNLOCK(_hlrCacheLock);
    return i;
}

@end
