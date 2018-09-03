//
//  UMSMS.m
//  ulibsms
//
//  Copyright © 2017 Andreas Fink (andreas@fink.org). All rights reserved.
//
// This source is dual licensed either under the GNU GENERAL PUBLIC LICENSE
// Version 3 from 29 June 2007 and other commercial licenses available by
// the author.
//
#import "UMSMS.h"
#import "UMSMS_Address.h"
#import <ulibgsmmap/ulibgsmmap.h>
#import <iconv.h>

static inline uint8_t grab(const uint8_t *bytes ,NSUInteger len, NSUInteger *pos, const char *file, long line)
{
    if(*pos >= len)
    {
        @throw([NSException exceptionWithName:@"BUFFER_OVERRUN"
                                       reason:@"reading beyond size of pdu"
                                     userInfo:@{@"file": @(file), @"line": @(line)} ]);
    }
    uint8_t r = bytes[*pos];
    *pos = *pos +1;
    return r;
}

#define  GRAB(bytes,len,pos)    grab(bytes,len,&pos,__FILE__,__LINE__)

@implementation UMSMS

#if 0
@synthesize _tp_mti; /* message type */
@synthesize tp_mms; /* more message to send */
@synthesize tp_sri; /* status report qualifier: 0 report to SUBMIT, 1 = report to COMMAND */
@synthesize tp_udhi; /*user data header indicator */
@synthesize tp_rp; /* reply path */
@synthesize tp_vpf; /* validity period present */
@synthesize tp_srr; /* status report requested */
@synthesize tp_pid; /* */
@synthesize tp_dcs; /* data coding scheme */
@synthesize tp_udl; /* user data length */
@synthesize tp_udhlen; /*user data header length */
@synthesize tp_mr; /* message refrence */
@synthesize tp_rd; /* reject duplicates */
@synthesize validity_time;
@synthesize coding;
@synthesize messageClass;
@synthesize compress;
@synthesize mwi_pdu;
@synthesize tp_fcs; /* status cause */
@synthesize t_ud;
@synthesize t_udh;
@synthesize tp_oa;
@synthesize tp_da;
@synthesize t_content;
@synthesize udh_decoded;
#endif

+ (NSData *) decode7bituncompressed:(NSData *)input len:(NSUInteger)len offset:(NSUInteger) offset
{
    int rmask[8] = { 0, 1, 3, 7, 15, 31, 63, 127 };
    int lmask[8] = { 0, 128, 192, 224, 240, 248, 252, 254 };
    unsigned char septet, octet, prevoctet;
    int i;
    int r = 1;
    int c = 7;
    int pos = 0;
    const uint8_t *bytes = input.bytes;
    NSMutableData *output = [[NSMutableData alloc]init];
    /* Shift the buffer offset bits to the left */
    
    uint8_t buffer[512];
    memset(buffer,0x00,sizeof(buffer));
    memcpy(buffer,bytes,(input.length > sizeof(buffer) ? sizeof(buffer) : input.length));

    if (offset > 0)
    {
        unsigned char *ip;
        for (i = 0, ip = buffer; i < input.length; i++)
        {
            if (i == input.length - 1)
            {
                *ip = *ip >> offset;
            }
            else
            {
                *ip = (*ip >> offset) | (*(ip + 1) << (8 - offset));
            }
            ip++;
        }
    }
    octet = buffer[pos];
    prevoctet = 0;
    for(i=0; i<len; i++)
    {
        uint8_t outputByte;
        septet = ((octet & rmask[c]) << (r-1)) + prevoctet;
        outputByte = septet;
        [output appendBytes:&outputByte length:1];
        prevoctet = (octet & lmask[r]) >> c;
        
        /* When r=7 we have a full character in prevoctet*/
        if((r==7) && (i<len-1))
        {
            i++;
            outputByte = prevoctet;
            [output appendBytes:&outputByte length:1];
            prevoctet = 0;
        }
        r = (r>6)? 1 : r+1;
        c = (c<2)? 7 : c-1;
        pos++;
        octet = buffer[pos];
    }
    return output;
}

