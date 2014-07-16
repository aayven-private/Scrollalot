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
#import "ParallaxBG.h"

//static CGFloat mmPerPixel = 0.078125;
//static CGFloat cmPerPixel = 0.0078125;
//static CGFloat mPerPixel = 0.000078125;
static CGFloat kmPerPixel = 0.000000078125;

//static CGFloat mmPSecInKmPH = 0.0036;
//static CGFloat mPSecInKmPH = 3.6;
static CGFloat kmPSecInKmPH = 3600.;

static CGFloat degreeInRadians = 0.0174532925;

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

@property (nonatomic) GlobalAppProperties *globalProps;
@property (nonatomic) float maxSpeed;

@property (nonatomic) ParallaxBG *parallaxBG;

@property (nonatomic) SKEmitterNode *topEmitter;
@property (nonatomic) SKEmitterNode *bottomEmitter;

@property (nonatomic) MarkerObject *spiral;

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
    self.mainMarker.hidden = YES;
    [self addChild:self.mainMarker];
    
    self.spiral = [[MarkerObject alloc] initWithTexture:[SKTexture textureWithImage:[UIImage imageNamed:@"spiral"]]];
    self.spiral.position = CGPointMake(self.size.width / 2.0, self.size.height / 2.0);
    [self addChild:self.spiral];
    
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
    //self.distance = 1;
    
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
    
    if (self.distance == 0) {
        [self addTextArray:@[@"LET", @"THE", @"SCROLL", @"BEGIN!"] completion:^{
            
        } andInterval:.7];
    } else {
        [self addTextArray:@[@"Back", @"for", @"MORE", @"SCROLL?:)"] completion:^{
            
        } andInterval:.7];
    }
    
    NSString *emitterPath = [[NSBundle mainBundle] pathForResource:@"SwipeEmitter" ofType:@"sks"];
    self.topEmitter = [NSKeyedUnarchiver unarchiveObjectWithFile:emitterPath];
    self.topEmitter.position = CGPointMake(self.size.width / 2.0, self.size.height + 30);
    self.topEmitter.particlePositionRange = CGVectorMake(self.size.width, 30);
    self.topEmitter.emissionAngle = 270 * degreeInRadians;
    
    self.bottomEmitter = [NSKeyedUnarchiver unarchiveObjectWithFile:emitterPath];
    self.bottomEmitter.position = CGPointMake(self.size.width / 2.0, -30);
    self.bottomEmitter.particlePositionRange = CGVectorMake(self.size.width, 30);
    
    [self addChild:self.topEmitter];
    [self addChild:self.bottomEmitter];
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
    
    if (self.mainMarker.physicsBody.velocity.dy < 0) {
        self.topEmitter.particleBirthRate = 1000;
        self.topEmitter.yAcceleration = self.mainMarker.physicsBody.velocity.dy;
        self.bottomEmitter.particleBirthRate = 0;
    } else if (self.mainMarker.physicsBody.velocity.dy > 0) {
        self.topEmitter.particleBirthRate = 0;
        self.bottomEmitter.particleBirthRate = 1000;
        self.bottomEmitter.yAcceleration = self.mainMarker.physicsBody.velocity.dy;
    } else {
        self.topEmitter.particleBirthRate = 0;
        self.bottomEmitter.particleBirthRate = 0;
    }
    
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
    
    _distance += distanceDiff * kmPerPixel * 2.0;
    
    _lastMarkerPosition = _mainMarker.position.y;
    
    if (_distance < 0.001) {
        _distanceLabel.text = [NSString stringWithFormat:@"%.1fcm", _distance * 100000];
    } else if (_distance < 1) {
        _distanceLabel.text = [NSString stringWithFormat:@"%.2fm", _distance * 1000];
    } else {
        _distanceLabel.text = [NSString stringWithFormat:@"%.3fkm", _distance];
    }
    
    _globalProps.globalDistance = [NSNumber numberWithDouble:_distance];
    
    _lastSpeedCheckInterval += timeSinceLast;
    if (_lastSpeedCheckInterval > _speedCheckInterval) {
        
        CGFloat measureDistance = fabs(_distance - _lastSpeedCheckDistance);
        CGFloat speed;
        speed = measureDistance * _lastSpeedCheckInterval * kmPSecInKmPH;

        self.speedLabel.text = [NSString stringWithFormat:@"%.1fKm/h", speed];
        
        if (speed > _maxSpeed) {
            _maxSpeed = speed;
            _globalProps.maxSpeed = [NSNumber numberWithFloat:_maxSpeed];
        }
        
        _lastSpeedCheckDistance = _distance;
        _lastSpeedCheckInterval = 0.0;
    }
    CGFloat distanceFromMiddle = fabs(self.size.height / 2.0 - _mainMarker.position.y) / ((self.size.height + _mainMarker.size.height) / 2.0);
    _spiral.xScale = _spiral.yScale = .35 * distanceFromMiddle + 1;
    _spiral.zRotation = ((self.size.height / 2.0 - _mainMarker.position.y) / ((self.size.height + _mainMarker.size.height) / 2.0)) * M_PI;
    
    NSLog(@"%f", distanceFromMiddle);
    
    //_spiral.zRotation = distanceFromMiddle * M_PI;
}

-(void)swipeWithVelocity:(float)velocity
{
    [self.mainMarker.physicsBody applyImpulse:CGVectorMake(0, -velocity)];
}

-(void)swipeInProgressAtPoint:(CGPoint)point withTranslation:(CGPoint)translation
{
    /*double angle = atan2(rwNormalize(translation).x, rwNormalize(translation).y);
    CGPoint locationInView = CGPointMake(point.x, self.size.height - point.y);
    if (angle != 0) {
        self.mainMarker.zRotation = angle;
    }*/
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
