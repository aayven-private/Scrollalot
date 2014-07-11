//
//  NetworkManager.h
//  RunnerGame
//
//  Created by Ivan Borsa on 07/07/14.
//  Copyright (c) 2014 Weloux. All rights reserved.
//

static NSString *kRequestFailReasonKey = @"request_fail_reason";
static NSString *kRequestFail_emptyUri = @"request_fail_empty_uri";

#import <Foundation/Foundation.h>
#import "RequestHelper.h"
#import "ResponseHelper.h"

@interface NetworkManager : NSObject

+ (id)createNetworkManager;
-(void)performHttpRequest:(RequestHelper *)requestInfo succesBlock:(void (^)(ResponseHelper *result))successBlock andFailBlock:(void (^)(ResponseHelper *result))failBlock;

@end
