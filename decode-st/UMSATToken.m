//
//  UMSATToken.m
//  decode-st
//
//  Created by Andreas Fink on 08.10.19.
//  Copyright © 2019 Andreas Fink (andreas@fink.org). All rights reserved.
//

#import "UMSATToken.h"
#import "UMSATTokenDeck.h"
#import "UMSATTokenDeckId.h"
#import "UMSATTokenSPS.h"
#import "UMSATTokenTextElementTable.h"
#import "UMSATTokenCard.h"
#import "UMSATTokenCardId.h"
#import "UMSATTokenCardTemplate.h"
#import "UMSATTokenVariableReference.h"
#import "UMSATTokenVariableReferenceList.h"
#import "UMSATTokenInlineValue.h"
#import "UMSATTokenInputList.h"
#import "UMSATTokenParameter.h"
#import "UMSATTokenURLReference.h"
#import "UMSATTokenAddressReference.h"
#import "UMSATTokenConstantParameter.h"
#import "UMSATTokenSecureMessage.h"
#import "UMSATTokenCouple.h"
#import "UMSATTokenInitVariable.h"
#import "UMSATTokenInitVariableSelected.h"
#import "UMSATTokenGetEnvironmentVariable.h"
#import "UMSATTokenSetHelp.h"
#import "UMSATTokenConcatenate.h"
#import "UMSATTokenExtract.h"
#import "UMSATTokenEcrypt.h"
#import "UMSATTokenDecrypt.h"
#import "UMSATTokenGoBack.h"
#import "UMSATTokenGoSelected.h"
#import "UMSATTokenSwitchCaseOnVariable.h"
#import "UMSATTokenExit.h"
#import "UMSATTokenManageContextualMenu.h"
#import "UMSATTokenExecuteSTKCommand.h"
#import "UMSATTokenExecutePlugin.h"


static inline uint8_t grab_byte(uint8_t *bytes,int *pos, int len);

@implementation UMSATToken

+ (NSString *)tagName:(int)tag1
{
    int tag = tag1 & 0x7F;
    switch(tag)
    {
        case STK_TAG_Deck:
            return @"Deck";
        case STK_TAG_DeckId:
            return @"DeckId";
        case    STK_TAG_SPS:
            return @"SPS (depreciated)";
        case    STK_TAG_TextElementTable:
            return @"TextElementTable";
        case    STK_TAG_Card:
            return @"Card";
        case    STK_TAG_CardId:
            return @"CardId";
        case    STK_TAG_CardTemplate:
            return @"CardTemplate";
        case    STK_TAG_VariableReference:
            return @"VariableReference";
        case    STK_TAG_VariableReferenceList:
            return @"VariableReferenceList";
        case    STK_TAG_InlineValue:
            return @"InlineValue";
        case    STK_TAG_InputList:
            return @"InputList";
        case    STK_TAG_Parameter:
            return @"Parameter";
        case    STK_TAG_URLReference:
            return @"URLReference";
        case    STK_TAG_AddressReference:
            return @"AddressReference";
        case    STK_TAG_ConstantParameter:
            return @"ConstantParameter";
        case    STK_TAG_SecureMessage:
            return @"SecureMessage";
        case    STK_TAG_Couple:
            return @"Couple";
        case    STK_TAG_InitVariable:
            return @"InitVariable";
        case    STK_TAG_InitVariableSelected:
            return @"InitVariableSelected";
        case    STK_TAG_GetEnvironmentVariable:
            return @"GetEnvironmentVariable";
        case    STK_TAG_SetHelp:
            return @"SetHelp";
        case    STK_TAG_Concatenate:
            return @"Concatenate";
        case    STK_TAG_Extract:
            return @"Extract";
        case    STK_TAG_Ecrypt:
            return @"Ecrypt";
        case    STK_TAG_Decrypt:
            return @"Decrypt";
        case    STK_TAG_GoBack:
            return @"GoBack";
        case    STK_TAG_GoSelected:
            return @"GoSelected";
        case    STK_TAG_SwitchCaseOnVariable:
            return @"SwitchCaseOnVariable";
        case    STK_TAG_Exit:
            return @"Exit";
        case    STK_TAG_ManageContextualMenu:
            return @"ManageContextualMenu";
        case    STK_TAG_ExecuteSTKCommand:
            return @"ExecuteSTKCommand";
        case    STK_TAG_ExecutePlugin:
            return @"ExecutePlugin";
        default:
            return [NSString stringWithFormat:@"Undefined_0x%02X",tag1];
    }
}

