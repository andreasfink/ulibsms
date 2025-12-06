//
//  NSData+sms.m
//  ulibsms
//
//  Created by Andreas Fink on 05.12.2025.
//

#import "NSData+sms.h"
#import "GsmCharSet.h"

@implementation NSData(sms)

- (NSString *) smsStringFromGsm7withNibbleLengthPrefix
{
    NSData                *d;
    const unsigned char    *b;
    NSString            *s;
    int                    nibblelen;

    if([self length]< 2)
        return @"";
    b = [self bytes];
    nibblelen = b[0];
    d = [[NSData alloc]initWithBytesNoCopy:(void *)[self bytes]+1 length: [self length]-1 freeWhenDone:0];
    s = [d smsStringFromGsm7:nibblelen];
    return s;
}

- (NSString *) smsStringFromGsm7:(int)nibblelen
{
    
    return [[self smsGsm7to8:nibblelen]smsStringFromGsm8];
}
   
-(NSString *) smsStringFromGsm8
{
    ssize_t i;
    ssize_t j;
    ssize_t n;
    uint16_t c1;
    unichar c;
    const unsigned char    *b = NULL;
    unichar             *uni = NULL;
    NSMutableData       *ubuf = NULL;
    NSString        *r = NULL;

    b = [self bytes];
    n = [self length];

    ubuf = [[NSMutableData  alloc]initWithCapacity: ((n+1) * 2)];
    uni = (unichar *)[ubuf bytes];
    j = 0;
    c1 = 0x00;
    for(i=0;i<n;i++)
    {
        c1 = c1 | b[i];
        switch(c1)
        {
            case 0x27:
                c1 = 0x2700;
                continue;
            case 0x2728:
                c = '{';
                break;
            case 0x2729:
                c = '}';
                break;
            case 0x273C:
                c = '[';
                break;
            case 0x273D:
                c = '~';
                break;
            case 0x273E:
                c = ']';
                break;
            case 0x272F:
                c = '\\';
                break;
            case 0x2765:
                c = 0x20AC; /* euro symbol */
                break;
            case 0x2714:
                c = '^';
                break;
            default:
                if(c1 > smsGsmToUnicode_table_size || (c1 < 0))
                {
                    c = ' ';
                }
                else
                {
                    c = smsGsmToUnicode[c1];
                }
        }
        uni[j++]= c;
        c1 = 0x00;
    }
    r = [[NSString alloc]initWithCharacters:uni length:j];
    return r;
}
- (NSData *)smsGsm7to8:(int)nibblelen
{
    NSMutableData *result = NULL;
    int inbyte = 0;
    int outbyte = 0;
    ssize_t len;
    ssize_t i;
    int bi;
    int bo;
    int bit;
    int    total_bitcount;
    const unsigned char *bytes;
    unsigned char ob;
    
       len = [self length];
    result = [[NSMutableData alloc]initWithCapacity: (len*8/7)+1];
    i = 0;
    bi = 0;
    bo = 0;
    bytes = (const unsigned char *)[self bytes];
    inbyte = bytes[i++];
    
    total_bitcount = nibblelen * 4;
    while (total_bitcount--)
    {
        bit = inbyte & 0x01;
        bi++;
        outbyte = ((outbyte >> 1) & 0x3F) | (bit << 6);
        bo++;
        if (bo > 6)
        {
            ob = outbyte & 0xFF;
            [result appendBytes:&ob length:1];
            outbyte = 0;
            bo = 0;
        }
        if (bi > 7)    /* we have consumed 8 bits, we need another byte */
        {
            if (i >=len) /* no byte left? drop out */
                break;
            inbyte = bytes[i++];
            bi = 0;
        }
        else
        {
            inbyte = inbyte >> 1;
        }
    }
    return result;
}

-(NSString *) smspStringFromGsm8
{
    ssize_t i;
    ssize_t j;
    ssize_t n;
    uint16_t c1;
    unichar c;
    const unsigned char    *b = NULL;
    unichar            *uni = NULL;
    NSMutableData    *ubuf = NULL;
    NSString        *r = NULL;

    b = [self bytes];
    n = [self length];

    ubuf = [[NSMutableData  alloc]initWithCapacity: ((n+1) * 2)];
    uni = (unichar *)[ubuf bytes];
    j = 0;
    c1 = 0x00;
    for(i=0;i<n;i++)
    {
        c1 = c1 | b[i];
        switch(c1)
        {
            case 0x27:
                c1 = 0x2700;
                continue;
            case 0x2728:
                c = '{';
                break;
            case 0x2729:
                c = '}';
                break;
            case 0x273C:
                c = '[';
                break;
            case 0x273D:
                c = '~';
                break;
            case 0x273E:
                c = ']';
                break;
            case 0x272F:
                c = '\\';
                break;
            case 0x2765:
                c = 0x20AC; /* euro symbol */
                break;
            case 0x2714:
                c = '^';
                break;
            default:
                if(c1 > smsGsmToUnicode_table_size || (c1 < 0))
                {
                    c = ' ';
                }
                else
                {
                    c = smsGsmToUnicode[c1];
                }
        }
        uni[j++]= c;
        c1 = 0x00;
    }
    r = [[NSString alloc]initWithCharacters:uni length:j];
    return r;
}

- (NSData *) smsGsm8to7withNibbleLengthPrefix
{
    int nibblelen=0;
    unsigned char c=0;
    NSMutableData *m = [[self smsGsm8to7:&nibblelen] mutableCopy];
    c=nibblelen;
    NSMutableData *n = [[NSMutableData alloc]initWithBytes:&c length:1];
    [n appendData:m];
    return n;
}



- (NSData *)smsGsm8to7: (int *)nibblelen;
{
    NSMutableData *result = NULL;
    ssize_t len=0;
    ssize_t i=0;
    int numbits=0;
    int value=0;
    ssize_t    len2=0;
    const unsigned char *bytes=NULL;
    unsigned char b=0;
    
    len    = [self length];
    result = [[NSMutableData alloc]init];
    bytes  = [self bytes];
    
    len2 = (len * 7 + 3) / 4;
    if(len2 > 0x7F)
    {
        NSLog(@"trying to do gsm8to7 with len2 = %d. That can't work",(int)len2);
    }
    *nibblelen = len2 & 0xFF;
    //[result appendBytes:&b    length:1];

    value = 0;
    numbits = 0;
    for (i = 0; i < len; i++)
    {
        value += bytes[i]<< numbits;
        numbits += 7;
        if (numbits >= 8)
        {
            b = value & 0xFF;
            [result appendBytes:&b    length:1];
            value >>= 8;
            numbits -= 8;
        }
    }
    if (numbits > 0)
    {
        b = value & 0xFF;
        [result appendBytes:&b    length:1];
    }
    if((*nibblelen!=11) || (result.length !=7))
    {
        [result appendBytes:&b    length:1];
    }
    return result;
}

@end
