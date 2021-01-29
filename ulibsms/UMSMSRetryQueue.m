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

#import "UMSMSRetryQueue.h"
#import "UMGlobalMessageCache.h"

#define DEBUG_LOGGING    1

@implementation UMSMSRetryQueue

-(UMSMSRetryQueue *)init
{
    self = [super init];
    if(self)
    {
        _retry_entries = [[NSMutableArray alloc]init];
        _lock = [[UMMutex alloc]initWithName:@"UMSMSRetryQueue"];
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
    NSLog(@"retryQueue queueForRetry:%@ retryTime: %@ expireTime:%@ priority: %d", messageId,next_consideration,last_considersation,priority);
#endif
    [_lock lock];
    NSDictionary *entry = @{ @"msg":msg,
                             @"messageId" : messageId,
                             @"retry-time":next_consideration,
                             @"expire-time":last_considersation,
                             @"priority":  @(priority),
                             };
    [_messageCache retainMessage:msg forMessageId:messageId file:__FILE__ line:__LINE__ func:__FUNCTION__];
    [_retry_entries addObject:entry];
    [_lock unlock];
}

- (void)messagesNeedingRetrying:(NSArray **)needsRetry1 orExpiring:(NSArray **)hasExpired1
{
    UMAssert(needsRetry1, @"needsRetry is pointing to NULL");
    UMAssert(hasExpired1, @"hasExpired is pointing to NULL");
    
    NSDate *now = [NSDate date];
    NSMutableArray *needsRetry = [[NSMutableArray alloc]init];
    NSMutableArray *hasExpired = [[NSMutableArray alloc]init];

    [_lock lock];
    NSUInteger n =[_retry_entries count];
    for(NSUInteger i=0;i<n; )
    {
        NSDictionary *entry = _retry_entries[i];
        NSDate *retryTime = entry[@"retry-time"];
        NSDate *expireTime = entry[@"expire-time"];
        if(retryTime.timeIntervalSinceReferenceDate < now.timeIntervalSinceReferenceDate)
        {
#ifdef DEBUG_LOGGING
            NSLog(@"retryQueue messagesNeedingRetrying:%@",entry[@"messageId"]);
#endif

            [needsRetry addObject:entry[@"msg"]];
            [_retry_entries removeObjectAtIndex:i];
            [_messageCache releaseMessage:entry[@"msg"] forMessageId:entry[@"messageId"] file:__FILE__ line:__LINE__ func:__FUNCTION__];
            n--;
        }
        else if(expireTime.timeIntervalSinceReferenceDate <= now.timeIntervalSinceReferenceDate)
        {
            [hasExpired addObject:entry[@"msg"]];
            [_retry_entries removeObjectAtIndex:i];
            [_messageCache releaseMessage:entry[@"msg"] forMessageId:entry[@"messageId"] file:__FILE__ line:__LINE__ func:__FUNCTION__];
            n--;
        }
        else
        {
            i++;
        }
    }
    [_lock unlock];
    *needsRetry1 = needsRetry;
    *hasExpired1 = hasExpired;
}

- (NSInteger)count
{
    NSInteger i;
    [_lock unlock];
    i = [_retry_entries count];
    [_lock unlock];
    return i;
}

@end
