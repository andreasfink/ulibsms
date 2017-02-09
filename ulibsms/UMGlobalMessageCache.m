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

static UMGlobalMessageCache *_sharedObject;

@implementation UMGlobalMessageCache

+ (UMGlobalMessageCache *)sharedInstance
{
    if(_sharedObject)
    {
        return _sharedObject;
    }
    _sharedObject =[[UMGlobalMessageCache alloc]init];
    return _sharedObject;
}
- (UMGlobalMessageCache *)init
{
    self = [super init];
    if(self)
    {
        cache = [[UMSynchronizedDictionary alloc]init];
    }
    return self;
}

- (void)retainMessage:(id)msg forMessageId:(NSString *)messageId file:(const char *)file line:(long)line func:(const char *)func
{
    @synchronized(self)
    {
        UMGlobalMessageCacheEntry *entry = cache[messageId];
        if(entry == NULL)
        {
            entry = [[UMGlobalMessageCacheEntry alloc]init];
            entry.messageId = messageId;
            entry.msg = msg;
            entry.retainCounter = 1;
            [self logEvent:[NSString stringWithFormat:@"retain 0->1 %s:%ld %s",file,line,func] messageId:messageId];

        }
        else
        {
            UMAssert(msg == entry.msg,@"two messages with same ID??");
            entry.retainCounter = entry.retainCounter + 1;
            [self logEvent:[NSString stringWithFormat:@"retain %d->%d %s:%ld %s",entry.retainCounter-1,entry.retainCounter,file,line,func] messageId:messageId];
        }
        cache[messageId]=entry;
    }
}

- (void)retainMessage:(id)msg forMessageId:(NSString *)messageId
{
    @synchronized(self)
    {
        UMGlobalMessageCacheEntry *entry = cache[messageId];
        if(entry == NULL)
        {
            entry = [[UMGlobalMessageCacheEntry alloc]init];
            entry.messageId = messageId;
            entry.msg = msg;
            entry.retainCounter = 1;
        }
        else
        {
            UMAssert(msg == entry.msg,@"two messages with same ID??");
            entry.retainCounter = entry.retainCounter + 1;
        }
        cache[messageId]=entry;
    }
}

- (void)releaseMessage:(id)msg forMessageId:(NSString *)messageId file:(const char *)file line:(long)line func:(const char *)func
{
    @synchronized(self)
    {
        UMGlobalMessageCacheEntry *entry = cache[messageId];
        if(entry)
        {
            [self logEvent:[NSString stringWithFormat:@"release %d->%d %s:%ld %s",entry.retainCounter,entry.retainCounter-1,file,line,func] messageId:messageId];
            entry.retainCounter = entry.retainCounter - 1;
            if(entry.retainCounter<1)
            {
                [cache removeObjectForKey:messageId];
            }
        }
        else
        {
            [self logEvent:[NSString stringWithFormat:@"not-found %s:%ld %s",file,line,func] messageId:messageId];
        }
    }
}

- (void)releaseMessage:(id)msg forMessageId:(NSString *)messageId
{
    @synchronized(self)
    {
        UMGlobalMessageCacheEntry *entry = cache[messageId];
        if(entry)
        {
            entry.retainCounter = entry.retainCounter - 1;
            if(entry.retainCounter<1)
            {
                [cache removeObjectForKey:messageId];
            }
        }
    }
}

- (id)findMessage:(NSString *)messageId
{
    @synchronized(self)
    {
        UMGlobalMessageCacheEntry *entry = cache[messageId];
        if(entry)
        {
            return entry.msg;
        }
    }
    return NULL;
}

- (void)logEvent:(NSString *)event messageId:(NSString *)messageId
{
    if(flog)
    {
        NSString *logLine = [NSString stringWithFormat:@"MessageCache: %@ %@",messageId,event];
        NSLog(@"%@",logLine);
        fprintf(flog,"%s\n",logLine.UTF8String);
        fflush(flog);
    }
}

- (void)openLog:(NSString *)logfilename
{
    if(flog)
    {
        fclose(flog);
        flog = NULL;
    }
    flog = fopen(logfilename.UTF8String,"w+");
    fprintf(flog,"open log\n");
    fflush(flog);
}

- (void)closeLog
{
    if(flog)
    {
        fclose(flog);
        flog = NULL;
    }
}

@end