- (void)decodePdu:(NSData *)data context:(id)context
{
    const uint8_t *bytes = data.bytes;
    NSUInteger     len = data.length;
    NSUInteger     pos = 0;
    
    /* see ETS 300 536 GSM 3.40 version 4.13.0 page 45 section 9.2.3.1 */
#define	_tp_mti(a)	(a & 0x03)
    /* value 1 means no more message are waiting for the MS in this SC so we negate it */
#define	TP_MMS(a)	(((a >> 2) & 0x01) ? 0 : 1)
#define	TP_VPF(a)	((a >> 3) & 0x03)
#define TP_SRR(a)	((a >> 5) & 0x01)  /* 1 means status report requested */
#define	TP_UDHI(a)	((a >> 6) & 0x01)  /* 1 means udh present */
#define	TP_RP(a)	((a >> 7) & 0x01)  /* 1 means reply path set */

    
    uint8_t	oct1 = GRAB(bytes,len,pos);
    _tp_mti	= _tp_mti(oct1);
    _tp_mms	= TP_MMS(oct1);
    _tp_vpf	= TP_VPF(oct1);
    _tp_srr	= TP_SRR(oct1);
    _tp_udhi = TP_UDHI(oct1);
    _tp_rp	= TP_RP(oct1);
    
    switch(_tp_mti)
    {
        case UMSMS_MessageType_DELIVER:
        {
            _tp_oa = [self grabAddress:bytes len:len pos:&pos];
            _tp_pid = GRAB(bytes,len,pos);
            _tp_dcs = GRAB(bytes,len,pos);
            _scts[0] = GRAB(bytes,len,pos);
            _scts[1] = GRAB(bytes,len,pos);
            _scts[2] = GRAB(bytes,len,pos);
            _scts[3] = GRAB(bytes,len,pos);
            _scts[4] = GRAB(bytes,len,pos);
            _scts[5] = GRAB(bytes,len,pos);
            _scts[6] = GRAB(bytes,len,pos);
            _scts[7] = 0;
            /*
             timestamp to string
            tscts = octstr_create(scts);
            octstr_binary_to_hex(tscts,1);
            mm_layer_log_debug((mm_generic_layer *)mi,PLACE_MSC_GENERAL,	"   TP-Service-Center-Timestamp: %c%c-%c%c-20%c%c %c%c:%c%c:%c%c TZ: %c%c",
                               octstr_get_char(tscts,5),
                               octstr_get_char(tscts,4),
                               octstr_get_char(tscts,3),
                               octstr_get_char(tscts,2),
                               octstr_get_char(tscts,1),
                               octstr_get_char(tscts,0),
                               octstr_get_char(tscts,7),
                               octstr_get_char(tscts,6),
                               octstr_get_char(tscts,9),
                               octstr_get_char(tscts,8),
                               octstr_get_char(tscts,11),
                               octstr_get_char(tscts,10),
                               octstr_get_char(tscts,13),
                               octstr_get_char(tscts,12));
            */
            _tp_udl = GRAB(bytes,len,pos);
            
            /* tp_udl is in characters not bytes */
            NSUInteger remaining_bytes = len - pos;
            _t_ud = [NSData dataWithBytes:&bytes[pos] length:remaining_bytes];
            _tp_udhlen = 0;
            if(_tp_udhi && _tp_udl > 0)
            {
                _tp_udhlen = GRAB(bytes,len,pos);
                remaining_bytes--;
                _t_udh = [NSData dataWithBytes:&bytes[pos-1] length:_tp_udhlen+1];
                pos += _tp_udhlen;
                remaining_bytes -= _tp_udhlen;
                if (((_tp_dcs & 0xF4) == 0xF4) || (_tp_dcs == 0x08))
                {
                    _tp_udl -= (_tp_udhlen + 1);
                }
                else
                {
                    int total_udhlen = _tp_udhlen + 1;
                    int num_of_septep = ((total_udhlen * 8) + 6) / 7;
                    _tp_udl -= num_of_septep;
                }
            }
            else
            {
                _t_udh = NULL;
                _tp_udhlen = 0;
            }

            if(_t_udh)
            {
                @try
                {
                    _udh_decoded = [self decodeUdh:_t_udh];
                }
                @catch(NSException *e)
                {
                    NSLog(@"Exception while decoding udh: %@",e);
                }
            }
            /* deal with the user data -- 7 or 8 bit encoded */
            NSData *tmp = [NSData dataWithBytes:&bytes[pos] length:remaining_bytes];
            if(((_tp_dcs & 0xF4) == 0xF4) || (_tp_dcs == 0x08)) /* 8 bit encoded */
            {
                /* 8 bit encoding */
                _t_ud = tmp;
                tmp = NULL;
            }
            else
            {
                /* 7 bit encoded */
                _t_ud = [[NSMutableData alloc]init];
                int offset = 0;
                if (_tp_udhi && (((_tp_dcs & 0xF4) == 0xF4) || (_tp_dcs == 0x00)))
                {
                    int nbits = (_tp_udhlen + 1) * 8;
                    offset = (((nbits / 7) + 1) * 7 - nbits) % 7;
                }
                _t_ud = [UMSMS decode7bituncompressed:tmp len:_tp_udl offset:offset];
            }
            [self dcs_to_fields];
        }
            break;
        case UMSMS_MessageType_COMMAND:
        {
            NSLog(@"UMSMS_MessageType_COMMAND not supported yet");
        }
            break;
    }
}


- (UMSMS_Address *)grabAddress:(const uint8_t *)bytes
                                            len:(NSUInteger)pdu_len
                                            pos:(NSUInteger *)p
{
    UMSMS_Address *tpa = [[UMSMS_Address alloc]init];
    
    int len = GRAB(bytes,pdu_len,*p);
    int ton = GRAB(bytes,pdu_len,*p);
    int npi = ton & 0x0F;
    ton =  (ton >> 4) & 0x07;
    
    tpa.ton = ton;
    tpa.npi = npi;

    int len2;
    if((len & 0x01) == 0) /* even */
    {
        len2 = len/2;
    }
    else
    {
        len2 = (len+1)/2;
    }
    if(len2 < 0)
    {
        len2 = 0;
    }
    NSData *tmp = [NSData dataWithBytes:&bytes[*p] length:len2];
    if(ton == 5) /* alphanumeric */
    {
        tpa.address = [NSString stringWithFormat:@"%02X%@",len,[tmp hexString]];
        /* FIXME: decode to UTF8String */
    }
    else
    {
        NSMutableString *s = [[NSMutableString alloc]init];
        const uint8_t *b2 = tmp.bytes;
        const char nib[16]="0123456789ABCDEF";
        
        for(int i=0;i<len2;i++)
        {
            int c = b2[i];
            [s appendFormat:@"%c%c", nib[c & 0x0F], nib[(c & 0xF0)>>4]];
        }
        tpa.address = [s substringToIndex:len];
    }
    (*p) += len2;
    return tpa;
}


-(void) dcs_to_fields
{
    int dcs = _tp_dcs;
    
    /* Non-MWI Mode 1 */
    if ((dcs & 0xF0) == 0xF0)
    {
        dcs &= 0x07;
        _coding = (dcs & 0x04) ? DC_8BIT : DC_7BIT; /* grab bit 2 */
        _messageClass = (dcs & 0x03); /* grab bits 1,0 */
    }
    
    /* Non-MWI Mode 0 */
    else if ((dcs & 0xC0) == 0x00)
    {
        _compress = ((dcs & 0x20) == 0x20) ? 1 : 0; /* grab bit 5 */
        _messageClass = ((dcs & 0x10) == 0x10) ?  (dcs & 0x03) : MC_UNDEF;
        /* grab bit 0,1 if bit 4 is on */
        _coding = ((dcs & 0x0C) >> 2); /* grab bit 3,2 */
    }
    
    /* MWI */
    else if ((dcs & 0xC0) == 0xC0)
    {
        _coding = ((dcs & 0x30) == 0x30) ? DC_UCS2 : DC_7BIT;
        if (dcs & 0x08)
        {
            dcs |= 0x04; /* if bit 3 is active, have mwi += 4 */
        }
        dcs &= 0x07;
        _mwi_pdu =  dcs ; /* grab bits 1,0 */
    } 
}



