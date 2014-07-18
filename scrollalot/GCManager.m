//
//  GCManager.m
//  scrollalot
//
//  Created by Ivan Borsa on 18/07/14.
//  Copyright (c) 2014 ivanborsa. All rights reserved.
//

#import "GCManager.h"

static NSString *kDistanceLeaderboardId = @"scrollalot_distance_leaderboard";
static NSString *kSpeedLeaderboardId = @"scrollalot_speed_leaderboard";
static NSString *kGCEnabledKey = @"scrollalot_gc_enabled";

@interface GCManager()

@property (nonatomic) BOOL isEnabled;

@end

@implementation GCManager

-(id)init
{
    if (self = [super init]) {
        NSNumber *isEnabled = [[NSUserDefaults standardUserDefaults] objectForKey:kGCEnabledKey];
        if (!isEnabled) {
            isEnabled = [NSNumber numberWithBool:YES];
            [[NSUserDefaults standardUserDefaults] setObject:isEnabled forKey:kGCEnabledKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        self.isEnabled = [isEnabled boolValue];
    }
    return self;
}

-(void)authenticateLocalPlayerForced:(BOOL)forced
{
    if (_isEnabled || forced) {
        GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
        __weak GKLocalPlayer *blockLocalPlayer = localPlayer;
        localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error){
            GCAuthResult *result = [[GCAuthResult alloc] init];
            if (viewController != nil) {
                result.authViewController = viewController;
            }
            else {
                result.authViewController = nil;
                result.wasSuccessul = blockLocalPlayer.isAuthenticated;
            }
            if (!blockLocalPlayer.isAuthenticated) {
                [self disableGameCenter];
            }
            [_delegate authenticationFinishedWithResult:result];
        };
    }
    if (forced) {
        [self enableGameCenter];
    }
}

-(void)reportDistance:(double)distance
{
    int64_t score_scaled = (int64_t) (distance * 1000.0);
    [self reportScore:score_scaled forLeaderboardID:kDistanceLeaderboardId];
}

-(void)reportSpeed:(float)speed
{
    int64_t score_scaled = (int64_t) (speed * 10.0);
    [self reportScore:score_scaled forLeaderboardID:kSpeedLeaderboardId];
}

- (void)reportScore:(int64_t)score forLeaderboardID:(NSString*)identifier
{
    if (_isEnabled) {
        GKScore *scoreReporter = [[GKScore alloc] initWithLeaderboardIdentifier:identifier];
        scoreReporter.value = score;
        scoreReporter.context = 0;
        NSArray *scores = @[scoreReporter];
        [GKScore reportScores:scores withCompletionHandler:^(NSError *error) {
            if (!error) {
                NSLog(@"Score report successful");
            }
        }];
    }
}

-(void)disableGameCenter
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:kGCEnabledKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)enableGameCenter
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:kGCEnabledKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
