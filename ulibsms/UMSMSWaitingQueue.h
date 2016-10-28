//
//  UMSMSWaitingQueue.h
//  ulibsms
//
//  Created by Andreas Fink on 02/07/15.
//  Copyright (c) 2016 Andreas Fink
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
