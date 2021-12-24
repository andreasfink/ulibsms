//
//  UMGlobalMessageCacheEntry.m
//  ulibsms
//
//  Copyright © 2017 Andreas Fink (andreas@fink.org). All rights reserved.
//
// This source is dual licensed either under the GNU GENERAL PUBLIC LICENSE
// Version 3 from 29 June 2007 and other commercial licenses available by
// the author.
//

#import "UMGlobalMessageCacheEntry.h"

@implementation UMGlobalMessageCacheEntry

- (UMGlobalMessageCacheEntry *)init
{
    self = [super init];
    if(self)
    {
        [self touch];
    }
    return self;
}

- (void)touch
{
    _keepInCacheUntil = [NSDate dateWithTimeIntervalSinceNow:61*60];
}

@end
