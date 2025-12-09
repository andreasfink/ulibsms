//
//  NSData+sms.h
//  ulibsms
//
//  Created by Andreas Fink on 05.12.2025.
//

#import <ulib/ulib.h>

@interface NSData(sms)
-(NSString *)smsStringFromGsm7withNibbleLengthPrefix;
-(NSData *)smsGsm8to7withNibbleLengthPrefix;
-(NSData *)smsGsm7to8:(int)nibblelen;
-(NSString *)smsStringFromGsm8;
-(NSString *)smsStringFromGsm7:(int)nibblelen;
-(NSData *)smsGsm8to7: (int *)nibblelen;

@end

