//
//  ResponseHelper.h
//  RunnerGame
//
//  Created by Ivan Borsa on 07/07/14.
//  Copyright (c) 2014 Weloux. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ResponseHelper : NSObject

@property (nonatomic) NSDictionary *responseDict;
@property (nonatomic) NSInteger responseCode;
@property (nonatomic) BOOL isSuccessful;
@property (nonatomic) NSDictionary *userInfo;
@property (nonatomic) NSError *error;

@end
