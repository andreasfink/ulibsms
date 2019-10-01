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
    
    NSInteger spipos = p;
    NSInteger rcend = p + CHL;
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
    for(NSInteger i=p;i<rcend;i++)
    {
        RC_CC_DS[j++] = bytes[i];
    }
    p = p + j;

    
    NSLog(@"CHL: %d (%02X)",CHL,CHL);
    NSLog(@"SPI: %d (%02X %02X)",SPI, ((SPI>>8) & 0xFF), (SPI & 0xFF));

    int c;
    NSLog(@"    X X X - - - - -   . . . . . . . . Reserved");
    c = (SPI >> 11) & 0x03;
    switch(c)
    {
        case 0:
            NSLog(@"    - - - 0 0 - - -   . . . . . . . . No counter available");
            break;
        case 1:
            NSLog(@"    - - - 0 1 - - -   . . . . . . . . Counter available; no replay or sequence checking");
            break;
        case 2:
            NSLog(@"    - - - 1 0 - - -   . . . . . . . . Process if and only if counter value is higher than the value in the RE");
            break;
        case 3:
            NSLog(@"    - - - 1 1 - - -   . . . . . . . . Process if and only if counter value is one higher than the value in the RE");
            break;
    }
    c = (SPI >> 10) & 0x01;
    switch(c)
    {
        case 0:
            NSLog(@"    - - - - - 0 - -   . . . . . . . . No Ciphering");
            break;
        case 1:
            NSLog(@"    - - - - - 1 - -   . . . . . . . . Ciphering");
            break;
    }
    c = (SPI >> 8) & 0x03;
    switch(c)
    {
        case 0:
            NSLog(@"    - - - - - - 0 0   . . . . . . . . No RC, CC or DS");
            break;
        case 1:
            NSLog(@"    - - - - - - 0 1   . . . . . . . . Redundancy Check");
            break;
        case 2:
            NSLog(@"    - - - - - - 1 0   . . . . . . . . Cryptographic Checksum");
            break;
        case 3:
            NSLog(@"    - - - - - - 1 1   . . . . . . . . Digital Signature");
            break;
    }

    NSLog(@"    . . . . . . . .   X X - - - - - - Reserved");

    c = (SPI >> 5) & 0x01;
    switch(c)
    {
        case 0:
            NSLog(@"    . . . . . . . .   - - 0 - - - - - PoR response shall be sent using SMS-DELIVER-REPORT");
            break;
        case 1:
            NSLog(@"    . . . . . . . .   - - 1 - - - - - PoR response shall be sent using SMS-SUBMIT");
            break;
    }
    c = (SPI >> 4) & 0x01;
    switch(c)
    {
        case 0:
            NSLog(@"    . . . . . . . .   - - - 0 - - - - PoR response shall not be ciphered");
            break;
        case 1:
            NSLog(@"    . . . . . . . .   - - - 1 - - - - PoR response shall be ciphered");
            break;
    }
    c = (SPI >> 2) & 0x03;

    switch(c)
    {
        case 0:
            NSLog(@"    . . . . . . . .   - - - - 0 0 - - No RC, CC or DS applied to PoR response to SE");
            break;
        case 1:
            NSLog(@"    . . . . . . . .   - - - - 0 1 - - PoR response with simple RC applied to it");
            break;
        case 2:
            NSLog(@"    . . . . . . . .   - - - - 1 0 - - PoR response with CC applied to it");
            break;
        case 3:
            NSLog(@"    . . . . . . . .   - - - - 1 1 - - PoR response with DS applied to it");
            break;
    }
    c = (SPI >> 0) & 0x03;
    switch(c)
    {
        case 0:
            NSLog(@"    . . . . . . . .   - - - - - - 0 0 No PoR reply to the Sending Entity (SE)");
            break;
        case 1:
            NSLog(@"    . . . . . . . .   - - - - - - 0 1 PoR required to be sent to the SE");
            break;
        case 2:
            NSLog(@"    . . . . . . . .   - - - - - - 1 0 PoR required only when an error has occured");
            break;
        case 3:
            NSLog(@"    . . . . . . . .   - - - - - - 1 1 Reserved");
            break;
    }

    NSLog(@"KIc: %d",KIc);

    NSLog(@"    %d %d %d %d - - - -                   indication of Keys to be used", ((KIc >>7)?1:0),((KIc >>6)?1:0),((KIc >>5)?1:0),((KIc >>4)?1:0) );

    c = (KIc >> 2) & 0x03;
    switch(c)
    {
        case 0:
            NSLog(@"    - - - - 0 0 - -                   DES in CBC mode");
            break;
        case 1:
            NSLog(@"    - - - - 0 1 - -                   Triple DES in outer-CBC mode using two different keys");
            break;
        case 2:
            NSLog(@"    - - - - 1 0 - -                   Triple DES in outer-CBC mode using three different keys");
            break;
        case 3:
            NSLog(@"    - - - - 1 1 - -                   DES in ECB mode");
            break;
    }
    c = (KIc >> 0) & 0x03;
    switch(c)
    {
        case 0:
            NSLog(@"    - - - - - - 0 0                   Algorithm known implicitly by both entities");
            break;
        case 1:
            NSLog(@"    - - - - - - 0 1                   DES");
            break;
        case 2:
            NSLog(@"    - - - - - - 1 0                   Reserved");
            break;
        case 3:
            NSLog(@"    - - - - - - 1 1                   proprietary Implementations");
            break;
    }

    NSLog(@"KID: %d",KID);
    NSLog(@"    %d %d %d %d - - - -                   indication of Keys to be used", ((KID >>7)?1:0),((KID >>6)?1:0),((KID >>5)?1:0),((KID >>4)?1:0) );

    c = (KID >> 2) & 0x03;
    switch(c)
    {
        case 0:
            NSLog(@"    - - - - 0 0 - -                   DES in CBC mode");
            break;
        case 1:
            NSLog(@"    - - - - 0 1 - -                   Triple DES in outer-CBC mode using two different keys");
            break;
        case 2:
            NSLog(@"    - - - - 1 0 - -                   Triple DES in outer-CBC mode using three different keys");
            break;
        case 3:
            NSLog(@"    - - - - 1 1 - -                   DES in ECB mode");
            break;
    }
    c = (KID >> 0) & 0x03;
    switch(c)
    {
        case 0:
            NSLog(@"    - - - - - - 0 0                   Algorithm known implicitly by both entities");
            break;
        case 1:
            NSLog(@"    - - - - - - 0 1                   DES");
            break;
        case 2:
            NSLog(@"    - - - - - - 1 0                   Reserved");
            break;
        case 3:
            NSLog(@"    - - - - - - 1 1                   proprietary Implementations");
            break;
    }

    NSLog(@"TAR: %02X %02X %02X (%d)",TAR_bytes[0],TAR_bytes[1],TAR_bytes[2],TAR);
    NSLog(@"CNTR: %02X %02X %02X %02X %02X",CNTR[0],CNTR[1],CNTR[2],CNTR[3],CNTR[4]);
    NSLog(@"PCNTR: %d",PCNTR);
    NSMutableString *s = [[NSMutableString alloc]init];
    for(int i=0;i<j;i++)
    {
        [s appendFormat:@" %02X",RC_CC_DS[i]];
    }

    NSLog(@"RC_CC_DS:%@",s);

    s = [[NSMutableString alloc]init];
    for(int i=p;i<len;i++)
    {
        [s appendFormat:@" %02X",bytes[i]];
    }
    NSLog(@"Payload:%@",s);


}
