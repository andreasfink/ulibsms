//
//  UMHLRCache.h
//  ulibsms
//
//  Copyright © 2017 Andreas Fink (andreas@fink.org). All rights reserved.
//
// This source is dual licensed either under the GNU GENERAL PUBLIC LICENSE
// Version 3 from 29 June 2007 and other commercial licenses available by
// the author.
//


#import <ulib/ulib.h>
@class UMHLRCacheEntry;

@interface UMHLRCache : UMObject
{
    UMSynchronizedDictionary *entries;
    int expiration_seconds;
    UMMutex* _lock;
}

@property(readwrite,assign)    int expiration_seconds;

- (void)addToCacheMSISDN:(NSString *)msisdn msc:(NSString *)msc imsi:(NSString *)imsi hlr:(NSString *)hlr;
- (void)expire;
- (UMHLRCacheEntry *)find:(NSString *)msisdn;

@end
