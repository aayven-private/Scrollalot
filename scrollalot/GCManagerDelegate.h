//
//  GCManagerDelegate.h
//  scrollalot
//
//  Created by Ivan Borsa on 18/07/14.
//  Copyright (c) 2014 ivanborsa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCAuthResult.h"

@protocol GCManagerDelegate <NSObject>

-(void)authenticationFinishedWithResult:(GCAuthResult *)result;
-(void)leaderBoardsDownloaded:(NSArray *)leaderBoards;

@end
