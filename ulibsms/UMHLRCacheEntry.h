//
//  UMHLRCacheEntry.h
//  ulibsms
//
//  Copyright © 2017 Andreas Fink (andreas@fink.org). All rights reserved.
//
// This source is dual licensed either under the GNU GENERAL PUBLIC LICENSE
// Version 3 from 29 June 2007 and other commercial licenses available by
// the author.
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
