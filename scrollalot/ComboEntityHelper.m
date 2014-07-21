//
//  ComboEntityHelper.m
//  scrollalot
//
//  Created by Ivan Borsa on 21/07/14.
//  Copyright (c) 2014 ivanborsa. All rights reserved.
//

#import "ComboEntityHelper.h"

@implementation ComboEntityHelper

-(id)initWithEntity:(ComboEntity *)entity
{
    if (self = [super init]) {
        self.comboPattern = entity.comboPattern;
        self.comboName = entity.comboName;
        self.achieved = entity.achieved;
        self.achievementId = entity.achievementId;
    }
    return self;
}

@end
