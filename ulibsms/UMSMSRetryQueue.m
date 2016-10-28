//
//  UMSMSRetryQueue.m
//  ulibsms
//
//  © 2016  by Andreas Fink
//
// This source is dual licensed either under the GNU GENERAL PUBLIC LICENSE
// Version 3 from 29 June 2007 and other commercial licenses available by
// the author.
//

#import "UMSMSRetryQueue.h"
#import "UMGlobalMessageCache.h"

//#define DEBUG_LOGGING    1

@implementation UMSMSRetryQueue

-(UMSMSRetryQueue *)init
{
    self = [super init];
    if(self)
    {
        retry_entries = [[NSMutableArray alloc]init];
    }
    return self;
}


-(void) queueForRetry:(id)msg
            messageId:(NSString *)messageId
            retryTime:(time_t) next_consideration
           expireTime:(time_t) last_considersation
             priority:(int) priority
{
#ifdef DEBUG_LOGGING
    NSString *retryTimeString  = UMTimeStampDTfromTime(next_consideration);
    NSString *expireTimeString = UMTimeStampDTfromTime(last_considersation);

    NSLog(@"retryQueue queueForRetry:%@ retryTime: %@ expireTime:%@ priority: %d", messageId,retryTimeString,expireTimeString,priority);
#endif

    @synchronized(self)
    {
        NSDictionary *entry = @{ @"msg":msg,
                                 @"messageId" : messageId,
                                 @"retry-time":[NSNumber numberWithLong:(long)next_consideration],
                                 @"expire-time":[NSNumber numberWithLong:(long)last_considersation],
                                 @"priority":  [NSNumber numberWithInt:priority],
                                 };
        [[UMGlobalMessageCache sharedInstance]retainMessage:msg forMessageId:messageId file:__FILE__ line:__LINE__ func:__FUNCTION__];

        [retry_entries addObject:entry];
    }
}

- (void)messagesNeedingRetrying:(NSArray **)needsRetry1 orExpiring:(NSArray **)hasExpired1
{
    UMAssert(needsRetry1, @"needsRetry is pointing to NULL");
    UMAssert(hasExpired1, @"hasExpired is pointing to NULL");
    
    time_t now;
    time(&now);

    NSMutableArray *needsRetry = [[NSMutableArray alloc]init];
    NSMutableArray *hasExpired = [[NSMutableArray alloc]init];
    @synchronized(self)
    {
        NSUInteger n =[retry_entries count];
        for(NSUInteger i=0;i<n; )
        {
            NSDictionary *entry = retry_entries[i];
            if([entry[@"retry-time"]longValue] < now)
            {
#ifdef DEBUG_LOGGING
                NSLog(@"retryQueue messagesNeedingRetrying:%@",entry[@"messageId"]);
#endif

                [needsRetry addObject:entry[@"msg"]];
                [retry_entries removeObjectAtIndex:i];
                [[UMGlobalMessageCache sharedInstance]releaseMessage:entry[@"msg"] forMessageId:entry[@"messageId"] file:__FILE__ line:__LINE__ func:__FUNCTION__];
                n--;
            }
            else if([entry[@"expire-time"]longValue] <= now)
            {
                [hasExpired addObject:entry[@"msg"]];
                [retry_entries removeObjectAtIndex:i];
                [[UMGlobalMessageCache sharedInstance]releaseMessage:entry[@"msg"] forMessageId:entry[@"messageId"] file:__FILE__ line:__LINE__ func:__FUNCTION__];
                n--;
            }
            else
            {
                i++;
            }
        }
    }
    *needsRetry1 = needsRetry;
    *hasExpired1 = hasExpired;
}

@end
