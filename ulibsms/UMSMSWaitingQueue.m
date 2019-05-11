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
        numbersInProgress = [[UMSynchronizedDictionary alloc]init];
    }
    return self;
}

- (BOOL)isTransactionToNumberInProgress:(NSString *)number
{
#ifdef DEBUG_LOGGING
    NSLog(@"waitingQueue isTransactionToNumberInProgress:%@",number);
#endif
    @synchronized(numbersInProgress)
    {
        UMSynchronizedArray *transactionsOfNumber = numbersInProgress[number];
        if([transactionsOfNumber count]>0)
        {
            return YES;
        }
        return NO;
    }
}

- (void)queueTransaction:(id<UMSMSTransactionProtocol>)transaction
               forNumber:(NSString *)number
{
#ifdef DEBUG_LOGGING
    NSLog(@"waitingQueue queueTransaction:%@ forNumber:%@",transaction,number);
#endif

    @synchronized(numbersInProgress)
    {
        UMQueue *transactionsOfNumber = numbersInProgress[number];
        if(transactionsOfNumber == NULL)
        {
            transactionsOfNumber = [[UMQueue alloc]init];
        }
        [transactionsOfNumber append:transaction];
        numbersInProgress[number] = transactionsOfNumber;
        
        [_messageCache retainMessage:transaction.msg forMessageId:transaction.messageId file:__FILE__ line:__LINE__ func:__FUNCTION__];

    }
}

- (id<UMSMSTransactionProtocol>)getNextTransactionForNumber:(NSString *)number
{
#ifdef DEBUG_LOGGING
    NSLog(@"waitingQueue getNextTransactionForNumber:%@",number);
#endif

    @synchronized(numbersInProgress)
    {
        UMQueue *transactionsOfNumber = numbersInProgress[number];
        if(transactionsOfNumber == NULL)
        {
#ifdef DEBUG_LOGGING
            NSLog(@"  return NULL");
#endif

            return NULL;
        }
        id<UMSMSTransactionProtocol> transaction = [transactionsOfNumber getFirst];
        [_messageCache releaseMessage:transaction.msg forMessageId:transaction.messageId file:__FILE__ line:__LINE__ func:__FUNCTION__];

        if([transactionsOfNumber count]<1)
        {
            [numbersInProgress removeObjectForKey:number];
        }
        else
        {
            numbersInProgress[number] = transactionsOfNumber;
        }
#ifdef DEBUG_LOGGING
        NSLog(@"  return %@",transaction);
#endif
        return transaction;
    }
}

- (NSInteger)count
{
    @synchronized(numbersInProgress)
    {
        return [numbersInProgress count];
    }
}

@end
