//
//  UMSATTokenExecuteSTKCommand.h
//  decode-st
//
//  Created by Andreas Fink on 18.10.19.
//  Copyright © 2019 Andreas Fink (andreas@fink.org). All rights reserved.
//

#import "UMSATToken.h"


@interface UMSATTokenExecuteSTKCommand : UMSATToken
{
    int _command_type;
    int _command_qualifier;
    int _destination_device;
    NSString *_varId;
}

@end


