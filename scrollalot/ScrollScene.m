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
#import "GlobalAppProperties.h"

//static CGFloat mmPerPixel = 0.078125;
static CGFloat cmPerPixel = 0.0078125;
static CGFloat mPerPixel = 0.000078125;
static CGFloat kmPerPixel = 0.000000078125;

static CGFloat mmPSecInKmPH = 0.0036;
static CGFloat mPSecInKmPH = 3.6;
static CGFloat kmPSecInKmPH = 3600.;

@interface ScrollScene()

@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;
@property (nonatomic) NSTimeInterval speedCheckInterval;
@property (nonatomic) NSTimeInterval lastSpeedCheckInterval;

@property (nonatomic) NSArray *markers;
@property (nonatomic) MarkerObject *mainMarker;
@property (nonatomic) CGFloat lastMarkerPosition;
@property (nonatomic) CGFloat lastSpeedCheckDistance;
@property (nonatomic) double distance;

@property (nonatomic) SKLabelNode *distanceLabel;
@property (nonatomic) SKLabelNode *speedLabel;

@property (nonatomic) NSString *distanceUnit;

@property (nonatomic) GlobalAppProperties *globalProps;
@property (nonatomic) float maxSpeed;

@end

@implementation ScrollScene

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        self.backgroundColor = [UIColor whiteColor];
        self.speedCheckInterval = 2.0;
        self.globalProps = [GlobalAppProperties sharedInstance];
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
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSNumber *maxSpeed = [defaults objectForKey:kMaxSpeedKey];
    if (!maxSpeed) {
        maxSpeed = [NSNumber numberWithDouble:0];
    }
    self.maxSpeed = maxSpeed.floatValue;
    
    NSNumber *globalDistance = [defaults objectForKey:kGlobalDistanceKey];
    if (!globalDistance) {
        globalDistance = [NSNumber numberWithDouble:0];
    }
    self.distance = globalDistance.doubleValue;
    self.globalProps.globalDistance = globalDistance;
    
    NSString *globalDistanceUnit = [defaults objectForKey:kDistanceUnitKey];
    if (!globalDistanceUnit) {
        globalDistanceUnit = kDistanceUnitCm;
    }
    self.distanceUnit = globalDistanceUnit;
    self.globalProps.distanceUnit = globalDistanceUnit;
    
    self.lastSpeedCheckDistance = self.distance;
    self.lastSpeedCheckInterval = 0;
    self.lastMarkerPosition = self.mainMarker.position.y;
    
    self.distanceLabel = [SKLabelNode labelNodeWithFontNamed:@"ArialMT"];
    self.distanceLabel.fontSize = 15.0;
    self.distanceLabel.position = CGPointMake(self.size.width - 50, self.size.height - 50);
    self.distanceLabel.fontColor = [UIColor blackColor];
    [self addChild:self.distanceLabel];
    
    self.speedLabel = [SKLabelNode labelNodeWithFontNamed:@"ArialMT"];
    self.speedLabel.fontSize = 15.0;
    self.speedLabel.position = CGPointMake(50, self.size.height - 50);
    self.speedLabel.fontColor = [UIColor blackColor];
    [self addChild:self.speedLabel];
    
    SKSpriteNode *middle = [[SKSpriteNode alloc] initWithColor:[UIColor redColor] size:CGSizeMake(100, 2)];
    middle.position = CGPointMake(self.size.width / 2.0 - self.mainMarker.size.width / 2.0, self.size.height / 2.0);
    [self addChild:middle];
    
    if (self.distanceUnit == 0) {
        [self addTextArray:@[@"LET", @"THE", @"SCROLL", @"BEGIN!"] completion:^{
            
        } andInterval:.7];
    } else {
        [self addTextArray:@[@"Back", @"for", @"MORE", @"SCROLL?:)"] completion:^{
            
        } andInterval:.7];
    }
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
    //NSLog(@"%f", _mainMarker.position.y);
    if (_mainMarker.position.y < -_mainMarker.size.height / 2.0) {
        _mainMarker.position = CGPointMake(_mainMarker.position.x, self.size.height + _mainMarker.size.height / 2.0);
        distanceDiff = 0.0;
    } else if (_mainMarker.position.y > self.size.height + _mainMarker.size.height / 2.0) {
        _mainMarker.position = CGPointMake(_mainMarker.position.x, -_mainMarker.size.height / 2.0);
        distanceDiff = 0.0;
    }
    
    if ([self.distanceUnit isEqualToString:kDistanceUnitCm]) {
        _distance += distanceDiff * cmPerPixel * 2.0;
    } else if ([self.distanceUnit isEqualToString:kDistanceUnitM]) {
        _distance += distanceDiff * mPerPixel * 2.0;
    } else if ([self.distanceUnit isEqualToString:kDistanceUnitKm]) {
        _distance += distanceDiff * kmPerPixel * 2.0;
    }
    
    _lastMarkerPosition = _mainMarker.position.y;
    //NSLog(@"Distance: %fcm", _distance);
    if ([self.distanceUnit isEqualToString:kDistanceUnitCm]) {
        _distanceLabel.text = [NSString stringWithFormat:@"%.1fcm", _distance];
        if (_distance > 100) {
            _distanceUnit = kDistanceUnitM;
            _globalProps.distanceUnit = _distanceUnit;
            _distance = _distance / 100.0;
            _lastSpeedCheckInterval = 0;
            _lastSpeedCheckDistance = _distance;
        }
    } else if ([self.distanceUnit isEqualToString:kDistanceUnitM]) {
        _distanceLabel.text = [NSString stringWithFormat:@"%.2fm", _distance];
        if (_distance > 1000) {
            _distanceUnit = kDistanceUnitKm;
            _globalProps.distanceUnit = _distanceUnit;
            _distance = _distance / 1000.0;
            _lastSpeedCheckInterval = 0;
            _lastSpeedCheckDistance = _distance;
        }
    } else if ([self.distanceUnit isEqualToString:kDistanceUnitKm]) {
        _distanceLabel.text = [NSString stringWithFormat:@"%.3fkm", _distance];
    }
    
    _globalProps.globalDistance = [NSNumber numberWithDouble:_distance];
    
    _lastSpeedCheckInterval += timeSinceLast;
    if (_lastSpeedCheckInterval > _speedCheckInterval) {
        CGFloat measureDistance = fabs(_distance - _lastSpeedCheckDistance);
        CGFloat speed;
        if ([_distanceUnit isEqualToString:kDistanceUnitCm]) {
            speed = measureDistance * _lastSpeedCheckInterval * mmPSecInKmPH;
        } else if ([_distanceUnit isEqualToString:kDistanceUnitM]) {
            speed = measureDistance * _lastSpeedCheckInterval * mPSecInKmPH;
        } else if ([_distanceUnit isEqualToString:kDistanceUnitKm]) {
            speed = measureDistance * _lastSpeedCheckInterval * kmPSecInKmPH;
        }
        self.speedLabel.text = [NSString stringWithFormat:@"%.1fKm/h", speed];
        
        if (speed > _maxSpeed) {
            _maxSpeed = speed;
            _globalProps.maxSpeed = [NSNumber numberWithFloat:_maxSpeed];
        }
        
        //CGFloat speed = measureDistance * _lastSpeedCheckInterval * mmPSecInKmPH;
        //NSLog(@"Speed: %f", speed);
        _lastSpeedCheckDistance = _distance;
        _lastSpeedCheckInterval = 0.0;
    }
    
}

