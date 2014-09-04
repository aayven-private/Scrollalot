//
//  ZoomInEffect.m
//  scrollalot
//
//  Created by Ivan Borsa on 04/09/14.
//  Copyright (c) 2014 ivanborsa. All rights reserved.
//

#import "ZoomInEffect.h"
#import "Constants.h"

@interface ZoomInEffect()

@property (nonatomic) SKEmitterNode *topLeftEmitter;
@property (nonatomic) SKEmitterNode *topRightEmitter;
@property (nonatomic) SKEmitterNode *bottomLeftEmitter;
@property (nonatomic) SKEmitterNode *bottomRightEmitter;
@property (nonatomic) SKEmitterNode *topEmitter;
@property (nonatomic) SKEmitterNode *bottomEmitter;
@property (nonatomic) SKEmitterNode *leftEmitter;
@property (nonatomic) SKEmitterNode *rightEmitter;

@property (nonatomic) SKAction *emitterAction;

@end

@implementation ZoomInEffect

-(id)initWithColor:(UIColor *)color size:(CGSize)size
{
    if (self = [super initWithColor:color size:size]) {
        NSString *emitterPath = [[NSBundle mainBundle] pathForResource:@"ZoomInEffect" ofType:@"sks"];
        self.topLeftEmitter = [NSKeyedUnarchiver unarchiveObjectWithFile:emitterPath];
        //self.topLeftEmitter.position = CGPointMake(self.size.width / 2.0, self.size.height / 2.0);
        self.topLeftEmitter.particlePositionRange = CGVectorMake(0, 0);
        self.topLeftEmitter.particleRotation = self.topLeftEmitter.emissionAngle = 45 * degreeInRadians;
        self.topLeftEmitter.particleSpeed = 0;
        //self.topLeftEmitter.particleSpeedRange = 200;
        self.topLeftEmitter.xAcceleration = -100;
        self.topLeftEmitter.yAcceleration = 100;
        self.topLeftEmitter.particleBirthRate = 0;
        [self addChild:self.topLeftEmitter];
        
        self.topRightEmitter = [NSKeyedUnarchiver unarchiveObjectWithFile:emitterPath];
        //self.topRightEmitter.position = CGPointMake(self.size.width / 2.0, self.size.height / 2.0);
        self.topRightEmitter.particlePositionRange = CGVectorMake(0, 0);
        self.topRightEmitter.particleRotation = self.topRightEmitter.emissionAngle = 135 * degreeInRadians;
        self.topRightEmitter.particleSpeed = 0;
        //self.topRightEmitter.particleSpeedRange = 200;
        self.topRightEmitter.xAcceleration = 100;
        self.topRightEmitter.yAcceleration = 100;
        self.topRightEmitter.particleBirthRate = 0;
        [self addChild:self.topRightEmitter];
        
        self.bottomLeftEmitter = [NSKeyedUnarchiver unarchiveObjectWithFile:emitterPath];
        //self.bottomLeftEmitter.position = CGPointMake(self.size.width / 2.0, self.size.height / 2.0);
        self.bottomLeftEmitter.particlePositionRange = CGVectorMake(0, 0);
        self.bottomLeftEmitter.particleRotation = self.bottomLeftEmitter.emissionAngle = 315 * degreeInRadians;
        self.bottomLeftEmitter.particleSpeed = 0;
        //self.bottomLeftEmitter.particleSpeedRange = 200;
        self.bottomLeftEmitter.xAcceleration = -100;
        self.bottomLeftEmitter.yAcceleration = -100;
        self.bottomLeftEmitter.particleBirthRate = 0;
        [self addChild:self.bottomLeftEmitter];
        
        self.bottomRightEmitter = [NSKeyedUnarchiver unarchiveObjectWithFile:emitterPath];
        //self.bottomRightEmitter.position = CGPointMake(self.size.width / 2.0, self.size.height / 2.0);
        self.bottomRightEmitter.particlePositionRange = CGVectorMake(0, 0);
        self.bottomRightEmitter.particleRotation = self.bottomRightEmitter.emissionAngle = 225 * degreeInRadians;
        self.bottomRightEmitter.particleSpeed = 0;
        //self.bottomRightEmitter.particleSpeedRange = 200;
        self.bottomRightEmitter.xAcceleration = 100;
        self.bottomRightEmitter.yAcceleration = -100;
        self.bottomRightEmitter.particleBirthRate = 0;
        [self addChild:self.bottomRightEmitter];
        
        self.topEmitter = [NSKeyedUnarchiver unarchiveObjectWithFile:emitterPath];
        //self.bottomRightEmitter.position = CGPointMake(self.size.width / 2.0, self.size.height / 2.0);
        self.topEmitter.particlePositionRange = CGVectorMake(0, 0);
        self.topEmitter.particleRotation = self.topEmitter.emissionAngle = 180 * degreeInRadians;
        self.topEmitter.particleSpeed = 0;
        //self.bottomRightEmitter.particleSpeedRange = 200;
        self.topEmitter.xAcceleration = 0;
        self.topEmitter.yAcceleration = 100;
        self.topEmitter.particleBirthRate = 0;
        [self addChild:self.topEmitter];
        
        self.bottomEmitter = [NSKeyedUnarchiver unarchiveObjectWithFile:emitterPath];
        //self.bottomRightEmitter.position = CGPointMake(self.size.width / 2.0, self.size.height / 2.0);
        self.bottomEmitter.particlePositionRange = CGVectorMake(0, 0);
        self.bottomEmitter.particleRotation = self.bottomEmitter.emissionAngle = 180 * degreeInRadians;
        self.bottomEmitter.particleSpeed = 0;
        //self.bottomRightEmitter.particleSpeedRange = 200;
        self.bottomEmitter.xAcceleration = 0;
        self.bottomEmitter.yAcceleration = -100;
        self.bottomEmitter.particleBirthRate = 0;
        [self addChild:self.bottomEmitter];
        
        self.leftEmitter = [NSKeyedUnarchiver unarchiveObjectWithFile:emitterPath];
        //self.bottomRightEmitter.position = CGPointMake(self.size.width / 2.0, self.size.height / 2.0);
        self.leftEmitter.particlePositionRange = CGVectorMake(0, 0);
        self.leftEmitter.particleRotation = self.leftEmitter.emissionAngle = 90 * degreeInRadians;
        self.leftEmitter.particleSpeed = 0;
        //self.bottomRightEmitter.particleSpeedRange = 200;
        self.leftEmitter.xAcceleration = -100;
        self.leftEmitter.yAcceleration = 0;
        self.leftEmitter.particleBirthRate = 0;
        [self addChild:self.leftEmitter];
        
        self.rightEmitter = [NSKeyedUnarchiver unarchiveObjectWithFile:emitterPath];
        //self.bottomRightEmitter.position = CGPointMake(self.size.width / 2.0, self.size.height / 2.0);
        self.rightEmitter.particlePositionRange = CGVectorMake(0, 0);
        self.rightEmitter.particleRotation = self.rightEmitter.emissionAngle = 90 * degreeInRadians;
        self.rightEmitter.particleSpeed = 0;
        //self.bottomRightEmitter.particleSpeedRange = 200;
        self.rightEmitter.xAcceleration = 100;
        self.rightEmitter.yAcceleration = 0;
        self.rightEmitter.particleBirthRate = 0;
        [self addChild:self.rightEmitter];
        
        self.emitterAction = [SKAction sequence:@[[SKAction runBlock:^{
            self.topLeftEmitter.particleBirthRate = self.topRightEmitter.particleBirthRate = self.bottomLeftEmitter.particleBirthRate = self.bottomRightEmitter.particleBirthRate = self.leftEmitter.particleBirthRate = self.rightEmitter.particleBirthRate = self.topEmitter.particleBirthRate = self.bottomEmitter.particleBirthRate = 200;
        }], [SKAction waitForDuration:.2], [SKAction runBlock:^{
            self.topLeftEmitter.particleBirthRate = self.topRightEmitter.particleBirthRate = self.bottomLeftEmitter.particleBirthRate = self.bottomRightEmitter.particleBirthRate = self.leftEmitter.particleBirthRate = self.rightEmitter.particleBirthRate = self.topEmitter.particleBirthRate = self.bottomEmitter.particleBirthRate = 50;
        }], [SKAction waitForDuration:.2], [SKAction waitForDuration:.2], [SKAction runBlock:^{
            self.topLeftEmitter.particleBirthRate = self.topRightEmitter.particleBirthRate = self.bottomLeftEmitter.particleBirthRate = self.bottomRightEmitter.particleBirthRate = self.leftEmitter.particleBirthRate = self.rightEmitter.particleBirthRate = self.topEmitter.particleBirthRate = self.bottomEmitter.particleBirthRate = 0;
        }]]];
    }
    return self;
}

-(void)switchParticleEffect:(BOOL)isOn
{
    if (isOn) {
        self.topLeftEmitter.particleBirthRate = self.topRightEmitter.particleBirthRate = self.bottomLeftEmitter.particleBirthRate = self.bottomRightEmitter.particleBirthRate = self.leftEmitter.particleBirthRate = self.rightEmitter.particleBirthRate = self.topEmitter.particleBirthRate = self.bottomEmitter.particleBirthRate = 100;
    } else {
        self.topLeftEmitter.particleBirthRate = self.topRightEmitter.particleBirthRate = self.bottomLeftEmitter.particleBirthRate = self.bottomRightEmitter.particleBirthRate = self.leftEmitter.particleBirthRate = self.rightEmitter.particleBirthRate = self.topEmitter.particleBirthRate = self.bottomEmitter.particleBirthRate = 0;
    }
}

-(void)triggerEmitter
{
    [self runAction:_emitterAction];
}

@end
