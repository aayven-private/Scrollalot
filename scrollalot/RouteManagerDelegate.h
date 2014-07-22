//
//  RouteManagerDelegate.h
//  scrollalot
//
//  Created by Ivan Borsa on 22/07/14.
//  Copyright (c) 2014 ivanborsa. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RouteManagerDelegate <NSObject>

-(void)nextRouteLoadedInDirection:(char)initialDirection andDistance:(NSNumber *)distance;
-(void)checkpointCompletedWithNextDirection:(char)nextDirection andDistance:(NSNumber *)distance;
-(void)routeCompleted:(NSString *)routeName;

@end
