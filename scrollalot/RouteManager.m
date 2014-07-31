//
//  RouteManager.m
//  scrollalot
//
//  Created by Ivan Borsa on 22/07/14.
//  Copyright (c) 2014 ivanborsa. All rights reserved.
//

#import "RouteManager.h"
#import "DBAccessLayer.h"
#import "RouteEntityHelper.h"
#import "CommonTools.h"

static NSString *kRouteNameKey = @"routeName";
static NSString *kRoutePatternKey = @"routePattern";
static NSString *kRouteAchievedKey = @"achieved";
static NSString *kRouteAchievementIdKey = @"achievementId";
static NSString *kRouteDistanceKey = @"routeDistance";
static NSString *kBadgeNameKey = @"badgeName";

static NSString *kLastReadRoutePackage = @"last_read_route_package";

@interface RouteManager()

@property (nonatomic) NSString *currentRouteName;
@property (nonatomic) NSString *currentRoutePattern;
@property (nonatomic) NSString *currentAchievementId;
@property (nonatomic) NSNumber *currentRouteDistance;
@property (nonatomic) NSString *currentBadgeName;

@property (nonatomic) NSNumber *routeIndex;

@end

@implementation RouteManager

static BOOL filterAchieved = YES;
static int currentPackageIndex = 2;

-(id)initWithDelegate:(id<RouteManagerDelegate>)delegate
{
    if (self = [super init]) {
        self.routeIndex = @0;
        self.delegate = delegate;
    }
    return self;
}

-(void)actionTaken:(NSString *)action
{
    if ([_currentRoutePattern characterAtIndex:_routeIndex.intValue] == [action characterAtIndex:0]) {
        _routeIndex = [NSNumber numberWithInt:_routeIndex.intValue + 1];
        if (_routeIndex.intValue < _currentRoutePattern.length) {
            char nextDirection = [_currentRoutePattern characterAtIndex:_routeIndex.intValue];
            [_delegate checkpointCompletedWithNextDirection:nextDirection andDistance:_currentRouteDistance];
        }
    } else {
        _routeIndex = @0;
    }
    
    if (_routeIndex.intValue == _currentRoutePattern.length) {
        //Route complete
        _routeIndex = @0;
        [_delegate routeCompleted:_currentRouteName andBadgeName:_currentBadgeName];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            if (_currentAchievementId && ![_currentAchievementId isEqualToString:@""]) {
                [self setCurrentRouteAchieved];
            }
            //[self loadNewRoute];
        });
    }
}

-(void)readRoutes
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *lastReadRoutePackage = [defaults objectForKey:kLastReadRoutePackage];
    if (!lastReadRoutePackage) {
        lastReadRoutePackage = [NSNumber numberWithInt:0];
        [defaults setObject:lastReadRoutePackage forKey:kLastReadRoutePackage];
        [defaults synchronize];
    }
    
    if (currentPackageIndex > lastReadRoutePackage.intValue) {
        NSManagedObjectContext *context = [DBAccessLayer createManagedObjectContext];
        for (int i=lastReadRoutePackage.intValue + 1; i<currentPackageIndex + 1; i++) {
            NSString *path = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"RoutePackage%d", i] ofType:@"plist"];
            NSArray *package = [NSArray arrayWithContentsOfFile:path];
            if (package) {
                [self addRoute:package withContext:context];
                [defaults setObject:[NSNumber numberWithInt:i] forKey:kLastReadRoutePackage];
                [defaults synchronize];
            }
        }
    }
}

-(void)addRoute:(NSArray *)package withContext:(NSManagedObjectContext *)context
{
    [context performBlockAndWait:^{
        for (NSDictionary *routeDict in package) {
            NSString *routeName = [routeDict objectForKey:kRouteNameKey];
            NSString *routePattern = [routeDict objectForKey:kRoutePatternKey];
            NSString *achievementId = [routeDict objectForKey:kRouteAchievementIdKey];
            NSNumber *routeDistance = [routeDict objectForKey:kRouteDistanceKey];
            NSString *badgeName = [routeDict objectForKey:kBadgeNameKey];
            
            RouteEntity *route = [NSEntityDescription insertNewObjectForEntityForName:@"RouteEntity" inManagedObjectContext:context];
            route.achieved = [NSNumber numberWithBool:NO];
            route.routeName = routeName;
            route.routePattern = routePattern;
            route.achievementId = achievementId;
            route.routeDistance = routeDistance;
            route.badgeName = badgeName;
        }
        if ([context hasChanges]) {
            [DBAccessLayer saveContext:context async:NO];
        }
    }];
}

