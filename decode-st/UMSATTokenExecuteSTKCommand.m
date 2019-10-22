//
//  UMSATTokenExecuteSTKCommand.m
//  decode-st
//
//  Created by Andreas Fink on 18.10.19.
//  Copyright © 2019 Andreas Fink (andreas@fink.org). All rights reserved.
//

#import "UMSATTokenExecuteSTKCommand.h"
static const char *stk_command_name(UMSAT_STKCommand_Type command);

@implementation UMSATTokenExecuteSTKCommand

- (void) decodePayload
{

    _tlvSequence = (_attributes & 0x40) ? YES : NO;
    uint8_t *bytes = (uint8_t *)_payload.bytes;
    NSUInteger len = _payload.length;
    if(len>=3)
    {
        _command_type  = bytes[0];
        _command_qualifier = bytes[1];
        _destination_device = bytes[2];
    }
    if(len>3)
    {
        NSData *d = [[NSData alloc]initWithBytes:&_payload.bytes[3] length:len-3];
        _varId = [d hexString];
    }
}

- (void)appendAttributesToString:(NSMutableString *)s prefix:ident
{
    [s appendFormat:@"%@           b6 tlvSequence:%@\n",ident,((_attributes & 0x40) ? @"YES" : @"NO")];
}


- (NSString *)descriptionWithPrefixMain:(NSString *)ident
{
    NSMutableString *s = [[NSMutableString alloc]init];

    [s appendFormat:@"%@Command-Type:       0x%02X (%s)\n",ident,(int)_command_type, stk_command_name(_command_type)];
    [s appendFormat:@"%@Command-Qualifier:  0x%02X\n",ident,_command_qualifier];
    [s appendFormat:@"%@Destination-Device: 0x%02X",ident,_destination_device];
    switch(_destination_device)
    {
        case 0x01:
            [s appendFormat:@" (Keypad)"];
            break;
        case 0x02:
            [s appendFormat:@" (Display)"];
            break;
        case 0x81:
            [s appendFormat:@" (UICC)"];
            break;
        case 0x82:
            [s appendFormat:@" (Terminal)"];
            break;
        case 0x83:
            [s appendFormat:@" (Network)"];
            break;
        default:
            if((_destination_device >= 0x10) & (_destination_device <=0x17))
            {
                [s appendFormat:@" (Additional Card Reader x (0 to 7))"];
            }
            else if((_destination_device >= 0x20) & (_destination_device <=0x27))
            {
                [s appendFormat:@" (Channel with Channel identifier x (1 to 7))"];
            }
            else if((_destination_device >= 0x30) & (_destination_device <=0x3F))
            {
                [s appendFormat:@" (eCAT client identifier (1 to F))"];
            }
            else
            {
                [s appendFormat:@" (reserved value)"];
            }
    }
    [s appendFormat:@"\n"];
    return s;
}

@end