- (NSData *)encodedContent
{
    NSMutableData *pdu = [[NSMutableData alloc]init];
    NSUInteger len = _t_content.length;
    if (((_tp_dcs & 0xF4) == 0xF4) || (_tp_dcs == 0x08))
    {
        /*  dcs+message class = 8 bit or Unicode */
        len +=_t_udh.length;
    }
    else
    {
        len += (((8* _t_udh.length) + 6)/7);
    }
    /* see ets_300 536 e4p.pdf (GSM 03.40) page 55 */
    /* http://www.3gpp.org/ftp/Specs/html-info/0340.htm */
    /* http://www.3gpp.org/ftp/Specs/html-info/23038.htm for DCS*/
    /* The reason we branch here is because UDH data length is determined
     in septets if we are in GSM coding, otherwise it's in octets. Adding 6
     will ensure that for an octet length of 0, we get septet length 0,
     and for octet length 1 we get septet length 2.*/
    /* note: the following data starts on a 7bit boundary and is not on octet level! very weird */
    /* len is counted in octets or septets, depending on DCS. so watch out! */
    
    
    if(len > 256)
    {
        @throw([NSException exceptionWithName:@"BUFFER_OVERRUN"
                                       reason:@"writing beyond size of pdu"
                                     userInfo:@{@"file": @(__FILE__), @"line": @(__LINE__)} ]);
    }
    [pdu appendByte:(uint8_t)len];
    if(_tp_udhi)
    {
        [pdu appendData:_t_udh];
    }
    if (((_tp_dcs & 0xF4) == 0xF4) || (_tp_dcs == 0x08)) /* 8 bit */
    {
        [pdu appendData:_t_content];
    }
    else
    {
        NSUInteger fillers;
        fillers =  (((8*_t_udh.length) + 6)/7); /* filled up septets */
        fillers = fillers * 7; /* bits */
        fillers -= 8* _t_udh.length; /*bits */
        
        NSUInteger newlen;
        NSData *packed =[UMSMS pack7bit:_t_content fillBits:fillers newLength:&newlen];
        [pdu appendData:packed];
    }
    return pdu;
}

- (NSString *)tp_mti_string
{
    switch(_tp_mti)
    {
        case UMSMS_MessageType_SUBMIT:
            return @"SUBMIT";
        case UMSMS_MessageType_DELIVER:
            return @"DELIVER";
        case UMSMS_MessageType_STATUS_REPORT:
            return @"STATUS_REPORT";
        default:
            return @"RESERVED";
    }
}

- (void)setTp_mti_string:(NSString *)s
{
    if([s caseInsensitiveCompare:@"SUBMIT"]==NSOrderedSame)
    {
        _tp_mti = UMSMS_MessageType_SUBMIT;
    }
    if([s caseInsensitiveCompare:@"SUBMIT_REPORT"]==NSOrderedSame)
    {
        _tp_mti = UMSMS_MessageType_SUBMIT_REPORT;
    }
    else if([s caseInsensitiveCompare:@"DELIVER"]==NSOrderedSame)
    {
        _tp_mti = UMSMS_MessageType_DELIVER;
    }
    else if([s caseInsensitiveCompare:@"DELIVER_REPORT"]==NSOrderedSame)
    {
        _tp_mti = UMSMS_MessageType_DELIVER_REPORT;
    }
    else if([s caseInsensitiveCompare:@"STATUS_REPORT"]==NSOrderedSame)
    {
        _tp_mti = UMSMS_MessageType_STATUS_REPORT;
    }
    else if([s caseInsensitiveCompare:@"RESERVED"]==NSOrderedSame)
    {
        _tp_mti = UMSMS_MessageType_RESERVED;
    }
    else if([s caseInsensitiveCompare:@"COMMAND"]==NSOrderedSame)
    {
        _tp_mti = UMSMS_MessageType_COMMAND;
    }
}


- (NSData *)encodePdu
{
    NSMutableData *pdu = [[NSMutableData alloc]init];

    switch(_tp_mti)
    {
        case UMSMS_MessageType_DELIVER:	/* SMS-DELIVER */
        {
            /* normal message from SMSC to mobile */
            uint8_t o = _tp_mti;
            o += _tp_mms << 2;
            o += (_tp_sri ? 1 : 0) << 5;
            o += _tp_udhi<< 6;
            o += _tp_rp << 7;
            
            [pdu appendByte:o];
            NSData *tp_oa_encoded = [_tp_oa encoded];
            [pdu appendData:tp_oa_encoded];
            [pdu appendByte:_tp_pid];
            [pdu appendByte:_tp_dcs];
            [pdu appendBytes:_scts length:7];
            [pdu appendData:[self encodedContent]];
        }
            break;
        case UMSMS_MessageType_SUBMIT:
        {
            /* a message from the MSC to a SMSC */
            /* normal MO from mobile to SMSC */
            uint8_t o = _tp_mti;
            o += _tp_rd << 2;
            o += _tp_srr << 5;
            o += _tp_udhi<< 6;
            o += _tp_rp << 7;
            o += _tp_vpf << 3;
            
            [pdu appendByte:o];
            [pdu appendByte:_tp_mr];
            
            /* destination address */
            NSData *tp_da_encoded = [_tp_da encoded];
            [pdu appendData:tp_da_encoded];
            [pdu appendByte:_tp_pid];
            [pdu appendByte:_tp_dcs];
            if(_tp_vpf)
            {
                if(_validity_time==0)
                {
                    _validity_time = 0xFF;
                }
                [pdu appendByte:_validity_time];
            }
            [pdu appendData:[self encodedContent]];
        }
            break;
        case UMSMS_MessageType_STATUS_REPORT:	/* SMS-STATUS-REPORT */
        {
            /* message from SMSC to mobile indicating a delivery report */
            uint8_t o = _tp_mti;
            o += _tp_mms << 2;
            o += _tp_sri << 5; /* status report qualifier: 0 report to SUBMIT, 1 = report to COMMAND */
            [pdu appendByte:o];
            [pdu appendByte:_tp_mr];
            NSData *tp_da_encoded = [_tp_da encoded];
            [pdu appendData:tp_da_encoded];
            [pdu appendBytes:_scts length:7];
            [pdu appendByte:_tp_fcs];
        }
            break;
        case UMSMS_MessageType_RESERVED:	/* reserved */
            break;
    }
    return pdu;
}