- (UMSATToken *)initWithData:(NSData *)data
{
    UMSATToken *returnToken = NULL;
    self = [super init];
    if(self)
    {
        uint8_t *bytes = (uint8_t *)data.bytes;
        int len = (int)data.length;
        int pos=0;
        int t =bytes[pos++];
        _token = t;
        _token = 0x7F & t;
        if(t & 0x80)
        {
            _attributesPresent = YES;
        }
        else
        {
            _attributesPresent = NO;
        }
        _len = [UMSATToken readLength:bytes pos:&pos len:len];
        int payloadLen = _len;
        _len += pos;
        if(_attributesPresent)
        {
            _attributes=0;
            int bitshift = 0;
            int attribute=0;
            do
            {
                attribute = grab_byte(bytes,&pos,len);
                payloadLen--;
                _attributes = _attributes | ((attribute & 0x7F) << bitshift);
                bitshift +=7;
            } while(attribute & 0x80);
        }

        _payload = [NSData dataWithBytes:&bytes[pos] length:payloadLen];
        switch(_token)
        {
            case STK_TAG_Deck:
                returnToken = [[UMSATTokenDeck alloc]initWithToken:self];
                break;
            case STK_TAG_DeckId:
                returnToken = [[UMSATTokenDeckId alloc]initWithToken:self];
                break;
            case STK_TAG_SPS:
                returnToken = [[UMSATTokenSPS alloc]initWithToken:self];
                break;
            case STK_TAG_TextElementTable:
                returnToken = [[UMSATTokenTextElementTable alloc]initWithToken:self];
                break;
            case STK_TAG_Card:
                returnToken = [[UMSATTokenCard alloc]initWithToken:self];
                break;
            case STK_TAG_CardId:
                returnToken = [[UMSATTokenCardId alloc]initWithToken:self];
                break;
            case STK_TAG_CardTemplate:
                returnToken = [[UMSATTokenCardTemplate alloc]initWithToken:self];
                break;
            case STK_TAG_VariableReference:
                returnToken = [[UMSATTokenVariableReference alloc]initWithToken:self];
                break;
            case STK_TAG_VariableReferenceList:
                returnToken = [[UMSATTokenVariableReferenceList alloc]initWithToken:self];
                break;
            case STK_TAG_InlineValue:
                returnToken = [[UMSATTokenInlineValue alloc]initWithToken:self];
                break;
            case STK_TAG_InputList:
                returnToken = [[UMSATTokenInputList alloc]initWithToken:self];
                break;
            case STK_TAG_Parameter:
                returnToken = [[UMSATTokenParameter alloc]initWithToken:self];
                break;
            case STK_TAG_URLReference:
                returnToken = [[UMSATTokenURLReference alloc]initWithToken:self];
                break;
            case STK_TAG_AddressReference:
                returnToken = [[UMSATTokenAddressReference alloc]initWithToken:self];
                break;
            case STK_TAG_ConstantParameter:
                returnToken = [[UMSATTokenConstantParameter alloc]initWithToken:self];
                break;
            case STK_TAG_SecureMessage:
                returnToken = [[UMSATTokenSecureMessage alloc]initWithToken:self];
                break;
            case STK_TAG_Couple:
                returnToken = [[UMSATTokenCouple alloc]initWithToken:self];
                break;
            case STK_TAG_InitVariable:
                returnToken = [[UMSATTokenInitVariable alloc]initWithToken:self];
                break;
            case STK_TAG_InitVariableSelected:
                returnToken = [[UMSATTokenInitVariableSelected alloc]initWithToken:self];
                break;
            case STK_TAG_GetEnvironmentVariable:
                returnToken = [[UMSATTokenGetEnvironmentVariable alloc]initWithToken:self];
                break;
            case STK_TAG_SetHelp:
                returnToken = [[UMSATTokenSetHelp alloc]initWithToken:self];
                break;
            case STK_TAG_Concatenate:
                returnToken = [[UMSATTokenConcatenate alloc]initWithToken:self];
                break;
            case STK_TAG_Extract:
                returnToken = [[UMSATTokenExtract alloc]initWithToken:self];
                break;
            case STK_TAG_Ecrypt:
                returnToken = [[UMSATTokenEcrypt alloc]initWithToken:self];
                break;
            case STK_TAG_Decrypt:
                returnToken = [[UMSATTokenDecrypt alloc]initWithToken:self];
                break;
            case STK_TAG_GoBack:
                returnToken = [[UMSATTokenGoBack alloc]initWithToken:self];
                break;
            case STK_TAG_GoSelected:
                returnToken = [[UMSATTokenGoSelected alloc]initWithToken:self];
                break;
            case STK_TAG_SwitchCaseOnVariable:
                returnToken = [[UMSATTokenSwitchCaseOnVariable alloc]initWithToken:self];
                break;
            case STK_TAG_Exit:
                returnToken = [[UMSATTokenExit alloc]initWithToken:self];
                break;
            case STK_TAG_ManageContextualMenu:
                returnToken = [[UMSATTokenManageContextualMenu alloc]initWithToken:self];
                break;
            case STK_TAG_ExecuteSTKCommand:
                returnToken = [[UMSATTokenExecuteSTKCommand alloc]initWithToken:self];
                break;
            case STK_TAG_ExecutePlugin:
                returnToken = [[UMSATTokenExecutePlugin alloc]initWithToken:self];
                break;
            default:
                returnToken = self;
        }
    }
    return returnToken;
}


