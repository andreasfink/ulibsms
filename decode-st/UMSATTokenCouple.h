//
//  UMSATTokenCouple.h
//  decode-st
//
//  Created by Andreas Fink on 18.10.19.
//  Copyright © 2019 Andreas Fink (andreas@fink.org). All rights reserved.
//

#import "UMSATToken.h"


@interface UMSATTokenCouple : UMSATToken
{
    UMSATToken *_parameterA;
    UMSATToken *_parameterB;
}
@end

