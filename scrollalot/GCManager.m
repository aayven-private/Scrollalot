//
//  GCManager.m
//  scrollalot
//
//  Created by Ivan Borsa on 18/07/14.
//  Copyright (c) 2014 ivanborsa. All rights reserved.
//

#import "GCManager.h"
#import "Constants.h"
#import "RouteManager.h"
#import "ComboManager.h"
#import "GlobalAppProperties.h"

static NSString *kDistanceLeaderboardId = @"scrollalot_distance_leaderboard";
static NSString *kSpeedLeaderboardId = @"scrollalot_speed_leaderboard";
static NSString *kGCEnabledKey = @"scrollalot_gc_enabled";

@interface GCManager()

@end

@implementation GCManager

@synthesize leaderBoards = _leaderBoards;

-(id)init
{
    if (self = [super init]) {
        NSNumber *isEnabled = [[NSUserDefaults standardUserDefaults] objectForKey:kGCEnabledKey];
        if (!isEnabled) {
            isEnabled = [NSNumber numberWithBool:YES];
            [[NSUserDefaults standardUserDefaults] setObject:isEnabled forKey:kGCEnabledKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        if (isEnabled) {
            self.isEnabled = [isEnabled boolValue];
        } else {
            self.isEnabled = NO;
        }
    }
    return self;
}

-(void)authenticateLocalPlayerShowLoginView:(BOOL)forced
{
    //if (_isEnabled || forced) {
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
                if (!blockLocalPlayer.isAuthenticated) {
                    [self disableGameCenter];
                } else {
                    [self enableGameCenter];
                    if ([_delegate respondsToSelector:@selector(playerDistanceDownloaded:)] && [_delegate respondsToSelector:@selector(playerSpeedDownloaded:)]) {
                        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                        NSNumber *distance = [defaults objectForKey:kGlobalDistanceKey];
                        if (!distance) {
                            distance = [NSNumber numberWithDouble:0];
                        }
                        NSNumber *speed = [defaults objectForKey:kMaxSpeedKey];
                        if (!speed) {
                            speed = [NSNumber numberWithFloat:0];
                        }
                        GKLeaderboard *leaderboardRequest = [[GKLeaderboard alloc] init];
                        if (leaderboardRequest != nil) {
                            
                            [GKLeaderboard loadLeaderboardsWithCompletionHandler:^(NSArray *leaderboards, NSError *error) {
                                for (GKLeaderboard *leaderBoard in leaderboards) {
                                    [leaderBoard loadScoresWithCompletionHandler:^(NSArray *scores, NSError *error) {
                                        if (!error) {
                                            if ([leaderBoard.identifier isEqual:kDistanceLeaderboardId]) {
                                                GKScore *playerDistance = leaderBoard.localPlayerScore;
                                                double playerDistance_d = (double)playerDistance.value / 1000.0;
                                                //NSLog(@"Distance: %f", (double)playerDistance.value / 1000.0);
                                                if (distance && playerDistance_d > distance.doubleValue) {
                                                    [_delegate playerDistanceDownloaded:playerDistance_d];
                                                }
                                                
                                            } else if ([leaderBoard.identifier isEqual:kSpeedLeaderboardId]) {
                                                GKScore *playerSpeed = leaderBoard.localPlayerScore;
                                                //NSLog(@"Speed: %f", (float)playerSpeed.value / 10.0);
                                                float playerSpeed_d = (float)playerSpeed.value / 10.0;
                                                if (speed && playerSpeed_d > speed.floatValue) {
                                                    //[_delegate playerSpeedDownloaded:playerSpeed_d];
                                                }
                                            }
                                        }
                                    }];
                                }
                            }];
                        }
                    }
                    
                    RouteManager *rm = [[RouteManager alloc] init];
                    [rm loadAchievements];
                    [[ComboManager sharedManager] loadAchievements];
                }
            }
            if (forced && [_delegate respondsToSelector:@selector(authenticationFinishedWithResult:)]) {
                [_delegate authenticationFinishedWithResult:result];
            } else {
                GlobalAppProperties *props = [GlobalAppProperties sharedInstance];
                props.storedGCAuthView = result.authViewController;
            }
        };
    //}
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
                //NSLog(@"Score report successful");
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

/*- (void)downloadLoadLeaderboardInfo
{
    [GKLeaderboard loadLeaderboardsWithCompletionHandler:^(NSArray *leaderboards, NSError *error) {
        self.leaderBoards = leaderboards;
        //[_delegate leaderBoardsDownloaded:leaderboards];
    }];
}*/

@end
