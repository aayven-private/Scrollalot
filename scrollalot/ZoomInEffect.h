//
//  ZoomInEffect.h
//  scrollalot
//
//  Created by Ivan Borsa on 04/09/14.
//  Copyright (c) 2014 ivanborsa. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface ZoomInEffect : SKSpriteNode

-(void)switchParticleEffect:(BOOL)isOn;
-(void)triggerEmitter;

@end
