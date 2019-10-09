//
//  UMSATToken.m
//  decode-st
//
//  Created by Andreas Fink on 08.10.19.
//  Copyright © 2019 Andreas Fink (andreas@fink.org). All rights reserved.
//

#import "UMSATToken.h"

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
            return [NSString stringWithFormat:@"Undefined_0x%2X",tag1];
    }
}

@end
