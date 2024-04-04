//
//  UMSATTokenURLReference.h
//  decode-st
//
//  Created by Andreas Fink on 18.10.19.
//  Copyright © 2019 Andreas Fink (andreas@fink.org). All rights reserved.
//

#import <ulibsms/UMSATToken.h>


@interface UMSATTokenURLReference : UMSATToken
{
    BOOL _usePost;
    BOOL _sendReferer;
    BOOL _forcedResident;
    BOOL _doNotWait;

    UMSATToken *_addressReference;
    NSArray *_parameters;
}

@end

