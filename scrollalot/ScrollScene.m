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

@property (nonatomic) NSMutableArray *verticalMarkers;
@property (nonatomic) NSMutableArray *horizontalMarkers;
@property (nonatomic) MarkerObject *mainMarker;
@property (nonatomic) CGPoint lastMarkerPosition;
@property (nonatomic) CGFloat lastSpeedCheckDistance;

@property (nonatomic) SKLabelNode *distanceLabel;
@property (nonatomic) SKLabelNode *speedLabel;
@property (nonatomic) SKLabelNode *maxSpeedLabel;

@property (nonatomic) GlobalAppProperties *globalProps;

@property (nonatomic) ParallaxBG *parallaxBG;

@property (nonatomic) SKEmitterNode *topEmitter;
@property (nonatomic) SKEmitterNode *bottomEmitter;
@property (nonatomic) SKEmitterNode *leftEmitter;
@property (nonatomic) SKEmitterNode *rightEmitter;

@property (nonatomic) MarkerObject *compass_arrow;
@property (nonatomic) MarkerObject *compass;

@property (nonatomic) float lastSpeed;
@property (nonatomic) double initialDistance;

@property (nonatomic) ComboManager *comboManager;
@property (nonatomic) RouteManager *routeManager;

@property (nonatomic) SKAction *pulseAction;

@property (nonatomic) SKSpriteNode *helpNode;

@property (nonatomic) BOOL helpNodeIsVisible;

@property (nonatomic) BOOL isDarkStyle;

@property (nonatomic) char currentRouteDirection;
@property (nonatomic) NSNumber *currentRouteDistance;

@end

