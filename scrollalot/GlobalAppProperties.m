//
//  GlobalAppProperties.m
//  scrollalot
//
//  Created by Ivan Borsa on 11/07/14.
//  Copyright (c) 2014 ivanborsa. All rights reserved.
//

#import "GlobalAppProperties.h"

@implementation GlobalAppProperties

+(id)sharedInstance
{
    static GlobalAppProperties *myInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        myInstance = [[self alloc] init];
    });
    return myInstance;
}

-(id)init
{
    if (self = [super init]) {
        
    }
    return self;
}

@end
