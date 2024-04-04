//
//  UMSATTokenParameter.h
//  decode-st
//
//  Created by Andreas Fink on 18.10.19.
//  Copyright © 2019 Andreas Fink (andreas@fink.org). All rights reserved.
//

#import <ulibsms/UMSATToken.h>


@interface UMSATTokenParameter : UMSATToken
{
    int _varId;
    NSData *_parameterName;
}
@end
