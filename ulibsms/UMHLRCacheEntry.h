//
//  UMHLRCacheEntry.h
//  ulibsms
//
//  Created by Andreas Fink on 06/07/15.
//  Copyright (c) 2016 Andreas Fink
//

#import <ulib/ulib.h>

@interface UMHLRCacheEntry : UMObject
{
    NSString *msisdn;
    NSString *msc;
    NSString *imsi;
    NSString *hlr;
    time_t  expires;
}


@property(readwrite,strong) NSString *msisdn;
@property(readwrite,strong) NSString *msc;
@property(readwrite,strong) NSString *imsi;
@property(readwrite,strong) NSString *hlr;
@property(readwrite,assign) time_t  expires;

@end
