//
//  UMSMSInProgressQueue.h
//  ulibsms
//
//  Copyright © 2017 Andreas Fink (andreas@fink.org). All rights reserved.
//
// This source is dual licensed either under the GNU GENERAL PUBLIC LICENSE
// Version 3 from 29 June 2007 and other commercial licenses available by
// the author.
//
#import <ulib/ulib.h>
#import <ulibsms/UMSMSTransactionProtocol.h>

@class UMGlobalMessageCache;
@interface UMSMSInProgressQueue : UMObject
{
    NSMutableDictionary *_dictById;
    NSMutableDictionary *_dictByNumber;
    UMGlobalMessageCache *_messageCache;
    UMMutex             *_inProgressQueueLock;
}

@property(readwrite,strong) UMGlobalMessageCache *messageCache;

- (void) add:(UMObject<UMSMSTransactionProtocol> *)transaction;

- (void) remove:(UMObject<UMSMSTransactionProtocol> *)transaction;
- (void) removeId:(NSString *)msgid destinationNumber:(NSString *)number;
- (id) findTransactionById:(NSString *)msgid;
- (id) findTransactionByNumber:(NSString *)number;
- (BOOL) hasExistingTransactionTo:(NSString *)number;
- (BOOL) hasExistingTransactionTo:(NSString *)number notMessageId:(NSString *)currentMsgId;
- (NSArray *)expiredTransactions;
- (NSArray *) checkForTasks;
- (NSUInteger)count;
@end
