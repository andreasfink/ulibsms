//
//  UMMultipartRegistry.h
//  ulibsms
//
//  Created by Andreas Fink on 15.10.22.
//  Copyright © 2022 Andreas Fink (andreas@fink.org). All rights reserved.
//

#import <ulib/ulib.h>
@class UMSMS;

@interface UMMultipartRegistry : UMObject
{
    UMSynchronizedDictionary *multipartByDestinationAndRef;
}

- (NSArray<UMSMS *>*)registerMultipartSMS:(UMSMS *)sms newMaxSize:(int)newMaxSize;


@end
