//
//  UMSMSInProgressQueue.h
//  ulibsms
//
//  Created by Andreas Fink on 02/07/15.
//  Copyright (c) 2016 Andreas Fink
//

#import <ulib/ulib.h>
#import "UMSMSTransactionProtocol.h"

@interface UMSMSInProgressQueue : UMObject
{
    UMSynchronizedDictionary *dictById;
    UMSynchronizedDictionary *dictByNumber;
}

- (void) add:(UMObject<UMSMSTransactionProtocol> *)transaction;
- (void) remove:(UMObject<UMSMSTransactionProtocol> *)transaction;
- (void) removeId:(NSString *)msgid destinationNumber:(NSString *)number;
- (id) findTransactionById:(NSString *)msgid;
- (id) findTransactionByNumber:(NSString *)number;
- (BOOL) hasExistingTransactionTo:(NSString *)number;
- (NSArray *)expiredTransactions;
- (NSArray *) checkForTasks;
- (NSUInteger)count;
@end
