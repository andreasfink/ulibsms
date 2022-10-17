//
//  UMMultipartRegistry.m
//  ulibsms
//
//  Created by Andreas Fink on 15.10.22.
//  Copyright © 2022 Andreas Fink (andreas@fink.org). All rights reserved.
//

#import "UMMultipartRegistry.h"
#import "UMSMS.h"
#import "UMMultipartSMS.h"

@implementation UMMultipartRegistry

- (UMMultipartRegistry *)init
{
    self = [super init];
    if(self)
    {
        multipartByDestinationAndRef = [[UMSynchronizedDictionary alloc]init];
    }
    return self;
}

- (NSArray<UMSMS *>*)registerMultipartSMS:(UMSMS *)sms newMaxSize:(int)newMaxSize
{
    if(sms.multipart_ref==NULL)
    {
        return @[sms];
    }
    
    NSString *key = [NSString stringWithFormat:@"%@.%@",sms.tp_da.address,sms.multipart_ref];
    
    UMMultipartSMS *multi = multipartByDestinationAndRef[key];
    if(multi)
    {
        [multi addMultipart:sms number:sms.multipart_current max:sms.multipart_max];
        if([multi allPartsPresent] == NO)
        {
            return @[];
        }
        [multi resplitByMaxSize:newMaxSize];
        NSMutableArray<UMSMS *>* a = [[NSMutableArray alloc]init];
        for(NSInteger i=0;i<multi.mulitpartsMaxCount.integerValue;i++)
        {
            UMSMS *sms = [multi getMultipart:i];
        }
    }
}


@end