-(void)setCurrentRouteAchieved
{
    [self reportAchievementIdentifier:_currentAchievementId percentComplete:100.0];
    if (filterAchieved) {
        NSManagedObjectContext *context = [DBAccessLayer createManagedObjectContext];
        [context performBlockAndWait:^{
            NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"RouteEntity"];
            NSPredicate *namePredicate = [NSPredicate predicateWithFormat:@"routeName == %@", _currentRouteName];
            [request setPredicate:namePredicate];
            
            NSError *error = nil;
            NSArray *routes = [context executeFetchRequest:request error:&error];
            if (!error) {
                if (routes.count == 1) {
                    RouteEntity *entity = [routes objectAtIndex:0];
                    entity.achieved = [NSNumber numberWithBool:YES];
                } else if (routes.count > 1) {
                    for (int i=1; i<routes.count; i++) {
                        RouteEntity *entityToDelete = [routes objectAtIndex:i];
                        [context deleteObject:entityToDelete];
                    }
                }
                if ([context hasChanges]) {
                    [DBAccessLayer saveContext:context async:NO];
                }
            }
        }];
    }
}

-(void)setRouteAchievedWithId:(NSString *)identifier
{
    //if (filterAchieved) {
        NSManagedObjectContext *context = [DBAccessLayer createManagedObjectContext];
        [context performBlockAndWait:^{
            NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"RouteEntity"];
            NSPredicate *namePredicate = [NSPredicate predicateWithFormat:@"achievementId == %@", identifier];
            [request setPredicate:namePredicate];
            
            NSError *error = nil;
            NSArray *routes = [context executeFetchRequest:request error:&error];
            if (!error) {
                if (routes.count == 1) {
                    RouteEntity *entity = [routes objectAtIndex:0];
                    entity.achieved = [NSNumber numberWithBool:YES];
                } else if (routes.count > 1) {
                    for (int i=1; i<routes.count; i++) {
                        RouteEntity *entityToDelete = [routes objectAtIndex:i];
                        [context deleteObject:entityToDelete];
                    }
                }
                if ([context hasChanges]) {
                    [DBAccessLayer saveContext:context async:NO];
                }
            }
        }];
    //}
}

-(NSMutableSet *)getAvailableRoutes
{
    __block NSMutableSet *result = [NSMutableSet set];
    NSManagedObjectContext *context = [DBAccessLayer createManagedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"RouteEntity"];
    NSPredicate *notAchievedPredicate = [NSPredicate predicateWithFormat:@"achieved == NO"];
    [request setPredicate:notAchievedPredicate];
    [context performBlockAndWait:^{
        NSError *error = nil;
        NSArray *routes = [context executeFetchRequest:request error:&error];
        
        if (!error) {
            for (RouteEntity *route in routes) {
                RouteEntityHelper *routeHelper = [[RouteEntityHelper alloc] initWithEntity:route];
                [result addObject:routeHelper];
            }
        }
    }];
    
    return result;
}

-(NSArray *)getAchievedRoutes_dictionary
{
    __block NSMutableArray *result = [NSMutableArray array];
    NSManagedObjectContext *context = [DBAccessLayer createManagedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"RouteEntity"];
    NSPredicate *notAchievedPredicate = [NSPredicate predicateWithFormat:@"achieved == YES"];
    [request setPredicate:notAchievedPredicate];
    [context performBlockAndWait:^{
        NSError *error = nil;
        NSArray *routes = [context executeFetchRequest:request error:&error];
        
        if (!error) {
            for (RouteEntity *route in routes) {
                [result addObject:[self entityToDictionary:route]];
            }
        }
    }];
    
    return result;
}

-(RouteEntityHelper *)getAvailableRouteWithLeastDistance
{
    __block RouteEntityHelper *result = nil;
    NSManagedObjectContext *context = [DBAccessLayer createManagedObjectContext];
    
    [context performBlockAndWait:^{
        float leastDistance = [self getMinimumAvailableRouteDistanceWithContext:context];
        
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"RouteEntity"];
        NSPredicate *notAchievedPredicate = [NSPredicate predicateWithFormat:@"achieved == NO AND routeDistance == %@", [NSNumber numberWithFloat:leastDistance]];
        [request setPredicate:notAchievedPredicate];
        
        NSSortDescriptor *sortByDistance = [[NSSortDescriptor alloc] initWithKey:@"routeDistance" ascending:YES];
        [request setSortDescriptors:@[sortByDistance]];
        
        
        NSError *error = nil;
        NSArray *routes = [context executeFetchRequest:request error:&error];
        
        if (!error && routes.count > 0) {
            
            int rnd = [CommonTools getRandomNumberFromInt:0 toInt:routes.count - 1];
            
            RouteEntity *minimumDistanceEntity = [routes objectAtIndex:rnd];
            result = [[RouteEntityHelper alloc] initWithEntity:minimumDistanceEntity];
        }
    }];
    
    return result;
}

