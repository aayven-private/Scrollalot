//
//  NetworkManager.m
//  RunnerGame
//
//  Created by Ivan Borsa on 07/07/14.
//  Copyright (c) 2014 Weloux. All rights reserved.
//

#import "NetworkManager.h"

@interface NetworkManager()

@property (nonatomic) NSOperationQueue *operationQueue;

@end

@implementation NetworkManager

+(id)createNetworkManager
{
    NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:0 diskCapacity:0 diskPath:nil];
    [NSURLCache setSharedURLCache:sharedCache];
    return [[NetworkManager alloc] init];
}

-(id)init
{
    if (self = [super init]) {
        self.operationQueue = [[NSOperationQueue alloc] init];
        self.operationQueue.name = @"PDOperationQueue";
    }
    return self;
}

-(void)performHttpRequest:(RequestHelper *)requestInfo succesBlock:(void (^)(ResponseHelper *result))successBlock andFailBlock:(void (^)(ResponseHelper *result))failBlock
{
    __block ResponseHelper *result = [[ResponseHelper alloc] init];
    if (!requestInfo.requestUri || [requestInfo.requestUri isEqualToString:@""]) {
        result.responseCode = -1;
        result.isSuccessful = NO;
        result.userInfo = [NSDictionary dictionaryWithObject:kRequestFail_emptyUri forKey:kRequestFailReasonKey];
        failBlock(result);
    }
    //NSLog(urlString);
    //prepare request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setTimeoutInterval:20];
    [request setURL:[NSURL URLWithString:requestInfo.requestUri]];
    [request setHTTPMethod:requestInfo.requestMethod];
    if (requestInfo.contentType && ![requestInfo.contentType isEqualToString:@""]) {
        [request setValue:requestInfo.contentType forHTTPHeaderField:@"Content-Type"];
    }
    [request setHTTPShouldHandleCookies:NO];
    [request setHTTPShouldUsePipelining:NO];
    
    if (requestInfo.customHeaders) {
        for (NSString *headerName in [requestInfo.customHeaders allKeys]) {
            [request addValue:[requestInfo.customHeaders objectForKey:headerName] forHTTPHeaderField:headerName];
        }
    }
    
    //create the body
    NSData *bodyData = [requestInfo.requestBody dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:bodyData];
    
    //post
    [NSURLConnection sendAsynchronousRequest:request queue:_operationQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (!connectionError) {
            NSDictionary *resultDict = [NSDictionary dictionaryWithObjectsAndKeys:data, @"data", [NSNumber numberWithInteger:[(NSHTTPURLResponse *)response statusCode]], @"code", nil];
            result.responseDict = resultDict;
            NSString *messageString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            //NSLog(@"Message: %@", messageString);
            NSString *errorMessage = [resultDict objectForKey:@"error"];
            if (errorMessage && ![errorMessage isEqualToString:@""]) {
                result.isSuccessful = NO;
                result.responseCode = [(NSHTTPURLResponse *)response statusCode];
                result.userInfo = [NSDictionary dictionaryWithObject:errorMessage forKey:@"errorMessage"];
                failBlock(result);
            } else {
                result.isSuccessful = YES;
                result.responseCode = [(NSHTTPURLResponse *)response statusCode];
                successBlock(result);
            }
        } else {
            result.isSuccessful = NO;
            result.responseCode = [(NSHTTPURLResponse *)response statusCode];
            result.error = connectionError;
            failBlock(result);
            //[_delegate downloadFailedWithError:error];
        }
    }];
}

@end
