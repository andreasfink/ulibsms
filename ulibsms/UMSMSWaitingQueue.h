//
//  UMSMSWaitingQueue.h
//  ulibsms
//
//  Copyright © 2017 Andreas Fink (andreas@fink.org). All rights reserved.
//
// This source is dual licensed either under the GNU GENERAL PUBLIC LICENSE
// Version 3 from 29 June 2007 and other commercial licenses available by
// the author.
//
#import <ulib/ulib.h>
#import "UMSMSTransactionProtocol.h"

@class UMGlobalMessageCache;

@interface UMSMSWaitingQueue : UMObject
{
    UMSynchronizedDictionary    *_numbersInProgress;
    UMGlobalMessageCache        *_messageCache;
    UMMutex                     *_lock;
}
@property (readwrite,strong)    UMGlobalMessageCache    *messageCache;

- (BOOL)isTransactionToNumberInProgress:(NSString *)number;
- (void)queueTransaction:(id<UMSMSTransactionProtocol>)transaction
               forNumber:(NSString *)number;

- (id<UMSMSTransactionProtocol>)getNextTransactionForNumber:(NSString *)number;
- (NSInteger)count;
@end
