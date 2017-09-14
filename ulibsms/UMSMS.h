//
//  UMSMS.h
//  ulibsms
//
//  Copyright © 2017 Andreas Fink (andreas@fink.org). All rights reserved.
//
// This source is dual licensed either under the GNU GENERAL PUBLIC LICENSE
// Version 3 from 29 June 2007 and other commercial licenses available by
// the author.
//
#import <ulib/ulib.h>

#import "UMSMS_Address.h"

typedef enum UMSMS_MessageType
{
    UMSMS_MessageType_DELIVER = 0,
    UMSMS_MessageType_DELIVER_REPORT = 0,
    UMSMS_MessageType_SUBMIT = 1,
    UMSMS_MessageType_SUBMIT_REPORT = 1,
    UMSMS_MessageType_STATUS_REPORT =2,
    UMSMS_MessageType_COMMAND = 2,
    UMSMS_MessageType_RESERVED = 3,
} UMSMS_MessageType;

#define SMS_PARAM_UNDEFINED  -1

#define COMPRESS_UNDEF  SMS_PARAM_UNDEFINED
#define COMPRESS_OFF    0
#define COMPRESS_ON     1

#define MC_UNDEF   SMS_PARAM_UNDEFINED
#define MC_CLASS0  0
#define MC_CLASS1  1
#define MC_CLASS2  2
#define MC_CLASS3  3

#define MWI_UNDEF      SMS_PARAM_UNDEFINED
#define MWI_VOICE_ON   0
#define MWI_FAX_ON     1
#define MWI_EMAIL_ON   2
#define MWI_OTHER_ON   3
#define MWI_VOICE_OFF  4
#define MWI_FAX_OFF    5
#define MWI_EMAIL_OFF  6
#define MWI_OTHER_OFF  7

#define DC_UNDEF  SMS_PARAM_UNDEFINED
#define DC_7BIT   0
#define DC_8BIT   1
#define DC_UCS2   2


#define RPI_UNDEF  SMS_PARAM_UNDEFINED
#define RPI_OFF    0
#define RPI_ON     1

#define SMS_7BIT_MAX_LEN 160
#define SMS_8BIT_MAX_LEN 140
#define SMS_UCS2_MAX_LEN 70

@interface UMSMS : UMObject
{
    int tp_mti; /* message type */
    int tp_mms; /* more message to send */
    int tp_sri; /* status report qualifier: 0 report to SUBMIT, 1 = report to COMMAND */
    int tp_udhi; /*user data header indicator */
    int tp_rp; /* reply path */
    int tp_vpf; /* validity period present */
    int tp_srr; /* status report requested */
    int tp_pid; /* */
    int tp_dcs; /* data coding scheme */
    int tp_udl; /* user data length */
    int tp_udhlen; /*user data header length */
    int tp_mr; /* message refrence */
    int tp_rd; /* reject duplicates */
    int validity_time;
    int coding;
    int messageClass;
    int compress;
    int mwi_pdu;
    int tp_fcs; /* status cause */
    NSData *t_ud;
    NSData *t_udh;
    NSDictionary *udh_decoded;
    char scts[8];
    UMSMS_Address *tp_oa;
    UMSMS_Address *tp_da;
    NSData *t_content;
    int multipart_ref;
    int multipart_max;
    int multipart_current;
    int language_lock_table_number;
    int language_shift_table_number;
}

@property(readwrite,assign) int tp_mti; /* message type */
@property(readwrite,assign) int tp_mms; /* more message to send */
@property(readwrite,assign) int tp_sri; /* status report qualifier: 0 report to SUBMIT, 1 = report to COMMAND */
@property(readwrite,assign) int tp_udhi; /*user data header indicator */
@property(readwrite,assign) int tp_rp; /* reply path */
@property(readwrite,assign) int tp_vpf; /* validity period present */
@property(readwrite,assign) int tp_srr; /* status report requested */
@property(readwrite,assign) int tp_pid; /* */
@property(readwrite,assign) int tp_dcs; /* data coding scheme */
@property(readwrite,assign) int tp_udl; /* user data length */
@property(readwrite,assign) int tp_udhlen; /*user data header length */
@property(readwrite,assign) int tp_mr; /* message refrence */
@property(readwrite,assign) int tp_rd; /* reject duplicates */
@property(readwrite,assign) int validity_time;
@property(readwrite,assign) int coding;
@property(readwrite,assign) int messageClass;
@property(readwrite,assign) int compress;
@property(readwrite,assign) int mwi_pdu;
@property(readwrite,assign) int tp_fcs; /* status cause */
@property(readwrite,strong) NSData *t_ud;
@property(readwrite,strong) NSData *t_udh;
@property(readwrite,strong) NSDictionary *udh_decoded;
@property(readwrite,strong) UMSMS_Address *tp_oa;
@property(readwrite,strong) UMSMS_Address *tp_da;
@property(readwrite,strong) NSData *t_content;
@property(readwrite,strong) NSString *tp_mti_string;

+ (NSData *) decode7bituncompressed:(NSData *)input len:(NSUInteger)len offset:(NSUInteger) offset;
+ (NSData *) pack7bit:(NSData *)input fillBits:(NSUInteger)fillers newLength:(NSUInteger *)newlen;
- (void)decodePdu:(NSData *)data context:(id)context;
- (UMSynchronizedSortedDictionary *)objectValue;
- (void)setText:(NSString *)text;
- (NSString *)text;
- (NSData *)encodePdu;
//+ (NSString *)gsmToUTF8:(NSData *)d;
+ (void)appendSmsMoForm:(NSMutableString *)s;
+ (void)appendSmsMtForm:(NSMutableString *)s;

- (UMSMS *)initWithHttpRequest:(UMHTTPRequest *)req;

@end
