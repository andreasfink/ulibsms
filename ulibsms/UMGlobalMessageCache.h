//
//  UMGlobalMessageCache.h
//  ulibsms
//
//  Copyright © 2017 Andreas Fink (andreas@fink.org). All rights reserved.
//
// This source is dual licensed either under the GNU GENERAL PUBLIC LICENSE
// Version 3 from 29 June 2007 and other commercial licenses available by
// the author.
//

#import <ulib/ulib.h>

@protocol UMMessageCacheMessageProtocol
- (NSString *)messageExpiry;
- (NSString *)messageId;
- (void)setMessageExpiry:(NSString *)m;
@end


@class UMessageCacheEntry;

@interface UMGlobalMessageCache : UMObject
{
    NSMutableDictionary *_cache;
    UMMutex             *_lock;
    FILE                *_flog;
}

//+ (UMGlobalMessageCache *)sharedInstance;

- (void)openLog:(NSString *)logfilename;
- (void)closeLog;

- (void)retainMessage:(id<UMMessageCacheMessageProtocol>)msg forMessageId:(NSString *)messageId file:(const char *)file line:(long)line func:(const char *)func;
//- (void)retainMessage:(id)msg forMessageId:(NSString *)messageId;

- (void)releaseMessage:(id<UMMessageCacheMessageProtocol>)msg forMessageId:(NSString *)messageId  file:(const char *)file line:(long)line func:(const char *)func;
//- (void)releaseMessage:(id)msg forMessageId:(NSString *)messageId;
- (id)findMessage:(NSString *)messageId;
- (NSInteger)count;

- (NSArray *)expiredMessages;

@end
