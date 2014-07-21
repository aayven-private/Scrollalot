//
//  ComboEntity.h
//  scrollalot
//
//  Created by Ivan Borsa on 21/07/14.
//  Copyright (c) 2014 ivanborsa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ComboEntity : NSManagedObject

@property (nonatomic, retain) NSString * comboName;
@property (nonatomic, retain) NSString * comboPattern;
@property (nonatomic, retain) NSString * achievementId;
@property (nonatomic, retain) NSNumber * achieved;

@end
