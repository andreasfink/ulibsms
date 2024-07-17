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

#import <ulibsms/UMGlobalMessageCache.h>
#import <ulibsms/UMGlobalMessageCacheEntry.h>

@implementation UMGlobalMessageCache

- (UMGlobalMessageCache *)init
{
    self = [super init];
    if(self)
    {
        _cache = [[NSMutableDictionary alloc]init];
        _globalMessageCacheLock =[[UMMutex alloc]initWithName:@"UMGlobalMessageCache"];
    }
    return self;
}

- (void)retainMessage:(id)msg forMessageId:(NSString *)messageId file:(const char *)file line:(long)line func:(const char *)func
{
    ummutex_lock(_globalMessageCacheLock);
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
    ummutex_unlock(_globalMessageCacheLock);
}

- (void)retainMessage:(id)msg forMessageId:(NSString *)messageId
{
    ummutex_lock(_globalMessageCacheLock);
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
    ummutex_unlock(_globalMessageCacheLock);
}

- (void)releaseMessage:(id)msg forMessageId:(NSString *)messageId file:(const char *)file line:(long)line func:(const char *)func
{
    ummutex_lock(_globalMessageCacheLock);
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
    ummutex_unlock(_globalMessageCacheLock);

}

- (void)releaseMessage:(id)msg forMessageId:(NSString *)messageId
{
    ummutex_lock(_globalMessageCacheLock);
    UMGlobalMessageCacheEntry *entry = _cache[messageId];
    if(entry)
    {
        entry.cacheRetainCounter = entry.cacheRetainCounter - 1;
        if(entry.cacheRetainCounter<1)
        {
            [_cache removeObjectForKey:messageId];
        }
    }
    ummutex_unlock(_globalMessageCacheLock);

}

- (id)findEntry:(NSString *)messageId
{
    ummutex_lock(_globalMessageCacheLock);
    UMGlobalMessageCacheEntry *entry = _cache[messageId];
    ummutex_unlock(_globalMessageCacheLock);
    return entry;
}

- (id)findMessage:(NSString *)messageId
{
    ummutex_lock(_globalMessageCacheLock);
    UMGlobalMessageCacheEntry *entry = _cache[messageId];
    ummutex_unlock(_globalMessageCacheLock);
    return entry.msg;
}

- (void)logEvent:(NSString *)event messageId:(NSString *)messageId
{
    if(_flog)
    {
        ummutex_lock(_globalMessageCacheLock);
        NSString *logLine = [NSString stringWithFormat:@"MessageCache: %@ %@",messageId,event];
        NSLog(@"%@",logLine);
        fprintf(_flog,"%s\n",logLine.UTF8String);
        fflush(_flog);
        ummutex_unlock(_globalMessageCacheLock);
    }
}

- (void)openLog:(NSString *)logfilename
{
    ummutex_lock(_globalMessageCacheLock);
    if(_flog)
    {
        fclose(_flog);
        _flog = NULL;
    }
    _flog = fopen(logfilename.UTF8String,"w+");
    fprintf(_flog,"open log\n");
    fflush(_flog);
    ummutex_unlock(_globalMessageCacheLock);

}

- (void)closeLog
{
    ummutex_lock(_globalMessageCacheLock);
    if(_flog)
    {
        fclose(_flog);
        _flog = NULL;
    }
    ummutex_unlock(_globalMessageCacheLock);

}

-(void)flush
{
    ummutex_lock(_globalMessageCacheLock);
    _cache = [[NSMutableDictionary alloc]init];
    ummutex_unlock(_globalMessageCacheLock);

}

- (NSInteger)count
{
    NSInteger i;
    ummutex_lock(_globalMessageCacheLock);
    i = _cache.count;
    ummutex_unlock(_globalMessageCacheLock);
    return i;
}


- (NSArray *)expiredMessages
{
    ummutex_lock(_globalMessageCacheLock);
    NSArray *messageIds = [_cache allKeys];
    NSDate *now = [NSDate date];
    NSMutableArray *expiredMessages = [[NSMutableArray alloc]init];
    for(NSString *msgId in messageIds)
    {
        
        id<UMMessageCacheMessageProtocol> msg = [self findMessage:msgId];
        UMGlobalMessageCacheEntry *entry = _cache[msgId];
        if([entry.keepInCacheUntil compare:now] == NSOrderedAscending)
        {
            [expiredMessages addObject:msg];
            [self releaseMessage:msg forMessageId:msgId];
        }
    }
    ummutex_unlock(_globalMessageCacheLock);
    return expiredMessages;
}

- (void) flushAll
{
    ummutex_lock(_globalMessageCacheLock);
    _cache = [[NSMutableDictionary alloc]init];
    ummutex_unlock(_globalMessageCacheLock);
}

@end

