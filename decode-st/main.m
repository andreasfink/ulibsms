//
//  main.m
//  decode-st
//
//  Created by Andreas Fink on 25.09.2019.
//  Copyright © 2019 Andreas Fink (andreas@fink.org). All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ulib/ulib.h>
#import "UMSATCommands.h"

void DecodeSTPayload(NSData *data,NSString *ident);
void DecodeDeck(NSData *data,NSString *ident);
void DecodeCard(NSData *data,NSString *ident);
void DecodeST(NSData *data);

int main(int argc, const char * argv[])
{
#if 1
    NSString *s = @"027000002e0d00000000505348000000000000421e811c200201618516702d112181020d0cf468656c6c6f20776f726c642b00";
   // NSString *s=@"00501115001500b00010da16d560989b32c302bcf9e3a68d55663d58d794468020a6dd8692037a2d9719b39e489220de600645a6409ca954247542ba6b84756d0a864008d4e76ddd97299dc69b3f59d13c18";

    NSData *d = [s unhexedData];
    DecodeST(d);
#else
    for(int idx=1;idx<argc;idx++)
    {
        @autoreleasepool
        {
            NSString *s = @(argv[idx]);
            NSData *d = [s unhexedData];
            DecodeST(d);
        }
    }
#endif
    return 0;
}