const char *stk_command_name(UMSAT_STKCommand_Type command)
{
    switch(command)
    {
    case STK_REFRESH:
        return "REFRESH";
    case STK_MORE_TIME:
        return "MORE_TIME";
    case STK_POLL_INTERVAL:
        return "POLL_INTERVAL";
    case STK_POLLING_OFF:
        return "POLLING_OFF";
    case STK_SET_UP_EVENT_LIST:
        return "SET_UP_EVENT_LIST";
    case STK_SET_UP_CALL:
        return "SET_UP_CALL";
    case STK_GSM_3G_SEND_SS:
        return "GSM_3G_SEND_SS";
    case STK_GSM_3G_SEND_USSD:
        return "GSM_3G_SEND_USSD";
    case STK_SEND_SHORT_MESSAGE:
        return "SEND_SHORT_MESSAGE";
    case STK_SEND_DTMF:
        return "SEND_DTMF";
    case STK_LAUNCH_BROWSER:
        return "LAUNCH_BROWSER";
    case STK_3GPP_GEOGRAPHICAL_LOCATION_REQUEST:
        return "3GPP_GEOGRAPHICAL_LOCATION_REQUEST";
    case STK_PLAY_TONE:
        return "PLAY_TONE";
    case STK_DISPLAY_TEXT:
        return "DISPLAY_TEXT";
    case STK_GET_INKEY:
        return "GET_INKEY";
    case STK_GET_INPUT:
        return "GET_INPUT";
    case STK_SELECT_ITEM:
        return "SELECT_ITEM";
    case STK_SET_UP_MENU:
        return "SET_UP_MENU";
    case STK_PROVIDE_LOCAL_INFORMATION:
        return "PROVIDE_LOCAL_INFORMATION";
    case STK_TIMER_MANAGEMENT:
        return "TIMER_MANAGEMENT";
    case STK_SET_UP_IDLE_MODE_TEXT:
        return "SET_UP_IDLE_MODE_TEXT";
    case STK_PERFORM_CARD_APDU:
        return "PERFORM_CARD_APDU";
    case STK_POWER_ON_CARD_:
        return "POWER_ON_CARD_";
    case STK_POWER_OFF_CARD:
        return "POWER_OFF_CARD";
    case STK_GET_READER_STATUS:
        return "GET_READER_STATUS";
    case STK_RUN_AT_COMMAND:
        return "RUN_AT_COMMAND";
    case STK_LANGUAGE_NOTIFICATION:
        return "LANGUAGE_NOTIFICATION";
    case STK_OPEN_CHANNEL:
        return "OPEN_CHANNEL";
    case STK_CLOSE_CHANNEL:
        return "CLOSE_CHANNEL";
    case STK_RECEIVE_DATA:
        return "RECEIVE_DATA";
    case STK_SEND_DATA:
        return "SEND_DATA";
    case STK_GET_CHANNEL_STATUS:
        return "GET_CHANNEL_STATUS";
    case STK_SERVICE_SEARCH:
        return "SERVICE_SEARCH";
    case STK_GET_SERVICE_INFORMATION:
        return "GET_SERVICE_INFORMATION";
    case STK_DECLARE_SERVICE:
        return "DECLARE_SERVICE";
    case STK_SET_FRAMES:
        return "SET_FRAMES";
    case STK_GET_FRAMES_STATUS:
        return "GET_FRAMES_STATUS";
    case STK_RETRIEVE_MULTIMEDIA_MESSAGE:
        return "RETRIEVE_MULTIMEDIA_MESSAGE";
    case STK_SUBMIT_MULTIMEDIA_MESSAGE:
        return "SUBMIT_MULTIMEDIA_MESSAGE";
    case STK_DISPLAY_MULTIMEDIA_MESSAGE:
        return "DISPLAY_MULTIMEDIA_MESSAGE";
    case STK_ACTIVATE:
        return "ACTIVATE";
    case STK_CONTACTLESS_STATE_CHANGED:
        return "CONTACTLESS_STATE_CHANGED";
    case STK_COMMAND_CONTAINER:
        return "COMMAND_CONTAINER";
    case STK_ENCAPSULATED_SESSION_CONTROL:
        return "ENCAPSULATED_SESSION_CONTROL";
    case STK_eUICC_OPERATION:
        return "eUICC_OPERATION";
    case STK_RESERVED_PROPRIETARY_USE_F0:
        return "RESERVED_PROPRIETARY_USE_F0";
    case STK_RESERVED_PROPRIETARY_USE_F1:
        return "RESERVED_PROPRIETARY_USE_F1";
    case STK_RESERVED_PROPRIETARY_USE_F2:
        return "RESERVED_PROPRIETARY_USE_F2";
    case STK_RESERVED_PROPRIETARY_USE_F3:
        return "RESERVED_PROPRIETARY_USE_F3";
    case STK_RESERVED_PROPRIETARY_USE_F4:
        return "RESERVED_PROPRIETARY_USE_F4";
    case STK_RESERVED_PROPRIETARY_USE_F5:
        return "RESERVED_PROPRIETARY_USE_F5";
    case STK_RESERVED_PROPRIETARY_USE_F6:
        return "RESERVED_PROPRIETARY_USE_F6";
    case STK_RESERVED_PROPRIETARY_USE_F7:
        return "RESERVED_PROPRIETARY_USE_F7";
    case STK_RESERVED_PROPRIETARY_USE_F8:
        return "RESERVED_PROPRIETARY_USE_F8";
    case STK_RESERVED_PROPRIETARY_USE_F9:
        return "RESERVED_PROPRIETARY_USE_F9";
    case STK_RESERVED_PROPRIETARY_USE_FA:
        return "RESERVED_PROPRIETARY_USE_FA";
    case STK_RESERVED_PROPRIETARY_USE_FB:
        return "RESERVED_PROPRIETARY_USE_FB";
    case STK_RESERVED_PROPRIETARY_USE_FC:
        return "RESERVED_PROPRIETARY_USE_FC";
    case STK_RESERVED_PROPRIETARY_USE_FD:
        return "RESERVED_PROPRIETARY_USE_FD";
    case STK_RESERVED_PROPRIETARY_USE_FE:
        return "RESERVED_PROPRIETARY_USE_FE";
    default:
        return "Unknown";
    }
}
