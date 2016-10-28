//
//  UMLayerSMS.m
//  ulibsms
//
//  Created by Andreas Fink on 01/07/15.
//  Copyright (c) 2016 Andreas Fink
//

#import "UMLayerSMS.h"
#import "UMSMSInProgressQueue.h"
#import "UMSMSWaitingQueue.h"
#import "UMSMSRetryQueue.h"
#import "UMHLRCache.h"

@implementation UMLayerSMS

@synthesize waitingQueue;
@synthesize inProgressQueue;
@synthesize retryQueue;
@synthesize smscNumber;
@synthesize mapInstance;
@synthesize hlrCache;

- (UMLayerSMS *)init
{
    self = [super init];
    if(self)
    {
        [self genericInitialisation];
    }
    return self;
}

- (void)genericInitialisation
{
    waitingQueue    = [[UMSMSWaitingQueue alloc]init];
    inProgressQueue = [[UMSMSInProgressQueue  alloc]init];
    retryQueue      = [[UMSMSRetryQueue alloc]init];
    hlrCache        = [[UMHLRCache alloc]init];
}

- (UMLayerSMS *)initWithTaskQueueMulti:(UMTaskQueueMulti *)tq
{
    self = [super initWithTaskQueueMulti:tq];
    if(self)
    {
        [self genericInitialisation];
    }
    return self;
}

@end
