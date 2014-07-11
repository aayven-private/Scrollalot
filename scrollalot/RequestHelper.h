//
//  RequestHelper.h
//  RunnerGame
//
//  Created by Ivan Borsa on 07/07/14.
//  Copyright (c) 2014 Weloux. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RequestHelper : NSObject

@property (nonatomic) NSString *requestUri;
@property (nonatomic) NSString *requestMethod;
@property (nonatomic) NSString *requestBody;
@property (nonatomic) NSString *contentType;
@property (nonatomic) NSData *requestData;
@property (nonatomic) NSString *requestType;
@property (nonatomic) NSDictionary *customHeaders;

@end
