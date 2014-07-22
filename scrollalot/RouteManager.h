//
//  RouteManager.h
//  scrollalot
//
//  Created by Ivan Borsa on 22/07/14.
//  Copyright (c) 2014 ivanborsa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RouteManagerDelegate.h"

@interface RouteManager : NSObject

@property (nonatomic, weak) id<RouteManagerDelegate> delegate;

-(id)initWithDelegate:(id<RouteManagerDelegate>)delegate;
-(void)readRoutes;
-(void)actionTaken:(NSString *)action;
-(void)loadNewRoute;

@end
