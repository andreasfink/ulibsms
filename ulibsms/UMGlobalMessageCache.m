//
//  UMGlobalMessageCache.m
//  ulibsms
//
//  Copyright © 2017 Andreas Fink (andreas@fink.org). All rights reserved.
//
// This source is dual licensed either under the GNU GENERAL PUBLIC LICENSE
// Version 3 from 29 June 2007 and other commercial licenses available by
// the author.
//

#import "UMGlobalMessageCache.h"
#import "UMGlobalMessageCacheEntry.h"

@implementation UMGlobalMessageCache

- (UMGlobalMessageCache *)init
{
    self = [super init];
    if(self)
    {
        _cache = [[NSMutableDictionary alloc]init];
        _lock =[[UMMutex alloc]initWithName:@"UMGlobalMessageCache"];
    }
    return self;
}

- (void)retainMessage:(id)msg forMessageId:(NSString *)messageId file:(const char *)file line:(long)line func:(const char *)func
{
    [_lock lock];
    UMGlobalMessageCacheEntry *entry = _cache[messageId];
    if(entry == NULL)
    {
        entry = [[UMGlobalMessageCacheEntry alloc]init];
        entry.messageId = messageId;
        entry.msg = msg;
        entry.cacheRetainCounter = 1;
        [self logEvent:[NSString stringWithFormat:@"retain 0->1 %s:%ld %s",file,line,func] messageId:messageId];

    }
    else
    {
        //UMAssert(msg == entry.msg,@"two messages with same ID??");
        entry.cacheRetainCounter = entry.cacheRetainCounter + 1;
        [entry touch];
        [self logEvent:[NSString stringWithFormat:@"retain %d->%d %s:%ld %s",entry.cacheRetainCounter-1,entry.cacheRetainCounter,file,line,func] messageId:messageId];
    }
    [entry touch];
    _cache[messageId]=entry;
    [_lock unlock];
}

- (void)retainMessage:(id)msg forMessageId:(NSString *)messageId
{
    [_lock lock];
    UMGlobalMessageCacheEntry *entry = _cache[messageId];
    if(entry == NULL)
    {
        entry = [[UMGlobalMessageCacheEntry alloc]init];
        entry.messageId = messageId;
        entry.msg = msg;
        entry.cacheRetainCounter = 1;
    }
    else
    {
        UMAssert(msg == entry.msg,@"two messages with same ID??");
        entry.cacheRetainCounter = entry.cacheRetainCounter + 1;
    }
    [entry touch];
    _cache[messageId]=entry;
    [_lock unlock];
}

- (void)releaseMessage:(id)msg forMessageId:(NSString *)messageId file:(const char *)file line:(long)line func:(const char *)func
{
    [_lock lock];
    UMGlobalMessageCacheEntry *entry = _cache[messageId];
    if(entry)
    {
        [self logEvent:[NSString stringWithFormat:@"release %d->%d %s:%ld %s",entry.cacheRetainCounter,entry.cacheRetainCounter-1,file,line,func] messageId:messageId];
        entry.cacheRetainCounter = entry.cacheRetainCounter - 1;
        if(entry.cacheRetainCounter<1)
        {
            [_cache removeObjectForKey:messageId];
        }
    }
    else
    {
        [self logEvent:[NSString stringWithFormat:@"not-found %s:%ld %s",file,line,func] messageId:messageId];
    }
    [_lock unlock];

}

- (void)releaseMessage:(id)msg forMessageId:(NSString *)messageId
{
    [_lock lock];
    UMGlobalMessageCacheEntry *entry = _cache[messageId];
    if(entry)
    {
        entry.cacheRetainCounter = entry.cacheRetainCounter - 1;
        if(entry.cacheRetainCounter<1)
        {
            [_cache removeObjectForKey:messageId];
        }
    }
    [_lock unlock];

}

- (id)findEntry:(NSString *)messageId
{
    [_lock lock];
    UMGlobalMessageCacheEntry *entry = _cache[messageId];
    [_lock unlock];
    return entry;
}

- (id)findMessage:(NSString *)messageId
{
    [_lock lock];
    UMGlobalMessageCacheEntry *entry = _cache[messageId];
    [_lock unlock];
    return entry.msg;
}

- (void)logEvent:(NSString *)event messageId:(NSString *)messageId
{
    if(_flog)
    {
        [_lock lock];
        NSString *logLine = [NSString stringWithFormat:@"MessageCache: %@ %@",messageId,event];
        NSLog(@"%@",logLine);
        fprintf(_flog,"%s\n",logLine.UTF8String);
        fflush(_flog);
        [_lock unlock];
    }
}

- (void)openLog:(NSString *)logfilename
{
    [_lock lock];
    if(_flog)
    {
        fclose(_flog);
        _flog = NULL;
    }
    _flog = fopen(logfilename.UTF8String,"w+");
    fprintf(_flog,"open log\n");
    fflush(_flog);
    [_lock unlock];

}

- (void)closeLog
{
    [_lock lock];
    if(_flog)
    {
        fclose(_flog);
        _flog = NULL;
    }
    [_lock unlock];

}

-(void)flush
{
    [_lock lock];
    _cache = [[NSMutableDictionary alloc]init];
    [_lock unlock];

}

- (NSInteger)count
{
    NSInteger i;
    [_lock lock];
    i = _cache.count;
    [_lock unlock];
    return i;
}


- (NSArray *)expiredMessages
{
    [_lock lock];
    NSArray *messageIds = [_cache allKeys];
    [_lock unlock];
    NSDate *now = [NSDate date];

    NSMutableArray *expiredMessages = [[NSMutableArray alloc]init];
    for(NSString *msgId in messageIds)
    {
        
        id<UMMessageCacheMessageProtocol> msg = [self findMessage:msgId];
        
        [_lock lock];
        UMGlobalMessageCacheEntry *entry = _cache[msgId];
        [_lock unlock];

        if(entry.keepInCacheUntil == NULL)
        {
            [entry touch];
        }
        if([now compare:entry.keepInCacheUntil] == NSOrderedDescending)
        {
            [expiredMessages addObject:msg];
            [self releaseMessage:msg forMessageId:msgId];
        }
    }
    return expiredMessages;
}

- (void) flushAll
{
    [_lock lock];
    _cache = [[NSMutableDictionary alloc]init];
    [_lock unlock];
}

@end

