//
//  main.m
//  decode-gsm7
//
//  Created by Andreas Fink on 07.11.18.
//  Copyright © 2018 Andreas Fink (andreas@fink.org). All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ulibsms/ulibsms.h>

int main(int argc, const char * argv[])
{
    for(int idx=1;idx<argc;idx++)
    {
        @autoreleasepool
        {
            NSString *s = @(argv[idx]);
            NSData *d = [s unhexedData];

            NSString *result = [d stringFromGsm7withNibbleLengthPrefix];
            NSLog(@"Result: %@",result);
        }
    }
    return 0;
}