+ (NSData *) pack7bit:(NSData *)input fillBits:(NSUInteger)fillers newLength:(NSUInteger *)newLen;
{
    NSMutableData *result;
    NSUInteger len;
    NSUInteger i;
    NSUInteger value;
    NSUInteger numbits;
    result = [[NSMutableData alloc]init];
    len = input.length;
    const uint8_t *bytes = input.bytes;
    NSUInteger pos  = 0;
    value = 0;

    numbits=fillers;
    
    for (i = 0; i < len; i++)
    {
        NSUInteger c = GRAB(bytes,len,pos);
        value += c << numbits;
        numbits += 7;
        if (numbits >= 8)
        {
            [result appendByte:(uint8_t)(value & 0xff)];
            value >>= 8;
            numbits -= 8;
        }
    }
    if (numbits > 0)
    {
        [result appendByte:(uint8_t)(value & 0xff)];
    }
    if(newLen)
    {
        *newLen = (len * 7 + 3) / 4;
    }
    return result;
}

- (UMSynchronizedSortedDictionary *)objectValue
{
    UMSynchronizedSortedDictionary *dict = [[UMSynchronizedSortedDictionary alloc]init];
    dict[@"_tp_mti"] = @(_tp_mti);
    dict[@"tp_mms"] = @(_tp_mms);
    dict[@"tp_sri"] = @(_tp_sri);
    dict[@"tp_udhi"] = @(_tp_udhi);
    dict[@"tp_rp"] = @(_tp_rp);
    dict[@"tp_vpf"] = @(_tp_vpf);
    dict[@"tp_srr"] = @(_tp_srr);
    dict[@"tp_pid"] = @(_tp_pid);
    dict[@"tp_dcs"] = @(_tp_dcs);
    dict[@"tp_udl"] = @(_tp_udl);
    dict[@"tp_mr"] = @(_tp_mr);
    dict[@"tp_rd"] = @(_tp_rd);
    dict[@"tp_fcs"] = @(_tp_fcs);
    dict[@"t_ud"] = _t_ud;
    dict[@"t_udh"] = _t_udh;
    if(_t_content)
    {
        dict[@"t_content"] =_t_content;
    }
    if(_tp_oa)
    {
        dict[@"tp_oa"] =
        @{
          @"ton" : @(_tp_oa.ton),
          @"npi" : @(_tp_oa.npi),
          @"address" : _tp_oa.address,
          };
    }
    if(_tp_da)
    {
        dict[@"tp_da"] =
        @{
          @"ton" : @(_tp_da.ton),
          @"npi" : @(_tp_da.npi),
          @"address" : _tp_da.address,
        };
    }
    dict[@"udh"] = _udh_decoded;
    return dict;
}

- (void)setText:(NSString *)text
{
    _t_content = [text gsm8];
 }


- (NSString *)textFromUCS2
{
    iconv_t cd = iconv_open ("UTF-8", "UCS-2");
    int ival = 1;
    iconvctl(cd,ICONV_SET_DISCARD_ILSEQ,&ival);
    
    char buffer[300];
    memset(buffer,0x00,sizeof(buffer));
    char const *inbuf = _t_ud.bytes;
    char *outbuf = &buffer[0];
    size_t inbytesleft = _t_ud.length;
    size_t outsize = sizeof(buffer)-1;
    size_t outbytesleft = outsize;
    iconv(cd,(char **)&inbuf,&inbytesleft,&outbuf,&outbytesleft);
    NSString *s = @(buffer);
    iconv_close(cd);
    return s;
}

- (NSString *)text
{
    NSString *t = @"unknown encoding";
    switch(_tp_dcs)
    {
        case 0:
            t = [_t_ud stringFromGsm8];
            break;
        case 0x08:
            t = [self textFromUCS2];
            break;
        case 0x03:
            t =  [[NSString alloc]initWithData:_t_ud encoding:NSISOLatin1StringEncoding];
            break;
        case 0x04:
            t = [_t_ud hexString];
            break;
        default:
        {
            switch(_coding)
            {
                case DC_7BIT:
                case DC_8BIT:
                    t= [_t_ud stringFromGsm8];
                    break;
                case DC_UCS2:
                    t = [self textFromUCS2];
                    break;
                default:
                    t = [_t_ud hexString];
                    break;
            }
        }
    }
    /*
    if(tp_udhi)
    {
        if(t_udh.length >=6)
        {
            const uint8_t *bytes = t_udh.bytes;
            if(bytes[0] >= 0x05)
            {
                if(bytes[1]==0x00)
                {
                    if(bytes[2]==0x03)
                    {
                        t = [NSString stringWithFormat:@"(%d/%d): %@",bytes[5],bytes[4],t];
                    }
                }
            }
        }
    }
     */
    if(t==NULL)
    {
        t=@"";
    }
    return t;
}


