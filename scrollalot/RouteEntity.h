//
//  RouteEntity.h
//  scrollalot
//
//  Created by Ivan Borsa on 22/07/14.
//  Copyright (c) 2014 ivanborsa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface RouteEntity : NSManagedObject

@property (nonatomic, retain) NSString * routeName;
@property (nonatomic, retain) NSString * routePattern;
@property (nonatomic, retain) NSString * achievementId;
@property (nonatomic, retain) NSNumber * routeDistance;
@property (nonatomic, retain) NSNumber * achieved;
@property (nonatomic, retain) NSString * badgeName;

@end
