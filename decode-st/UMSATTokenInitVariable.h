//
//  UMSATTokenInitVariable.h
//  decode-st
//
//  Created by Andreas Fink on 18.10.19.
//  Copyright © 2019 Andreas Fink (andreas@fink.org). All rights reserved.
//

#import "UMSATToken.h"


@interface UMSATTokenInitVariable : UMSATToken
{
    int         _varCount;
    int         _var[256];
    UMSATToken *_val[256];
}
@end


