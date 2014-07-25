//
//  CommonTools.h
//  BeeGame
//
//  Created by Ivan Borsa on 24/03/14.
//  Copyright (c) 2014 aayven. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonHMAC.h>

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

@interface CommonTools : NSObject

+(int)getRandomNumberFromInt:(int)from toInt:(int)to;
+(float)getRandomFloatFromFloat:(float)from toFloat:(float)to;
+(NSString *)hmacForKey:(NSString *)key andData:(NSString *)data;

@end
