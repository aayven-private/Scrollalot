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
#import "CommonTools.h"

//static CGFloat mmPerPixel = 0.078125;
//static CGFloat cmPerPixel = 0.0078125;
//static CGFloat mPerPixel = 0.000078125;
static CGFloat kmPerPixel = 0.000000078125;

//static CGFloat mmPSecInKmPH = 0.0036;
//static CGFloat mPSecInKmPH = 3.6;
static CGFloat kmPSecInKmPH = 3600.;

static CGFloat degreeInRadians = 0.0174532925;

static NSString *kHadRouteKey = @"had_route";
static NSString *kHadComboKey = @"had_combo";

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

@property (nonatomic) SKEmitterNode *topRouteEmitter;
@property (nonatomic) SKEmitterNode *bottomRouteEmitter;
@property (nonatomic) SKEmitterNode *leftRouteEmitter;
@property (nonatomic) SKEmitterNode *rightRouteEmitter;

//@property (nonatomic) SKEmitterNode *bgEmitter;

@property (nonatomic) MarkerObject *compass_arrow;
@property (nonatomic) MarkerObject *compass;

@property (nonatomic) float lastSpeed;
@property (nonatomic) double initialDistance;

@property (nonatomic) ComboManager *comboManager;
@property (nonatomic) RouteManager *routeManager;

@property (nonatomic) SKAction *pulseAction;
@property (nonatomic) SKAction *pulseAction_long;

@property (nonatomic) SKAction *arrowAction;

@property (nonatomic) SKSpriteNode *helpNode;

@property (nonatomic) BOOL helpNodeIsVisible;

@property (nonatomic) BOOL isDarkStyle;

@property (nonatomic) char currentRouteDirection;
@property (nonatomic) char lastRouteDirection;
@property (nonatomic) float currentRouteDistance;

@property (nonatomic) CGFloat routeDistanceX;
@property (nonatomic) CGFloat routeDistanceY;

@property (nonatomic) SKShapeNode *maxSpeedBox;

@property (nonatomic) SKSpriteNode *directionMarker;

@property (nonatomic) SKTexture *arrowLeftTexture;
@property (nonatomic) SKTexture *arrowRightTexture;
@property (nonatomic) SKTexture *arrowUpTexture;
@property (nonatomic) SKTexture *arrowDownTexture;

@property (nonatomic) int checkpointCount;

@property (nonatomic) SKAction *rotateToLeft;
@property (nonatomic) SKAction *rotateToRight;
@property (nonatomic) SKAction *rotateToTop;
@property (nonatomic) SKAction *rotateToBottom;
@property (nonatomic) SKAction *pulseAction_route;
@property (nonatomic) SKAction *vibrateAction;

@property (nonatomic) BOOL compassRotationFixed;

@property (nonatomic) BOOL isRouteTutorial;
@property (nonatomic) BOOL isComboTutorial;

@property (nonatomic) BOOL startedRouteTutorial;

@end

@implementation ScrollScene

static BOOL startWithTutorials = YES;

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
        
        self.pulseAction = [SKAction sequence:@[[SKAction scaleTo:1.2 duration:.1], [SKAction scaleTo:1.0 duration:.1]]];
        self.pulseAction_long = [SKAction sequence:@[[SKAction scaleTo:1.5 duration:.2], [SKAction scaleTo:1.0 duration:.2]]];
        self.pulseAction_route = [SKAction repeatActionForever:[SKAction sequence:@[[SKAction scaleTo:1.2 duration:.3], [SKAction scaleTo:1.0 duration:.3]]]];
        
        self.helpNodeIsVisible = NO;
        
        self.routeDistanceX = 0;
        self.routeDistanceY = 0;
        
        self.arrowDownTexture = [SKTexture textureWithImageNamed:@"arrow_down"];
        self.arrowUpTexture = [SKTexture textureWithImageNamed:@"arrow_up"];
        self.arrowLeftTexture = [SKTexture textureWithImageNamed:@"arrow_left"];
        self.arrowRightTexture = [SKTexture textureWithImageNamed:@"arrow_right"];
        
        SKAction *fadeInGrow = [SKAction group:@[[SKAction fadeAlphaTo:1.0 duration:.5], [SKAction scaleTo:2.5 duration:.5]]];
        SKAction *shrinkAndFlyToCorner = [SKAction group:@[[SKAction scaleTo:1.0 duration:.3], [SKAction moveTo:CGPointMake(self.size.width - 45, 65) duration:.3]]];
        
        self.arrowAction = [SKAction sequence:@[fadeInGrow, shrinkAndFlyToCorner]];
        
        self.checkpointCount = 0;

        self.rotateToLeft = [SKAction rotateToAngle:-M_PI_2 duration:.1 shortestUnitArc:YES];
        self.rotateToRight = [SKAction rotateToAngle:M_PI_2 duration:.1 shortestUnitArc:YES];
        self.rotateToTop = [SKAction rotateToAngle:-M_PI duration:.1 shortestUnitArc:YES];
        self.rotateToBottom = [SKAction rotateToAngle:0 duration:.1 shortestUnitArc:YES];
        self.compassRotationFixed = NO;
        
        
    }
    return self;
}

