//
//  UMSMSWaitingQueue.m
//  ulibsms
//
//  Copyright © 2017 Andreas Fink (andreas@fink.org). All rights reserved.
//
// This source is dual licensed either under the GNU GENERAL PUBLIC LICENSE
// Version 3 from 29 June 2007 and other commercial licenses available by
// the author.
//
#import "UMSMSWaitingQueue.h"
#import "UMGlobalMessageCache.h"

//#define DEBUG_LOGGING    1


@implementation UMSMSWaitingQueue

- (UMSMSWaitingQueue *)init
{
    self = [super init];
    if(self)
    {
        _numbersInProgress = [[UMSynchronizedDictionary alloc]init];
        _waitingQueueLock = [[UMMutex alloc]initWithName:@"sms-waiting-queue"];
        _awaitNumberFreeTime = 6.0;
    }
    return self;
}

- (BOOL)isTransactionToNumberInProgress:(NSString *)number
{
    BOOL returnValue = NO;
    @autoreleasepool
    {
        [_waitingQueueLock lock];
    #ifdef DEBUG_LOGGING
        NSLog(@"waitingQueue isTransactionToNumberInProgress:%@",number);
    #endif
        UMQueueSingle *transactionsOfNumber = _numbersInProgress[number];
        if([transactionsOfNumber count]>0)
        {
            returnValue = YES;
        }
        [_waitingQueueLock unlock];
    }
    return returnValue;
}

- (void)queueTransaction:(id<UMSMSTransactionProtocol>)transaction
               forNumber:(NSString *)number
{
    @autoreleasepool
    {
        [_waitingQueueLock lock];
#ifdef DEBUG_LOGGING
    NSLog(@"waitingQueue queueTransaction:%@ forNumber:%@",transaction,number);
#endif
        UMQueueSingle *transactionsOfNumber = _numbersInProgress[number];
        if(transactionsOfNumber == NULL)
        {
            transactionsOfNumber = [[UMQueueSingle alloc]init];
        }
        transaction.awaitNumberFreeExpiration = [NSDate dateWithTimeIntervalSinceNow:_awaitNumberFreeTime];
        [transactionsOfNumber append:transaction];
        _numbersInProgress[number] = transactionsOfNumber;
        [_messageCache retainMessage:transaction.msg forMessageId:transaction.messageId file:__FILE__ line:__LINE__ func:__FUNCTION__];
        [_waitingQueueLock unlock];
    }
}

- (id<UMSMSTransactionProtocol>)getNextTransactionForNumber:(NSString *)number
{
    id<UMSMSTransactionProtocol> transaction = NULL;
    @autoreleasepool
    {
        [_waitingQueueLock lock];
#ifdef DEBUG_LOGGING
    NSLog(@"waitingQueue getNextTransactionForNumber:%@",number);
#endif

        UMQueueSingle *transactionsOfNumber = _numbersInProgress[number];
        if(transactionsOfNumber == NULL)
        {
#ifdef DEBUG_LOGGING
            NSLog(@"  return NULL");
#endif
        }
        else
        {
            transaction = [transactionsOfNumber getFirst];
            [_messageCache releaseMessage:transaction.msg forMessageId:transaction.messageId file:__FILE__ line:__LINE__ func:__FUNCTION__];
            if([transactionsOfNumber count]<1)
            {
                [_numbersInProgress removeObjectForKey:number];
            }
            else
            {
                _numbersInProgress[number] = transactionsOfNumber;
            }
        }
#ifdef DEBUG_LOGGING
        NSLog(@"  returning %@",transaction);
#endif
        [_waitingQueueLock unlock];
    }
    return transaction;
}

- (NSInteger)count
{
    NSInteger count = 0;
    [_waitingQueueLock unlock];
    count =  [_numbersInProgress count];
    [_waitingQueueLock unlock];
    return count;
}


- (NSArray <NSString *> *)overdueNumbers
{
    id<UMSMSTransactionProtocol> transaction = NULL;

    NSMutableArray *result = [[NSMutableArray alloc]init];
    @autoreleasepool
    {
        [_waitingQueueLock lock];
        NSArray *allNumbers = [_numbersInProgress allKeys];
        for(NSString *msisdn in allNumbers)
        {
            UMQueueSingle *transactionsOfNumber = _numbersInProgress[msisdn];
            transaction = [transactionsOfNumber peekFirst];
            if([transaction isExpired])
            {
                [result addObject:msisdn];
            }
        }
        [_waitingQueueLock unlock];
    }
    return result;
}
@end
