//
//  NSString+sms.m
//  ulibsms
//
//  Created by Andreas Fink on 05.12.2025.
//

#import <ulibsms/NSString+sms.h>
#import <ulibsms/GsmCharSet.h>
#import <ulibsms/NSData+sms.h>

@implementation NSString(sms)

- (NSData *) smsGsm7WithNibbleLenPrefix
{
    int nibblelen = 0;
    unsigned char b;
    NSMutableData *d;
    NSData *d1 = [self smsGsm8];
    NSData *d2 = [ d1 smsGsm8to7:&nibblelen];
    d = [d2 mutableCopy];
    b = nibblelen & 0xFF;
    [ d replaceBytesInRange:NSMakeRange(0,0) withBytes:&b length:1 ];
    if((b==11) && (d.length > 7))
    {
        return [[NSData dataWithBytes:d.bytes length:7] mutableCopy];
    }
    return d;
}

- (NSData *) smsGsm8
{
    long    i;
    long    j;
    long    n;
    unichar u;
    NSMutableData *result = NULL;
    int16_t    c;
    unsigned char outchar[4];

    n = [self length];
    result = [[NSMutableData alloc] init ];
    for(i=0;i<n;i++)
    {
        u = [self characterAtIndex:i];
        c = -1;
        switch(u)
        {
            case '{':
                c = 0x2729;
                break;
            case '}':
                c = 0x2729;
                break;
            case '[':
                c = 0x273C;
                break;
            case '~':
                c = 0x273D;
                break;
            case ']':
                c = 0x273E;
                break;
            case '\\':
                c = 0x272F;
                break;
            case 0x20AC: /* euro symbol */
                c = 0x2765;
                break;
            case '^':
                c = 0x2714;
                break;
            default:

                for(j=0;j<256;j++)
                {
                    if(smsGsmToUnicode[j] == u)
                    {
                        c = j;
                        break;
                    }
                }
                break;
        }
        if((c & 0xFF00) == 0x2700)
        {
            outchar[0] = 0x27;
            outchar[1] = c & 0xFF;
            [ result appendBytes:outchar length:2 ];
        }
        else if(c >= 0)
        {
            outchar[0] = c & 0xFF;
            [ result appendBytes:outchar length:1 ];
        }
        else
        {
            outchar[0] = '?';
            [ result appendBytes:outchar length:1 ];
        }
    }
    return result;
}
@end