@implementation ScrollScene

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        self.backgroundColor = [UIColor whiteColor];
        self.speedCheckInterval = 2.0;
        self.globalProps = [GlobalAppProperties sharedInstance];
        self.verticalMarkers = [NSMutableArray array];
        self.horizontalMarkers = [NSMutableArray array];
        self.isDarkStyle = NO;
        if (self.isDarkStyle) {
            self.backgroundColor = [UIColor blackColor];
        } else {
            self.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0];
        }
        self.comboManager = [ComboManager sharedManager];
        self.comboManager.delegate = self;
        self.routeManager = [[RouteManager alloc] initWithDelegate:self];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [self.routeManager readRoutes];
            [self.routeManager loadNewRoute];
        });
        self.pulseAction = [SKAction sequence:@[[SKAction scaleTo:1.2 duration:.1], [SKAction scaleTo:1.0 duration:.1]]];
        self.helpNodeIsVisible = NO;
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
    
    self.compass = [[MarkerObject alloc] initWithTexture:[SKTexture textureWithImage:[UIImage imageNamed:@"compass"]]];
    self.compass.position = CGPointMake(self.size.width / 2.0, self.size.height / 2.0);
    self.compass.name = @"compass";
    [self addChild:self.compass];
    
    self.compass_arrow = [[MarkerObject alloc] initWithTexture:[SKTexture textureWithImage:[UIImage imageNamed:@"compass_arrow"]]];
    self.compass_arrow.position = CGPointMake(self.size.width / 2.0, self.size.height / 2.0);
    self.compass_arrow.xScale = self.compass_arrow.yScale = 0.8;
    self.compass_arrow.name = @"compass";
    [self addChild:self.compass_arrow];
    
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
    self.initialDistance = self.distance;
    
    self.lastSpeedCheckDistance = self.distance;
    self.lastSpeedCheckInterval = 0;
    self.lastMarkerPosition = self.mainMarker.position;
    
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
    self.topEmitter.particlePositionRange = CGVectorMake(self.size.width + 50, 30);
    self.topEmitter.emissionAngle = 270 * degreeInRadians;
    
    self.bottomEmitter = [NSKeyedUnarchiver unarchiveObjectWithFile:emitterPath];
    self.bottomEmitter.position = CGPointMake(self.size.width / 2.0, -30);
    self.bottomEmitter.particlePositionRange = CGVectorMake(self.size.width + 50, 30);
    
    self.leftEmitter = [NSKeyedUnarchiver unarchiveObjectWithFile:emitterPath];
    self.leftEmitter.position = CGPointMake(-30, self.size.height / 2.0);
    self.leftEmitter.particlePositionRange = CGVectorMake(30, self.size.height + 50);
    self.leftEmitter.emissionAngle = 0;
    
    self.rightEmitter = [NSKeyedUnarchiver unarchiveObjectWithFile:emitterPath];
    self.rightEmitter.position = CGPointMake(self.size.width + 30, self.size.height / 2.0);
    self.rightEmitter.particlePositionRange = CGVectorMake(30, self.size.height + 50);
    self.rightEmitter.emissionAngle = 180 * degreeInRadians;
    
    [self addChild:self.topEmitter];
    [self addChild:self.bottomEmitter];
    [self addChild:self.leftEmitter];
    [self addChild:self.rightEmitter];
    
    UIColor *markerColor;
    if (_isDarkStyle) {
        markerColor = [UIColor whiteColor];
    } else {
        markerColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0];
    }
    
    /*for (int i=0; i<2; i++) {
        MarkerObject *horizontalLeft = [[MarkerObject alloc] initWithColor:markerColor size:CGSizeMake(200, 5)];
        horizontalLeft.position = CGPointMake(0, self.size.height * (1 + i) / 3.0);
        [self.horizontalMarkers addObject:horizontalLeft];
        [self addChild:horizontalLeft];
        
        MarkerObject *horizontalRight = [[MarkerObject alloc] initWithColor:markerColor size:CGSizeMake(200, 5)];
        horizontalRight.position = CGPointMake(self.size.width, self.size.height * (1 + i) / 3.0);
        [self.horizontalMarkers addObject:horizontalRight];
        [self addChild:horizontalRight];
    }
    
    for (int i=0; i<2; i++) {
        MarkerObject *verticalTop = [[MarkerObject alloc] initWithColor:markerColor size:CGSizeMake(5, 300)];
        verticalTop.position = CGPointMake(self.size.width * (1 + i) / 3.0, self.size.height);
        [self.verticalMarkers addObject:verticalTop];
        [self addChild:verticalTop];
        
        MarkerObject *verticalBottom = [[MarkerObject alloc] initWithColor:markerColor size:CGSizeMake(5, 300)];
        verticalBottom.position = CGPointMake(self.size.width * (1 + i) / 3.0, 0);
        [self.verticalMarkers addObject:verticalBottom];
        [self addChild:verticalBottom];
    }*/
    
    MarkerObject *leftMarker = [[MarkerObject alloc] initWithColor:markerColor size:CGSizeMake(200, 5)];
    leftMarker.position = CGPointMake(0, self.size.height / 2.0);
    [self.horizontalMarkers addObject:leftMarker];
    [self addChild:leftMarker];
    
    MarkerObject *rightMarker = [[MarkerObject alloc] initWithColor:markerColor size:CGSizeMake(200, 5)];
    rightMarker.position = CGPointMake(self.size.width, self.size.height / 2.0);
    [self.horizontalMarkers addObject:rightMarker];
    [self addChild:rightMarker];
    
    MarkerObject *topMarker = [[MarkerObject alloc] initWithColor:markerColor size:CGSizeMake(5, 300)];
    topMarker.position = CGPointMake(self.size.width / 2.0, self.size.height);
    [self.verticalMarkers addObject:topMarker];
    [self addChild:topMarker];
    
    MarkerObject *bottomMarker = [[MarkerObject alloc] initWithColor:markerColor size:CGSizeMake(5, 300)];
    bottomMarker.position = CGPointMake(self.size.width / 2.0, 0);
    [self.verticalMarkers addObject:bottomMarker];
    [self addChild:bottomMarker];
    
    SKShapeNode *distanceBox = [SKShapeNode node];
    [distanceBox setPath:CGPathCreateWithRoundedRect(CGRectMake(self.size.width - 150, self.size.height - 80, 130, 50), 8, 8, nil)];
    distanceBox.strokeColor = distanceBox.fillColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.7];
    [self addChild:distanceBox];
    
    self.distanceLabel = [SKLabelNode labelNodeWithFontNamed:@"ArialMT"];
    self.distanceLabel.fontSize = 18.0;
    self.distanceLabel.position = CGPointMake(self.size.width - 85, self.size.height - 60);
    self.distanceLabel.fontColor = [UIColor whiteColor];
    [self addChild:self.distanceLabel];
    
    SKShapeNode *speedBox = [SKShapeNode node];
    [speedBox setPath:CGPathCreateWithRoundedRect(CGRectMake(self.size.width / 2.0 - 65, 40, 130, 50), 8, 8, nil)];
    speedBox.strokeColor = speedBox.fillColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.7];
    [self addChild:speedBox];
    
    self.speedLabel = [SKLabelNode labelNodeWithFontNamed:@"ArialMT"];
    self.speedLabel.fontSize = 18.0;
    self.speedLabel.position = CGPointMake(self.size.width / 2.0, 60);;
    self.speedLabel.fontColor = [UIColor whiteColor];
    self.speedLabel.text = @"0.0Km/h";
    [self addChild:self.speedLabel];
    
    SKShapeNode *maxSpeedBox = [SKShapeNode node];
    [maxSpeedBox setPath:CGPathCreateWithRoundedRect(CGRectMake(20, self.size.height - 80, 130, 50), 8, 8, nil)];
    maxSpeedBox.strokeColor = maxSpeedBox.fillColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.7];
    maxSpeedBox.name = @"maxspeedbox";
    [self addChild:maxSpeedBox];
    
    self.maxSpeedLabel = [SKLabelNode labelNodeWithFontNamed:@"ArialMT"];
    self.maxSpeedLabel.fontSize = 18.0;
    self.maxSpeedLabel.position = CGPointMake(85, self.size.height - 60) ;
    self.maxSpeedLabel.fontColor = [UIColor whiteColor];
    self.maxSpeedLabel.text = [NSString stringWithFormat:@"%.1fkm/h", self.maxSpeed];
    [self addChild:self.maxSpeedLabel];
    
    self.helpNode = [[SKSpriteNode alloc] initWithColor:[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.7] size:self.size];
    self.helpNode.position = CGPointMake(self.size.width / 2.0, self.size.height / 2.0);
    
    SKNode *nerdText = [SKNode node];
    SKLabelNode *a = [SKLabelNode labelNodeWithFontNamed:@"ArialMT"];
    a.fontSize = 16;
    a.fontColor = [SKColor whiteColor];
    SKLabelNode *b = [SKLabelNode labelNodeWithFontNamed:@"ArialMT"];
    b.fontSize = 16;
    b.fontColor = [SKColor whiteColor];
    NSString *st1 = @"Here you can see your current speed";
    NSString *st2 = @"and the total distance covered.";
    b.position = CGPointMake(b.position.x, b.position.y - 20);
    a.text = st1;
    b.text = st2;
    [nerdText addChild:a];
    [nerdText addChild:b];
    nerdText.position = CGPointMake(5, 140);
    [self.helpNode addChild:nerdText];
    
    /*SKLabelNode *helpLabel1 = [SKLabelNode labelNodeWithFontNamed:@"ArialMT"];
    helpLabel1.fontSize = 18.0;
    helpLabel1.position = CGPointMake(100, 100);
    
    helpLabel1.fontColor = [UIColor whiteColor];
    helpLabel1.text = @"Here you can see your current speed and the total distance covered. Scroll on for more!";
    [self.helpNode addChild:helpLabel1];*/
    [self addChild:self.helpNode];
    
    NSNumber *wasHelpShown = [[NSUserDefaults standardUserDefaults] objectForKey:kWasHelpShownKey];
    //wasHelpShown = nil;
    if (!wasHelpShown) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:kWasHelpShownKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        self.helpNodeIsVisible = YES;
        self.helpNode.hidden = NO;
    } else {
        self.helpNode.hidden = YES;
    }
    
}

