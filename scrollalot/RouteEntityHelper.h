//
//  RouteEntityHelper.h
//  scrollalot
//
//  Created by Ivan Borsa on 22/07/14.
//  Copyright (c) 2014 ivanborsa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RouteEntity.h"

@interface RouteEntityHelper : NSObject

@property (nonatomic) NSString * routeName;
@property (nonatomic) NSString * routePattern;
@property (nonatomic) NSString * achievementId;
@property (nonatomic) NSNumber * routeDistance;
@property (nonatomic) NSNumber *achieved;

-(id)initWithEntity:(RouteEntity *)entity;

@end
