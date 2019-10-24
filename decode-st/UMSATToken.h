//
//  UMSATToken.h
//  decode-st
//
//  Created by Andreas Fink on 08.10.19.
//  Copyright © 2019 Andreas Fink (andreas@fink.org). All rights reserved.
//

#import <ulibasn1/ulibasn1.h>


typedef enum STK_TAG
{
    STK_TAG_Deck                    = 0x01,
    STK_TAG_DeckId                  = 0x02,
    STK_TAG_SPS                     = 0x03, /* depreciated */
    STK_TAG_TextElementTable        = 0x04,
    STK_TAG_Card                    = 0x05,
    STK_TAG_CardId                  = 0x06,
    STK_TAG_CardTemplate            = 0x07,
    STK_TAG_VariableReference       = 0x08,
    STK_TAG_VariableReferenceList   = 0x09,
    STK_TAG_InlineValue             = 0x0A,
    STK_TAG_InputList               = 0x0B,
    STK_TAG_Parameter               = 0x0C,
    STK_TAG_URLReference            = 0x0D,
    STK_TAG_AddressReference        = 0x0E,
    STK_TAG_ConstantParameter       = 0x0F,
    STK_TAG_SecureMessage           = 0x10,
    STK_TAG_Couple                  = 0x11,
    STK_TAG_InitVariable            = 0x20,
    STK_TAG_InitVariableSelected    = 0x21,
    STK_TAG_GetEnvironmentVariable  = 0x22,
    STK_TAG_SetHelp                 = 0x23, /* depreciated */
    STK_TAG_Concatenate             = 0x24,
    STK_TAG_Extract                 = 0x25,
    STK_TAG_Ecrypt                  = 0x26,
    STK_TAG_Decrypt                 = 0x27,
    STK_TAG_GoBack                  = 0x28,
    STK_TAG_GoSelected              = 0x29,
    STK_TAG_SwitchCaseOnVariable    = 0x2A,
    STK_TAG_Exit                    = 0x2B,
    STK_TAG_ManageContextualMenu    = 0x2C,
    STK_TAG_ExecuteSTKCommand       = 0x2D,
    STK_TAG_ExecutePlugin           = 0x2E,
} STK_TAG;


@interface UMSATToken : UMObject
{
    int     _token;
    int     _len;
    BOOL    _attributesPresent;
    int64_t _attributes;
    NSData *_payload;
    NSArray *_subEntries;
}

@property(readwrite,assign) int token;
@property(readwrite,assign) int len;
@property(readwrite,assign) BOOL attributesPresent;
@property(readwrite,assign) int64_t attributes;
@property(readwrite,strong) NSData *payload;
@property(readwrite,strong) NSArray *subEntries;

- (UMSATToken *)initWithData:(NSData *)data;
- (UMSATToken *)initWithToken:(UMSATToken *)token;
- (void)lookForSubtokens;
- (NSString *)descriptionWithPrefix:(NSString *)ident;
- (NSString *)tokenName;
- (void)appendAttributesToString:(NSMutableString *)s prefix:ident;
- (void)decodePayload;

@end

