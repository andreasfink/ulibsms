//
//  NSString+sms.h
//  ulibsms
//
//  Created by Andreas Fink on 05.12.2025.
//

#import <ulib/ulib.h>


@interface NSString(sms)
- (NSData *) smsGsm8;
- (NSData *) smsGsm7WithNibbleLenPrefix;

@end


