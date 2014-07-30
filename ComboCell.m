//
//  ComboCell.m
//  scrollalot
//
//  Created by Ivan Borsa on 29/07/14.
//  Copyright (c) 2014 ivanborsa. All rights reserved.
//

#import "ComboCell.h"

@implementation ComboCell

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        self.layer.borderWidth=1.0f;
        self.layer.borderColor=[UIColor darkGrayColor].CGColor;
        self.layer.cornerRadius = 8.0;
        
        [self.layer setMasksToBounds:NO];
        [self.layer setRasterizationScale:[[UIScreen mainScreen] scale]];
        [self.layer setShouldRasterize:YES];
        [self.layer setShadowColor:[[UIColor whiteColor] CGColor]];
        //[layer setShadowOffset:CGSizeMake(1.0f,1.5f)];
        [self.layer setShadowRadius:8.0f];
        [self.layer setShadowOpacity:0.2f];
        [self.layer setShadowPath:[[UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:self.layer.cornerRadius] CGPath]];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
