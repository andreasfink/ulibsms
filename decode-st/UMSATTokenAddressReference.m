//
//  UMSATTokenAddressReference.m
//  decode-st
//
//  Created by Andreas Fink on 18.10.19.
//  Copyright © 2019 Andreas Fink (andreas@fink.org). All rights reserved.
//

#import "UMSATTokenAddressReference.h"

@implementation UMSATTokenAddressReference


- (NSString *)descriptionWithPrefixMain:(NSString *)ident
{
    NSMutableString *s = [[NSMutableString alloc]init];
    [s appendFormat:@"%@AddressReference:       %@\n",ident,[_payload hexString]];
    return s;
}
@end
