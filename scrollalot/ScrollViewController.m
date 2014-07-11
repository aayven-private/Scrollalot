//
//  ViewController.m
//  scrollalot
//
//  Created by Ivan Borsa on 10/07/14.
//  Copyright (c) 2014 ivanborsa. All rights reserved.
//

#import "ScrollViewController.h"
#import "ScrollScene.h"

@interface ScrollViewController()

@property (nonatomic) ScrollScene *scrollScene;

@end

@implementation ScrollViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIPanGestureRecognizer* panSwipeRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanSwipe:)];
    // Here you can customize for example the minimum and maximum number of fingers required
    panSwipeRecognizer.minimumNumberOfTouches = 1;
    [self.view addGestureRecognizer:panSwipeRecognizer];
    
    // Configure the view.
    SKView * skView = (SKView *)self.view;
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
    
    // Create and configure the scene.
    SKScene * scene = [ScrollScene sceneWithSize:skView.bounds.size];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    // Present the scene.
    [skView presentScene:scene];
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
        //skView.showsPhysics = NO;
        
        // Create and configure the scene.
        _scrollScene = [ScrollScene sceneWithSize:skView.bounds.size];
        _scrollScene.scaleMode = SKSceneScaleModeAspectFill;
        
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
    CGPoint t = [recognizer translationInView:recognizer.view];
    [recognizer setTranslation:CGPointZero inView:recognizer.view];
    
    // TODO: Here, you should translate your target view using this translation
    //someView.center = CGPointMake(someView.center.x + t.x, someView.center.y + t.y);
    
    // But also, detect the swipe gesture
    if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        CGPoint vel = [recognizer velocityInView:recognizer.view];
        NSLog(@"VelY: %f", vel.y);
        /*if (vel.x < SWIPE_LEFT_THRESHOLD)
        {
            // TODO: Detected a swipe to the left
            //NSLog(@"VelX: %f", vel.x);
        }
        else if (vel.x > SWIPE_RIGHT_THRESHOLD)
        {
            // TODO: Detected a swipe to the right
            //NSLog(@"VelX: %f", vel.x);
        }
        else if (vel.y < SWIPE_UP_THRESHOLD)
        {
            // TODO: Detected a swipe up
            NSLog(@"VelY: %f", vel.y);
        }
        else if (vel.y > SWIPE_DOWN_THRESHOLD)
        {
            // TODO: Detected a swipe down
            NSLog(@"VelY: %f", vel.y);
        }
        else
        {
            // TODO:
            // Here, the user lifted the finger/fingers but didn't swipe.
            // If you need you can implement a snapping behaviour, where based on the location of your         targetView,
            // you focus back on the targetView or on some next view.
            // It's your call
        }*/
    }
}

@end