-(void)loadNewRoute
{
    RouteEntityHelper *nextRoute = [self getAvailableRouteWithLeastDistance];
    if (nextRoute) {
        //NSLog(@"Route loaded: %@", nextRoute.routeName);
        _currentRoutePattern = nextRoute.routePattern;
        _currentRouteName = nextRoute.routeName;
        _currentRouteDistance = nextRoute.routeDistance;
        _currentAchievementId = nextRoute.achievementId;
        _currentBadgeName = nextRoute.badgeName;
        [_delegate nextRouteLoadedInDirection:[_currentRoutePattern characterAtIndex:0] andDistance:_currentRouteDistance];
    } else {
        [_delegate noAvailableRoutes];
    }
}

-(void)loadRouteManually:(RouteEntityHelper *)route
{
    _currentRouteName = route.routeName;
    _currentRouteDistance = route.routeDistance;
    _currentRoutePattern = route.routePattern;
    _currentAchievementId = nil;
    [_delegate nextRouteLoadedInDirection:[_currentRoutePattern characterAtIndex:0] andDistance:_currentRouteDistance];
}

-(float)getMinimumAvailableRouteDistanceWithContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"RouteEntity"
                                              inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    [fetchRequest setResultType:NSDictionaryResultType];
    
    NSPredicate *notAchievedPredicate = [NSPredicate predicateWithFormat:@"achieved == NO"];
    [fetchRequest setPredicate:notAchievedPredicate];
    
    NSExpression *keyPathExpression = [NSExpression expressionForKeyPath:@"routeDistance"];
    NSExpression *leastDistanceExpression = [NSExpression
                                        expressionForFunction:@"min:"
                                        arguments:[NSArray arrayWithObject:keyPathExpression]];
    
    NSExpressionDescription *leastDistanceExpressionDescription =
    [[NSExpressionDescription alloc] init];
    [leastDistanceExpressionDescription setName:@"routeDistance"];
    [leastDistanceExpressionDescription setExpression:leastDistanceExpression];
    [leastDistanceExpressionDescription setExpressionResultType:NSDecimalAttributeType];
    
    [fetchRequest setPropertiesToFetch:[NSArray arrayWithObject:
                                        leastDistanceExpressionDescription]];
    NSError *error = nil;
    NSArray *fetchResults = [context executeFetchRequest:fetchRequest error:&error];
    NSNumber *distance = [[fetchResults lastObject] valueForKey:@"routeDistance"];
    
    return distance.floatValue;

}

-(NSDictionary *)entityToDictionary:(RouteEntity *)entity
{
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    [result setObject:entity.badgeName forKey:@"badgeName"];
    [result setObject:entity.routeName forKey:@"name"];
    [result setObject:entity.routePattern forKey:@"pattern"];
    [result setObject:entity.routeDistance forKey:@"distance"];
    [result setObject:entity.achievementId forKey:@"achievementId"];
    return result;
}

- (void)reportAchievementIdentifier:(NSString*) identifier percentComplete:(float) percent
{
    GKAchievement *achievement = [[GKAchievement alloc] initWithIdentifier: identifier];
    achievement.percentComplete = percent;
    if (achievement)
    {
        [GKAchievement reportAchievements:@[achievement] withCompletionHandler:^(NSError *error) {
            if (error != nil) {
                NSLog(@"Error in reporting achievements: %@", error);
            }
        }];
    }
}

- (void)loadAchievements
{
    [GKAchievement loadAchievementsWithCompletionHandler:^(NSArray *achievements, NSError *error) {
        if (error != nil)
        {
            // Handle the error.
        }
        if (achievements != nil)
        {
            for (GKAchievement *achievement in achievements) {
                NSLog(@"Achievement: %@, progress: %f", achievement.identifier, achievement.percentComplete);
                if ([achievement.identifier hasPrefix:@"scrollalot_route"] && achievement.percentComplete == 100.0) {
                    [self setRouteAchievedWithId:achievement.identifier];
                }
            }
        }
    }];
    
    NSArray *achievedRoutes = [self getAchievedRoutes_dictionary];
    for (NSDictionary *dict in achievedRoutes) {
        [self reportAchievementIdentifier:[dict objectForKey:@"achievementId"] percentComplete:100.0];
    }
}

@end
