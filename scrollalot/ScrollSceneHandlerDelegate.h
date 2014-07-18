//
//  ScrollSceneHandlerDelegate.h
//  scrollalot
//
//  Created by Ivan Borsa on 11/07/14.
//  Copyright (c) 2014 ivanborsa. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ScrollSceneHandlerDelegate <NSObject>

-(void)reportMaxSpeed:(float)speed;
-(void)reportDistance:(double)distance;
-(void)presentLeaderBoards;

@end