- (UMSynchronizedArray *)decodeUdh:(NSData *)data
{
    UMSynchronizedArray *arr = [[UMSynchronizedArray alloc]init];
    if(data.length < 2)
    {
        return arr;
    }

    const uint8_t *bytes = data.bytes;
    NSInteger len  = data.length;
    NSInteger i;

    if(bytes[0] != len - 1)
    {
        return arr;
    }
    for(i=1;i<(len-1);i++)
    {
        int iei = bytes[i];
        int ielen = bytes[i+1];
        if( (len - 2 - i ) < ielen)
        {
            break;
        }
        const uint8_t *iebytes = &bytes[i+2];
        i++;
        i = i+ielen+1;
        NSData *d2 = [NSData dataWithBytes:iebytes length:ielen];
        UMSynchronizedSortedDictionary *dict2 = [[UMSynchronizedSortedDictionary alloc]init];
        dict2[@"iei"] = @(iei);
        dict2[@"iel"] = @(ielen);
        dict2[@"data"] = d2;
        switch(iei)
        {
            case 0x00:
            {
                dict2[@"type"] = @"concatenated";
                if(ielen !=3)
                {
                    dict2[@"error"] = @"invalid-ielength";
                    break;
                }
                _multipart_ref = iebytes[0];
                _multipart_max = iebytes[1];
                _multipart_current = iebytes[2];
                dict2[@"reference-number"] = @(_multipart_ref);
                dict2[@"max"] = @(_multipart_max);
                dict2[@"part"] = @(_multipart_current);
                break;
            }
            case 0x01:
            {
                dict2[@"type"] = @"Special SMS Message Indication";
                if(ielen !=2)
                {
                    dict2[@"error"] = @"invalid-ielength";
                    break;
                }
                break;
            }
            case 0x03:
            {
                dict2[@"type"] = @"Special SMS Message Indication";
                if(ielen !=2)
                {
                    dict2[@"error"] = @"invalid-ielength";
                    break;
                }
                break;
            }
            case 0x04:
            {
                dict2[@"type"] = @"Application port addressing scheme 8bit";
                if(ielen !=2)
                {
                    dict2[@"error"] = @"invalid-ielength";
                    break;
                }
                break;
            }
            case 0x05:
            {
                dict2[@"type"] = @"Application port addressing scheme 16bit";
                if(ielen !=4)
                {
                    dict2[@"error"] = @"invalid-ielength";
                    break;
                }
                break;
            }
            case 0x06:
            {
                dict2[@"type"] = @"ASMSC Control Parameters";
                if(ielen !=1)
                {
                    dict2[@"error"] = @"invalid-ielength";
                    break;
                }
                break;
            }
            case 0x07:
            {
                dict2[@"type"] = @"UDH Source Indicator";
                if(ielen !=1)
                {
                    dict2[@"error"] = @"invalid-ielength";
                    break;
                }
                break;
            }
            case 0x08:
            {
                dict2[@"type"] = @"Concatenated short message, 16-bit reference";
                if(ielen !=4)
                {
                    dict2[@"error"] = @"invalid-ielength";
                    break;
                }
                break;
            }
            case 0x09:
            {
                dict2[@"type"] = @"WCMP";
                break;
            }
            case 0x0A:
            {
                dict2[@"type"] = @"Text Formatting EMS";
                break;
            }
            case 0x0B:
            {
                dict2[@"type"] = @"Predefined Sound	EMS";
                break;
            }
            case 0x0C:
            {
                dict2[@"type"] = @"User Defined Sound (iMelody EMS)";
                break;
            }
            case 0x0D:
            {
                dict2[@"type"] = @"Predefined Animation (EMS)";
                break;
            }
            case 0x0E:
            {
                dict2[@"type"] = @"Large Animation (EMS)";
                break;
            }
            case 0x0F:
            {
                dict2[@"type"] = @"Small Animation (EMS)";
                break;
            }
            case 0x10:
            {
                dict2[@"type"] = @"Large Picture (EMS)";
                break;
            }
            case 0x11:
            {
                dict2[@"type"] = @"Smalll Picture (EMS)";
                break;
            }
            case 0x12:
            {
                dict2[@"type"] = @"Variable Picture (EMS)";
                break;
            }
            case 0x13:
            {
                dict2[@"type"] = @"User prompt indicator (EMS)";
                break;
            }
            case 0x14:
            {
                dict2[@"type"] = @"Extended Object (EMS)";
                break;
            }
            case 0x15:
            {
                dict2[@"type"] = @"Reused Extended Object (EMS)";
                break;
            }
            case 0x16:
            {
                dict2[@"type"] = @"Compression Control (EMS)";
                break;
            }
            case 0x17:
            {
                dict2[@"type"] = @"Object Distribution Indicator (EMS)";
                break;
            }
            case 0x18:
            {
                dict2[@"type"] = @"Standard WVG object (EMS)";
                break;
            }
            case 0x19:
            {
                dict2[@"type"] = @"Character Size WVG object (EMS)";
                break;
            }
            case 0x1A:
            case 0x1B:
            case 0x1C:
            case 0x1D:
            case 0x1E:
            case 0x1F:
            {
                dict2[@"type"] = @"Extended Object Data Request Command (EMS)";
                break;
            }

            case 0x20:
            {
                dict2[@"type"] = @"RFC 822 E-Mail Header"; /* len = 1*/
                break;
            }
            case 0x21:
            {
                dict2[@"type"] = @"Hyperlink format element";
                break;
            }
            case 0x22:
            {
                dict2[@"type"] = @"Reply Address Element";
                break;
            }
            case 0x23:
            {
                dict2[@"type"] = @"Enhanced Voice Mail Information";
                break;
            }
            case 0x24:
            {
                dict2[@"type"] = @"National Language Single Shift"; /* len =1 */
                _language_shift_table_number=iebytes[0];
                dict2[@"language-code"] = @(_language_shift_table_number);
                break;
            }
            case 0x25:
            {
                dict2[@"type"] = @"National Language Locking Shift"; /* len =1 */
                _language_lock_table_number=iebytes[0];
                dict2[@"language-code"] = @(_language_lock_table_number);
                break;
            }
            default:
                if((iei >=0x26) && (iei <=0x6F))
                {
                    dict2[@"type"] = @"Reserved for future use"; /* len =1 */
                    break;
                }
                if((iei >=0x70) && (iei <=0x7F))
                {
                    dict2[@"type"] = @"(U)SIM Toolkit Security Headers"; /* len =1 */
                    break;
                }
                else if((iei >=0x80) && (iei <=0x9F))
                {
                    dict2[@"type"] = @"SME to SME specific use"; /* len =1 */
                    break;
                }
                else if((iei >=0xA0) && (iei <=0xBF))
                {
                    dict2[@"type"] = @"SME to SME specific use"; /* len =1 */
                    break;
                }
                else if((iei >=0xC0) && (iei <=0xDF))
                {
                    dict2[@"type"] = @"SC specific use"; /* len =1 */
                    break;
                }
                else if((iei >=0xE0) && (iei <=0xFF))
                {
                    dict2[@"type"] = @"Reserved for future use"; /* len =1 */
                    break;
                }
                break;
        }
        [arr addObject:dict2];
    }
    return arr;
}

