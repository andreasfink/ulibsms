//
//  UMGlobalMessageCache.h
//  ulibsms
//
//  © 2016  by Andreas Fink
//
// This source is dual licensed either under the GNU GENERAL PUBLIC LICENSE
// Version 3 from 29 June 2007 and other commercial licenses available by
// the author.
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