-(void)swipeWithVelocity:(float)velocity
{
    [self.mainMarker.physicsBody applyImpulse:CGVectorMake(0, -velocity)];
}

-(void)addTextArray:(NSArray *)textArray completion:(void(^)())completion andInterval:(float)interval
{
    SKLabelNode *textLabel = [SKLabelNode labelNodeWithFontNamed:@"ArialMT"];
    textLabel.fontColor = [UIColor blackColor];
    textLabel.fontSize = 25;
    
    NSMutableArray *textActions = [NSMutableArray array];
    
    SKAction *growAndFade = [SKAction group:@[[SKAction fadeOutWithDuration:interval], [SKAction scaleTo:6.0 duration:interval]]];
    
    for (NSString *text in textArray) {
        SKAction *ta = [SKAction group:@[[SKAction fadeInWithDuration:0.0], [SKAction scaleTo:1.0 duration:0.0], [SKAction runBlock:^{
            textLabel.text = text;
        }]]];
        
        SKAction *tas = [SKAction sequence:@[growAndFade, ta]];
        
        [textActions addObject:tas];
    }
    
    [textActions addObject:growAndFade];
    [textActions addObject:[SKAction removeFromParent]];
    
    SKAction *countDown = [SKAction sequence:textActions];
    
    textLabel.position = CGPointMake(self.size.width / 2.0, self.size.height / 2.0);
    textLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    textLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    [textLabel runAction:countDown completion:completion];
    
    [self addChild:textLabel];
}

@end
