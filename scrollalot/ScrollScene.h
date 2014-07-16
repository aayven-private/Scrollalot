//
//  MyScene.h
//  scrollalot
//

//  Copyright (c) 2014 ivanborsa. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "ScrollSceneHandlerDelegate.h"

@interface ScrollScene : SKScene

@property (nonatomic, weak) id<ScrollSceneHandlerDelegate> delegate;

-(void)initEnvironment;
-(void)swipeWithVelocity:(float)velocity;
-(void)swipeInProgressAtPoint:(CGPoint)point withTranslation:(CGPoint)translation;

@end
