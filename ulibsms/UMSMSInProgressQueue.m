//
//  UMSMSInProgressQueue.m
//  ulibsms
//
//  © 2016  by Andreas Fink
//
// This source is dual licensed either under the GNU GENERAL PUBLIC LICENSE
// Version 3 from 29 June 2007 and other commercial licenses available by
// the author.
//

#import <ulib/ulib.h>
#import "UMSMSInProgressQueue.h"
#import "UMGlobalMessageCache.h"


//#define DEBUG_LOGGING   1

@implementation UMSMSInProgressQueue

- (UMSMSInProgressQueue *)init
{
    self = [super init];
    if(self)
    {
        dictById = [[UMSynchronizedDictionary alloc]init];
        dictByNumber = [[UMSynchronizedDictionary alloc]init];
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
        dictById[msgid] = transaction;
        dictByNumber[number] = transaction;  
        [[UMGlobalMessageCache sharedInstance]retainMessage:transaction.msg forMessageId:msgid file:__FILE__ line:__LINE__ func:__FUNCTION__];
    }
}

- (void) remove:(UMObject<UMSMSTransactionProtocol> *)transaction
{
//    UMAssert(transaction!=NULL,@"you ask me to remove a NULL transaction!");
#ifdef DEBUG_LOGGING
    NSLog(@"inProgressQueue remove:%@",transaction);
#endif

    @synchronized(self)
    {
        [dictById removeObjectForKey:transaction.messageId];
        [dictByNumber removeObjectForKey:transaction.destinationNumber];
        [[UMGlobalMessageCache sharedInstance]releaseMessage:transaction.msg forMessageId:transaction.messageId file:__FILE__ line:__LINE__ func:__FUNCTION__];
    }
}


- (void) removeId:(NSString *)msgid destinationNumber:(NSString *)number
{
#ifdef DEBUG_LOGGING
    NSLog(@"inProgressQueue removeId:%@ destinationNumber:%@",msgid,number);
#endif
    @synchronized(self)
    {
        id msg = [[UMGlobalMessageCache sharedInstance] findMessage:msgid];
        if(msg)
        {
            [[UMGlobalMessageCache sharedInstance]releaseMessage:msg forMessageId:msgid file:__FILE__ line:__LINE__ func:__FUNCTION__];
            [dictById removeObjectForKey:msgid];
            [dictByNumber removeObjectForKey:number];
        }
    }
}


- (id) findTransactionById:(NSString *)msgid
{
#ifdef DEBUG_LOGGING
    NSLog(@"inProgressQueue findTransactionById:%@",msgid);
#endif

    @synchronized(self)
    {
        id t= dictById[msgid];
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
        return t;
    }
    return NULL;
}

- (id) findTransactionByNumber:(NSString *)number
{
#ifdef DEBUG_LOGGING
    NSLog(@"inProgressQueue findTransactionByNumber:%@",number);
#endif

    @synchronized(self)
    {
        id t = dictByNumber[number];
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
        return t;
    }
}

-(BOOL)hasExistingTransactionTo:(NSString *)number
{
#ifdef DEBUG_LOGGING
    NSLog(@"inProgressQueue hasExistingTransactionTo:%@",number);
#endif
@synchronized(self)
    {
        id t = [self findTransactionByNumber:number];
        if(t)
        {
#ifdef DEBUG_LOGGING
            NSLog(@"  YES");
#endif
            return YES;
        }
#ifdef DEBUG_LOGGING
        NSLog(@"  NO");
#endif
    }
    return NO;
}

- (NSArray *) expiredTransactions
{
    NSMutableArray *expiredObjects = [[NSMutableArray alloc]init];
    @synchronized(self)
    {
        NSArray *keys = [dictById allKeys];
        for (NSString *key in keys)
        {
            UMObject<UMSMSTransactionProtocol> *transaction = dictById[key];
            if([transaction isExpired])
            {
                [expiredObjects addObject:transaction];
#ifdef DEBUG_LOGGING
                NSLog(@"inProgressQueue expiredTransaction %@",transaction);
#endif

                [dictById removeObjectForKey:transaction.messageId];
                [dictByNumber removeObjectForKey:transaction.destinationNumber];
                [[UMGlobalMessageCache sharedInstance]releaseMessage:transaction.msg forMessageId:transaction.messageId file:__FILE__ line:__LINE__ func:__FUNCTION__];

            }
        }
    }
    return expiredObjects;
}

- (NSArray *) checkForTasks
{
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    @synchronized(self)
    {
        NSArray *keys = [dictById allKeys];
        for (NSString *key in keys)
        {
            UMObject<UMSMSTransactionProtocol> *transaction = dictById[key];
            NSDictionary *dict = [transaction checkForTasks];
            if(dict)
            {
#ifdef DEBUG_LOGGING
                NSLog(@"inProgressQueue check for tasks %@",dict);
#endif

                [arr addObject:dict];
            }
        }
    }
    return arr;
}

- (NSUInteger)count
{
    NSInteger i;
    @synchronized (self)
    {
        i = dictById.count;
    }
    return i;
}

@end
