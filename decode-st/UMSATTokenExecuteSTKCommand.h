//
//  UMSATTokenExecuteSTKCommand.h
//  decode-st
//
//  Created by Andreas Fink on 18.10.19.
//  Copyright © 2019 Andreas Fink (andreas@fink.org). All rights reserved.
//

#import "UMSATToken.h"

typedef enum UMSAT_STKCommand_Type
{
    STK_REFRESH                 = 0x01,
    STK_MORE_TIME               = 0x02,
    STK_POLL_INTERVAL           = 0x03,
    STK_POLLING_OFF             = 0x04,
    STK_SET_UP_EVENT_LIST       = 0x05,
    STK_SET_UP_CALL             = 0x10,
    STK_GSM_3G_SEND_SS          = 0x11,
    STK_GSM_3G_SEND_USSD        = 0x12,
    STK_SEND_SHORT_MESSAGE      = 0x13,
    STK_SEND_DTMF               = 0x14,
    STK_LAUNCH_BROWSER                      = 0x15,
    STK_3GPP_GEOGRAPHICAL_LOCATION_REQUEST  = 0x16,
    STK_PLAY_TONE                           = 0x20,
    STK_DISPLAY_TEXT                        = 0x21,
    STK_GET_INKEY                           = 0x22,
    STK_GET_INPUT                           = 0x23,
    STK_SELECT_ITEM                         = 0x24,
    STK_SET_UP_MENU                         = 0x25,
    STK_PROVIDE_LOCAL_INFORMATION           = 0x26,
    STK_TIMER_MANAGEMENT                    = 0x27,
    STK_SET_UP_IDLE_MODE_TEXT               = 0x28,
    STK_PERFORM_CARD_APDU                   = 0x30,
    STK_POWER_ON_CARD_                      = 0x31,
    STK_POWER_OFF_CARD                      = 0x32,
    STK_GET_READER_STATUS                   = 0x33,
    STK_RUN_AT_COMMAND                      = 0x34,
    STK_LANGUAGE_NOTIFICATION               = 0x35,
    STK_OPEN_CHANNEL                        = 0x40,
    STK_CLOSE_CHANNEL                       = 0x41,
    STK_RECEIVE_DATA                        = 0x42,
    STK_SEND_DATA                           = 0x43,
    STK_GET_CHANNEL_STATUS                  = 0x44,
    STK_SERVICE_SEARCH                      = 0x45,
    STK_GET_SERVICE_INFORMATION             = 0x46,
    STK_DECLARE_SERVICE                     = 0x47,
    STK_SET_FRAMES                          = 0x50,
    STK_GET_FRAMES_STATUS                   = 0x51,
    STK_RETRIEVE_MULTIMEDIA_MESSAGE         = 0x60,
    STK_SUBMIT_MULTIMEDIA_MESSAGE           = 0x61,
    STK_DISPLAY_MULTIMEDIA_MESSAGE          = 0x62,
    STK_ACTIVATE                            = 0x70,
    STK_CONTACTLESS_STATE_CHANGED           = 0x71,
    STK_COMMAND_CONTAINER                   = 0x72,
    STK_ENCAPSULATED_SESSION_CONTROL        = 0x73,
    STK_eUICC_OPERATION                     = 0x74,
 //   STK_End_of_the_proactive_UICC_session_not_applicable    = 0x81,
    STK_RESERVED_PROPRIETARY_USE_F0         = 0xF0,
    STK_RESERVED_PROPRIETARY_USE_F1         = 0xF1,
    STK_RESERVED_PROPRIETARY_USE_F2         = 0xF2,
    STK_RESERVED_PROPRIETARY_USE_F3         = 0xF3,
    STK_RESERVED_PROPRIETARY_USE_F4         = 0xF4,
    STK_RESERVED_PROPRIETARY_USE_F5         = 0xF5,
    STK_RESERVED_PROPRIETARY_USE_F6         = 0xF6,
    STK_RESERVED_PROPRIETARY_USE_F7         = 0xF7,
    STK_RESERVED_PROPRIETARY_USE_F8         = 0xF8,
    STK_RESERVED_PROPRIETARY_USE_F9         = 0xF9,
    STK_RESERVED_PROPRIETARY_USE_FA         = 0xFA,
    STK_RESERVED_PROPRIETARY_USE_FB         = 0xFB,
    STK_RESERVED_PROPRIETARY_USE_FC         = 0xFC,
    STK_RESERVED_PROPRIETARY_USE_FD         = 0xFD,
    STK_RESERVED_PROPRIETARY_USE_FE         = 0xFE,
} UMSAT_STKCommand_Type;

@interface UMSATTokenExecuteSTKCommand : UMSATToken
{
    UMSAT_STKCommand_Type _command_type;
    int _command_qualifier;
    int _destination_device;
    NSString *_varId;
}

@end