+ (void)appendSmsMoForm:(NSMutableString *)s
{

    [s appendString:@"<tr><td colspan=2 class=subtitle>SMS Parameters:</td></tr>\n"];

    [s appendString:@"<tr>\n"];
    [s appendString:@"    <td class=optional>tp-rp</td>\n"];
    [s appendString:@"    <td class=optional><input name=\"tp-rp\" type=text value=\"0\">Reply Path: 0 |&nbsp;1</td>\n"];
    [s appendString:@"</tr>\n"];

    [s appendString:@"<tr>\n"];
    [s appendString:@"    <td class=optional>tp-udhi</td>\n"];
    [s appendString:@"    <td class=optional><input name=\"tp-udhi\" type=text value=\"0\">User Data Header Indicator: 0 |&nbsp;1</td>\n"];
    [s appendString:@"</tr>\n"];

    [s appendString:@"<tr>\n"];
    [s appendString:@"    <td class=optional>tp-srr</td>\n"];
    [s appendString:@"    <td class=optional><input name=\"tp-srr\" type=text value=\"0\">Status Report Requested</td>\n"];
    [s appendString:@"</tr>\n"];

    [s appendString:@"<tr>\n"];
    [s appendString:@"    <td class=optional>tp-vpf</td>\n"];
    [s appendString:@"    <td class=optional><input name=\"tp-vpf\" type=text value=\"2\">Validity Period Format: 0 |&nbsp;1 | 2 |&nbsp;3</td>\n"];
    [s appendString:@"</tr>\n"];

    [s appendString:@"<tr>\n"];
    [s appendString:@"    <td class=optional>tp-rd</td>\n"];
    [s appendString:@"    <td class=optional><input name=\"tp-rd\" type=text value=\"0\">(Reject Duplicates)</td>\n"];
    [s appendString:@"</tr>\n"];

    [s appendString:@"<tr>\n"];
    [s appendString:@"    <td class=mandatory>tp-mti</td>\n"];

    [s appendString:@"    <td class=mandatory><input name=\"tp-mti\" type=text value=\"SUBMIT\">Message Type Indicator: SUBMIT</td>\n"];
    [s appendString:@"</tr>\n"];


    [s appendString:@"<tr>\n"];
    [s appendString:@"    <td class=optional>tp-mr</td>\n"];
    [s appendString:@"    <td class=optional><input name=\"tp-mr\" type=text value=\"0\">Message Reference: 0..255</td>\n"];
    [s appendString:@"</tr>\n"];


    /* TP-Destination-Address */
    [s appendString:@"<tr>\n"];
    [s appendString:@"    <td class=mandatory>tp-da</td>\n"];
    [s appendString:@"    <td class=mandatory><input name=\"tp-da\" type=text placeholder=\"+12345678\">Destination Address (E164 Number). Reiver of SMS</td>\n"];
    [s appendString:@"</tr>\n"];

    /* pid */
    [s appendString:@"<tr>\n"];
    [s appendString:@"    <td class=optional>tp-pid</td>\n"];
    [s appendString:@"    <td class=optional><input name=\"tp-pid\" type=text value=\"0\">Process Indicator: 0..255</td>\n"];
    [s appendString:@"</tr>\n"];

    /* DCS */
    [s appendString:@"<tr>\n"];
    [s appendString:@"    <td class=optional>tp-dcs</td>\n"];
    [s appendString:@"    <td class=optional><input name=\"tp-dcs\" type=text value=\"0\">Data Coding Scheme: 0..255</td>\n"];
    [s appendString:@"</tr>\n"];

    /* validity time */
    [s appendString:@"<tr>\n"];
    [s appendString:@"    <td class=optional>validity-time</td>\n"];
    [s appendString:@"    <td class=optional><input name=\"validity-time\" type=text value=\"255\">0...255</td>\n"];
    [s appendString:@"</tr>\n"];

    [s appendString:@"<tr>\n"];
    [s appendString:@"    <td class=optional>t-udh</td>\n"];
    [s appendString:@"    <td class=optional><input name=\"t-udh\" type=text>User Data Header (hex bytes)</td>\n"];
    [s appendString:@"</tr>\n"];

    [s appendString:@"<tr>\n"];
    [s appendString:@"    <td class=optional>text</td>\n"];
    [s appendString:@"    <td class=optional><input name=\"text\" type=text>Text</td>\n"];
    [s appendString:@"</tr>\n"];

}
+ (void)appendSmsMtForm:(NSMutableString *)s
{
    [s appendString:@"<tr><td colspan=2 class=subtitle>SMS Parameters:</td></tr>\n"];

    [s appendString:@"<tr>\n"];
    [s appendString:@"    <td class=optional>tp-rp</td>\n"];
    [s appendString:@"    <td class=optional><input name=\"tp-rp\" type=text value=\"0\">Reply Path: 0 |&nbsp;1</td>\n"];
    [s appendString:@"</tr>\n"];

    [s appendString:@"<tr>\n"];
    [s appendString:@"    <td class=optional>tp-udhi</td>\n"];
    [s appendString:@"    <td class=optional><input name=\"tp-udhi\" type=text value=\"0\">User Data Header Indicator: 0 |&nbsp;1</td>\n"];
    [s appendString:@"</tr>\n"];

    [s appendString:@"<tr>\n"];
    [s appendString:@"    <td class=optional>tp-sri</td>\n"];
    [s appendString:@"    <td class=optional><input name=\"tp-sri\" type=text value=\"0\">Status Report Indication</td>\n"];
    [s appendString:@"</tr>\n"];

    [s appendString:@"<tr>\n"];
    [s appendString:@"    <td class=optional>tp-lp</td>\n"];
    [s appendString:@"    <td class=optional><input name=\"tp-lp\" type=text value=\"0\">Loop Prevention</td>\n"];
    [s appendString:@"</tr>\n"];

    [s appendString:@"<tr>\n"];
    [s appendString:@"    <td class=optional>tp-mms</td>\n"];
    [s appendString:@"    <td class=optional><input name=\"tp-mms\" type=text value=\"0\">More Messsages to Send: 0 |&nbsp;1</td>\n"];
    [s appendString:@"</tr>\n"];

    [s appendString:@"<tr>\n"];
    [s appendString:@"    <td class=mandatory>tp-mti</td>\n"];

    [s appendString:@"    <td class=mandatory><input name=\"tp-mti\" type=text value=\"DELIVER\">Message Type Indicator: DELIVER</td>\n"];
    [s appendString:@"</tr>\n"];

    /* tp originating address */
    [s appendString:@"<tr>\n"];
    [s appendString:@"    <td class=mandatory>tp-oa</td>\n"];
    [s appendString:@"    <td class=mandatory><input name=\"tp-oa\" type=text placeholder=\"+12345678\">Originating Address (E164 Number). Sender of SMS</td>\n"];
    [s appendString:@"</tr>\n"];

    /* pid */
    [s appendString:@"<tr>\n"];
    [s appendString:@"    <td class=optional>tp-pid</td>\n"];
    [s appendString:@"    <td class=optional><input name=\"tp-pid\" type=text value=\"0\">Process Indicator: 0..255</td>\n"];
    [s appendString:@"</tr>\n"];

    /* DCS */
    [s appendString:@"<tr>\n"];
    [s appendString:@"    <td class=optional>tp-dcs</td>\n"];
    [s appendString:@"    <td class=optional><input name=\"tp-dcs\" type=text value=\"0\">Data Coding Scheme: 0..255</td>\n"];
    [s appendString:@"</tr>\n"];

    /* SCTS time */
    [s appendString:@"<tr>\n"];
    [s appendString:@"    <td class=optional>scts</td>\n"];
    [s appendString:@"    <td class=optional><input name=\"scts\" type=text value=\"\" placeholder=\"yyyy-MM-dd HH:mm:ss\">Service Center Time Stamp</td>\n"];
    [s appendString:@"</tr>\n"];

    [s appendString:@"<tr>\n"];
    [s appendString:@"    <td class=optional>t-udh</td>\n"];
    [s appendString:@"    <td class=optional><input name=\"t-udh\" type=text>User Data Header (hex bytes)</td>\n"];
    [s appendString:@"</tr>\n"];

    [s appendString:@"<tr>\n"];
    [s appendString:@"    <td class=optional>text</td>\n"];
    [s appendString:@"    <td class=optional><input name=\"text\" type=text>Text</td>\n"];
    [s appendString:@"</tr>\n"];
}