/*-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
 
    
    for (UITouch *touch in touches) {

    }
}*/

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_helpNodeIsVisible) {
        _helpNodeIsVisible = NO;
        _helpNode.hidden = YES;
    } else {
        UITouch *touch = [touches anyObject];
        CGPoint location = [touch locationInNode:self];
        SKNode *node = [self nodeAtPoint:location];
        
        NSArray *nodes = [self nodesAtPoint:location];
        if ([nodes containsObject:_compass] || [nodes containsObject:_compass_arrow]) {
            [_compass runAction:_pulseAction];
            [_compass_arrow runAction:_pulseAction];
            [_delegate presentLeaderBoards];
        }
    }
}

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
    
    if (self.mainMarker.physicsBody.velocity.dx < 0) {
        self.leftEmitter.particleBirthRate = 0;
        self.rightEmitter.particleBirthRate = 700;
        self.rightEmitter.xAcceleration = self.mainMarker.physicsBody.velocity.dx;
    } else if (self.mainMarker.physicsBody.velocity.dx > 0) {
        self.leftEmitter.particleBirthRate = 700;
        self.rightEmitter.particleBirthRate = 0;
        self.leftEmitter.xAcceleration = self.mainMarker.physicsBody.velocity.dx;
    } else {
        self.leftEmitter.particleBirthRate = 0;
        self.rightEmitter.particleBirthRate = 0;
    }
    
    self.topEmitter.xAcceleration = self.bottomEmitter.xAcceleration = self.leftEmitter.xAcceleration = self.rightEmitter.xAcceleration = _mainMarker.physicsBody.velocity.dx;
    
    self.topEmitter.yAcceleration = self.bottomEmitter.yAcceleration = self.leftEmitter.yAcceleration = self.rightEmitter.yAcceleration = _mainMarker.physicsBody.velocity.dy;
    
    [self updateWithTimeSinceLastUpdate:timeSinceLast];
}

