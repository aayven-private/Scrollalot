//
//  ComboEntityHelper.h
//  scrollalot
//
//  Created by Ivan Borsa on 21/07/14.
//  Copyright (c) 2014 ivanborsa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ComboEntity.h"

@interface ComboEntityHelper : NSObject

@property (nonatomic) NSString * comboName;
@property (nonatomic) NSString * comboPattern;
@property (nonatomic) NSString * achievementId;
@property (nonatomic) NSNumber * achieved;

-(id)initWithEntity:(ComboEntity *)entity;

@end
