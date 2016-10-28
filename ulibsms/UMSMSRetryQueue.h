//
//  UMSMSRetryQueue.h
//  ulibsms
//
//  Created by Andreas Fink on 02/07/15.
//  Copyright (c) 2016 Andreas Fink
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
