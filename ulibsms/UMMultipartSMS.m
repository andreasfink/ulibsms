//
//  UMMultipartSMS.m
//  ulibsms
//
//  Created by Andreas Fink on 26.09.22.
//  Copyright © 2022 Andreas Fink (andreas@fink.org). All rights reserved.
//

#import "UMMultipartSMS.h"

@implementation UMMultipartSMS

- (void)addMultipart:(UMSMS *)sms
              number:(NSNumber *)pos
                 max:(NSNumber *)max
{
    if(pos.integerValue > max.integerValue)
    {
        max = @(pos.integerValue + 1);
    }
    _mulitpartsMaxCount = max;
    if(_multiparts == NULL)
    {
        _multiparts = [[UMSynchronizedArray alloc]init];
    }
    for(NSInteger i = _multiparts.count ; i < _mulitpartsMaxCount.integerValue;i++)
    {
        _multiparts[i] = [NSNull null];
    }
    _multiparts[pos.intValue] = sms;
}

- (BOOL)allPartsPresent
{
    if((_mulitpartsMaxCount == 0) || (_multiparts.count == 0))
    {
        return NO;
    }
    for(NSInteger i=0;i<_multiparts.count;i++)
    {
        if([_multiparts[i] isKindOfClass:[NSNull class]])
        {
            return NO;
        }
    }
    return YES;
}
- (void)combine
{
    NSMutableData *combinedData = [[NSMutableData alloc]init];
    for(NSInteger i=0;i<_multiparts.count;i++)
    {
        id smsPart = _multiparts[i];
        if([smsPart isKindOfClass:[UMSMS class]])
        {
            NSData *part = smsPart.t_ud;
            [combinedData appendData:part];
        }
    }
    self.t_ud = combine;
}

- (void)resplitByMaxSize:(NSInteger)maxSize
{
    [self combine];
                                                          
}

- (UMSMS *)getMultipart:(NSInteger)index
{
    return NULL;
}



/* Checks if message is concatenated. Returns:

{
    Msg *msg = *pmsg;
    int l, iel = 0, refnum, pos, c, part, totalparts, i, sixteenbit;
    Octstr *udh = msg->sms.udhdata, *key;
    ConcatMsg *cmsg;
    int ret = concat_complete;


    for (pos = 1, c = -1; pos < l - 1; pos += iel + 2)
    {
        iel = octstr_get_char(udh, pos + 1);
        if ((c = octstr_get_char(udh, pos)) == 0 || c == 8)
        {
            break;
        }
    }
    if (pos >= l)  /* no concat UDH found. */
    {
        return concat_none;
    }
    /* c = 0 means 8 bit, c = 8 means 16 bit concat info */
    sixteenbit = (c == 8);
    refnum = (!sixteenbit) ? octstr_get_char(udh, pos + 2) :
            (octstr_get_char(udh, pos + 2) << 8) | octstr_get_char(udh, pos + 3);
    totalparts = octstr_get_char(udh, pos + 3 + sixteenbit);
    part = octstr_get_char(udh, pos + 4 + sixteenbit);

    if (part < 1 || part > totalparts) {
        warning(0, "Invalid concatenation UDH [ref = %d] in message from %s!",
                refnum, octstr_get_cstr(msg->sms.sender));
        return concat_none;
    }

    /* extract UDH */
    udh = octstr_duplicate(msg->sms.udhdata);
    octstr_delete(udh, pos, iel + 2);
    if (octstr_len(udh) <= 1) /* no other UDH elements. */
        octstr_delete(udh, 0, octstr_len(udh));
    else
        octstr_set_char(udh, 0, octstr_len(udh) - 1);

    debug("bb.sms.splits", 0, "Got part %d [ref %d, total parts %d] of message from %s. Dump follows:",
          part, refnum, totalparts, octstr_get_cstr(msg->sms.sender));
     
    msg_dump(msg, 0);
     
    key = octstr_format("'%S' '%S' '%S' '%d' '%d' '%H'", msg->sms.sender, msg->sms.receiver, smscid, refnum, totalparts, udh);
    mutex_lock(concat_lock);
    if ((cmsg = dict_get(incoming_concat_msgs, key)) == NULL) {
        cmsg = gw_malloc(sizeof(*cmsg));
        cmsg->refnum = refnum;
        cmsg->total_parts = totalparts;
        cmsg->udh = udh;
        udh = NULL;
        cmsg->num_parts = 0;
        cmsg->key = octstr_duplicate(key);
        cmsg->ack = ack_success;
        cmsg->smsc_id = octstr_duplicate(smscid);
        cmsg->parts = gw_malloc(totalparts * sizeof(*cmsg->parts));
        memset(cmsg->parts, 0, cmsg->total_parts * sizeof(*cmsg->parts)); /* clear it. */

        dict_put(incoming_concat_msgs, key, cmsg);
    }
    octstr_destroy(key);
    octstr_destroy(udh);

    /* check if we have seen message part before... */
    if (cmsg->parts[part - 1] != NULL) {
        error(0, "Duplicate message part %d, ref %d, from %s, to %s. Discarded!",
                part, refnum, octstr_get_cstr(msg->sms.sender), octstr_get_cstr(msg->sms.receiver));
        store_save_ack(msg, ack_success);
        msg_destroy(msg);
        *pmsg = msg = NULL;
        mutex_unlock(concat_lock);
        return concat_pending;
    } else {
        cmsg->parts[part -1] = msg;
        cmsg->num_parts++;
        /* always update receive time so we have it from last part and don't timeout */
        cmsg->trecv = time(NULL);
    }

    if (cmsg->num_parts < cmsg->total_parts) {  /* wait for more parts. */
        *pmsg = msg = NULL;
        mutex_unlock(concat_lock);
        return concat_pending;
    }

    /* we have all the parts: Put them together, modify UDH, return message. */
    msg = msg_duplicate(cmsg->parts[0]);
    uuid_generate(msg->sms.id); /* give it a new ID. */

    debug("bb.sms.splits",0,"Received all concatenated message parts from %s, to %s, refnum %d",
          octstr_get_cstr(msg->sms.sender), octstr_get_cstr(msg->sms.receiver), refnum);

    for (i = 1; i < cmsg->total_parts; i++)
        octstr_append(msg->sms.msgdata, cmsg->parts[i]->sms.msgdata);

    /* Attempt to save the new one, if that fails, then reply with fail. */
    if (store_save(msg) == -1) {
        mutex_unlock(concat_lock);
        msg_destroy(msg);
        *pmsg = msg = NULL;
        return concat_error;
    } else
        *pmsg = msg; /* return the message part. */

    /* fix up UDH */
    octstr_destroy(msg->sms.udhdata);
    msg->sms.udhdata = cmsg->udh;
    cmsg->udh = NULL;

    /* Delete it from the queue and from the Dict. */
    /* Note: dict_put with NULL value delete and destroy value */
    dict_put(incoming_concat_msgs, cmsg->key, NULL);
    mutex_unlock(concat_lock);

    debug("bb.sms.splits", 0, "Got full message [ref %d] of message from %s to %s. Dumping: ",
          refnum, octstr_get_cstr(msg->sms.sender), octstr_get_cstr(msg->sms.receiver));
    msg_dump(msg,0);

    return ret;
}

@end
