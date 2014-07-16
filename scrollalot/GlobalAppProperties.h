//
//  GlobalAppProperties.h
//  scrollalot
//
//  Created by Ivan Borsa on 11/07/14.
//  Copyright (c) 2014 ivanborsa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GlobalAppProperties : NSObject

+(id)sharedInstance;

@property (nonatomic) NSNumber *globalDistance;
@property (nonatomic) NSNumber *maxSpeed;

@end
