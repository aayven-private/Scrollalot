//
//  AchievementsViewController.h
//  scrollalot
//
//  Created by Ivan Borsa on 28/07/14.
//  Copyright (c) 2014 ivanborsa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AchievementsViewController : UIViewController<UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic) NSMutableDictionary *achievementsDict;

@end
