//
//  ViewController.m
//  scrollalot
//
//  Created by Ivan Borsa on 10/07/14.
//  Copyright (c) 2014 ivanborsa. All rights reserved.
//

#import "ScrollViewController.h"
#import "ScrollScene.h"
#import "Constants.h"
#import "GCManager.h"
#import "AchievementsViewController.h"
#import "RouteManager.h"
#import "ComboManager.h"

@interface ScrollViewController()

@property (nonatomic) ScrollScene *scrollScene;
@property (nonatomic) GCManager *gcManager;

@end

@implementation ScrollViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIPanGestureRecognizer* panSwipeRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanSwipe:)];
    //panSwipeRecognizer.cancelsTouchesInView = NO;
    // Here you can customize for example the minimum and maximum number of fingers required
    panSwipeRecognizer.minimumNumberOfTouches = 1;
    [self.view addGestureRecognizer:panSwipeRecognizer];
    
    UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    [self.view addGestureRecognizer:pinchRecognizer];
    
    self.gcManager = [[GCManager alloc] init];
    self.gcManager.delegate = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self.gcManager authenticateLocalPlayerShowLoginView:NO];
    });
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    // Configure the view.
    SKView * skView = (SKView *)self.view;
    if (!skView.scene) {
        skView.showsFPS = NO;
        skView.showsNodeCount = NO;
        //skView.showsPhysics = YES;
        
        // Create and configure the scene.
        _scrollScene = [ScrollScene sceneWithSize:skView.bounds.size];
        _scrollScene.scaleMode = SKSceneScaleModeAspectFill;
        [_scrollScene initEnvironment];
        _scrollScene.delegate = self;
        
        // Present the scene.
        [skView presentScene:_scrollScene];
    }
}

#define SWIPE_UP_THRESHOLD -100.0f
#define SWIPE_DOWN_THRESHOLD 100.0f
#define SWIPE_LEFT_THRESHOLD -100.0f
#define SWIPE_RIGHT_THRESHOLD 100.0f

- (void)handlePanSwipe:(UIPanGestureRecognizer*)recognizer
{
    // Get the translation in the view
    CGPoint l = [recognizer locationInView:self.view];
    CGPoint t = [recognizer translationInView:recognizer.view];
    [recognizer setTranslation:CGPointZero inView:recognizer.view];
    //NSLog(NSStringFromCGPoint(rwNormalize(t)));
    if (recognizer.state != UIGestureRecognizerStateBegan) {
        [_scrollScene swipeInProgressAtPoint:l withTranslation:t];
    }
    
    //[recognizer setTranslation:CGPointZero inView:recognizer.view];
    
    // TODO: Here, you should translate your target view using this translation
    //someView.center = CGPointMake(someView.center.x + t.x, someView.center.y + t.y);
    
    // But also, detect the swipe gesture
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        //NSLog(@"BEGAN");
    }
    if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        CGPoint vel = [recognizer velocityInView:recognizer.view];
        //NSLog(@"VelY: %f", vel.y);
        [_scrollScene swipeWithVelocity:vel];
    }
}

-(void)handlePinch:(UIPinchGestureRecognizer *)recognizer
{
    CGFloat zoomSpeed;
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        
        if (recognizer.scale < 1) {
            //Zoom in
            zoomSpeed = (1.0 / recognizer.scale) * recognizer.velocity;
        } else {
            //Zoom out
            zoomSpeed = recognizer.scale * recognizer.velocity;
        }
        
        NSLog(@"Pinch scale: %f", recognizer.scale);
        NSLog(@"Pinch velocity: %f", recognizer.velocity);
        //NSLog(@"Pinch velocity / scale: %f", recognizer.velocity / recognizer.scale);
    }
}

-(void)reportMaxSpeed:(float)speed
{
    [_gcManager reportSpeed:speed];
}

-(void)reportDistance:(double)distance
{
    [_gcManager reportDistance:distance];
}

- (void)presentLeaderBoards {
    self.gcManager = [[GCManager alloc] init];
    self.gcManager.delegate = self;
    
    AchievementsViewController *vc = [[AchievementsViewController alloc] initWithNibName:@"AchievementsViewController" bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController
{
    [gameCenterViewController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

-(void)playerDistanceDownloaded:(double)distance
{
    [_scrollScene distanceDownloadedFromGC:distance];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithDouble:distance] forKey:kGlobalDistanceKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)playerSpeedDownloaded:(float)speed
{
    _scrollScene.maxSpeed = speed;
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:speed] forKey:kMaxSpeedKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


@end
