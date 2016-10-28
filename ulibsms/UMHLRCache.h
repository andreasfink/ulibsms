//
//  UMHLRCache.h
//  ulibsms
//
//  Created by Andreas Fink on 06/07/15.
//  Copyright (c) 2016 Andreas Fink
//

#import <ulib/ulib.h>
@class UMHLRCacheEntry;

@interface UMHLRCache : UMObject
{
    UMSynchronizedDictionary *entries;
    int expiration_seconds;
}

@property(readwrite,assign)    int expiration_seconds;

- (void)addToCacheMSISDN:(NSString *)msisdn msc:(NSString *)msc imsi:(NSString *)imsi hlr:(NSString *)hlr;
- (void)expire;
- (UMHLRCacheEntry *)find:(NSString *)msisdn;

@end
