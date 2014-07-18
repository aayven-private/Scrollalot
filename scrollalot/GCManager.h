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

@property (nonatomic) BOOL isEnabled;
@property (nonatomic) NSArray *leaderBoards;

-(void)authenticateLocalPlayer;
-(void)reportDistance:(double)distance;
-(void)reportSpeed:(float)speed;
-(void)downloadLoadLeaderboardInfo;

@end
