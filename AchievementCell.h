//
//  AchievementCell.h
//  scrollalot
//
//  Created by Ivan Borsa on 28/07/14.
//  Copyright (c) 2014 ivanborsa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AchievementCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UIImageView *badgeView;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;

@end
