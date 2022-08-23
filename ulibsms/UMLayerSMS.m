//
//  UMLayerSMS.m
//  ulibsms
//
//  Copyright © 2017 Andreas Fink (andreas@fink.org). All rights reserved.
//
// This source is dual licensed either under the GNU GENERAL PUBLIC LICENSE
// Version 3 from 29 June 2007 and other commercial licenses available by
// the author.
//
#import "UMLayerSMS.h"
#import "UMSMSInProgressQueue.h"
#import "UMSMSWaitingQueue.h"
#import "UMSMSRetryQueue.h"
#import "UMHLRCache.h"
#import "UMGlobalMessageCache.h"

@implementation UMLayerSMS


- (UMLayerSMS *)initWithMessageCache:(UMGlobalMessageCache *)cache
{
    self = [super initWithoutExecutionQueue:@"UMLayerSMS"];
    if(self)
    {
        [self genericInitialisation];
    }
    return self;
}

- (void)genericInitialisation
{
    _waitingQueue    = [[UMSMSWaitingQueue alloc]init];
    _inProgressQueue = [[UMSMSInProgressQueue  alloc]init];
    _retryQueue      = [[UMSMSRetryQueue alloc]init];
    _hlrCache        = [[UMHLRCache alloc]init];
    if(_layerHistory==NULL)
    {
        _layerHistory    = [[UMHistoryLog alloc]initWithMaxLines:1000];
    }
}

- (UMLayerSMS *)initWithoutExecutionQueue:(NSString *)name
{
    self = [super initWithoutExecutionQueue:name];
    if(self)
    {
        [self genericInitialisation];
    }
    return self;
}

- (UMLayerSMS *)initWithTaskQueueMulti:(UMTaskQueueMulti *)tq
                                  name:(NSString *)name
{
    NSString *s = [NSString stringWithFormat:@"sms/%@",name];

    self = [super initWithTaskQueueMulti:tq name:s];
    if(self)
    {
        [self genericInitialisation];
    }
    return self;
}

@end