void DecodeST(NSData *data)
{
    uint8_t *bytes = (uint8_t *) data.bytes;
    NSInteger len = data.length;
    NSInteger p = 0;
    /*
    for(int i=0;i<len;i++)
    {
        fprintf(stdout,"Byte[%d] = %02X =  %d\n",i,bytes[i],bytes[i]);
    }
     */
    /* 3GPP TS 23.048 version 5.9.0 Release 5 17 ETSI TS 123 048 V5.9.0 (2005-06)*/
    
    /* UDH Header */
    if(len<3)
    {
        return;
    }
    if( (bytes[0]==0x02) &&
        ((bytes[1]==0x70) || (bytes[1]==0x71)) &&
        (bytes[3]==0x00))
    {
        fprintf(stdout,"Skipping UDH header 02 70 00\n");
        p += 3;
    }
    int CPL = 0;
    int CHL = 0;
    int SPI;
    int KIc;
    int KID;
    uint8_t TAR_bytes[3];
    int TAR;
    uint8_t CNTR[5];
    int PCNTR;
    uint8_t RC_CC_DS[8];
    
    if((p+1)<len)
    {
        CPL = (bytes[p] << 8) | bytes[p+1];
        fprintf(stdout,"CPL:      %d (%02X %02X)\n",CPL,bytes[p],bytes[p+1]);
        p = p + 2;
    }

    if(p>=len)
    {
        return;
    }
    CHL = bytes[p++];
    
    NSInteger spipos = p;
    NSInteger rcend = p + CHL;
    SPI = (bytes[p] << 8) || bytes[p+1];
    p+=2;

    KIc = bytes[p++];
    KID = bytes[p++];
    TAR_bytes[0] = bytes[p];
    TAR_bytes[1] = bytes[p+1];
    TAR_bytes[2] = bytes[p+2];
    TAR = (TAR_bytes[0] << 16) | (TAR_bytes[1] << 8) | TAR_bytes[2];
    p+=3;
    CNTR[0] = bytes[p++];
    CNTR[1] = bytes[p++];
    CNTR[2] = bytes[p++];
    CNTR[3] = bytes[p++];
    CNTR[4] = bytes[p++];
    PCNTR = bytes[p++];

    int j=0;
    for(NSInteger i=p;i<rcend;i++)
    {
        RC_CC_DS[j++] = bytes[i];
    }
    p = p + j;

    
    fprintf(stdout,"CHL:      0x%02X (%d)\n",CHL,CHL);
    fprintf(stdout,"SPI:      0x%02X%02X (%d)\n",((SPI>>8) & 0xFF), (SPI & 0xFF),SPI);

    int c;
    fprintf(stdout,"          X X X - - - - -   . . . . . . . . Reserved\n");
    c = (SPI >> 11) & 0x03;
    switch(c)
    {
        case 0:
            fprintf(stdout,"          - - - 0 0 - - -   . . . . . . . . No counter available\n");
            break;
        case 1:
            fprintf(stdout,"          - - - 0 1 - - -   . . . . . . . . Counter available; no replay or sequence checking\n");
            break;
        case 2:
            fprintf(stdout,"          - - - 1 0 - - -   . . . . . . . . Process if and only if counter value is higher than the value in the RE\n");
            break;
        case 3:
            fprintf(stdout,"          - - - 1 1 - - -   . . . . . . . . Process if and only if counter value is one higher than the value in the RE\n");
            break;
    }
    c = (SPI >> 10) & 0x01;
    switch(c)
    {
        case 0:
            fprintf(stdout,"          - - - - - 0 - -   . . . . . . . . No Ciphering\n");
            break;
        case 1:
            fprintf(stdout,"          - - - - - 1 - -   . . . . . . . . Ciphering\n");
            break;
    }
    c = (SPI >> 8) & 0x03;
    switch(c)
    {
        case 0:
            fprintf(stdout,"          - - - - - - 0 0   . . . . . . . . No RC, CC or DS\n");
            break;
        case 1:
            fprintf(stdout,"          - - - - - - 0 1   . . . . . . . . Redundancy Check\n");
            break;
        case 2:
            fprintf(stdout,"          - - - - - - 1 0   . . . . . . . . Cryptographic Checksum\n");
            break;
        case 3:
            fprintf(stdout,"          - - - - - - 1 1   . . . . . . . . Digital Signature\n");
            break;
    }

    fprintf(stdout,"          . . . . . . . .   X X - - - - - - Reserved\n");

    c = (SPI >> 5) & 0x01;
    switch(c)
    {
        case 0:
            fprintf(stdout,"          . . . . . . . .   - - 0 - - - - - PoR response shall be sent using SMS-DELIVER-REPORT\n");
            break;
        case 1:
            fprintf(stdout,"          . . . . . . . .   - - 1 - - - - - PoR response shall be sent using SMS-SUBMIT\n");
            break;
    }
    c = (SPI >> 4) & 0x01;
    switch(c)
    {
        case 0:
            fprintf(stdout,"          . . . . . . . .   - - - 0 - - - - PoR response shall not be ciphered\n");
            break;
        case 1:
            fprintf(stdout,"          . . . . . . . .   - - - 1 - - - - PoR response shall be ciphered\n");
            break;
    }
    c = (SPI >> 2) & 0x03;

    switch(c)
    {
        case 0:
            fprintf(stdout,"          . . . . . . . .   - - - - 0 0 - - No RC, CC or DS applied to PoR response to SE\n");
            break;
        case 1:
            fprintf(stdout,"          . . . . . . . .   - - - - 0 1 - - PoR response with simple RC applied to it\n");
            break;
        case 2:
            fprintf(stdout,"          . . . . . . . .   - - - - 1 0 - - PoR response with CC applied to it\n");
            break;
        case 3:
            fprintf(stdout,"          . . . . . . . .   - - - - 1 1 - - PoR response with DS applied to it\n");
            break;
    }
    c = (SPI >> 0) & 0x03;
    switch(c)
    {
        case 0:
            fprintf(stdout,"          . . . . . . . .   - - - - - - 0 0 No PoR reply to the Sending Entity (SE)\n");
            break;
        case 1:
            fprintf(stdout,"          . . . . . . . .   - - - - - - 0 1 PoR required to be sent to the SE\n");
            break;
        case 2:
            fprintf(stdout,"          . . . . . . . .   - - - - - - 1 0 PoR required only when an error has occured\n");
            break;
        case 3:
            fprintf(stdout,"          . . . . . . . .   - - - - - - 1 1 Reserved\n");
            break;
    }

    fprintf(stdout,"KIc:      0x%02X (%d)\n",KIc,KIc);

    fprintf(stdout,"          %d %d %d %d - - - -                   indication of Keys to be used\n", ((KIc >>7)?1:0),((KIc >>6)?1:0),((KIc >>5)?1:0),((KIc >>4)?1:0) );

    c = (KIc >> 2) & 0x03;
    switch(c)
    {
        case 0:
            fprintf(stdout,"          - - - - 0 0 - -                   DES in CBC mode\n");
            break;
        case 1:
            fprintf(stdout,"          - - - - 0 1 - -                   Triple DES in outer-CBC mode using two different keys\n");
            break;
        case 2:
            fprintf(stdout,"          - - - - 1 0 - -                   Triple DES in outer-CBC mode using three different keys\n");
            break;
        case 3:
            fprintf(stdout,"          - - - - 1 1 - -                   DES in ECB mode\n");
            break;
    }
    c = (KIc >> 0) & 0x03;
    switch(c)
    {
        case 0:
            fprintf(stdout,"          - - - - - - 0 0                   Algorithm known implicitly by both entities\n");
            break;
        case 1:
            fprintf(stdout,"          - - - - - - 0 1                   DES\n");
            break;
        case 2:
            fprintf(stdout,"          - - - - - - 1 0                   Reserved\n");
            break;
        case 3:
            fprintf(stdout,"          - - - - - - 1 1                   proprietary Implementations\n");
            break;
    }

    fprintf(stdout,"KID:      0x%02X (%d)\n",KID,KID);
    fprintf(stdout,"          %d %d %d %d - - - -                   indication of Keys to be used\n", ((KID >>7)?1:0),((KID >>6)?1:0),((KID >>5)?1:0),((KID >>4)?1:0) );

    c = (KID >> 2) & 0x03;
    switch(c)
    {
        case 0:
            fprintf(stdout,"          - - - - 0 0 - -                   DES in CBC mode\n");
            break;
        case 1:
            fprintf(stdout,"          - - - - 0 1 - -                   Triple DES in outer-CBC mode using two different keys\n");
            break;
        case 2:
            fprintf(stdout,"          - - - - 1 0 - -                   Triple DES in outer-CBC mode using three different keys\n");
            break;
        case 3:
            fprintf(stdout,"          - - - - 1 1 - -                   DES in ECB mode\n");
            break;
    }
    c = (KID >> 0) & 0x03;
    switch(c)
    {
        case 0:
            fprintf(stdout,"          - - - - - - 0 0                   Algorithm known implicitly by both entities\n");
            break;
        case 1:
            fprintf(stdout,"          - - - - - - 0 1                   DES\n");
            break;
        case 2:
            fprintf(stdout,"          - - - - - - 1 0                   Reserved\n");
            break;
        case 3:
            fprintf(stdout,"          - - - - - - 1 1                   proprietary Implementations\n");
            break;
    }

    fprintf(stdout,"TAR:      0x%02X%02X%02X (%d)\n",TAR_bytes[0],TAR_bytes[1],TAR_bytes[2],TAR);
    fprintf(stdout,"CNTR:     0x%02X%02X%02X%02X%02X\n",CNTR[0],CNTR[1],CNTR[2],CNTR[3],CNTR[4]);
    fprintf(stdout,"PCNTR:    0x%2X (%d)\n",PCNTR,PCNTR);
    NSMutableString *s = [[NSMutableString alloc]init];
    for(int i=0;i<j;i++)
    {
        [s appendFormat:@"%02X",RC_CC_DS[i]];
    }

    fprintf(stdout,"RC_CC_DS: 0x%s\n",s.UTF8String);

    s = [[NSMutableString alloc]init];
    NSData *payload = [NSData dataWithBytes:&bytes[p] length:len-p];
    for(NSInteger i=p;i<len;i++)
    {
        [s appendFormat:@" %02X",bytes[i]];
        if((i-p+1)%16==0)
        {
            [s appendString:@"\n         "];
        }
    }
    fprintf(stdout,"Payload: %s\n",s.UTF8String);
    DecodeSTPayload(payload,@"");
}



