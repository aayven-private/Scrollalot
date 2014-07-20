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
    self.gcManager = [[GCManager alloc] init];
    self.gcManager.delegate = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self.gcManager authenticateLocalPlayerForced:YES];
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
    [_scrollScene initEnvironment];
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

-(void)authenticationFinishedWithResult:(GCAuthResult *)result
{
    if (result.authViewController) {
        //Present the authentication view to the user
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:result.authViewController animated:YES completion:^{
                
            }];
        });
    } else {
        if (result.wasSuccessul) {
            
            GKLocalPlayer *lp = [GKLocalPlayer localPlayer];
            NSLog(@"AUTH_SUCCESS for player: %@", lp.displayName);
            [_gcManager downloadLoadLeaderboardInfo];
        } else {
            NSLog(@"AUTH_FAIL");
        }
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

-(void)leaderBoardsDownloaded:(NSArray *)leaderBoards
{
    
    
}

- (void)presentLeaderBoards {
    GCManager *gcm = [[GCManager alloc] init];
    if (!gcm.isEnabled) {
        [gcm authenticateLocalPlayerForced:YES];
    } else {
        
    }
    GKGameCenterViewController* gameCenterController = [[GKGameCenterViewController alloc] init];
    gameCenterController.viewState = GKGameCenterViewControllerStateLeaderboards;
    gameCenterController.gameCenterDelegate = self;
    [self presentViewController:gameCenterController animated:YES completion:nil];
}

- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController
{
    [gameCenterViewController dismissViewControllerAnimated:YES completion:^{
        
    }];
}


@end
