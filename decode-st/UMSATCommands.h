//
//  UMSATCommands.h
//  decode-st
//
//  Created by Andreas Fink on 03.10.2019.
//  Copyright © 2019 Andreas Fink (andreas@fink.org). All rights reserved.
//

#import <ulibasn1/ulibasn1.h>
#import <ulibsms/UMSATToken.h>

@interface UMSATCommands : UMObject
{
    int token;
    
}

+ (NSString *)tagName:(int)tag1;
+ (int)readLength:(uint8_t *)bytes pos:(int *)pos len:(int)len;

@end

