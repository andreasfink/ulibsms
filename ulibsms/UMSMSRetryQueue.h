//
//  UMSMSRetryQueue.h
//  ulibsms
//
//  Copyright © 2017 Andreas Fink (andreas@fink.org). All rights reserved.
//
// This source is dual licensed either under the GNU GENERAL PUBLIC LICENSE
// Version 3 from 29 June 2007 and other commercial licenses available by
// the author.
//

#import <ulib/ulib.h>


@class UMGlobalMessageCache;

@interface UMSMSRetryQueue : UMObject
{
    NSMutableArray       *_retry_entries;
    UMMutex              *_lock;
    UMGlobalMessageCache *_messageCache;
}
@property (readwrite,strong)    UMGlobalMessageCache    *messageCache;

-(void) queueForRetry:(id)msg
            messageId:(NSString *)messageId
            retryTime:(NSDate *) next_consideration
           expireTime:(NSDate *) last_considersation
             priority:(int) priority;

- (void)messagesNeedingRetrying:(NSArray **)needsRetry1
                     orExpiring:(NSArray **)hasExpired1;
- (NSInteger)count;
@end
