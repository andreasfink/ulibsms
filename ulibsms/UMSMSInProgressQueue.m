//
//  UMSMSInProgressQueue.m
//  ulibsms
//
//  Copyright © 2017 Andreas Fink (andreas@fink.org). All rights reserved.
//
// This source is dual licensed either under the GNU GENERAL PUBLIC LICENSE
// Version 3 from 29 June 2007 and other commercial licenses available by
// the author.
//

#import <ulib/ulib.h>
#import <ulibsms/UMSMSInProgressQueue.h>
#import <ulibsms/UMGlobalMessageCache.h>


//#define DEBUG_LOGGING   1

@implementation UMSMSInProgressQueue

- (UMSMSInProgressQueue *)init
{
    self = [super init];
    if(self)
    {
        _dictById     = [[NSMutableDictionary alloc]init];
        _dictByNumber = [[NSMutableDictionary alloc]init];
        _inProgressQueueLock = [[UMMutex alloc]initWithName:@"UMSMSInProgressQueue"];
    }
    return self;
}


- (void) add:(UMObject<UMSMSTransactionProtocol> *)transaction
{
#ifdef DEBUG_LOGGING
    NSLog(@"inProgressQueue add:%@",transaction);
#endif
    
    @synchronized(self)
    {
        NSString *msgid = transaction.messageId;
        NSString *number = transaction.destinationNumber;
        _dictById[msgid] = transaction;
        _dictByNumber[number] = transaction;
        [_messageCache retainMessage:transaction.msg forMessageId:msgid file:__FILE__ line:__LINE__ func:__FUNCTION__];
    }
}

- (void) remove:(UMObject<UMSMSTransactionProtocol> *)transaction
{
//    UMAssert(transaction!=NULL,@"you ask me to remove a NULL transaction!");
#ifdef DEBUG_LOGGING
    NSLog(@"inProgressQueue remove:%@",transaction);
#endif

    [_inProgressQueueLock lock];
    [_dictById removeObjectForKey:transaction.messageId];
    [_dictByNumber removeObjectForKey:transaction.destinationNumber];
    [_messageCache releaseMessage:transaction.msg forMessageId:transaction.messageId file:__FILE__ line:__LINE__ func:__FUNCTION__];
    [_inProgressQueueLock unlock];

}


- (void) removeId:(NSString *)msgid destinationNumber:(NSString *)number
{
#ifdef DEBUG_LOGGING
    NSLog(@"inProgressQueue removeId:%@ destinationNumber:%@",msgid,number);
#endif
    [_inProgressQueueLock lock];
    id msg = [_messageCache findMessage:msgid];
    if(msg)
    {
        [_messageCache releaseMessage:msg forMessageId:msgid file:__FILE__ line:__LINE__ func:__FUNCTION__];
        [_dictById removeObjectForKey:msgid];
        [_dictByNumber removeObjectForKey:number];
    }
    [_inProgressQueueLock unlock];
}


- (id) findTransactionById:(NSString *)msgid
{
#ifdef DEBUG_LOGGING
    NSLog(@"inProgressQueue findTransactionById:%@",msgid);
#endif

    [_inProgressQueueLock lock];
    id t= _dictById[msgid];
    if(t)
    {
#ifdef DEBUG_LOGGING
        NSLog(@"  found: %@",t);
#endif
    }
    else
    {
#ifdef DEBUG_LOGGING
        NSLog(@"  not found");
#endif 
    }
    [_inProgressQueueLock unlock];
    return t;

}

- (id) findTransactionByNumber:(NSString *)number
{
#ifdef DEBUG_LOGGING
    NSLog(@"inProgressQueue findTransactionByNumber:%@",number);
#endif

    [_inProgressQueueLock lock];
    id t = _dictByNumber[number];
    if(t)
    {
#ifdef DEBUG_LOGGING
        NSLog(@"  found: %@",t);
#endif
    }
    else
    {
#ifdef DEBUG_LOGGING
        NSLog(@"  not found");
#endif
    }
    [_inProgressQueueLock unlock];
    return t;
}

-(BOOL)hasExistingTransactionTo:(NSString *)number
{
    return [self hasExistingTransactionTo:number notMessageId:NULL];
}

-(BOOL)hasExistingTransactionTo:(NSString *)number notMessageId:(NSString *)currentMsgId
{
#ifdef DEBUG_LOGGING
    NSLog(@"inProgressQueue hasExistingTransactionTo:%@ notMessageId:%@",number,currentMsgId ? currentMsgId : @"NULL");
#endif

    [_inProgressQueueLock lock];
    BOOL returnValue = NO;
    id<UMSMSTransactionProtocol> t = [self findTransactionByNumber:number];
    if(t)
    {
        if([t.messageId isEqualToString:currentMsgId])
        {
            returnValue = NO;
        }
        else
        {
            returnValue = YES;
        }
    }
    [_inProgressQueueLock unlock];
    return returnValue;
}

- (NSArray *) expiredTransactions
{
    NSMutableArray *expiredObjects = [[NSMutableArray alloc]init];
    [_inProgressQueueLock lock];
    NSArray *keys = [_dictById allKeys];
    for (NSString *key in keys)
    {
        UMObject<UMSMSTransactionProtocol> *transaction = _dictById[key];
        if([transaction isExpired])
        {
            [expiredObjects addObject:transaction];
#ifdef DEBUG_LOGGING
            NSLog(@"inProgressQueue expiredTransaction %@",transaction);
#endif

            [_dictById removeObjectForKey:transaction.messageId];
            [_dictByNumber removeObjectForKey:transaction.destinationNumber];
            [_messageCache releaseMessage:transaction.msg forMessageId:transaction.messageId file:__FILE__ line:__LINE__ func:__FUNCTION__];

        }
    }
    [_inProgressQueueLock unlock];

    return expiredObjects;
}

- (NSArray *) checkForTasks
{
    NSMutableArray *arr = [[NSMutableArray alloc]init];

    [_inProgressQueueLock lock];

    NSArray *keys = [_dictById allKeys];
    for (NSString *key in keys)
    {
        UMObject<UMSMSTransactionProtocol> *transaction = _dictById[key];
        NSDictionary *dict = [transaction checkForTasks];
        if(dict)
        {
#ifdef DEBUG_LOGGING
            NSLog(@"inProgressQueue check for tasks %@",dict);
#endif
            [arr addObject:dict];
        }
    }
    [_inProgressQueueLock unlock];
    return arr;
}

- (NSUInteger)count
{
    NSInteger i;
    [_inProgressQueueLock lock];
    i = _dictById.count;
    [_inProgressQueueLock unlock];
    return i;
}

@end
