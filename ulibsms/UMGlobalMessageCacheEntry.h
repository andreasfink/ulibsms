//
//  UMGlobalMessageCacheEntry.h
//  ulibsms
//
//  Created by Andreas Fink on 06/07/15.
//  Copyright (c) 2016 Andreas Fink
//

#import <ulib/ulib.h>

@interface UMGlobalMessageCacheEntry : UMObject
{
    NSString    *messageId;
    id          msg;
    int         retainCounter;
}

@property(readwrite,strong) NSString   *messageId;
@property(readwrite,strong) id          msg;
@property(readwrite,assign) int         retainCounter;


@end
