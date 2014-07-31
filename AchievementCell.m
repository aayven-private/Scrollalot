//
//  AchievementCell.m
//  scrollalot
//
//  Created by Ivan Borsa on 28/07/14.
//  Copyright (c) 2014 ivanborsa. All rights reserved.
//

#import "AchievementCell.h"

@interface AchievementCell ()

@end

@implementation AchievementCell

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 82, 80, 38)];
        self.nameLabel.textAlignment = NSTextAlignmentCenter;
        self.nameLabel.font = [UIFont fontWithName:@"Pacifico-Regular" size:17.0];
        self.nameLabel.textColor = [UIColor whiteColor];
        self.nameLabel.adjustsFontSizeToFitWidth = YES;
        self.nameLabel.minimumScaleFactor = 0.7;
        [self addSubview:self.nameLabel];
        
        self.layer.borderWidth=1.0f;
        self.layer.borderColor=[UIColor darkGrayColor].CGColor;
        self.layer.cornerRadius = 8.0;
        
        [self.layer setMasksToBounds:NO];
        [self.layer setRasterizationScale:[[UIScreen mainScreen] scale]];
        [self.layer setShouldRasterize:YES];
        [self.layer setShadowColor:[[UIColor whiteColor] CGColor]];
        //[layer setShadowOffset:CGSizeMake(1.0f,1.5f)];
        [self.layer setShadowRadius:5.0f];
        [self.layer setShadowOpacity:0.2f];
        [self.layer setShadowPath:[[UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:self.layer.cornerRadius] CGPath]];
    }
    return self;
}

@end
