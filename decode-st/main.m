//
//  main.m
//  decode-st
//
//  Created by Andreas Fink on 25.09.2019.
//  Copyright © 2019 Andreas Fink (andreas@fink.org). All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ulib/ulib.h>

void DecodeST(NSData *data);

int main(int argc, const char * argv[])
{
    NSString *s = @"027000002e0d00000000505348000000000000421e811c200201618516702d112181020d0cf468656c6c6f20776f726c642b00";
    NSData *d = [s unhexedData];
    DecodeST(d);
/*
    for(int idx=1;idx<argc;idx++)
    {
        @autoreleasepool
        {
            NSString *s = @(argv[idx]);
            NSData *d = [s unhexedData];
            DecodeST(d);
        }
    }
 */
    return 0;
}

void DecodeST(NSData *data)
{
    uint8_t *bytes = (uint8_t *) data.bytes;
    NSInteger len = data.length;
    NSInteger p = 0;
    
    for(int i=0;i<len;i++)
    {
        NSLog(@"Byte[%d] = %02X =  %d",i,bytes[i],bytes[i]);
    }
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
        NSLog(@"Skipping UDH header 02 70 00");
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
        NSLog(@"CPL: %d (%02X %02X)",CPL,bytes[p],bytes[p+1]);
        p = p + 2;
    }

    if(p>=len)
    {
        return;
    }
    CHL = bytes[p++];
    
    int spipos = p;
    int rcend = p + CHL;
    SPI = (bytes[p] << 8) || bytes[p+1];
    p+=2;

    KIc = bytes[p++];
    KID = bytes[p++];
    TAR_bytes[0] = bytes[p];
    TAR_bytes[1] = bytes[p+1];
    TAR_bytes[2] = bytes[p+2];
    TAR = (bytes[p] << 16) || (bytes[p+1] << 8) || bytes[p+2];
    p+=3;
    CNTR[0] = bytes[p++];
    CNTR[1] = bytes[p++];
    CNTR[2] = bytes[p++];
    CNTR[3] = bytes[p++];
    CNTR[4] = bytes[p++];
    PCNTR = bytes[p++];

    int j=0;
    for(int i=spipos;i<rcend;i++)
    {
        RC_CC_DS[j++] = bytes[i];
    }
    p = p + j;

    
    NSLog(@"CHL: %d (%02X)",CHL,CHL);
    NSLog(@"SPI: %d (%02X %02X)",SPI, ((SPI>>8) & 0xFF), (SPI & 0xFF));
    NSLog(@"KIc: %d",KIc);
    NSLog(@"KID: %d",KID);
    NSLog(@"TAR: %02X %02X %02X (%d)",TAR_bytes[0],TAR_bytes[1],TAR_bytes[2],TAR);
    NSLog(@"CNTR: %02X %02X %02X %02X %02X",CNTR[0],CNTR[1],CNTR[2],CNTR[3],CNTR[4]);
    NSLog(@"PCNTR: %d",PCNTR);
    NSMutableString *s = [[NSMutableString alloc]init];
    for(int i=0;i<8;i++)
    {
        [s appendFormat:@" %02X",RC_CC_DS[i]];
    }
    NSLog(@"RC_CC_DS:%@",s);

}
