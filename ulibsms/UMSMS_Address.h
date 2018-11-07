//
//  UMSMS_Address.h
//  ulibsms
//
//  Copyright © 2017 Andreas Fink (andreas@fink.org). All rights reserved.
//
// This source is dual licensed either under the GNU GENERAL PUBLIC LICENSE
// Version 3 from 29 June 2007 and other commercial licenses available by
// the author.
//
#import <ulib/ulib.h>
#import <ulibgsmmap/ulibgsmmap.h>

@interface UMSMS_Address : UMObject
{
    GSMMAP_TonType _ton;
    GSMMAP_NpiType _npi;
    NSString *_address;
}

@property(readwrite,assign) GSMMAP_TonType ton;
@property(readwrite,assign) GSMMAP_NpiType npi;
@property(readwrite,strong) NSString *address;

- (UMSMS_Address *)initWithAlpha:(NSString *)digits;
- (UMSMS_Address *)initWithString:(NSString *)addr;
- (UMSMS_Address *)initWithAddress:(NSString *)msisdn ton:(GSMMAP_TonType)xton npi:(GSMMAP_NpiType)xnpi;
- (NSData *)encoded;
- (NSString *)stringValue;

@end
