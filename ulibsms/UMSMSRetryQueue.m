//
//  UMSMSRetryQueue.m
//  ulibsms
//
//  Copyright © 2017 Andreas Fink (andreas@fink.org). All rights reserved.
//
// This source is dual licensed either under the GNU GENERAL PUBLIC LICENSE
// Version 3 from 29 June 2007 and other commercial licenses available by
// the author.
//

#include <stdio.h>

#import <ulibsms/UMSMSRetryQueue.h>
#import <ulibsms/UMGlobalMessageCache.h>


//#define DEBUG_LOGGING    1

#define LOG_TO_STDERR(str)  { fprintf(stderr,"%s\n",str.UTF8String); fflush(stderr); }

@implementation UMSMSRetryQueue

-(UMSMSRetryQueue *)init
{
    self = [super init];
    if(self)
    {
        _retry_entries = [[NSMutableArray alloc]init];
        _retryQueueLock = [[UMMutex alloc]initWithName:@"UMSMSRetryQueue"];
    }
    return self;
}


-(void) queueForRetry:(id)msg
            messageId:(NSString *)messageId
            retryTime:(NSDate *) next_consideration
           expireTime:(NSDate *) last_considersation
             priority:(int) priority
{
#ifdef DEBUG_LOGGING
    NSString *s = [NSString stringWithFormat:@"retryQueue queueForRetry:%@ retryTime: %@ expireTime:%@ priority: %d", messageId,next_consideration,last_considersation,priority];
    LOG_TO_STDERR(s);
#endif
    ummutex_lock(_retryQueueLock);
    NSDictionary *entry = @{ @"msg":msg,
                             @"messageId" : messageId,
                             @"retry-time":next_consideration,
                             @"expire-time":last_considersation,
                             @"priority":  @(priority),
                             };
    [_messageCache retainMessage:msg forMessageId:messageId file:__FILE__ line:__LINE__ func:__func__];
    [_retry_entries addObject:entry];
    ummutex_unlock(_retryQueueLock);
}

- (void)messagesNeedingRetrying:(NSArray **)needsRetry1 orExpiring:(NSArray **)hasExpired1
{
#ifdef DEBUG_LOGGING
    LOG_TO_STDERR(@"messagesNeedingRetrying called");
#endif

    UMAssert(needsRetry1, @"needsRetry is pointing to NULL");
    UMAssert(hasExpired1, @"hasExpired is pointing to NULL");
    
    NSDate *now = [NSDate date];
    NSMutableArray *needsRetry = [[NSMutableArray alloc]init];
    NSMutableArray *hasExpired = [[NSMutableArray alloc]init];
    
    ummutex_lock(_retryQueueLock);

    NSUInteger n =[_retry_entries count];
    for(NSUInteger i=0;i<n; )
    {
        NSDictionary *entry = _retry_entries[i];
        NSDate *retryTime = entry[@"retry-time"];
        NSDate *expireTime = entry[@"expire-time"];
        if(retryTime.timeIntervalSinceReferenceDate < now.timeIntervalSinceReferenceDate)
        {
#ifdef DEBUG_LOGGING
            NSString *s = [NSString stringWithFormat:@"retryQueue messagesNeedingRetrying:%@",entry[@"messageId"]];
            LOG_TO_STDERR(s);
#endif

            [needsRetry addObject:entry[@"msg"]];
            [_retry_entries removeObjectAtIndex:i];
            [_messageCache releaseMessage:entry[@"msg"] forMessageId:entry[@"messageId"] file:__FILE__ line:__LINE__ func:__func__];
            n--;
        }
        else if(expireTime.timeIntervalSinceReferenceDate <= now.timeIntervalSinceReferenceDate)
        {
            [hasExpired addObject:entry[@"msg"]];
            [_retry_entries removeObjectAtIndex:i];
            [_messageCache releaseMessage:entry[@"msg"] forMessageId:entry[@"messageId"] file:__FILE__ line:__LINE__ func:__func__];
            n--;
        }
        else
        {
            i++;
        }
    }
    ummutex_unlock(_retryQueueLock);
    *needsRetry1 = needsRetry;
    *hasExpired1 = hasExpired;

#ifdef DEBUG_LOGGING
    NSString *s = [NSString stringWithFormat:@"messagesNeedingRetrying returns %lu/%lu",needsRetry.count,hasExpired.count];
    LOG_TO_STDERR(s);
#endif

}

- (NSInteger)count
{
    NSInteger i;
    ummutex_lock(_retryQueueLock);
    i = [_retry_entries count];
    ummutex_unlock(_retryQueueLock);
    return i;
}

@end