-(void)initEnvironment
{
    self.comboManager = [ComboManager sharedManager];
    self.comboManager.delegate = self;
    self.routeManager = [[RouteManager alloc] initWithDelegate:self];
    
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
    
    /*emitterPath = [[NSBundle mainBundle] pathForResource:@"RouteEffect" ofType:@"sks"];
    self.bgEmitter = [NSKeyedUnarchiver unarchiveObjectWithFile:emitterPath];
    self.bgEmitter.position = CGPointMake(self.size.width / 2.0, self.size.height /2.0);
    [self addChild:self.bgEmitter];*/
    
    emitterPath = [[NSBundle mainBundle] pathForResource:@"RouteEffect" ofType:@"sks"];
    self.topRouteEmitter = [NSKeyedUnarchiver unarchiveObjectWithFile:emitterPath];
    self.topRouteEmitter.position = CGPointMake(self.size.width / 2.0, self.size.height + 30);
    self.topRouteEmitter.particlePositionRange = CGVectorMake(80, 30);
    self.topRouteEmitter.emissionAngle = 270 * degreeInRadians;
    
    self.bottomRouteEmitter = [NSKeyedUnarchiver unarchiveObjectWithFile:emitterPath];
    self.bottomRouteEmitter.position = CGPointMake(self.size.width / 2.0, -30);
    self.bottomRouteEmitter.particlePositionRange = CGVectorMake(80, 30);
    
    self.leftRouteEmitter = [NSKeyedUnarchiver unarchiveObjectWithFile:emitterPath];
    self.leftRouteEmitter.position = CGPointMake(-30, self.size.height / 2.0);
    self.leftRouteEmitter.particlePositionRange = CGVectorMake(30, 80);
    self.leftRouteEmitter.emissionAngle = 0;
    
    self.rightRouteEmitter = [NSKeyedUnarchiver unarchiveObjectWithFile:emitterPath];
    self.rightRouteEmitter.position = CGPointMake(self.size.width + 30, self.size.height / 2.0);
    self.rightRouteEmitter.particlePositionRange = CGVectorMake(30, 80);
    self.rightRouteEmitter.emissionAngle = 180 * degreeInRadians;
    
    self.rightRouteEmitter.particleBirthRate = self.leftRouteEmitter.particleBirthRate = self.topRouteEmitter.particleBirthRate = self.bottomRouteEmitter.particleBirthRate = 0;
    
    [self addChild:self.topRouteEmitter];
    [self addChild:self.bottomRouteEmitter];
    [self addChild:self.leftRouteEmitter];
    [self addChild:self.rightRouteEmitter];
    
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
    self.speedLabel.position = CGPointMake(self.size.width / 2.0, 60);
    self.speedLabel.fontColor = [UIColor whiteColor];
    self.speedLabel.text = @"0.0Km/h";
    [self addChild:self.speedLabel];
    
    self.maxSpeedBox = [SKShapeNode node];
    [self.maxSpeedBox setPath:CGPathCreateWithRoundedRect(CGRectMake(20, self.size.height - 80, 130, 50), 8, 8, nil)];
    self.maxSpeedBox.strokeColor = self.maxSpeedBox.fillColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.7];
    self.maxSpeedBox.name = @"maxspeedbox";
    [self addChild:self.maxSpeedBox];
    
    self.maxSpeedLabel = [SKLabelNode labelNodeWithFontNamed:@"ArialMT"];
    self.maxSpeedLabel.fontSize = 18.0;
    self.maxSpeedLabel.position = CGPointMake(85, self.size.height - 60) ;
    self.maxSpeedLabel.fontColor = [UIColor whiteColor];
    self.maxSpeedLabel.text = [NSString stringWithFormat:@"%.1fkm/h", self.maxSpeed];
    [self addChild:self.maxSpeedLabel];
    
    /*self.helpNode = [[SKSpriteNode alloc] initWithColor:[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.7] size:self.size];
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
    [self.helpNode addChild:nerdText];*/
    
    self.currentRouteDirection = 'n';
    self.lastRouteDirection = 'n';
    self.currentRouteDistance = 0;
    
    /*SKLabelNode *helpLabel1 = [SKLabelNode labelNodeWithFontNamed:@"ArialMT"];
    helpLabel1.fontSize = 18.0;
    helpLabel1.position = CGPointMake(100, 100);
    
    helpLabel1.fontColor = [UIColor whiteColor];
    helpLabel1.text = @"Here you can see your current speed and the total distance covered. Scroll on for more!";
    [self.helpNode addChild:helpLabel1];*/
    
    self.compass = [[MarkerObject alloc] initWithTexture:[SKTexture textureWithImage:[UIImage imageNamed:@"compass"]]];
    self.compass.position = CGPointMake(self.size.width / 2.0, self.size.height / 2.0);
    self.compass.name = @"compass";
    [self addChild:self.compass];
    
    self.compass_arrow = [[MarkerObject alloc] initWithTexture:[SKTexture textureWithImage:[UIImage imageNamed:@"arrow"]]];
    self.compass_arrow.position = CGPointMake(self.size.width / 2.0, self.size.height / 2.0);
    //self.compass_arrow.xScale = self.compass_arrow.yScale = 0.8;
    self.compass_arrow.name = @"compass";
    [self addChild:self.compass_arrow];
    
    self.compass_arrow.zRotation = -M_PI;
    
    NSNumber *wasHelpShown = [[NSUserDefaults standardUserDefaults] objectForKey:kWasHelpShownKey];
    NSNumber *hadRoute = [[NSUserDefaults standardUserDefaults] objectForKey:kHadRouteKey];
    NSNumber *hadCombo = [[NSUserDefaults standardUserDefaults] objectForKey:kHadComboKey];
    
    if (startWithTutorials) {
        wasHelpShown = hadRoute = hadCombo = nil;
    }
    
    if (!wasHelpShown) {
        self.helpNode = [self createBasicHelp1];
        self.helpNode.position = CGPointMake(self.size.width / 2.0, self.size.height / 2.0);
        self.helpNodeIsVisible = YES;
        self.helpNode.hidden = NO;
        [self addChild:self.helpNode];
    } else {
        self.helpNode.hidden = YES;
    }
    
    self.startedRouteTutorial = NO;
    
    if (!hadRoute) {
        self.isRouteTutorial = YES;
        self.startedRouteTutorial = YES;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [self.routeManager readRoutes];
            RouteEntityHelper *tutorialRoute = [[RouteEntityHelper alloc] init];
            int rnd = [CommonTools getRandomNumberFromInt:0 toInt:3];
            switch (rnd) {
                case 0:
                tutorialRoute.routePattern = @"urdl";
                break;
                case 1:
                tutorialRoute.routePattern = @"dlur";
                break;
                case 2:
                tutorialRoute.routePattern = @"lurd";
                break;
                case 3:
                tutorialRoute.routePattern = @"rdlu";
                break;
                default:
                break;
            }
            tutorialRoute.routeName = @"Tutorial";
            tutorialRoute.routeDistance = [NSNumber numberWithFloat:0.001];
            [self.routeManager loadRouteManually:tutorialRoute];
        });
    } else {
        self.isRouteTutorial = NO;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [self.routeManager readRoutes];
            [self.routeManager loadNewRoute];
        });
    }
    
    if (!hadCombo) {
        self.isComboTutorial = YES;
    } else {
        self.isComboTutorial = NO;
    }
    
    if (!wasHelpShown) {
        
    } else {
        [self addTextArray:@[@"Back", @"for", @"MORE", @"SCROLL?:)"] completion:^{
            
        } andInterval:.7];
    }
    
    //[self.compass_arrow runAction:self.rotateToTop];
}