-(void)updateWithTimeSinceLastUpdate:(CFTimeInterval)timeSinceLast
{
    for (SKSpriteNode *marker in _horizontalMarkers) {
        if (marker.position.y < -marker.size.height / 2.0) {
            marker.position = CGPointMake(marker.position.x, self.size.height + marker.size.height / 2.0);
        } else if (marker.position.y > self.size.height + marker.size.height / 2.0) {
            marker.position = CGPointMake(marker.position.x, -marker.size.height / 2.0);
        }
    }
    
    for (SKSpriteNode *marker in _verticalMarkers) {
        if (marker.position.x < -marker.size.width / 2.0) {
            marker.position = CGPointMake(self.size.width + marker.size.width / 2.0, marker.position.y);
        } else if (marker.position.x > self.size.width + marker.size.width / 2.0) {
            marker.position = CGPointMake(-marker.size.width / 2.0, marker.position.y);
        }
    }
    
    CGFloat distanceDiffX = fabs(_lastMarkerPosition.x - _mainMarker.position.x);
    CGFloat distanceDiffY = fabs(_lastMarkerPosition.y - _mainMarker.position.y);
    
    //CGFloat distanceDiff = fabsf(_lastMarkerPosition - _mainMarker.position.y);
    
    //NSLog(@"%f", _mainMarker.position.y);
    
    CGFloat positionX = _mainMarker.position.x;
    CGFloat positionY = _mainMarker.position.y;
    
    if (_mainMarker.position.x < -_mainMarker.size.width / 2.0) {
        distanceDiffX = 0;
        positionX = self.size.width + _mainMarker.size.width / 2.0;
    } else if (_mainMarker.position.x > self.size.width + _mainMarker.size.width / 2.0) {
        distanceDiffX = 0;
        positionX = -_mainMarker.size.width / 2.0;
    }
    
    if (_mainMarker.position.y < -_mainMarker.size.height / 2.0) {
        distanceDiffY = 0;
        positionY = self.size.height + _mainMarker.size.height / 2.0;
    } else if (_mainMarker.position.y > self.size.height + _mainMarker.size.height / 2.0) {
        distanceDiffY = 0;
        positionY = -_mainMarker.size.height / 2.0;
    }
    
    _mainMarker.position = CGPointMake(positionX, positionY);
    
    CGFloat distanceDiff = sqrt(pow(distanceDiffX, 2) + pow(distanceDiffY, 2));
    
    _distance += distanceDiff * kmPerPixel * 2.0;
    
    _lastMarkerPosition = _mainMarker.position;
    
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
        CGFloat speed = measureDistance * _lastSpeedCheckInterval * kmPSecInKmPH;

        self.speedLabel.text = [NSString stringWithFormat:@"%.1fKm/h", speed];
        
        if (speed > _maxSpeed) {
            _maxSpeed = speed;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                [_delegate reportMaxSpeed:_maxSpeed];
            });
            _globalProps.maxSpeed = [NSNumber numberWithFloat:_maxSpeed];
            _maxSpeedLabel.text = [NSString stringWithFormat:@"%.1fkm/h", _maxSpeed];
        }
        
        if (speed < _lastSpeed && _lastSpeed == _maxSpeed) {
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:_maxSpeed] forKey:kMaxSpeedKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self addTextArray:@[@"Speed", @"Record!"] completion:^{
                
            } andInterval:.5];
        }
        
        _lastSpeed = speed;
        
        _lastSpeedCheckDistance = _distance;
        _lastSpeedCheckInterval = 0.0;
    }
    
    _compass_arrow.zRotation = ((self.size.height / 2.0 - _mainMarker.position.y) / ((self.size.height + _mainMarker.size.height) / 2.0)) * M_PI;
    
    for (MarkerObject *marker in _horizontalMarkers) {
        CGFloat distanceFromMiddle = fabs(self.size.height / 2.0 - marker.position.y) / ((self.size.height + marker.size.height) / 2.0) + 0.6;
        marker.xScale = distanceFromMiddle;
        distanceFromMiddle -= 0.4;
        marker.alpha = distanceFromMiddle * distanceFromMiddle;
    }
    
    for (MarkerObject *marker in _verticalMarkers) {
        CGFloat distanceFromMiddle = fabs(self.size.width / 2.0 - marker.position.x) / ((self.size.width + marker.size.width) / 2.0) + 0.65;
        marker.yScale = distanceFromMiddle;
        distanceFromMiddle -= 0.45;
        marker.alpha = distanceFromMiddle * distanceFromMiddle;
    }
    
    if (_distance * 1000 > _initialDistance * 1000 + 10) {
        _initialDistance = _distance;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [_delegate reportDistance:_distance];
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithDouble:_distance] forKey:kGlobalDistanceKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
        });
    }
}