#define SET_OPTIONAL_PARAMETER(p,var,name)   \
{\
    var = [p[name]urldecode];\
    if([var isEqualToString:@"default" ])\
    {\
        var = NULL;\
    } \
}

- (UMSMS *)initWithHttpRequest:(UMHTTPRequest *)req
{
    self = [super init];
    if(self)
    {
        NSDictionary *p = req.params;

        NSString *web_tp_mti;
        NSString *web_tp_mms;
        NSString *web_tp_sri;
        NSString *web_tp_udhi;
        NSString *web_tp_rp;
        NSString *web_tp_vpf;
        NSString *web_tp_srr;
        NSString *web_tp_pid;
        NSString *web_tp_dcs;
        NSString *web_tp_mr;
        NSString *web_tp_rd;
        NSString *web_validity_time;
        NSString *web_t_udh;
        NSString *web_tp_oa;
        NSString *web_tp_da;
        NSString *web_text;
        NSString *web_scts;

        SET_OPTIONAL_PARAMETER(p,web_tp_mti,@"tp-mti");
        SET_OPTIONAL_PARAMETER(p,web_tp_mms,@"tp-mms");
        SET_OPTIONAL_PARAMETER(p,web_tp_sri,@"tp-sri");
        SET_OPTIONAL_PARAMETER(p,web_tp_udhi,@"tp-udhi");
        SET_OPTIONAL_PARAMETER(p,web_tp_rp,@"tp-rp");
        SET_OPTIONAL_PARAMETER(p,web_tp_vpf,@"tp-vpf");
        SET_OPTIONAL_PARAMETER(p,web_tp_srr,@"tp-srr");
        SET_OPTIONAL_PARAMETER(p,web_tp_pid,@"tp-pid");
        SET_OPTIONAL_PARAMETER(p,web_tp_dcs,@"tp-dcs");
        SET_OPTIONAL_PARAMETER(p,web_tp_mr,@"tp-mr");
        SET_OPTIONAL_PARAMETER(p,web_tp_rd,@"tp-rd");
        SET_OPTIONAL_PARAMETER(p,web_validity_time,@"validity-time");
        SET_OPTIONAL_PARAMETER(p,web_t_udh,@"t-udh");
        SET_OPTIONAL_PARAMETER(p,web_tp_oa,@"tp-oa");
        SET_OPTIONAL_PARAMETER(p,web_tp_da,@"tp-da");
        SET_OPTIONAL_PARAMETER(p,web_text,@"text");
        SET_OPTIONAL_PARAMETER(p,web_scts,@"scts");

        if([web_tp_mti isEqualToStringCaseInsensitive:@"DELIVER"])
        {
            _tp_mti = UMSMS_MessageType_DELIVER;
        }
        else if([web_tp_mti isEqualToStringCaseInsensitive:@"DELIVER-REPORT"])
        {
            _tp_mti = UMSMS_MessageType_DELIVER_REPORT;
        }
        else if([web_tp_mti isEqualToStringCaseInsensitive:@"SUBMIT"])
        {
            _tp_mti = UMSMS_MessageType_SUBMIT;
        }
        else if([web_tp_mti isEqualToStringCaseInsensitive:@"SUBMIT-REPORT"])
        {
            _tp_mti = UMSMS_MessageType_SUBMIT_REPORT;
        }
        else if([web_tp_mti isEqualToStringCaseInsensitive:@"STATUS-REPORT"])
        {
            _tp_mti = UMSMS_MessageType_STATUS_REPORT;
        }
        else if([web_tp_mti isEqualToStringCaseInsensitive:@"COMMAND"])
        {
            _tp_mti = UMSMS_MessageType_COMMAND;
        }
        else if([web_tp_mti isEqualToStringCaseInsensitive:@"RESERVED"])
        {
            _tp_mti = UMSMS_MessageType_RESERVED;
        }

        if(web_tp_mms.length>0)
        {
            _tp_mms = [web_tp_mms boolValue];
        }
        if(web_tp_sri.length>0)
        {
            _tp_sri = [web_tp_sri boolValue];
        }
        if(web_tp_udhi.length>0)
        {
            _tp_udhi = [web_tp_udhi boolValue];
        }
        if(web_tp_rp.length>0)
        {
            _tp_rp = [web_tp_rp boolValue];
        }
        if(web_tp_vpf.length>0) /* this is only present on SUBMIT */
        {
            _tp_vpf = [web_tp_vpf intValue];
        }
        if(web_tp_srr.length>0)
        {
            _tp_srr = [web_tp_srr boolValue];
        }
        if(web_tp_pid.length>0)
        {
            _tp_pid = [web_tp_pid intValue] & 0xFF;
        }
        if(web_tp_dcs.length>0)
        {
            _tp_dcs = [web_tp_dcs intValue] & 0xFF;
        }
        if(web_tp_mr.length>0)
        {
            _tp_mr = [web_tp_mr intValue] & 0xFF;
        }
        if(web_tp_rd.length>0)
        {
            _tp_rd = [web_tp_rd boolValue];
        }
        if(web_validity_time.length>0)
        {
            _validity_time = [web_validity_time intValue];
        }
        if(web_t_udh.length>0)
        {
            _t_udh = [web_t_udh unhexData];
        }
        if(web_tp_oa.length > 0)
        {
            _tp_oa = [[UMSMS_Address alloc]initWithString:web_tp_oa]; /*oa msisdn */
        }
        if(web_tp_da.length > 0)
        {
            _tp_da = [[UMSMS_Address alloc]initWithString:web_tp_da];
        }
        if(web_text.length > 0)
        {
            _t_content = [web_text gsm8];
        }

        NSTimeZone *tz      = [NSTimeZone systemTimeZone];
        int offset_minutes  = (int)[tz secondsFromGMTForDate:[NSDate date]] / 60;
        int offset_15min    = offset_minutes / 15;
        int offset_negative = offset_15min < 0;
        offset_15min = abs(offset_15min);
        NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        NSString *timeStamp;

        NSDate *sctsDate = [NSDate new];

        if((web_scts.length > 0) && (![web_scts isEqualToString:@"now"]))
        {
            if(web_scts.length < 19)
            {
                @throw([NSException exceptionWithName:@"Invalid SCTS length (expecting yyyy-MM-dd HH:mm:ss)"  reason:NULL userInfo:@{}]);
            }

            NSDateFormatter *dateFormatter1 = [[NSDateFormatter alloc] init];
            [dateFormatter1 setLocale:usLocale];
            [dateFormatter1 setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            [dateFormatter1 setTimeZone:tz];
            sctsDate = [dateFormatter1 dateFromString:web_scts];
        }

        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setLocale:usLocale];
        [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
        [dateFormatter setTimeZone:tz];
        timeStamp = [dateFormatter stringFromDate:sctsDate];

        const char *tmp_dt = [timeStamp UTF8String];
        _scts[0]  = (tmp_dt[2] - '0') << 0; /* YY */
        _scts[0] |= (tmp_dt[3] - '0') << 4;
        _scts[1]  = (tmp_dt[4] - '0') << 0; /* MM */
        _scts[1] |= (tmp_dt[5] - '0') << 4;
        _scts[2]  = (tmp_dt[6] - '0') << 0; /* DD */
        _scts[2] |= (tmp_dt[7] - '0') << 4;
        _scts[3]  = (tmp_dt[8] - '0') << 0; /* hh */
        _scts[3] |= (tmp_dt[9] - '0') << 4;
        _scts[4]  = (tmp_dt[10] - '0') << 0; /* mm */
        _scts[4] |= (tmp_dt[11] - '0') << 4;
        _scts[5]  = (tmp_dt[12] - '0') << 0; /* ss */
        _scts[5] |= (tmp_dt[13] - '0') << 4;
        _scts[6]  = (offset_15min & 0xF0) >> 4;
        _scts[6] |= (offset_15min & 0x0F) << 4;
        if(offset_negative)
        {
            _scts[6]  |= 0x08;
        }
    }
    return self;
}
@end
