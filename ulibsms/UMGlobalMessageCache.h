//
//  UMGlobalMessageCache.h
//  ulibsms
//
//  Created by Andreas Fink on 06/07/15.
//  Copyright (c) 2016 Andreas Fink
//

#import <ulib/ulib.h>

@class UMessageCacheEntry;

@interface UMGlobalMessageCache : UMObject
{
    UMSynchronizedDictionary    *cache;
    FILE *flog;
}

+ (UMGlobalMessageCache *)sharedInstance;

- (void)openLog:(NSString *)logfilename;
- (void)closeLog;

- (void)retainMessage:(id)msg forMessageId:(NSString *)messageId file:(const char *)file line:(long)line func:(const char *)func;
//- (void)retainMessage:(id)msg forMessageId:(NSString *)messageId;

- (void)releaseMessage:(id)msg forMessageId:(NSString *)messageId  file:(const char *)file line:(long)line func:(const char *)func;
//- (void)releaseMessage:(id)msg forMessageId:(NSString *)messageId;
- (id)findMessage:(NSString *)messageId;

@end
