//
//  NSData+sms.h
//  ulibsms
//
//  Copyright © 2025 Andreas Fink (andreas@fink.org). All rights reserved.
//
// This source is dual licensed either under the GNU GENERAL PUBLIC LICENSE
// Version 3 from 29 June 2007 and other commercial licenses available by
// the author.
//

#import <ulibasn1/ulibasn1.h>

@interface NSData (map)

- (NSString *) smsStringFromGsm7withNibbleLengthPrefix;
- (NSString *) smsStringFromGsm7:(int)nibblelen;
- (NSString *) smsStringFromGsm8;
- (NSMutableData *) sms7to8:(int)nibblelen;    /* Note: the 7 bit presentation always have a 'length' byte in nibbles in front */
- (NSMutableData *) sms8to7:(int *)nibblelen;
- (NSMutableData *) sms8to7withNibbleLengthPrefix;
@end


