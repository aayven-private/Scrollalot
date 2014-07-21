//
//  ComboManager.m
//  RunnerGame
//
//  Created by Ivan Borsa on 16/04/14.
//  Copyright (c) 2014 Weloux. All rights reserved.
//

#import "ComboManager.h"
#import "Constants.h"
#import "DBAccessLayer.h"
#import "AchievedComboEntity.h"
#import "ComboEntity.h"

static NSString *kComboNameKey = @"comboName";
static NSString *kComboPatternKey = @"comboPattern";
static NSString *kAchievedKey = @"achieved";
static NSString *kAchievementIdKey = @"achievementId";

static NSString *kLastReadPackage = @"last_read_package";

static NSString *kDown100Combo = @"dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd";
static NSString *kUp100Combo = @"uuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuu";
static NSString *kUpDown10Combo = @"udududududududududud";
static NSString *kUpUpDownDown5Combo = @"uudduudduudduudduudd";
static NSString *kUpUpDown5Combo = @"uuduuduuduuduud";
static NSString *kUpDownLeftRightCombo = @"udlr";

@interface ComboManager()

@property (nonatomic) NSMutableDictionary *combos;
@property (nonatomic) NSDictionary *annulateDict;
@property (nonatomic) NSMutableDictionary *comboNames;
@property (nonatomic) NSMutableSet *achievedCombos;
@property (nonatomic) DBAccessLayer *dbLayer;

@end

@implementation ComboManager

static BOOL filterAchieved = YES;
static int currentPackageIndex = 1;

+ (id)sharedManager {
    static ComboManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
        sharedMyManager.combos = [NSMutableDictionary dictionary];
        sharedMyManager.comboNames = [NSMutableDictionary dictionary];
        sharedMyManager.achievedCombos = [NSMutableSet set];
        
        [sharedMyManager readCombos];
    });
    return sharedMyManager;
}

-(void)actionTaken:(NSString *)action
{
    __block NSMutableSet *achievedCombos = [NSMutableSet set];
    for (NSString *comboPattern in [_combos allKeys]) {
        NSNumber *comboIndex = [_combos objectForKey:comboPattern];
        
        if ([comboPattern characterAtIndex:comboIndex.intValue] == [action characterAtIndex:0]) {
            comboIndex = [NSNumber numberWithInt:comboIndex.intValue + 1];
        } else {
            comboIndex = @0;
        }
        
        if (comboIndex.intValue == comboPattern.length) {
            NSString *comboName = [_comboNames objectForKey:comboPattern];
            if (![_achievedCombos containsObject:comboName]) {
                [achievedCombos addObject:comboName];
                [_achievedCombos addObject:comboName];
            }
            comboIndex = @0;
        }
        
        [_combos setObject:comboIndex forKey:comboPattern];
    }

    if (achievedCombos.count > 0) {
        [_delegate combosCompleted:[achievedCombos copy]];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [self setCombosAchieved:achievedCombos];
        });
    }
}

-(void)readCombos
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *lastReadComboPackage = [defaults objectForKey:kLastReadPackage];
    if (!lastReadComboPackage) {
        lastReadComboPackage = [NSNumber numberWithInt:0];
        [defaults setObject:lastReadComboPackage forKey:kLastReadPackage];
        [defaults synchronize];
    }
    
    if (currentPackageIndex > lastReadComboPackage.intValue) {
        NSManagedObjectContext *context = [DBAccessLayer createManagedObjectContext];
        for (int i=lastReadComboPackage.integerValue + 1; i<currentPackageIndex + 1; i++) {
            NSString *path = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"ComboPackage%d", i] ofType:@"plist"];
            NSArray *package = [NSArray arrayWithContentsOfFile:path];
            if (package) {
                [self addPackage:package withContext:context];
                [defaults setObject:[NSNumber numberWithInt:i] forKey:kLastReadPackage];
            }
        }
    }
    
    NSMutableSet *availableCombos = [self getAvailableCombos];
    for (ComboEntityHelper *combo in availableCombos) {
        [_combos setObject:@0 forKey:combo.comboPattern];
        [_comboNames setObject:combo.comboName forKey:combo.comboPattern];
    }
}

-(void)addPackage:(NSArray *)package withContext:(NSManagedObjectContext *)context
{
    [context performBlockAndWait:^{
        for (NSDictionary *comboDict in package) {
            NSString *comboName = [comboDict objectForKey:kComboNameKey];
            NSString *comboPattern = [comboDict objectForKey:kComboPatternKey];
            NSString *achievementId = [comboDict objectForKey:kAchievementIdKey];
            
            ComboEntity *combo = [NSEntityDescription insertNewObjectForEntityForName:@"ComboEntity" inManagedObjectContext:context];
            combo.achieved = [NSNumber numberWithBool:NO];
            combo.comboName = comboName;
            combo.comboPattern = comboPattern;
            combo.achievementId = achievementId;
        }
        if ([context hasChanges]) {
            [DBAccessLayer saveContext:context async:NO];
        }
    }];
}

-(void)setCombosAchieved:(NSSet *)achievedCombos
{
    if (filterAchieved) {
        for (NSString *comboName in achievedCombos) {
            [_achievedCombos addObject:comboName];
        }
        NSManagedObjectContext *context = [DBAccessLayer createManagedObjectContext];
        [context performBlock:^{
            for (NSString *comboName in achievedCombos) {
                NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"ComboEntity"];
                NSPredicate *namePredicate = [NSPredicate predicateWithFormat:@"comboName == %@", comboName];
                [request setPredicate:namePredicate];
                
                NSError *error = nil;
                NSArray *combos = [context executeFetchRequest:request error:&error];
                if (!error) {
                    if (combos.count == 1) {
                        ComboEntity *entity = [combos objectAtIndex:0];
                        entity.achieved = [NSNumber numberWithBool:YES];
                    } else if (combos.count > 1) {
                        for (int i=1; i<combos.count; i++) {
                            ComboEntity *entityToDelete = [combos objectAtIndex:i];
                            [context deleteObject:entityToDelete];
                        }
                    }
                    if ([context hasChanges]) {
                        [DBAccessLayer saveContext:context async:YES];
                    }
                }
            }
        }];
    }
}

-(NSMutableSet *)getAvailableCombos
{
    __block NSMutableSet *result = [NSMutableSet set];
    NSManagedObjectContext *context = [DBAccessLayer createManagedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"ComboEntity"];
    NSPredicate *notAchievedPredicate = [NSPredicate predicateWithFormat:@"achieved == NO"];
    [request setPredicate:notAchievedPredicate];
    [context performBlockAndWait:^{
        NSError *error = nil;
        NSArray *combos = [context executeFetchRequest:request error:&error];
        
        if (!error) {
            for (ComboEntity *combo in combos) {
                ComboEntityHelper *comboHelper = [[ComboEntityHelper alloc] initWithEntity:combo];
                [result addObject:comboHelper];
            }
        }
    }];
    
    return result;
}

@end
