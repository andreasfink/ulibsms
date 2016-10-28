//
//  UMSMSTransactionProtocol.h
//  ulibsms
//
//  Created by Andreas Fink on 02/07/15.
//  Copyright (c) 2016 Andreas Fink
//

#import <ulib/ulib.h>

@protocol UMSMSTransactionProtocol<NSObject>

- (NSString *)destinationNumber;
- (NSString *)messageId;
- (id) msg;
- (void) expireAction;
- (BOOL) isExpired;
- (NSDictionary *)checkForTasks;   /* checks for timers etc and returns a dictionay of actions to do, No actions = NULL */

@end
