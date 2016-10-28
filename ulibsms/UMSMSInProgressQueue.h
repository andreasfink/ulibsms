//
//  UMSMSInProgressQueue.h
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
