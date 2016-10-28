//
//  UMSMSWaitingQueue.h
//  ulibsms
//
//  © 2016  by Andreas Fink
//
// This source is dual licensed either under the GNU GENERAL PUBLIC LICENSE
// Version 3 from 29 June 2007 and other commercial licenses available by
// the author.
//
#import <ulib/ulib.h>
#import "UMSMSTransactionProtocol.h"


@interface UMSMSWaitingQueue : UMObject
{
    UMSynchronizedDictionary *numbersInProgress;
}

- (BOOL)isTransactionToNumberInProgress:(NSString *)number;
- (void)queueTransaction:(id<UMSMSTransactionProtocol>)transaction forNumber:(NSString *)number;
- (id<UMSMSTransactionProtocol>)getNextTransactionForNumber:(NSString *)number;

@end
