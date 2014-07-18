//
//  GCManager.h
//  scrollalot
//
//  Created by Ivan Borsa on 18/07/14.
//  Copyright (c) 2014 ivanborsa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
#import "GCManagerDelegate.h"

@interface GCManager : NSObject

@property (nonatomic, weak) id<GCManagerDelegate> delegate;

-(void)authenticateLocalPlayerForced:(BOOL)forced;
-(void)reportDistance:(double)distance;
-(void)reportSpeed:(float)speed;

@end
