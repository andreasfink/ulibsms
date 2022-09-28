//
//  UMMultipartSMS.h
//  ulibsms
//
//  Created by Andreas Fink on 26.09.22.
//  Copyright © 2022 Andreas Fink (andreas@fink.org). All rights reserved.
//

#import <ulib/ulib.h>

#import "UMSMS.h"

@interface UMMultipartSMS : UMSMS
{
    NSInteger           _mulitpartsMaxCount;
    UMSynchronizedArray *_multiparts;
    NSInteger           _refNo;
    NSString            *_smscNumber;
    NSString            *_mscNumber;
    NSDate              *_lastPartArrived;
    NSDate              *_firstPartArrived;    
}

- (void)addMultipart:(UMSMS *)sms number:(NSInteger)pos max:(NSInteger)max;
- (BOOL)allPartsPresent;
- (void)combine;
- (void)resplitByMaxSize:(NSInteger)maxSize;
- (UMSMS *)getMultipart:(NSInteger)index;
- (NSInteger)mulitpartsMaxCount;

@property(readwrite,assign,atomic) NSInteger mulitpartsMaxCount;
@property(readwrite,assign,atomic) NSInteger           refNo;
@property(readwrite,strong,atomic) NSString            *smscNumber;
@property(readwrite,strong,atomic) NSString            *mscNumber;

@end

