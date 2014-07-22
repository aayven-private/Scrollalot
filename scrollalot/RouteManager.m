//
//  RouteManager.m
//  scrollalot
//
//  Created by Ivan Borsa on 22/07/14.
//  Copyright (c) 2014 ivanborsa. All rights reserved.
//

#import "RouteManager.h"

@implementation RouteManager

+ (id)sharedManager {
    static RouteManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];

    });
    return sharedMyManager;
}

@end