-(void)swipeWithVelocity:(CGPoint)velocity
{
    if (fabs(velocity.y) >= fabs(velocity.x)) {
        if (velocity.y < 0) {
            [_comboManager actionTaken:@"u"];
        } else if (velocity.y > 0) {
            [_comboManager actionTaken:@"d"];
        }
    } else {
        if (velocity.x < 0) {
            [_comboManager actionTaken:@"l"];
        } else if (velocity.x > 0) {
            [_comboManager actionTaken:@"r"];
        }
    }
    [self.mainMarker.physicsBody applyImpulse:CGVectorMake(velocity.x, -velocity.y)];
    for (SKSpriteNode *marker in _horizontalMarkers) {
        [marker.physicsBody applyImpulse:CGVectorMake(0, -velocity.y)];
    }
    for (MarkerObject *marker in _verticalMarkers) {
        [marker.physicsBody applyImpulse:CGVectorMake(velocity.x, 0)];
    }
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

-(void)combosCompleted:(NSSet *)combos
{
    NSLog(@"Combos: %@", combos);
    [self addTextArray:[combos sortedArrayUsingDescriptors:nil] completion:^{
        
    } andInterval:.5];
}

-(void)setMaxSpeed:(float)maxSpeed
{
    _maxSpeed = maxSpeed;
    _globalProps.maxSpeed = [NSNumber numberWithFloat:_maxSpeed];
    _maxSpeedLabel.text = [NSString stringWithFormat:@"%.1fkm/h", _maxSpeed];
}

-(void)setDistance:(double)distance
{
    _distance = distance;
    _globalProps.globalDistance = [NSNumber numberWithDouble:_distance];
    if (_distance < 0.001) {
        _distanceLabel.text = [NSString stringWithFormat:@"%.1fcm", _distance * 100000];
    } else if (_distance < 1) {
        _distanceLabel.text = [NSString stringWithFormat:@"%.2fm", _distance * 1000];
    } else {
        _distanceLabel.text = [NSString stringWithFormat:@"%.3fkm", _distance];
    }
}

-(void)nextRouteLoadedInDirection:(char)initialDirection andDistance:(NSNumber *)distance
{
    _currentRouteDirection = initialDirection;
    _currentRouteDistance = distance;
}

-(void)routeCompleted:(NSString *)routeName
{
    [self addTextArray:@[routeName, @"Completed!"] completion:^{
        
    } andInterval:.5];
}

-(void)checkpointCompletedWithNextDirection:(char)nextDirection andDistance:(NSNumber *)distance
{
    _currentRouteDirection = nextDirection;
    _currentRouteDistance = distance;
}

-(void)distanceDownloadedFromGC:(double)distance
{
    _distance = distance;
    _lastSpeedCheckDistance = distance;
}

@end
