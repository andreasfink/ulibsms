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

@interface UMSMSRetryQueue : UMObject
{
    NSMutableArray *retry_entries;
}

-(void) queueForRetry:(id)msg
            messageId:(NSString *)messageId
            retryTime:(time_t) next_consideration
           expireTime:(time_t) last_considersation
             priority:(int) priority;
- (void)messagesNeedingRetrying:(NSArray **)needsRetry1
                     orExpiring:(NSArray **)hasExpired1;

@end
