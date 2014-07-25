//
//  CommonTools.m
//  BeeGame
//
//  Created by Ivan Borsa on 24/03/14.
//  Copyright (c) 2014 aayven. All rights reserved.
//

#import "CommonTools.h"

#define ARC4RANDOM_MAX 0x100000000

@implementation CommonTools

+(int)getRandomNumberFromInt:(int)from toInt:(int)to
{
    return from + arc4random() %(to+1-from);;
}

+(float)getRandomFloatFromFloat:(float)from toFloat:(float)to
{
    return ((float)arc4random() / ARC4RANDOM_MAX) * (to-from) + from;
}

+(NSString *)hmacForKey:(NSString *)key andData:(NSString *)data
{
    const char *cKey  = [key cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [data cStringUsingEncoding:NSASCIIStringEncoding];
    
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    
    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
    
    return [[HMAC.description stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]] stringByReplacingOccurrencesOfString:@" " withString:@""];
}

@end
