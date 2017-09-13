//
//  UMGSMCharacterTable.h
//  ulibsms
//
//  Created by Andreas Fink on 13.09.17.
//  Copyright © 2017 Andreas Fink (andreas@fink.org). All rights reserved.
//

#import <ulib/ulib.h>

@interface UMGSMCharacterTable : UMObject
{
    UMSynchronizedDictionary *_entries; /* entries of NSString objects */
    UMSynchronizedDictionary *_singleShiftEntries; /* entries of NSString objects */
    UMSynchronizedDictionary *_lockingShiftEntries; /* entries of NSString objects */
}

+ (UMGSMCharacterTable *)defaultGsmCharacterTable;

@end
