//
//  UMSMS_Address.m
//  ulibsms
//
//  © 2016  by Andreas Fink
//
// This source is dual licensed either under the GNU GENERAL PUBLIC LICENSE
// Version 3 from 29 June 2007 and other commercial licenses available by
// the author.
//
#import "UMSMS_Address.h"
#import <ulibgsmmap/ulibgsmmap.h>

static int is_all_digits(const char *text, NSUInteger startpos, NSUInteger len);

static int is_all_digits(const char *text, NSUInteger startpos, NSUInteger len)
{
    NSUInteger i=0;
    for(i=startpos;i<len;i++)
    {
        switch(text[i])
        {
            case	'0':
            case	'1':
            case	'2':
            case	'3':
            case	'4':
            case	'5':
            case	'6':
            case	'7':
            case	'8':
            case	'9':
            case	'*':
            case	'#':
            case	'a':
                break;
            default:
                return 0;
        }
    }
    return 1;
}


@implementation UMSMS_Address

@synthesize ton;
@synthesize npi;
@synthesize address;

- (UMSMS_Address *)initWithString:(NSString *)digits
{
    self = [super init];
    if(self)
    {
        if(digits == nil)
        {
            address = @"";
            ton = 0;
            npi = 0;
        }
        else if([digits length] < 2)
        {
            address = @"";
            ton = 0;
            npi = 0;
        }
        else if ([digits compare:@"+" options:NSLiteralSearch range:NSMakeRange(0,1)] == NSOrderedSame )
        {
            address = [digits substringFromIndex:1];
            ton = 1;
            npi = 1;
        }
        else if(([digits length] >= 2) && ( [digits compare:@"00" options:NSLiteralSearch  range:NSMakeRange(0,2)] == NSOrderedSame ))
        {
            address = [digits substringFromIndex:2];
            ton = 1;
            npi = 1;
        }
        else if ( [digits compare:@"0" options:NSLiteralSearch range:NSMakeRange(0,1)] == NSOrderedSame )
        {
            address = [digits substringFromIndex:1];
            ton = 2;
            npi = 1;
        }
        else if ([digits compare:@":" options:NSLiteralSearch range:NSMakeRange(0,1)] == NSOrderedSame )
        {
            int aton;
            int anpi;
            
            char number[257];
            char numstr[257];
            memset(number,0,sizeof(number) );
            memset(numstr,0,sizeof(numstr));
            strncpy(numstr,[digits UTF8String],(sizeof(numstr)-1));
            
            /* this should do somehting like this sscanf(numstr,":%d:%d:%s",&aton,&anpi,number);
             but it should be safe to have additional : in the remaining string part */
            size_t i=0;
            size_t n=strlen(numstr);
            size_t colon_pos[3];
            int colon_index=0;
            
            for(i=0;i<n;i++)
            {
                if(numstr[i]==':')
                {
                    colon_pos[colon_index++] = i;
                    if (colon_index >=3)
                    {
                        break;
                    }
                }
            }
            if(colon_index < 3)
            {
                address = @"";
                ton = 0;
                npi = 0;
                return self;
            }
            numstr[colon_pos[1]]='\0';
            numstr[colon_pos[2]]='\0';
            aton = atoi(&numstr[colon_pos[0]+1]);
            anpi = atoi(&numstr[colon_pos[1]+1]);
            strncpy(number,&numstr[colon_pos[2]+1],(sizeof(number)-1));
            
            ton = aton % 8;
            npi = anpi % 16;
            size_t len = strlen(number);
            if(ton==5) /* alphanumeric */
            {
                address = [[NSString alloc] initWithBytes:number length:len encoding:(NSUTF8StringEncoding)];
            }
            else
            {
                size_t j=0;
                if(len >= sizeof(number))
                {
                    len = sizeof(number)-1;
                }
                for(i=0;i<len;i++)
                {
                    switch(number[i])
                    {
                        case '0':
                        case '1':
                        case '2':
                        case '3':
                        case '4':
                        case '5':
                        case '6':
                        case '7':
                        case '8':
                        case '9':
                            number[j++]=number[i];
                            break;
                        case 'A':
                        case 'a':
                            number[j++]='A';
                            break;
                        case 'B':
                        case 'b':
                            number[j++]='B';
                            break;
                        case 'C':
                        case 'c':
                            number[j++]='C';
                            break;
                        case 'D':
                        case 'd':
                            number[j++]='D';
                            break;
                        case 'E':
                        case 'e':
                            number[j++]='E';
                            break;
                        case 'F':
                        case 'f':
                            number[j++]='F';
                            break;
                        default:
                            break;
                    }
                }
                number[j] = '\0';
                address = @(number);
            }
        }
        else
        {
            if(is_all_digits(digits.UTF8String, 0,digits.length)==0)
            {
                ton = 5;
                npi = 0;
                address = [[[digits gsm8]gsm8to7withNibbleLengthPrefix]hexString];
            }
            else
            {
                ton = 1;
                npi = 1;
                address = digits;
            }
        }
    }
    return self;
}

- (UMSMS_Address *)initWithAddress:(NSString *)msisdn ton:(GSMMAP_TonType)xton npi:(GSMMAP_NpiType)xnpi
{
    self = [super init];
    if(self)
    {
        ton = xton;
        npi = xnpi;
        address = msisdn;
    }
    return self;
}


- (NSData *)encoded
{
    NSMutableData *d = [[NSMutableData alloc]init];
    
    NSUInteger len = address.length;
    int b = ((ton & 0x07) << 4) | (npi & 0x0F);
    
    NSString *addr = address;
    
    if(ton != 5) /* not alphanumeric */
    {
        if(len > 255)
        {
            @throw([NSException exceptionWithName:@"BUFFER_OVERRUN"
                                           reason:@"writing beyond size of pdu"
                                         userInfo:@{@"file": @(__FILE__), @"line": @(__LINE__)} ]);
        }

        if(len & 0x01) /* odd */
        {
            addr = [NSString stringWithFormat:@"%@F",addr]; /* add filler */
        }
        
        [d appendByte:(uint8_t)len];
        [d appendByte:(uint8_t)b];
        NSData *addrdata = [addr unhexedData];
        const uint8_t *bytes = addrdata.bytes;
        NSUInteger i;
        NSUInteger n = addrdata.length;
        for(i=0;i<n;i++)
        {
            uint8_t c = bytes[i];
            uint8_t c2 = ((c & 0x0F) << 4) | ((c & 0xF0) >>4 );
            [d appendByte:c2];
        }
    }
    else
    {
        @throw([NSException exceptionWithName:@"NOT_IMPLEMENTED_YET"
                                       reason:@"encoding of alphanumeric address not yet implemented"
                                     userInfo:@{@"file": @(__FILE__), @"line": @(__LINE__)} ]);
        
    }
    return d;
}
@end
