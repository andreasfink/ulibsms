//
//  NSData+sms.m
//  sms
//
//  Copyright © 2017 Andreas Fink (andreas@fink.org). All rights reserved.
//
// This source is dual licensed either under the GNU GENERAL PUBLIC LICENSE
// Version 3 from 29 June 2007 and other commercial licenses available by
// the author.
//

#import <ulibssm/NSData+sms.h>
#import <ulibgsmmap/NSString+map.h>
#import <ulibgsmmap/GsmCharSet.h>
#import <stdint.h>

#define NRP '?'

@implementation NSData (DataHexFunctions)

- (NSString *)smsStringFromGsm8
{
    NSMutableString *out = [[NSMutableString alloc]init];
    const uint8_t *inBytes = self.bytes;
    NSInteger i;
    NSInteger len = self.length;
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
                    break;
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
                case 0x1A:
                    c = @"Ξ";
                    break;
                case 0x01B:
                    escape = YES;
                    break;
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


-(NSString *) smsStringFromGsm7withNibbleLengthPrefix
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

-(NSString *) smsStringFromGsm7:(int)nibblelen
{
    return [[self sms7to8:nibblelen]smsStringFromGsm8];
}

- (NSMutableData *)sms7to8:(int)nibblelen
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

- (NSMutableData *)sms8to7:(int *)nibblelen;
{
    NSMutableData *result = NULL;
    ssize_t len=0;
    ssize_t i=0;
    int numbits=0;
    int value=0;
    ssize_t    len2=0;
    const unsigned char *bytes;
    unsigned char b;

    len    = [self length];
    result = [[NSMutableData alloc]init];
    bytes  = [self bytes];

    len2 = (len * 7 + 3) / 4;
    if(len2 > 0x7F)
    {
        NSLog(@"trying to do gsm8to7 with len2 = %ld. That can't work",len2);
    }
    if(nibblelen)
    {
        *nibblelen = len2 & 0xFF;
    }
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
    //[result appendBytes:&b    length:1];
    return result;
}

- (NSMutableData *) sms8to7withNibbleLengthPrefix
{
    int nibblelen;
    unsigned char c;
    NSMutableData *m = [self sms8to7:&nibblelen];
    NSMutableData *n = [[NSMutableData alloc]initWithBytes:&c length:1];
    [n appendData:m];
    return n;
}

@end
