//
//  AchievementsViewController.h
//  scrollalot
//
//  Created by Ivan Borsa on 28/07/14.
//  Copyright (c) 2014 ivanborsa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>
#import "GCManager.h"

@interface AchievementsViewController : UIViewController<UICollectionViewDataSource, UICollectionViewDelegate, GKGameCenterControllerDelegate>

@property (nonatomic) NSMutableDictionary *achievementsDict;

@end
