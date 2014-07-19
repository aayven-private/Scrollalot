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

static NSString *kComboNameKey = @"comboName";
static NSString *kComboPatternKey = @"comboPattern";
static NSString *kAchievedKey = @"achieved";

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

+ (id)sharedManager {
    static ComboManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
        //sharedMyManager.combos = [NSMutableDictionary dictionaryWithObjects:@[@0, @0, @0, @0, @0] forKeys:@[kDown100Combo, kUp100Combo, kUpDown10Combo, kUpUpDownDown5Combo, kUpUpDown5Combo]];
        //sharedMyManager.annulateDict = [NSDictionary dictionaryWithObjects:@[@[kComboPatternMad, kComboPatternTriple], @[kComboPatternTriple]] forKeys:@[kComboPatternVeryMad, kComboPatternMad]];
        sharedMyManager.combos = [NSMutableDictionary dictionary];
        sharedMyManager.comboNames = [NSMutableDictionary dictionary];
        
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
    _achievedCombos = [NSMutableSet set];
    if (filterAchieved) {
        _achievedCombos = [self getAlreadyAchievedCombos];
    }
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Combos" ofType:@"plist"];
    NSArray *comboList = [NSArray arrayWithContentsOfFile:path];
    for (NSDictionary *comboDict in comboList) {
        NSString *comboName = [comboDict objectForKeyedSubscript:kComboNameKey];
        NSString *comboPattern = [comboDict objectForKey:kComboPatternKey];
        if (![_achievedCombos containsObject:comboName]) {
            [_combos setObject:@0 forKey:comboPattern];
            [_comboNames setObject:comboName forKey:comboPattern];
        }
    }
}

-(void)setCombosAchieved:(NSSet *)achievedCombos
{
    if (filterAchieved) {
        for (NSString *comboName in achievedCombos) {
            [_achievedCombos addObject:comboName];
        }
        NSManagedObjectContext *context = [DBAccessLayer createManagedObjectContext];
        [context performBlock:^{
            for (NSString *newCombo in achievedCombos) {
                AchievedComboEntity *combo = [NSEntityDescription insertNewObjectForEntityForName:@"AchievedComboEntity" inManagedObjectContext:context];
                combo.comboName = newCombo;
                if ([context hasChanges]) {
                    [DBAccessLayer saveContext:context async:NO];
                }
            }
        }];
    }
}

-(NSMutableSet *)getAlreadyAchievedCombos
{
    __block NSMutableSet *result = [NSMutableSet set];
    NSManagedObjectContext *context = [DBAccessLayer createManagedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"AchievedComboEntity"];
    [context performBlockAndWait:^{
        NSError *error = nil;
        NSArray *combos = [context executeFetchRequest:request error:&error];
        
        if (!error) {
            for (AchievedComboEntity *achievedCombo in combos) {
                [result addObject:achievedCombo.comboName];
            }
        }
    }];
    
    return result;
}

@end