/*-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
 
    
    for (UITouch *touch in touches) {

    }
}*/

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    NSArray *nodes = [self nodesAtPoint:location];
    if ([nodes containsObject:_helpNode]) {
        NSString *helpName = _helpNode.name;
        _helpNodeIsVisible = NO;
        [_helpNode removeFromParent];
        _helpNode = nil;
        if ([helpName isEqualToString:@"basic1"]) {
            _helpNode = [self createBasicHelp2];
        } else if ([helpName isEqualToString:@"basic2"]) {
            _helpNode = [self createBasicHelp3];
        } else if ([helpName isEqualToString:@"basic3"]) {
            _helpNode = [self createBasicHelp4];
        } else if ([helpName isEqual:@"basic4"]) {
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:kWasHelpShownKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [self addTextArray:@[@"LET", @"THE", @"SCROLL", @"BEGIN!"] completion:^{
                
            } andInterval:.7];
        } else if ([helpName isEqualToString:@"combo"]) {
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:kHadComboKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
        } else if ([helpName isEqualToString:@"route2"]) {
            _isRouteTutorial = NO;
        }
        if (_helpNode) {
            _helpNodeIsVisible = YES;
            _helpNode.hidden = NO;
            [self addChild:_helpNode];
        }
    } else {
        //UITouch *touch = [touches anyObject];
        //CGPoint location = [touch locationInNode:self];
        //SKNode *node = [self nodeAtPoint:location];
        
        //NSArray *nodes = [self nodesAtPoint:location];
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
        self.rightEmitter.particleBirthRate = 1000;
        self.rightEmitter.xAcceleration = self.mainMarker.physicsBody.velocity.dx;
    } else if (self.mainMarker.physicsBody.velocity.dx > 0) {
        self.leftEmitter.particleBirthRate = 1000;
        self.rightEmitter.particleBirthRate = 0;
        self.leftEmitter.xAcceleration = self.mainMarker.physicsBody.velocity.dx;
    } else {
        self.leftEmitter.particleBirthRate = 0;
        self.rightEmitter.particleBirthRate = 0;
    }
    
    if (_currentRouteDirection == 'u') {
        _topRouteEmitter.yAcceleration = self.mainMarker.physicsBody.velocity.dy;
    } else if (_currentRouteDirection == 'd') {
        _bottomRouteEmitter.yAcceleration = self.mainMarker.physicsBody.velocity.dy;
    } else if (_currentRouteDirection == 'l') {
        _leftRouteEmitter.xAcceleration = self.mainMarker.physicsBody.velocity.dx;
    } else if (_currentRouteDirection == 'r') {
        _rightRouteEmitter.xAcceleration = self.mainMarker.physicsBody.velocity.dx;
    }
    
    //_leftRouteEmitter.xAcceleration = _rightRouteEmitter.xAcceleration = _mainMarker.physicsBody.velocity.dx;
    //_topRouteEmitter.xAcceleration = _bottomRouteEmitter.xAcceleration = _mainMarker.physicsBody.velocity.dx / 10;
    //_topRouteEmitter.yAcceleration = _bottomRouteEmitter.yAcceleration = _mainMarker.physicsBody.velocity.dy;
    //_leftRouteEmitter.yAcceleration = _rightRouteEmitter.yAcceleration = _mainMarker.physicsBody.velocity.dy / 10;
    
    self.topEmitter.xAcceleration = self.bottomEmitter.xAcceleration = self.leftEmitter.xAcceleration = self.rightEmitter.xAcceleration = _mainMarker.physicsBody.velocity.dx;
    self.topEmitter.yAcceleration = self.bottomEmitter.yAcceleration = self.leftEmitter.yAcceleration = self.rightEmitter.yAcceleration = _mainMarker.physicsBody.velocity.dy;
    
    self.topEmitter.particleRotation = self.bottomEmitter.particleRotation = self.leftEmitter.particleRotation = self.rightEmitter.particleRotation = atan2(_mainMarker.physicsBody.velocity.dx, -_mainMarker.physicsBody.velocity.dy);
    self.topRouteEmitter.particleRotation = self.bottomRouteEmitter.particleRotation = self.leftRouteEmitter.particleRotation = self.rightRouteEmitter.particleRotation = atan2(_mainMarker.physicsBody.velocity.dx, -_mainMarker.physicsBody.velocity.dy);
    
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
    
    CGFloat routeDistanceX = _lastMarkerPosition.x - _mainMarker.position.x;
    CGFloat routeDistanceY = _lastMarkerPosition.y - _mainMarker.position.y;
    
    _routeDistanceX += routeDistanceX * kmPerPixel * 2.0;
    _routeDistanceY += routeDistanceY * kmPerPixel * 2.0;
    
    if (_currentRouteDirection == 'u') {
        if (_currentRouteDistance < _routeDistanceY) {
            [_routeManager actionTaken:@"u"];
            _routeDistanceX = 0;
            _routeDistanceY = 0;
        } else if (_routeDistanceY < -_currentRouteDistance) {
            _routeDistanceY = 0;
            if (!_isRouteTutorial) {
                [self cancelRoute];
            }
        }
    } else if (_currentRouteDirection == 'd') {
        if (_routeDistanceY < -_currentRouteDistance) {
            [_routeManager actionTaken:@"d"];
            _routeDistanceX = 0;
            _routeDistanceY = 0;
        } else if (_routeDistanceY > _currentRouteDistance) {
            _routeDistanceY = 0;
            if (!_isRouteTutorial) {
                [self cancelRoute];
            }
        }
    } else if (_currentRouteDirection == 'l') {
        if (_routeDistanceX < -_currentRouteDistance) {
            [_routeManager actionTaken:@"l"];
            _routeDistanceX = 0;
            _routeDistanceY = 0;
        } else if (_routeDistanceX > _currentRouteDistance) {
            _routeDistanceX = 0;
            if (!_isRouteTutorial) {
                [self cancelRoute];
            }
        }
    } else if (_currentRouteDirection == 'r') {
        if (_currentRouteDistance < _routeDistanceX) {
            [_routeManager actionTaken:@"r"];
            _routeDistanceX = 0;
            _routeDistanceY = 0;
        } else if (_routeDistanceX < -_currentRouteDistance) {
            _routeDistanceX = 0;
            if (!_isRouteTutorial) {
                [self cancelRoute];
            }
        }
    } else {
        _routeDistanceX = 0;
        _routeDistanceY = 0;
    }
    
    //NSLog(@"Route distance in X: %f, Route distance in Y: %f", _routeDistanceX, _routeDistanceY);
    
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
            
            //[_maxSpeedBox runAction:_pulseAction];
            [_maxSpeedLabel runAction:_pulseAction_long];
            //[self addTextArray:@[@"Speed", @"Record!"] completion:^{
                
            //} andInterval:.5];
        }
        
        _lastSpeed = speed;
        
        _lastSpeedCheckDistance = _distance;
        _lastSpeedCheckInterval = 0.0;
    }
    
    if (!_compassRotationFixed) {
        //_compass_arrow.zRotation = ((self.size.height / 2.0 - _mainMarker.position.y) / ((self.size.height + _mainMarker.size.height) / 2.0)) * M_PI;
    }
    
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

