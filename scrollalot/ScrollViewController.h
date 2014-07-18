//
//  ViewController.h
//  scrollalot
//

//  Copyright (c) 2014 ivanborsa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
#import <AudioToolbox/AudioServices.h>
#import <GameKit/GameKit.h>
#import "ScrollSceneHandlerDelegate.h"
#import "GCManager.h"

@interface ScrollViewController : UIViewController <ScrollSceneHandlerDelegate, GCManagerDelegate>

@end
