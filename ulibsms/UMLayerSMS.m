//
//  UMLayerSMS.m
//  ulibsms
//
//  © 2016  by Andreas Fink
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