void DecodeSTPayload(NSData *data, NSString *ident)
{
    uint8_t *bytes = (uint8_t *)data.bytes;
    int len = (int)data.length;
    for(int i=0;i<len;)
    {
        BOOL container = NO;
        uint8_t token = bytes[i++];
        NSString *s = [UMSATCommands tagName:token];

        token = 0x7F & token;
        fprintf(stdout,"\n%sTAG     0x%02X %s\n",ident.UTF8String,token,s.UTF8String);
        int taglen = [UMSATCommands readLength:bytes pos:&i len:len];
        fprintf(stdout,"%sLEN     0x%02X (%d)\n",ident.UTF8String,taglen,taglen);

        if((token==0x42) || (token==STK_TAG_Deck))
        {
            container = YES;
        }
        if(token & 0x80)
        {
            uint64_t attributes = 0;
            int bitshift = 0;

            uint8_t attribute = bytes[i++];
            do
            {
                attribute = bytes[i++];
                attributes = attributes | ((attribute & 0x7F) << bitshift);
                bitshift +=7;
                fprintf(stdout,"%sATTR    0x%02X\n",ident.UTF8String,attribute);
            } while(attribute & 80);
            for(i=0;i<64;i++)
            {
                if((1<<i) & attributes)
                {
                    fprintf(stdout,"%s        Attribute_%d set\n",ident.UTF8String,i);
                }
            }
        }
        if(taglen>0)
        {
            fprintf(stdout,"%sDATA    ",ident.UTF8String);
            for(int j=0;j<taglen;j++)
            {
                fprintf(stdout,"0x%02X ",(int)bytes[i++]);
            }
            fprintf(stdout,"\n");
        }
        if(container)
        {
            ident = [NSString stringWithFormat:@"   %@",ident];
            NSData *d = [NSData dataWithBytes:&bytes[i-taglen] length:taglen];
            DecodeSTPayload(d,ident);
        }
    }
}



