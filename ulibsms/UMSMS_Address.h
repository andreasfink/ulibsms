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
#import <ulibgsmmap/ulibgsmmap.h>


typedef    enum SMS_TonType
{
    SMS_TON_UNKNOWN              = 0,
    SMS_TON_INTERNATIONAL         = 1,
    SMS_TON_NATIONAL             = 2,
    SMS_TON_NETWORK_SPECIFIC     = 3,
    SMS_TON_SUBSCRIBER             = 4,
    SMS_TON_ALPHANUMERIC         = 5,
    SMS_TON_ABBREVIATED            = 6,
    SMS_TON_RESERVED             = 7,
    SMS_TON_IMSI                 = 100,
    SMS_TON_URL                    = 101,
    SMS_TON_EMAIL                 = 102,
    SMS_TON_POINTCODE            = 103,
    SMS_TON_EMPTY                = 104,
    SMS_TON_MISSING              = 105,
    SMS_TON_EMPTY2               = 106,
    SMS_TON_EMPTY3               = 103,

} SMS_TonType;

typedef enum SMS_NpiType
{
    SMS_NPI_UNKNOWN                = 0,
    SMS_NPI_ISDN_E164            = 1,
    SMS_NPI_GENERIC              = 2,
    SMS_NPI_DATA_X121            = 3,         /* was 2 */
    SMS_NPI_TELEX                 = 4,         /* was 3 */
    SMS_NPI_E212                 = 6, /* imsi */
    SMS_NPI_E214                 = 7, /* mgt */
    SMS_NPI_NATIONAL             = 8,
    SMS_NPI_PRIVATE                = 9,
    SMS_NPI_ERMES                 = 10,
    SMS_NPI_RESERVED             = 15,
    SMS_NPI_IMSI                 = 100,
    SMS_NPI_INTERNET             = 101,
    SMS_NPI_POINTCODE            = 103,
} SMS_NpiType;

@interface UMSMS_Address : UMObject
{
    SMS_TonType _ton;
    SMS_NpiType _npi;
    NSString *_address;
}

@property(readwrite,assign) SMS_TonType ton;
@property(readwrite,assign) SMS_NpiType npi;
@property(readwrite,strong) NSString *address;

- (UMSMS_Address *)initWithAlpha:(NSString *)digits;
- (UMSMS_Address *)initWithString:(NSString *)addr;
- (UMSMS_Address *)initWithAddress:(NSString *)msisdn ton:(SMS_TonType)xton npi:(SMS_NpiType)xnpi;
- (NSData *)encoded;
- (NSString *)stringValue;

@end
