//
//  UMSMSTransactionProtocol.h
//  ulibsms
//
//  Copyright © 2017 Andreas Fink (andreas@fink.org). All rights reserved.
//
// This source is dual licensed either under the GNU GENERAL PUBLIC LICENSE
// Version 3 from 29 June 2007 and other commercial licenses available by
// the author.
//
#import <ulib/ulib.h>

@protocol UMSMSTransactionProtocol<NSObject>

- (NSString *)destinationNumber;
- (NSString *)messageId;
- (id) msg;
- (void) expireAction;
- (BOOL) isExpired;
- (NSDate *)awaitNumberFreeExpiration;
- (void)setAwaitNumberFreeExpiration:(NSDate *)date;
- (NSDictionary *)checkForTasks;   /* checks for timers etc and returns a dictionay of actions to do, No actions = NULL */

@end
