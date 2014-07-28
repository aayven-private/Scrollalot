//
//  ComboManager.h
//  RunnerGame
//
//  Created by Ivan Borsa on 16/04/14.
//  Copyright (c) 2014 Weloux. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
#import "ComboManagerDelegate.h"
#import "ComboEntityHelper.h"

@interface ComboManager : NSObject

@property (nonatomic, weak) id<ComboManagerDelegate> delegate;

+(id)sharedManager;
-(void)actionTaken:(NSString *)action;
-(NSArray *)getAchievedCombos_dictionary;

@end