void DecodeDeck(NSData *data, NSString *ident)
{
    uint8_t *bytes = (uint8_t *)data.bytes;
    int len = (int)data.length;
    for(int i=0;i<len;)
    {
        BOOL container = NO;
        uint8_t token = bytes[i++];
        NSString *s = [UMSATCommands tagName:token];

        token = 0x7F & token;
        fprintf(stdout,"\n%sTAG     0x%02X %s\n",ident.UTF8String,token,s.UTF8String);
        int taglen = [UMSATCommands readLength:bytes pos:&i len:len];
        fprintf(stdout,"%sLEN     0x%02X (%d)\n",ident.UTF8String,taglen,taglen);

        if((token==0x42) || (token==STK_TAG_Deck))
        {
            container = YES;
        }
        if(token & 0x80)
        {
            uint64_t attributes = 0;
            int bitshift = 0;

            uint8_t attribute = bytes[i++];
            do
            {
                attribute = bytes[i++];
                attributes = attributes | ((attribute & 0x7F) << bitshift);
                bitshift +=7;
                fprintf(stdout,"%sATTR    0x%02X\n",ident.UTF8String,attribute);
            } while(attribute & 80);
            for(i=0;i<64;i++)
            {
                if((1<<i) & attributes)
                {
                    fprintf(stdout,"%s        Attribute_%d set\n",ident.UTF8String,i);
                }
            }
        }
        if(taglen>0)
        {
            fprintf(stdout,"%sDATA    ",ident.UTF8String);
            for(int j=0;j<taglen;j++)
            {
                fprintf(stdout,"0x%02X ",(int)bytes[i++]);
            }
            fprintf(stdout,"\n");
        }
        ident = [NSString stringWithFormat:@"   %@",ident];

    }
}


void DecodeCard(NSData *data, NSString *ident)
{
    uint8_t *bytes = (uint8_t *)data.bytes;
    int len = (int)data.length;
    for(int i=0;i<len;)
    {
        BOOL container = NO;
        uint8_t token = bytes[i++];
        NSString *s = [UMSATCommands tagName:token];

        token = 0x7F & token;
        fprintf(stdout,"\n%sTAG     0x%02X %s\n",ident.UTF8String,token,s.UTF8String);
        int taglen = [UMSATCommands readLength:bytes pos:&i len:len];
        fprintf(stdout,"%sLEN     0x%02X (%d)\n",ident.UTF8String,taglen,taglen);

        if((token==0x42) || (token==STK_TAG_Deck))
        {
            container = YES;
        }
        if(token & 0x80)
        {
            uint64_t attributes = 0;
            int bitshift = 0;

            uint8_t attribute = bytes[i++];
            do
            {
                attribute = bytes[i++];
                attributes = attributes | ((attribute & 0x7F) << bitshift);
                bitshift +=7;
                fprintf(stdout,"%sATTR    0x%02X\n",ident.UTF8String,attribute);
            } while(attribute & 80);
            for(i=0;i<64;i++)
            {
                if((1<<i) & attributes)
                {
                    fprintf(stdout,"%s        Attribute_%d set\n",ident.UTF8String,i);
                }
            }
        }
        if(taglen>0)
        {
            fprintf(stdout,"%sDATA    ",ident.UTF8String);
            for(int j=0;j<taglen;j++)
            {
                fprintf(stdout,"0x%02X ",(int)bytes[i++]);
            }
            fprintf(stdout,"\n");
        }
        if(container)
        {
            ident = [NSString stringWithFormat:@"   %@",ident];
            NSData *d = [NSData dataWithBytes:&bytes[i-taglen] length:taglen];
            DecodeSTPayload(d,ident);
        }
    }
}
