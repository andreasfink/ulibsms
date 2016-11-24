//
//  UMSMS.m
//  ulibsms
//
//  © 2016  by Andreas Fink
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


@synthesize tp_mti; /* message type */
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
#define	TP_MTI(a)	(a & 0x03)
    /* value 1 means no more message are waiting for the MS in this SC so we negate it */
#define	TP_MMS(a)	(((a >> 2) & 0x01) ? 0 : 1)
#define	TP_VPF(a)	((a >> 3) & 0x03)
#define TP_SRR(a)	((a >> 5) & 0x01)  /* 1 means status report requested */
#define	TP_UDHI(a)	((a >> 6) & 0x01)  /* 1 means udh present */
#define	TP_RP(a)	((a >> 7) & 0x01)  /* 1 means reply path set */

    
    uint8_t	oct1 = GRAB(bytes,len,pos);
    tp_mti	= TP_MTI(oct1);
    tp_mms	= TP_MMS(oct1);
    tp_vpf	= TP_VPF(oct1);
    tp_srr	= TP_SRR(oct1);
    tp_udhi = TP_UDHI(oct1);
    tp_rp	= TP_RP(oct1);
    
    switch(tp_mti)
    {
        case UMSMS_MessageType_DELIVER:
        {
            tp_oa = [self grabAddress:bytes len:len pos:&pos];
            tp_pid = GRAB(bytes,len,pos);
            tp_dcs = GRAB(bytes,len,pos);
            scts[0] = GRAB(bytes,len,pos);
            scts[1] = GRAB(bytes,len,pos);
            scts[2] = GRAB(bytes,len,pos);
            scts[3] = GRAB(bytes,len,pos);
            scts[4] = GRAB(bytes,len,pos);
            scts[5] = GRAB(bytes,len,pos);
            scts[6] = GRAB(bytes,len,pos);
            scts[7] = 0;
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
            tp_udl = GRAB(bytes,len,pos);
            
            /* tp_udl is in characters not bytes */
            int remaining_bytes = len - pos;
            t_ud = [NSData dataWithBytes:&bytes[pos] length:remaining_bytes];
            tp_udhlen = 0;
            if(tp_udhi && tp_udl > 0)
            {
                tp_udhlen = GRAB(bytes,len,pos);
                t_udh = [NSData dataWithBytes:&bytes[pos-1] length:tp_udhlen+1];
                pos += tp_udhlen;
                if (((tp_dcs & 0xF4) == 0xF4) || (tp_dcs == 0x08))
                {
                    tp_udl -= (tp_udhlen + 1);
                }
                else
                {
                    int total_udhlen = tp_udhlen + 1;
                    int num_of_septep = ((total_udhlen * 8) + 6) / 7;
                    tp_udl -= num_of_septep;
                }
            }
            else
            {
                t_udh = NULL;
                tp_udhlen = 0;
            }
            
            /* deal with the user data -- 7 or 8 bit encoded */
            NSData *tmp = [NSData dataWithBytes:&bytes[pos] length:remaining_bytes];
            if(((tp_dcs & 0xF4) == 0xF4) || (tp_dcs == 0x08)) /* 8 bit encoded */
            {
                /* 8 bit encoding */
                t_ud = tmp;
                tmp = NULL;
            }
            else
            {
                /* 7 bit encoded */
                t_ud = [[NSMutableData alloc]init];
                int offset = 0;
                if (tp_udhi && (((tp_dcs & 0xF4) == 0xF4) || (tp_dcs == 0x00)))
                {
                    int nbits = (tp_udhlen + 1) * 8;
                    offset = (((nbits / 7) + 1) * 7 - nbits) % 7;
                }
                t_ud = [UMSMS decode7bituncompressed:tmp len:tp_udl offset:offset];
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
    }
    else
    {
        NSMutableString *s = [[NSMutableString alloc]init];
        const uint8_t *b2 = tmp.bytes;
        const char nib[16]="0123456789ABCDEF";
        
        for(int i=0;i<len2;i++)
        {
            int c = b2[i];
            c = ((c & 0x0F)<< 4) + ((c & 0xF0) >> 4);
            [s appendFormat:@"%c%c",
                nib[c & 0x0F],
                nib[(c & 0xF0)>>4]];
        }
        tpa.address = [s substringToIndex:len];
    }
    (*p) += len2;
    return tpa;
}


-(void) dcs_to_fields
{
    int dcs = tp_dcs;
    
    /* Non-MWI Mode 1 */
    if ((dcs & 0xF0) == 0xF0)
    {
        dcs &= 0x07;
        coding = (dcs & 0x04) ? DC_8BIT : DC_7BIT; /* grab bit 2 */
        messageClass = (dcs & 0x03); /* grab bits 1,0 */
    }
    
    /* Non-MWI Mode 0 */
    else if ((dcs & 0xC0) == 0x00)
    {
        compress = ((dcs & 0x20) == 0x20) ? 1 : 0; /* grab bit 5 */
        messageClass = ((dcs & 0x10) == 0x10) ?  (dcs & 0x03) : MC_UNDEF;
        /* grab bit 0,1 if bit 4 is on */
        coding = ((dcs & 0x0C) >> 2); /* grab bit 3,2 */
    }
    
    /* MWI */
    else if ((dcs & 0xC0) == 0xC0)
    {
        coding = ((dcs & 0x30) == 0x30) ? DC_UCS2 : DC_7BIT;
        if (dcs & 0x08)
        {
            dcs |= 0x04; /* if bit 3 is active, have mwi += 4 */
        }
        dcs &= 0x07;
        mwi_pdu =  dcs ; /* grab bits 1,0 */
    } 
}



- (NSData *)encodedContent
{
    NSMutableData *pdu = [[NSMutableData alloc]init];
    NSUInteger len = t_content.length;
    if (((tp_dcs & 0xF4) == 0xF4) || (tp_dcs == 0x08))
    {
        /*  dcs+message class = 8 bit or Unicode */
        len += t_udh.length;
    }
    else
    {
        len += (((8* t_udh.length) + 6)/7);
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
    if(tp_udhi)
    {
        [pdu appendData:t_udh];
    }
    if (((tp_dcs & 0xF4) == 0xF4) || (tp_dcs == 0x08)) /* 8 bit */
    {
        [pdu appendData:t_content];
    }
    else
    {
        NSUInteger fillers;
        fillers =  (((8*t_udh.length) + 6)/7); /* filled up septets */
        fillers = fillers * 7; /* bits */
        fillers -= 8* t_udh.length; /*bits */
        
        NSUInteger newlen;
        NSData *packed =[UMSMS pack7bit:t_content fillBits:fillers newLength:&newlen];
        [pdu appendData:packed];
    }
    return pdu;
}

- (NSString *)tp_mti_string
{
    switch(tp_mti)
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
        tp_mti = UMSMS_MessageType_SUBMIT;
    }
    if([s caseInsensitiveCompare:@"SUBMIT_REPORT"]==NSOrderedSame)
    {
        tp_mti = UMSMS_MessageType_SUBMIT_REPORT;
    }
    else if([s caseInsensitiveCompare:@"DELIVER"]==NSOrderedSame)
    {
        tp_mti = UMSMS_MessageType_DELIVER;
    }
    else if([s caseInsensitiveCompare:@"DELIVER_REPORT"]==NSOrderedSame)
    {
        tp_mti = UMSMS_MessageType_DELIVER_REPORT;
    }
    else if([s caseInsensitiveCompare:@"STATUS_REPORT"]==NSOrderedSame)
    {
        tp_mti = UMSMS_MessageType_STATUS_REPORT;
    }
    else if([s caseInsensitiveCompare:@"RESERVED"]==NSOrderedSame)
    {
        tp_mti = UMSMS_MessageType_RESERVED;
    }
    else if([s caseInsensitiveCompare:@"COMMAND"]==NSOrderedSame)
    {
        tp_mti = UMSMS_MessageType_COMMAND;
    }
}
- (NSData *)encodePdu
{
    NSMutableData *pdu = [[NSMutableData alloc]init];

    switch(tp_mti)
    {
        case UMSMS_MessageType_DELIVER:	/* SMS-DELIVER */
        {
            /* normal message from SMSC to mobile */
            uint8_t o = tp_mti;
            o += tp_mms << 2;
            o += tp_sri << 5;
            o += tp_udhi<< 6;
            o += tp_rp << 7;
            
            [pdu appendByte:o];
            NSData *tp_oa_encoded = [tp_oa encoded];
            [pdu appendData:tp_oa_encoded];
            [pdu appendByte:tp_pid];
            [pdu appendByte:tp_dcs];
            [pdu appendBytes:scts length:7];
            [pdu appendData:[self encodedContent]];
        }
            break;
        case UMSMS_MessageType_SUBMIT:
        {
            /* a message from the MSC to a SMSC */
            /* normal MO from mobile to SMSC */
            uint8_t o = tp_mti;
            o += tp_rd << 2;
            o += tp_srr << 5;
            o += tp_udhi<< 6;
            o += tp_rp << 7;
            o += tp_vpf << 3;
            
            [pdu appendByte:o];
            [pdu appendByte:tp_mr];
            
            /* destination address */
            NSData *tp_da_encoded = [tp_da encoded];
            [pdu appendData:tp_da_encoded];
            [pdu appendByte:tp_pid];
            [pdu appendByte:tp_dcs];
            if(tp_vpf)
            {
                if(validity_time==0)
                {
                    validity_time = 0xFF;
                }
                [pdu appendByte:validity_time];
            }
            [pdu appendData:[self encodedContent]];
        }
            break;
        case UMSMS_MessageType_STATUS_REPORT:	/* SMS-STATUS-REPORT */
        {
            /* message from SMSC to mobile indicating a delivery report */
            uint8_t o = tp_mti;
            o += tp_mms << 2;
            o += tp_sri << 5; /* status report qualifier: 0 report to SUBMIT, 1 = report to COMMAND */
            [pdu appendByte:o];
            [pdu appendByte:tp_mr];
            NSData *tp_da_encoded = [tp_da encoded];
            [pdu appendData:tp_da_encoded];
            [pdu appendBytes:scts length:7];
            [pdu appendByte:tp_fcs];
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
    dict[@"tp_mti"] = @(tp_mti);
    dict[@"tp_mms"] = @(tp_mms);
    dict[@"tp_sri"] = @(tp_sri);
    dict[@"tp_udhi"] = @(tp_udhi);
    dict[@"tp_rp"] = @(tp_rp);
    dict[@"tp_vpf"] = @(tp_vpf);
    dict[@"tp_srr"] = @(tp_srr);
    dict[@"tp_pid"] = @(tp_pid);
    dict[@"tp_dcs"] = @(tp_dcs);
    dict[@"tp_udl"] = @(tp_udl);
    dict[@"tp_mr"] = @(tp_mr);
    dict[@"tp_rd"] = @(tp_rd);
    dict[@"tp_fcs"] = @(tp_fcs);
    dict[@"t_ud"] = t_ud;
    dict[@"t_udh"] =t_udh;
    if(t_content)
    {
        dict[@"t_content"] =t_content;
    }
    if(tp_oa)
    {
        dict[@"tp_oa"] =
        @{
          @"ton" : @(tp_oa.ton),
          @"npi" : @(tp_oa.npi),
          @"address" : tp_oa.address,
          };
    }
    if(tp_da)
    {
        dict[@"tp_da"] =
        @{
          @"ton" : @(tp_da.ton),
          @"npi" : @(tp_da.npi),
          @"address" : tp_da.address,
          };
    }
    return dict;
}

- (void)setText:(NSString *)text
{
    t_content = [text gsm8];
 }


- (NSString *)textFromUCS2
{
    iconv_t cd = iconv_open ("UTF-8", "UCS-2");
    int ival = 1;
    iconvctl(cd,ICONV_SET_DISCARD_ILSEQ,&ival);
    size_t read_chars;

    char buffer[300];
    memset(buffer,0x00,sizeof(buffer));
    char *inbuf = t_ud.bytes;
    char *outbuf = &buffer[0];
    size_t inbytesleft = t_ud.length;
    size_t outsize = sizeof(buffer)-1;
    size_t outbytesleft = outsize;
    if(iconv(cd,&inbuf,&inbytesleft,&outbuf,&outbytesleft) < 0)
    {
        NSLog(@"error %d while calling iconv()",errno);
    }
    int len = outsize-outbytesleft;
    NSString *s = @(buffer);
    return s;
}

- (NSString *)text
{
    NSString *t = @"unknown encoding";
    switch(tp_dcs)
    {
        case 0:
            t= [t_ud stringFromGsm8];
            break;
        case 0x08:
            t = [self textFromUCS2];
            break;
        case 0x03:
            t =  [[NSString alloc]initWithData:t_ud encoding:NSISOLatin1StringEncoding];
            break;
        case 0x04:
            t = [t_ud hexString];
            break;
        default:
            t = [t_ud hexString];
            break;
    }
    if(tp_udhi)
    {
        if(t_udh.length >=6)
        {
            uint8_t *bytes = t_udh.bytes;
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
    return t;
}
#if 0
+ (NSString *)gsmToUTF8:(NSData *)d
{
    NSMutableString *out = [[NSMutableString alloc]init];
    uint8_t *inBytes = d.bytes;
    NSInteger i;
    NSInteger len = d.length;
    BOOL escape = NO;
    for(i=0;i<len;i++)
    {
        NSString *c = @"";
        if(escape)
        {
            escape = NO;
            switch(inBytes[i])
            {
                case 0x14:
                    c = @"^";
                    break;
                case 0x28:
                    c = @"{";
                    break;
                case 0x29:
                    c = @"}";
                    break;
                case 0x2F:
                    c = @"\\";
                    break;
                case 0x3C:
                    c = @"[";
                    break;
                case 0x3D:
                    c = @"~";
                    break;
                case 0x3E:
                    c = @"]";
                    break;
                case 0x40:
                    c = @"|";
                    break;
                case 0x65:
                    c = @"€";
                    break;
                case 0x0A:
                    c = @"\n";
                    break;
                default:
                break;
            }
        }
        else
        {
            switch(inBytes[i])
            {
                case 0x00:
                    c = @"@";
                    break;
                case 0x01:
                    c = @"£";
                    break;
                case 0x02:
                    c = @"$";
                    break;
                case 0x03:
                    c = @"¥";
                    break;
                case 0x04:
                    c = @"è";
                    break;
                case 0x05:
                    c = @"é";
                    break;
                case 0x06:
                    c = @"ù";
                    break;
                case 0x07:
                    c = @"ì";
                    break;
                case 0x08:
                    c = @"ò";
                    break;
                case 0x09:
                    c = @"Ç";
                    break;
                case 0x0A:
                    c = @"\n";
                    break;
                case 0x0B:
                    c = @"Ø";
                case 0x0C:
                    c = @"ø";
                    break;
                case 0x0D:
                    c = @"\r";
                    break;
                case 0x0E:
                    c = @"Å";
                    break;
                case 0x0F:
                    c = @"å";
                    break;
                case 0x10:
                    c = @"Δ";
                    break;
                case 0x11:
                    c = @"_";
                    break;
                case 0x12:
                    c = @"Φ";
                    break;
                case  0x13:
                    c = @"Γ";
                    break;
                case  0x14:
                    c = @"Λ";
                    break;
                case  0x15:
                    c = @"Ω";
                    break;
                case  0x16:
                    c = @"Π";
                    break;
                case  0x17:
                    c = @"Ψ";
                    break;
                case  0x18:
                    c = @"Σ";
                    break;
                case  0x19:
                    c = @"Θ";
                    break;
                case 0x01A:
                    escape = YES;
                    break;
                case 0x1B:
                    c = @"Ξ";
                case 0x1C:
                    c = @"Æ";
                    break;
                case 0x1D:
                    c = @"æ";
                    break;
                case 0x1E:
                    c = @"ß";
                    break;
                case 0x1F:
                    c = @"É";
                    break;
                case 0x24:
                    c = @"¤";
                    break;
                case 0x40:
                    c = @"¡";
                    break;
                case 0x5B:
                    c = @"Ä";
                    break;
                case 0x5C:
                    c = @"Ö";
                    break;
                case 0x5D:
                    c = @"Ñ";
                    break;
                case 0x5E:
                    c = @"Ü";
                    break;
                case 0x5F:
                    c = @"§";
                    break;
                case 0x60:
                    c = @"¿";
                    break;
                case 0x7B:
                    c = @"ä";
                    break;
                case 0x7C:
                    c = @"ö";
                    break;
                case 0x7D:
                    c = @"ñ";
                    break;
                case 0x7E:
                    c = @"ü";
                    break;
                case 0x7F:
                    c = @"à";
                    break;
                default:
                    c = [NSString stringWithFormat:@"%c",inBytes[i]];
                    break;
            }
        }
        [out appendString:c];
    }
    return out;
}
#endif

@end
