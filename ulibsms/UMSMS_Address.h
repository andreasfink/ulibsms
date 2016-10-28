//
//  UMSMS_Address.h
//  ulibsms
//
//  Created by Andreas Fink on 01/08/16.
//
//

#import <ulib/ulib.h>
#import <ulibgsmmap/ulibgsmmap.h>

@interface UMSMS_Address : UMObject
{
    GSMMAP_TonType ton;
    GSMMAP_NpiType npi;
    NSString *address;
}

@property(readwrite,assign) GSMMAP_TonType ton;
@property(readwrite,assign) GSMMAP_NpiType npi;
@property(readwrite,strong) NSString *address;

- (UMSMS_Address *)initWithString:(NSString *)addr;
- (UMSMS_Address *)initWithAddress:(NSString *)msisdn ton:(GSMMAP_TonType)xton npi:(GSMMAP_NpiType)xnpi;
- (NSData *)encoded;

@end