- (UMSATToken *) initWithToken:(UMSATToken *)otherToken
{
    self = [super init];
    if(self)
    {
        _token = otherToken.token;
        _len = otherToken.len;
        _attributesPresent = otherToken.attributesPresent;
        _attributes = otherToken.attributes;
        _payload = otherToken.payload;
        [self decodePayload];
    }
    return self;
}

- (void) decodePayload
{
    /* to be overloaded by subclasses */
}

- (void)lookForSubtokens
{
    NSData *payload = _payload;
    NSMutableArray *tokens = [[NSMutableArray alloc]init];
    NSInteger len0 = payload.length;
    while(len0>=2)
    {
        UMSATToken *token = [[UMSATToken alloc]initWithData:payload];
        if(token)
        {
            [tokens addObject:token];
        }
        else
        {
            break;
        }
        NSInteger len1 = token.len;
        len0 -= len1;
        if(len0>=2)
        {
            payload = [NSData dataWithBytes:&payload.bytes[len1] length:len0];
        }
    }
    _subEntries = tokens;
}

+ (int)readLength:(uint8_t *)bytes
              pos:(int *)pos
              len:(int)len
{
    int value = 0;
    uint8_t byte = grab_byte(bytes,pos,len);
    {
        if (byte == 0x80)
        {
            /* indefinitive form */
            value = -1;
        }
        else if (byte < 0x80)
        {
            /* short form */
            value =  byte;
        }
        else
        {
            int count = byte & 0x7F;
            while(count > 0)
            {
                byte = grab_byte(bytes,pos,len);
                value = (value << 8) | byte;
                count--;
            }
        }
    }
    return value;
}

- (NSString *)tokenName
{
    return [UMSATToken tagName:_token];
}

- (NSString *)description
{
    return [self descriptionWithPrefix:@""];
}

- (void)appendAttributesToString:(NSMutableString *)s prefix:ident
{
    return;
}

- (NSString *)descriptionWithPrefix:(NSString *)ident
{
    NSMutableString *s = [[NSMutableString alloc]init];
    [s appendString:[self descriptionWithPrefixHeader:ident]];
    [s appendString:[self descriptionWithPrefixMain:ident]];
    [s appendString:[self descriptionWithPrefixFooter:ident]];
    return s;
}

- (NSString *)descriptionWithPrefixHeader:(NSString *)ident
{
    NSMutableString *s = [[NSMutableString alloc]init];

    [s appendFormat:@"\n%@TAG       0x%02X %@\n",ident,_token,self.tokenName];
    [s appendFormat:@"%@LEN       0x%02lX (%ld)\n",ident,_payload.length,_payload.length];
    if(_attributesPresent)
    {
        [s appendFormat:@"%@ATTR      0x%02llX\n",ident,_attributes];
        [self appendAttributesToString:s prefix:ident];
    }
    if(_payload.length > 0)
    {
        uint8_t *bytes = (uint8_t *)_payload.bytes;
        NSUInteger len = _payload.length;
        [s appendFormat:@"%@DATA     ",ident];
        for(NSInteger i=0;i<len;i++)
        {
            [s appendFormat:@" %02X",bytes[i]];
            if(((i+1)%16==0) && (i<(len-1)))
            {
                [s appendFormat:@"\n%@         ",ident];
            }
        }
        [s appendString:@"\n"];
    }
    return s;
}

- (NSString *)descriptionWithPrefixMain:(NSString *)ident
{
    return @"";
}


- (NSString *)descriptionWithPrefixFooter:(NSString *)ident
{
    NSMutableString *s = [[NSMutableString alloc]init];

    if(_subEntries.count > 0)
    {
        ident = [NSString stringWithFormat:@"%@    ",ident];
        for(UMSATToken *t in _subEntries)
        {
            [s appendString:[t descriptionWithPrefix:ident]];
        }
    }
    return s;
}

@end

static inline uint8_t grab_byte(uint8_t *bytes,int *pos, int len)
{
    if(*pos >= len)
    {
        @throw([NSException exceptionWithName:@"ASN1_READ_BEYOND_EOD"
                                       reason:NULL
                                     userInfo:@{
                                                @"sysmsg" : @"reading beyond end of data in length bytes",
                                                }
                ]);
    }
    uint8_t byte = bytes[(*pos)++];
    return byte;
}