-(void)cancelRoute
{
    _routeDistanceX = 0;
    _routeDistanceY = 0;
    _currentRouteDistance = 0;
    _currentRouteDirection = 'n';
    _lastRouteDirection = 'n';
    _compassRotationFixed = NO;
    [_compass_arrow removeAllActions];
    [_compass_arrow runAction:[SKAction scaleTo:1.0 duration:0]];
    _rightRouteEmitter.particleBirthRate = _leftRouteEmitter.particleBirthRate = _topRouteEmitter.particleBirthRate = _bottomRouteEmitter.particleBirthRate = 0;
    if (_directionMarker) {
        [_directionMarker runAction:[SKAction sequence:@[[SKAction group:@[[SKAction fadeAlphaTo:0.0 duration:.5], [SKAction scaleTo:3.5 duration:.5]]], [SKAction removeFromParent]]]];
    }
    [_routeManager loadNewRoute];
}

-(void)swipeWithVelocity:(CGPoint)velocity
{
    if (!_helpNodeIsVisible) {
        //NSLog(@"Impulse: (%f, %f)", velocity.x, velocity.y);
        if (fabs(velocity.y) >= fabs(velocity.x)) {
            if (velocity.y < 0) {
                [_comboManager actionTaken:@"d"];
                //[_compass_arrow runAction:_rotateToBottom];
            } else if (velocity.y > 0) {
                [_comboManager actionTaken:@"u"];
                //[_compass_arrow runAction:_rotateToTop];
            }
        } else {
            if (velocity.x < 0) {
                [_comboManager actionTaken:@"r"];
                //[_compass_arrow runAction:_rotateToRight];
            } else if (velocity.x > 0) {
                [_comboManager actionTaken:@"l"];
                //[_compass_arrow runAction:_rotateToLeft];
            }
        }
        if (!_compassRotationFixed) {
            [_compass_arrow runAction:[SKAction rotateToAngle:atan2(-velocity.x, -velocity.y) duration:.1 shortestUnitArc:YES]];
        }
        
        [self.mainMarker.physicsBody applyImpulse:CGVectorMake(velocity.x, -velocity.y)];
        for (SKSpriteNode *marker in _horizontalMarkers) {
            [marker.physicsBody applyImpulse:CGVectorMake(0, -velocity.y)];
        }
        for (MarkerObject *marker in _verticalMarkers) {
            [marker.physicsBody applyImpulse:CGVectorMake(velocity.x, 0)];
        }
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
    //NSLog(@"Combos: %@", combos);
    if (_isComboTutorial) {
        _isComboTutorial = NO;
        
        _helpNode = [self createComboHelpWithComboName:[combos anyObject]];
        _helpNodeIsVisible = YES;
        [self addChild:_helpNode];
    } else {
        [self addTextArray:[combos sortedArrayUsingDescriptors:nil] completion:^{
            
        } andInterval:.5];
    }
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
    NSLog(@"New route direction: %c", initialDirection);
    _currentRouteDirection = initialDirection;
    _lastRouteDirection = 'n';
    _currentRouteDistance = distance.floatValue;
    if (_directionMarker) {
        [_directionMarker removeFromParent];
        _directionMarker = nil;
    }
}

-(void)routeCompleted:(NSString *)routeName
{
    /*CGPoint currentMarkerDirection = rwNormalize(CGPointMake(_mainMarker.physicsBody.velocity.dx, _mainMarker.physicsBody.velocity.dy));
    CGVector bonusImpulse = CGVectorMake(currentMarkerDirection.x * _currentRouteDistance * 10000000, -currentMarkerDirection.y * _currentRouteDistance * 10000000);
    [_mainMarker.physicsBody applyImpulse:bonusImpulse];
    
    for (SKSpriteNode *marker in _horizontalMarkers) {
        [marker.physicsBody applyImpulse:CGVectorMake(0, bonusImpulse.dy)];
    }
    for (MarkerObject *marker in _verticalMarkers) {
        [marker.physicsBody applyImpulse:CGVectorMake(bonusImpulse.dx, 0)];
    }*/
    
    //_currentRouteDistance = 0.1;
    //_checkpointCount = 10;
    
    CGVector bonusImpulse;
    switch (_currentRouteDirection) {
        case 'u': {
            bonusImpulse = CGVectorMake(0, -(_currentRouteDistance * 1000 * (_checkpointCount + 1)) * 30000);
        } break;
        case 'd': {
            bonusImpulse = CGVectorMake(0, (_currentRouteDistance * 1000 * (_checkpointCount + 1)) * 30000);
        } break;
        case 'l': {
            bonusImpulse = CGVectorMake((_currentRouteDistance * 1000 * (_checkpointCount + 1)) * 30000, 0);
        } break;
        case 'r': {
            bonusImpulse = CGVectorMake(-(_currentRouteDistance * 1000 * (_checkpointCount + 1)) * 30000, 0);
        } break;
        default:
        break;
    }
    
    //NSLog(@"Impulse: (%f, %f)", bonusImpulse.dx, bonusImpulse.dy);
    
    [self.mainMarker.physicsBody applyImpulse:bonusImpulse];
    for (SKSpriteNode *marker in _horizontalMarkers) {
        [marker.physicsBody applyImpulse:CGVectorMake(0, bonusImpulse.dy)];
    }
    for (MarkerObject *marker in _verticalMarkers) {
        [marker.physicsBody applyImpulse:CGVectorMake(bonusImpulse.dx, 0)];
    }
    
    _rightRouteEmitter.particleBirthRate = _leftRouteEmitter.particleBirthRate = _topRouteEmitter.particleBirthRate = _bottomRouteEmitter.particleBirthRate = 0;
    
    _compassRotationFixed = NO;
    [_compass_arrow removeAllActions];
    
    //_distance += _currentRouteDistance * (_checkpointCount + 1);
    //_lastSpeedCheckDistance = _distance;
    [_distanceLabel runAction:_pulseAction_long];
    _currentRouteDirection = 'n';
    _currentRouteDistance = 0;
    _lastRouteDirection = 'n';
    
    if (_directionMarker) {
        [_directionMarker runAction:[SKAction sequence:@[[SKAction group:@[[SKAction fadeAlphaTo:0.0 duration:.5], [SKAction scaleTo:3.5 duration:.5]]], [SKAction removeFromParent]]]];
    }
    //if (NO) {
    if ([routeName isEqualToString:@"Tutorial"]) {
        _helpNode = [self createRouteFinishedHelp];
        _helpNodeIsVisible = YES;
        [self addChild:_helpNode];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:kHadRouteKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [self runAction:[SKAction sequence:@[[SKAction fadeAlphaTo:0.1 duration:.2], [SKAction fadeAlphaTo:1.0 duration:.2]]]];
        [self addTextArray:@[routeName, @"Completed!"] completion:^{
            
        } andInterval:.7];
    }
    
    /*NSString *boomPath =[[NSBundle mainBundle] pathForResource:@"RewardEffect" ofType:@"sks"];
    SKEmitterNode *boom = [NSKeyedUnarchiver unarchiveObjectWithFile:boomPath];
    boom.targetNode = self;
    boom.particlePositionRange = CGVectorMake(10, 10);
    boom.position = CGPointMake(self.size.width / 2.0, self.size.height / 2.0);
    
    SKAction *boomAction = [SKAction sequence:@[[SKAction runBlock:^{
        [self addChild:boom];
    }], [SKAction waitForDuration:3], [SKAction runBlock:^{
        [boom removeFromParent];
    }]]];
    [self runAction:boomAction];*/
    
    [_compass_arrow runAction:[SKAction scaleTo:1.0 duration:0]];
    
    _routeDistanceX = 0;
    _routeDistanceY = 0;
}

-(void)checkpointCompletedWithNextDirection:(char)nextDirection andDistance:(NSNumber *)distance
{
    _rightRouteEmitter.particleBirthRate = _leftRouteEmitter.particleBirthRate = _topRouteEmitter.particleBirthRate = _bottomRouteEmitter.particleBirthRate = 0;
    
    _routeDistanceX = 0;
    _routeDistanceY = 0;
    
    if (_startedRouteTutorial) {
        _helpNode = [self createRouteHelp];
        [self addChild:_helpNode];
        _helpNodeIsVisible = YES;
        _startedRouteTutorial = NO;
    }
    if (!_compassRotationFixed) {
        _compassRotationFixed = YES;
        [_compass_arrow runAction:_pulseAction_route];
    }
    _checkpointCount++;
    _lastRouteDirection = _currentRouteDirection;
    _currentRouteDirection = nextDirection;
    _currentRouteDistance = distance.floatValue;
    NSLog(@"Checkpoint completed, next direction: %c", nextDirection);
    
    SKTexture *arrowTexture = nil;
    BOOL isNewMarker = NO;
    
    isNewMarker = !_directionMarker;
    
    switch (nextDirection) {
        case 'u': {
            arrowTexture = _arrowUpTexture;
            _topRouteEmitter.particleBirthRate = 1000;
            [_compass_arrow runAction:_rotateToTop];
        } break;
        case 'd': {
            arrowTexture = _arrowDownTexture;
            _bottomRouteEmitter.particleBirthRate = 1000;
            [_compass_arrow runAction:_rotateToBottom];
        } break;
        case 'l': {
            arrowTexture = _arrowLeftTexture;
            _leftRouteEmitter.particleBirthRate = 1000;
            [_compass_arrow runAction:_rotateToLeft];
        } break;
        case 'r': {
            arrowTexture = _arrowRightTexture;
            _rightRouteEmitter.particleBirthRate = 1000;
            [_compass_arrow runAction:_rotateToRight];
        } break;
        default:
        break;
    }
    
    if (isNewMarker) {
        _directionMarker = [[SKSpriteNode alloc] initWithTexture:arrowTexture];
        _directionMarker.alpha = 0.0;
        _directionMarker.position = CGPointMake(self.size.width / 2.0, self.size.height / 2.0);
        [_directionMarker runAction:_arrowAction];
        [self addChild:_directionMarker];
    } else {
        _directionMarker.texture = arrowTexture;
        [_directionMarker runAction:_pulseAction_long];
    }
}

-(void)noAvailableRoutes
{
    _currentRouteDirection = 'n';
    _lastRouteDirection = 'n';
    _currentRouteDistance = 0.0;
    _checkpointCount = 0;
}

-(void)distanceDownloadedFromGC:(double)distance
{
    _distance = distance;
    _lastSpeedCheckDistance = distance;
}

-(SKSpriteNode *)createBasicHelp1
{
    SKSpriteNode *helpNode = [[SKSpriteNode alloc] initWithColor:[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.7] size:self.size];
    helpNode.position = CGPointMake(self.size.width / 2.0, self.size.height / 2.0);
    
    helpNode.name = @"basic1";
    
    SKNode *captionBox = [SKNode node];
    SKLabelNode *caption = [SKLabelNode labelNodeWithFontNamed:@"ArialMT"];
    caption.fontSize = 28;
    caption.fontColor = [SKColor whiteColor];
    NSString *cpt = @"Welcome to scrollalot!";
    caption.text = cpt;
    [captionBox addChild:caption];
    captionBox.position = CGPointMake(0, 130);
    
    SKNode *nerdText1 = [SKNode node];
    SKLabelNode *a = [SKLabelNode labelNodeWithFontNamed:@"ArialMT"];
    a.fontSize = 16;
    a.fontColor = [SKColor whiteColor];
    SKLabelNode *b = [SKLabelNode labelNodeWithFontNamed:@"ArialMT"];
    b.fontSize = 16;
    b.fontColor = [SKColor whiteColor];
    NSString *st1 = @"First of all, thanks for downloading";
    NSString *st2 = @"the game. Let me explain you the basics:)";
    b.position = CGPointMake(a.position.x, a.position.y - 20);
    a.text = st1;
    b.text = st2;
    [nerdText1 addChild:a];
    [nerdText1 addChild:b];
    nerdText1.position = CGPointMake(0, 80);
    
    SKNode *nerdText2 = [SKNode node];
    SKLabelNode *c = [SKLabelNode labelNodeWithFontNamed:@"ArialMT"];
    c.fontSize = 16;
    c.fontColor = [SKColor whiteColor];
    SKLabelNode *d = [SKLabelNode labelNodeWithFontNamed:@"ArialMT"];
    d.fontSize = 16;
    d.fontColor = [SKColor whiteColor];
    st1 = @"The goal is to scroll as much as you can.";
    st2 = @"That's right, it is that easy!";
    NSString *st3 = @"All you have to do is swipe in any direction.";
    d.position = CGPointMake(c.position.x, c.position.y - 20);
    c.text = st1;
    d.text = st2;
    SKLabelNode *e = [SKLabelNode labelNodeWithFontNamed:@"ArialMT"];
    e.fontSize = 16;
    e.fontColor = [SKColor whiteColor];
    e.text = st3;
    e.position = CGPointMake(d.position.x, d.position.y - 20);
    [nerdText2 addChild:c];
    [nerdText2 addChild:d];
    [nerdText2 addChild:e];
    nerdText2.position = CGPointMake(0, 30);
    
    SKNode *nerdText3 = [SKNode node];
    SKLabelNode *f = [SKLabelNode labelNodeWithFontNamed:@"ArialMT"];
    f.fontSize = 16;
    f.fontColor = [SKColor whiteColor];
    SKLabelNode *g = [SKLabelNode labelNodeWithFontNamed:@"ArialMT"];
    g.fontSize = 16;
    g.fontColor = [SKColor whiteColor];
    st1 = @"Tap on the screen and I will show you";
    st2 = @"everything you need to know.";
    g.position = CGPointMake(f.position.x, f.position.y - 20);
    f.text = st1;
    g.text = st2;
    [nerdText3 addChild:f];
    [nerdText3 addChild:g];
    nerdText3.position = CGPointMake(0, -40);
    
    [helpNode addChild:captionBox];
    [helpNode addChild:nerdText1];
    [helpNode addChild:nerdText2];
    [helpNode addChild:nerdText3];
    
    return helpNode;
}

-(SKSpriteNode *)createBasicHelp2
{
    SKSpriteNode *helpNode = [[SKSpriteNode alloc] initWithColor:[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.7] size:self.size];
    helpNode.position = CGPointMake(self.size.width / 2.0, self.size.height / 2.0);
    
    helpNode.name = @"basic2";
    
    SKNode *nerdText1 = [SKNode node];
    SKLabelNode *a = [SKLabelNode labelNodeWithFontNamed:@"ArialMT"];
    a.fontSize = 16;
    a.fontColor = [SKColor whiteColor];
    SKLabelNode *b = [SKLabelNode labelNodeWithFontNamed:@"ArialMT"];
    b.fontSize = 16;
    b.fontColor = [SKColor whiteColor];
    NSString *st1 = @"Here you can see speed record";
    NSString *st2 = @"and the total distance covered.";
    b.position = CGPointMake(a.position.x, a.position.y - 20);
    a.text = st1;
    b.text = st2;
    [nerdText1 addChild:a];
    [nerdText1 addChild:b];
    nerdText1.position = CGPointMake(0, 140);
    
    SKNode *nerdText2 = [SKNode node];
    SKLabelNode *c = [SKLabelNode labelNodeWithFontNamed:@"ArialMT"];
    c.fontSize = 16;
    c.fontColor = [SKColor whiteColor];
    SKLabelNode *d = [SKLabelNode labelNodeWithFontNamed:@"ArialMT"];
    d.fontSize = 16;
    d.fontColor = [SKColor whiteColor];
    st1 = @"Here is the compass showing";
    st2 = @"your current direction.";
    NSString *st3 = @"Tap it to see your results in Game Center!";
    d.position = CGPointMake(c.position.x, c.position.y - 20);
    c.text = st1;
    d.text = st2;
    SKLabelNode *e = [SKLabelNode labelNodeWithFontNamed:@"ArialMT"];
    e.fontSize = 16;
    e.fontColor = [SKColor whiteColor];
    e.text = st3;
    e.position = CGPointMake(d.position.x, d.position.y - 20);
    [nerdText2 addChild:c];
    [nerdText2 addChild:d];
    [nerdText2 addChild:e];
    nerdText2.position = CGPointMake(0, 30);
    
    SKNode *nerdText3 = [SKNode node];
    SKLabelNode *f = [SKLabelNode labelNodeWithFontNamed:@"ArialMT"];
    f.fontSize = 16;
    f.fontColor = [SKColor whiteColor];
    SKLabelNode *g = [SKLabelNode labelNodeWithFontNamed:@"ArialMT"];
    g.fontSize = 16;
    g.fontColor = [SKColor whiteColor];
    st1 = @"Here you can see your current speed";
    st2 = @"of scrolling.";
    g.position = CGPointMake(f.position.x, f.position.y - 20);
    f.text = st1;
    g.text = st2;
    [nerdText3 addChild:f];
    [nerdText3 addChild:g];
    nerdText3.position = CGPointMake(0, -120);
    
    [helpNode addChild:nerdText1];
    [helpNode addChild:nerdText2];
    [helpNode addChild:nerdText3];
    
    return helpNode;
}

-(SKSpriteNode *)createBasicHelp3
{
    SKSpriteNode *helpNode = [[SKSpriteNode alloc] initWithColor:[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.7] size:self.size];
    helpNode.position = CGPointMake(self.size.width / 2.0, self.size.height / 2.0);
    
    helpNode.name = @"basic3";
    
    SKNode *nerdText1 = [SKNode node];
    SKLabelNode *a = [SKLabelNode labelNodeWithFontNamed:@"ArialMT"];
    a.fontSize = 16;
    a.fontColor = [SKColor whiteColor];
    SKLabelNode *b = [SKLabelNode labelNodeWithFontNamed:@"ArialMT"];
    b.fontSize = 16;
    b.fontColor = [SKColor whiteColor];
    NSString *st1 = @"That' all you need to know for now.";
    NSString *st2 = @"Quite simple, huh?:)";
    b.position = CGPointMake(a.position.x, a.position.y - 20);
    a.text = st1;
    b.text = st2;
    [nerdText1 addChild:a];
    [nerdText1 addChild:b];
    nerdText1.position = CGPointMake(0, 80);
    
    SKNode *nerdText2 = [SKNode node];
    SKLabelNode *c = [SKLabelNode labelNodeWithFontNamed:@"ArialMT"];
    c.fontSize = 16;
    c.fontColor = [SKColor whiteColor];
    SKLabelNode *d = [SKLabelNode labelNodeWithFontNamed:@"ArialMT"];
    d.fontSize = 16;
    d.fontColor = [SKColor whiteColor];
    st1 = @"I know, I know... Why should you do this?";
    st2 = @"Well, if you advance in the game,";
    NSString *st3 = @"you will see that there's more in it.";
    d.position = CGPointMake(c.position.x, c.position.y - 20);
    c.text = st1;
    d.text = st2;
    SKLabelNode *e = [SKLabelNode labelNodeWithFontNamed:@"ArialMT"];
    e.fontSize = 16;
    e.fontColor = [SKColor whiteColor];
    e.text = st3;
    e.position = CGPointMake(d.position.x, d.position.y - 20);
    [nerdText2 addChild:c];
    [nerdText2 addChild:d];
    [nerdText2 addChild:e];
    nerdText2.position = CGPointMake(0, 30);
    
    SKNode *nerdText3 = [SKNode node];
    SKLabelNode *f = [SKLabelNode labelNodeWithFontNamed:@"ArialMT"];
    f.fontSize = 16;
    f.fontColor = [SKColor whiteColor];
    //SKLabelNode *g = [SKLabelNode labelNodeWithFontNamed:@"ArialMT"];
    //g.fontSize = 16;
    //g.fontColor = [SKColor whiteColor];
    st1 = @"But more on that later...";
    //st2 = @"Just tap on the screen if you feel ready!";
    //g.position = CGPointMake(f.position.x, f.position.y - 20);
    f.text = st1;
    //g.text = st2;
    [nerdText3 addChild:f];
    //[nerdText3 addChild:g];
    nerdText3.position = CGPointMake(0, -40);
    
    [helpNode addChild:nerdText1];
    [helpNode addChild:nerdText2];
    [helpNode addChild:nerdText3];
    
    return helpNode;
}

-(SKSpriteNode *)createBasicHelp4
{
    SKSpriteNode *helpNode = [[SKSpriteNode alloc] initWithColor:[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.7] size:self.size];
    helpNode.position = CGPointMake(self.size.width / 2.0, self.size.height / 2.0);
    
    helpNode.name = @"basic4";
    
    SKNode *nerdText2 = [SKNode node];
    SKLabelNode *c = [SKLabelNode labelNodeWithFontNamed:@"ArialMT"];
    c.fontSize = 16;
    c.fontColor = [SKColor whiteColor];
    SKLabelNode *d = [SKLabelNode labelNodeWithFontNamed:@"ArialMT"];
    d.fontSize = 16;
    d.fontColor = [SKColor whiteColor];
    NSString *st1 = @"Hint: try scrolling";
    NSString *st2 = @"in different directions.";
    NSString *st3 = @"Tap on the screen if you're ready:)";
    d.position = CGPointMake(c.position.x, c.position.y - 20);
    c.text = st1;
    d.text = st2;
    SKLabelNode *e = [SKLabelNode labelNodeWithFontNamed:@"ArialMT"];
    e.fontSize = 16;
    e.fontColor = [SKColor whiteColor];
    e.text = st3;
    e.position = CGPointMake(d.position.x, d.position.y - 20);
    [nerdText2 addChild:c];
    [nerdText2 addChild:d];
    [nerdText2 addChild:e];
    nerdText2.position = CGPointMake(0, 30);
    
    [helpNode addChild:nerdText2];
    
    return helpNode;
}

-(SKSpriteNode *)createRouteHelp
{
    SKSpriteNode *helpNode = [[SKSpriteNode alloc] initWithColor:[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.7] size:self.size];
    helpNode.position = CGPointMake(self.size.width / 2.0, self.size.height / 2.0);
    
    helpNode.name = @"route1";
    
    SKNode *nerdText1 = [SKNode node];
    SKLabelNode *a = [SKLabelNode labelNodeWithFontNamed:@"ArialMT"];
    a.fontSize = 16;
    a.fontColor = [SKColor whiteColor];
    SKLabelNode *b = [SKLabelNode labelNodeWithFontNamed:@"ArialMT"];
    b.fontSize = 16;
    b.fontColor = [SKColor whiteColor];
    NSString *st1 = @"You have found a route!";
    NSString *st2 = @"Complete it by following the compass.";
    b.position = CGPointMake(a.position.x, a.position.y - 20);
    a.text = st1;
    b.text = st2;
    [nerdText1 addChild:a];
    [nerdText1 addChild:b];
    nerdText1.position = CGPointMake(0, 80);
    
    SKNode *nerdText2 = [SKNode node];
    SKLabelNode *c = [SKLabelNode labelNodeWithFontNamed:@"ArialMT"];
    c.fontSize = 16;
    c.fontColor = [SKColor whiteColor];
    SKLabelNode *d = [SKLabelNode labelNodeWithFontNamed:@"ArialMT"];
    d.fontSize = 16;
    d.fontColor = [SKColor whiteColor];
    st1 = @"When you find a route, the compass";
    st2 = @"shows you which direction to go";
    NSString *st3 = @"to reach the next checkpoint.";
    d.position = CGPointMake(c.position.x, c.position.y - 20);
    c.text = st1;
    d.text = st2;
    SKLabelNode *e = [SKLabelNode labelNodeWithFontNamed:@"ArialMT"];
    e.fontSize = 16;
    e.fontColor = [SKColor whiteColor];
    e.text = st3;
    e.position = CGPointMake(d.position.x, d.position.y - 20);
    [nerdText2 addChild:c];
    [nerdText2 addChild:d];
    [nerdText2 addChild:e];
    nerdText2.position = CGPointMake(0, 30);
    
    SKNode *nerdText3 = [SKNode node];
    SKLabelNode *f = [SKLabelNode labelNodeWithFontNamed:@"ArialMT"];
    f.fontSize = 16;
    f.fontColor = [SKColor whiteColor];
    SKLabelNode *g = [SKLabelNode labelNodeWithFontNamed:@"ArialMT"];
    g.fontSize = 16;
    g.fontColor = [SKColor whiteColor];
    st1 = @"If you complete the route,";
    st2 = @"you get a badge and bonus distance.";
    g.position = CGPointMake(f.position.x, f.position.y - 20);
    f.text = st1;
    g.text = st2;
    [nerdText3 addChild:f];
    [nerdText3 addChild:g];
    nerdText3.position = CGPointMake(0, -40);
    
    [helpNode addChild:nerdText1];
    [helpNode addChild:nerdText2];
    [helpNode addChild:nerdText3];
    
    return helpNode;
}

-(SKSpriteNode *)createRouteFinishedHelp
{
    SKSpriteNode *helpNode = [[SKSpriteNode alloc] initWithColor:[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.7] size:self.size];
    helpNode.position = CGPointMake(self.size.width / 2.0, self.size.height / 2.0);
    
    helpNode.name = @"route2";
    
    SKNode *nerdText1 = [SKNode node];
    SKLabelNode *a = [SKLabelNode labelNodeWithFontNamed:@"ArialMT"];
    a.fontSize = 16;
    a.fontColor = [SKColor whiteColor];
    SKLabelNode *b = [SKLabelNode labelNodeWithFontNamed:@"ArialMT"];
    b.fontSize = 16;
    b.fontColor = [SKColor whiteColor];
    NSString *st1 = @"Congratulations!";
    NSString *st2 = @"You just finished your first route!";
    b.position = CGPointMake(a.position.x, a.position.y - 20);
    a.text = st1;
    b.text = st2;
    [nerdText1 addChild:a];
    [nerdText1 addChild:b];
    nerdText1.position = CGPointMake(0, 80);
    
    SKNode *nerdText2 = [SKNode node];
    SKLabelNode *c = [SKLabelNode labelNodeWithFontNamed:@"ArialMT"];
    c.fontSize = 16;
    c.fontColor = [SKColor whiteColor];
    SKLabelNode *d = [SKLabelNode labelNodeWithFontNamed:@"ArialMT"];
    d.fontSize = 16;
    d.fontColor = [SKColor whiteColor];
    st1 = @"You can find plenty of routes";
    st2 = @"during the game. Just start scrolling in";
    NSString *st3 = @"a direction and watch the compass!";
    d.position = CGPointMake(c.position.x, c.position.y - 20);
    c.text = st1;
    d.text = st2;
    SKLabelNode *e = [SKLabelNode labelNodeWithFontNamed:@"ArialMT"];
    e.fontSize = 16;
    e.fontColor = [SKColor whiteColor];
    e.text = st3;
    e.position = CGPointMake(d.position.x, d.position.y - 20);
    [nerdText2 addChild:c];
    [nerdText2 addChild:d];
    [nerdText2 addChild:e];
    nerdText2.position = CGPointMake(0, 30);
    
    SKNode *nerdText3 = [SKNode node];
    SKLabelNode *f = [SKLabelNode labelNodeWithFontNamed:@"ArialMT"];
    f.fontSize = 16;
    f.fontColor = [SKColor whiteColor];
    SKLabelNode *g = [SKLabelNode labelNodeWithFontNamed:@"ArialMT"];
    g.fontSize = 16;
    g.fontColor = [SKColor whiteColor];
    st1 = @"When the compass is fixed in a direction,";
    st2 = @"just follow it as you did now!";
    g.position = CGPointMake(f.position.x, f.position.y - 20);
    f.text = st1;
    g.text = st2;
    [nerdText3 addChild:f];
    [nerdText3 addChild:g];
    nerdText3.position = CGPointMake(0, -40);
    
    [helpNode addChild:nerdText1];
    [helpNode addChild:nerdText2];
    [helpNode addChild:nerdText3];
    
    return helpNode;
}

-(SKSpriteNode *)createComboHelpWithComboName:(NSString *)comboName
{
    SKSpriteNode *helpNode = [[SKSpriteNode alloc] initWithColor:[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.7] size:self.size];
    helpNode.position = CGPointMake(self.size.width / 2.0, self.size.height / 2.0);
    
    helpNode.name = @"combo";
    
    SKNode *captionBox = [SKNode node];
    SKLabelNode *caption = [SKLabelNode labelNodeWithFontNamed:@"ArialMT"];
    caption.fontSize = 28;
    caption.fontColor = [SKColor whiteColor];
    NSString *cpt = comboName;
    caption.text = cpt;
    [captionBox addChild:caption];
    captionBox.position = CGPointMake(0, 130);
    
    SKNode *nerdText1 = [SKNode node];
    SKLabelNode *a = [SKLabelNode labelNodeWithFontNamed:@"ArialMT"];
    a.fontSize = 16;
    a.fontColor = [SKColor whiteColor];
    SKLabelNode *b = [SKLabelNode labelNodeWithFontNamed:@"ArialMT"];
    b.fontSize = 16;
    b.fontColor = [SKColor whiteColor];
    NSString *st1 = @"Congratulations!";
    NSString *st2 = @"You just found a combo!";
    b.position = CGPointMake(a.position.x, a.position.y - 20);
    a.text = st1;
    b.text = st2;
    [nerdText1 addChild:a];
    [nerdText1 addChild:b];
    nerdText1.position = CGPointMake(0, 80);
    
    SKNode *nerdText2 = [SKNode node];
    SKLabelNode *c = [SKLabelNode labelNodeWithFontNamed:@"ArialMT"];
    c.fontSize = 16;
    c.fontColor = [SKColor whiteColor];
    SKLabelNode *d = [SKLabelNode labelNodeWithFontNamed:@"ArialMT"];
    d.fontSize = 16;
    d.fontColor = [SKColor whiteColor];
    st1 = @"A combo is a special sequence of actions";
    st2 = @"All combos have their own pattern.";
    NSString *st3 = @"If you find a combo, you get a badge.";
    d.position = CGPointMake(c.position.x, c.position.y - 20);
    c.text = st1;
    d.text = st2;
    SKLabelNode *e = [SKLabelNode labelNodeWithFontNamed:@"ArialMT"];
    e.fontSize = 16;
    e.fontColor = [SKColor whiteColor];
    e.text = st3;
    e.position = CGPointMake(d.position.x, d.position.y - 20);
    [nerdText2 addChild:c];
    [nerdText2 addChild:d];
    [nerdText2 addChild:e];
    nerdText2.position = CGPointMake(0, 30);
    
    SKNode *nerdText3 = [SKNode node];
    SKLabelNode *f = [SKLabelNode labelNodeWithFontNamed:@"ArialMT"];
    f.fontSize = 16;
    f.fontColor = [SKColor whiteColor];
    SKLabelNode *g = [SKLabelNode labelNodeWithFontNamed:@"ArialMT"];
    g.fontSize = 16;
    g.fontColor = [SKColor whiteColor];
    st1 = @"You can only achieve each combo";
    st2 = @"once in the game. Collect them all!:)";
    g.position = CGPointMake(f.position.x, f.position.y - 20);
    f.text = st1;
    g.text = st2;
    [nerdText3 addChild:f];
    [nerdText3 addChild:g];
    nerdText3.position = CGPointMake(0, -40);
    
    [helpNode addChild:captionBox];
    [helpNode addChild:nerdText1];
    [helpNode addChild:nerdText2];
    [helpNode addChild:nerdText3];
    
    return helpNode;
}

@end
