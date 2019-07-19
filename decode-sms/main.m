//
//  main.m
//  decode-sms
//
//  Created by Andreas Fink on 07.11.18.
//  Copyright © 2018 Andreas Fink (andreas@fink.org). All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ulibsms/ulibsms.h>

int main(int argc, const char * argv[])
{
	@autoreleasepool
	{
		NSString *s = @"Verify";
		NSData *d = [s dataUsingEncoding:NSISOLatin1StringEncoding];
		int nibblelen;
		
		NSMutableData *result = NULL;
		ssize_t len;
		ssize_t i;
		int numbits;
		int value;
		ssize_t	len2;
		const unsigned char *bytes;
		unsigned char b;
		
		len    = [d length];
		result = [[NSMutableData alloc]initWithCapacity: len];
		bytes  = [d bytes];
			
		len2 = (len * 7 + 3) / 4;
		if(len2 > 0x7F)
		{
			NSLog(@"trying to do gsm8to7 with len2 = %ld. That can't work as nibblelen > 256",(long)len2);
		}
		nibblelen = len2 & 0xFF;
		
		value = 0;
		numbits = 0;
		for (i = 0; i < len; i++)
		{
			value += bytes[i]<< numbits;
			numbits += 7;
			if (numbits >= 8)
			{
				b = value & 0xFF;
				[result appendBytes:&b	length:1];
				value >>= 8;
				numbits -= 8;
			}
		}
		if (numbits > 0)
		{
			b = value & 0xFF;
			[result appendBytes:&b	length:1];
		}
		NSLog(@"Result: %@, nibblelen=%d",result,nibblelen);

		
		NSLog(@"Result2: %@",[[s gsm7WithNibbleLenPrefix] hexString]);

	}

    {
        NSString *s = @"Garena";
        NSData *d = [s dataUsingEncoding:NSISOLatin1StringEncoding];
        int nibblelen;

        NSMutableData *result = NULL;
        ssize_t len;
        ssize_t i;
        int numbits;
        int value;
        ssize_t    len2;
        const unsigned char *bytes;
        unsigned char b;

        len    = [d length];
        result = [[NSMutableData alloc]initWithCapacity: len];
        bytes  = [d bytes];

        len2 = (len * 7 + 3) / 4;
        if(len2 > 0x7F)
        {
            NSLog(@"trying to do gsm8to7 with len2 = %ld. That can't work as nibblelen > 256",(long)len2);
        }
        nibblelen = len2 & 0xFF;

        value = 0;
        numbits = 0;
        for (i = 0; i < len; i++)
        {
            value += bytes[i]<< numbits;
            numbits += 7;
            if (numbits >= 8)
            {
                b = value & 0xFF;
                [result appendBytes:&b    length:1];
                value >>= 8;
                numbits -= 8;
            }
        }
        if (numbits > 0)
        {
            b = value & 0xFF;
            [result appendBytes:&b    length:1];
        }
        NSLog(@"Result: %@, nibblelen=%d",result,nibblelen);


        NSLog(@"Result2: %@",[[s gsm7WithNibbleLenPrefix] hexString]);

    }
	return 0;
}
