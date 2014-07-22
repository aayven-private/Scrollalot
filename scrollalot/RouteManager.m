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

static NSString *kRouteNameKey = @"routeName";
static NSString *kRoutePatternKey = @"routePattern";
static NSString *kRouteAchievedKey = @"routeAchieved";
static NSString *kRouteAchievementIdKey = @"routeAchievementId";
static NSString *kRouteDistanceKey = @"routeDistance";

static NSString *kLastReadRoutePackage = @"last_read_route_package";

@interface RouteManager()

@property (nonatomic) NSString *currentRouteName;
@property (nonatomic) NSString *currentRoutePattern;
@property (nonatomic) NSString *currentAchievementId;
@property (nonatomic) NSNumber *currentRouteDistance;

@property (nonatomic) NSNumber *routeIndex;

@end

@implementation RouteManager

static BOOL filterAchieved = YES;
static int currentPackageIndex = 1;

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
        [_delegate routeCompleted:_currentRouteName];
        _routeIndex = @0;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [self setCurrentRouteAchieved];
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
            
            RouteEntity *route = [NSEntityDescription insertNewObjectForEntityForName:@"RouteEntity" inManagedObjectContext:context];
            route.achieved = [NSNumber numberWithBool:NO];
            route.routeName = routeName;
            route.routePattern = routePattern;
            route.achievementId = achievementId;
            route.routeDistance = routeDistance;
        }
        if ([context hasChanges]) {
            [DBAccessLayer saveContext:context async:NO];
        }
    }];
}

-(void)setCurrentRouteAchieved
{
    if (filterAchieved) {
        NSManagedObjectContext *context = [DBAccessLayer createManagedObjectContext];
        [context performBlock:^{
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
                    [DBAccessLayer saveContext:context async:YES];
                }
            }
        }];
    }
}

-(NSMutableSet *)getAvailableRoutes
{
    __block NSMutableSet *result = [NSMutableSet set];
    NSManagedObjectContext *context = [DBAccessLayer createManagedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"RouteEntity"];
    //NSPredicate *notAchievedPredicate = [NSPredicate predicateWithFormat:@"achieved == NO"];
    //[request setPredicate:notAchievedPredicate];
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

-(void)loadNewRoute
{
    NSMutableSet *availableRoutes = [self getAvailableRoutes];
    if (availableRoutes.count > 0) {
        RouteEntityHelper *nextRoute = [availableRoutes anyObject];
        _currentRoutePattern = nextRoute.routePattern;
        _currentRouteName = nextRoute.routeName;
        _currentRouteDistance = nextRoute.routeDistance;
        _currentAchievementId = nextRoute.achievementId;
        [_delegate nextRouteLoadedInDirection:[_currentRoutePattern characterAtIndex:0] andDistance:_currentRouteDistance];
    }
}

@end
