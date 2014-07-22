//
//  MyScene.h
//  scrollalot
//

//  Copyright (c) 2014 ivanborsa. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "ScrollSceneHandlerDelegate.h"
#import "ComboManager.h"
#import "RouteManager.h"

@interface ScrollScene : SKScene<ComboManagerDelegate, RouteManagerDelegate>

@property (nonatomic, weak) id<ScrollSceneHandlerDelegate> delegate;
@property (nonatomic) double distance;
@property (nonatomic) float maxSpeed;

-(void)initEnvironment;
-(void)distanceDownloadedFromGC:(double)distance;
-(void)swipeWithVelocity:(CGPoint)velocity;
-(void)swipeInProgressAtPoint:(CGPoint)point withTranslation:(CGPoint)translation;

@end
