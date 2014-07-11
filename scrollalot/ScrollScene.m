//
//  MyScene.m
//  scrollalot
//
//  Created by Ivan Borsa on 10/07/14.
//  Copyright (c) 2014 ivanborsa. All rights reserved.
//

#import "ScrollScene.h"
#import "SceneObject.h"
#import "MarkerObject.h"

static CGFloat mmPerPixel = 0.078125;

@interface ScrollScene()

@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;

@property (nonatomic) NSArray *markers;
@property (nonatomic) MarkerObject *mainMarker;
@property (nonatomic) CGFloat lastMarkerPosition;
@property (nonatomic) CGFloat distance;
@property (nonatomic) SKLabelNode *distanceLabel;

@end

@implementation ScrollScene

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

-(void)initEnvironment
{
    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    self.physicsWorld.gravity = CGVectorMake(0, 0);
    self.physicsBody.categoryBitMask = 0;
    self.physicsBody.contactTestBitMask = 0;
    self.physicsBody.collisionBitMask = 0;
    self.physicsBody.friction = 0.0f;
    self.physicsBody.restitution = 0.0f;
    self.physicsBody.usesPreciseCollisionDetection = YES;
    self.physicsBody.linearDamping = 1.0;
    self.scaleMode = SKSceneScaleModeAspectFill;
    
    self.mainMarker = [[MarkerObject alloc] initWithTexture:[SKTexture textureWithImage:[UIImage imageNamed:@"square"]]];
    self.mainMarker.position = CGPointMake(self.size.width / 2.0, self.size.height / 2.0);
    [self addChild:self.mainMarker];
    
    self.distance = 0;
    self.lastMarkerPosition = self.mainMarker.position.y;
    
    self.distanceLabel = [SKLabelNode labelNodeWithFontNamed:@"ArialMT"];
    self.distanceLabel.fontSize = 15.0;
    self.distanceLabel.position = CGPointMake(self.size.width - 50, self.size.height - 50);
    self.distanceLabel.fontColor = [UIColor blackColor];
    [self addChild:self.distanceLabel];
    
    SKSpriteNode *middle = [[SKSpriteNode alloc] initWithColor:[UIColor redColor] size:CGSizeMake(100, 2)];
    middle.position = CGPointMake(self.size.width / 2.0 - self.mainMarker.size.width / 2.0, self.size.height / 2.0);
    [self addChild:middle];
}

/*-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
 
    
    for (UITouch *touch in touches) {

    }
}*/

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    CFTimeInterval timeSinceLast = currentTime - _lastUpdateTimeInterval;
    if (timeSinceLast > 1) { // more than a second since last update
        timeSinceLast = 1.0 / 60.0;
    }
    _lastUpdateTimeInterval = currentTime;
    [self updateWithTimeSinceLastUpdate:timeSinceLast];
}

-(void)updateWithTimeSinceLastUpdate:(CFTimeInterval)timeSinceLast
{
    CGFloat distanceDiff = fabsf(_lastMarkerPosition - _mainMarker.position.y);
    
    if (_mainMarker.position.y < -_mainMarker.size.height / 2.0) {
        _mainMarker.position = CGPointMake(_mainMarker.position.x, self.size.height + _mainMarker.size.height / 2.0);
        distanceDiff = 0.0;
    } else if (_mainMarker.position.y > self.size.height + _mainMarker.size.height / 2.0) {
        _mainMarker.position = CGPointMake(_mainMarker.position.x, -_mainMarker.size.height / 2.0);
        distanceDiff = 0.0;
    }
    
    _distance += distanceDiff * mmPerPixel / 10.0;
    _lastMarkerPosition = _mainMarker.position.y;
    //NSLog(@"Distance: %fcm", _distance);
    if (_distance < 100) {
        _distanceLabel.text = [NSString stringWithFormat:@"%.1fcm", _distance];
    } else if (_distance < 100000) {
        _distanceLabel.text = [NSString stringWithFormat:@"%.2fm", _distance / 100.];
    } else {
        _distanceLabel.text = [NSString stringWithFormat:@"%.3fkm", _distance / 100000.];
    }
}

-(void)swipeWithVelocity:(float)velocity
{
    [self.mainMarker.physicsBody applyImpulse:CGVectorMake(0, -velocity)];
}

@end
