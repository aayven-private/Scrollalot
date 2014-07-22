//
//  RouteEntityHelper.m
//  scrollalot
//
//  Created by Ivan Borsa on 22/07/14.
//  Copyright (c) 2014 ivanborsa. All rights reserved.
//

#import "RouteEntityHelper.h"

@implementation RouteEntityHelper

-(id)initWithEntity:(RouteEntity *)entity
{
    if (self = [super init]) {
        self.routeName = entity.routeName;
        self.routePattern = entity.routePattern;
        self.achievementId = entity.achievementId;
        self.routeDistance = entity.routeDistance;
        self.achieved = entity.achieved;
    }
    return self;
}

@end
