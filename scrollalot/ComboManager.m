//
//  ComboManager.m
//  RunnerGame
//
//  Created by Ivan Borsa on 16/04/14.
//  Copyright (c) 2014 Weloux. All rights reserved.
//

#import "ComboManager.h"
#import "Constants.h"

static NSString *kDown100Combo = @"dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd";
static NSString *kUp100Combo = @"uuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuu";
static NSString *kUpDown10Combo = @"udududududududududud";
static NSString *kUpUpDownDown5Combo = @"uudduudduudduudduudd";
static NSString *kUpUpDown5Combo = @"uuduuduuduuduud";

@interface ComboManager()

@property (nonatomic) NSMutableDictionary *combos;
@property (nonatomic) NSDictionary *annulateDict;

@end

@implementation ComboManager

+ (id)sharedManager {
    static ComboManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
        sharedMyManager.combos = [NSMutableDictionary dictionaryWithObjects:@[@0, @0, @0, @0, @0] forKeys:@[kDown100Combo, kUp100Combo, kUpDown10Combo, kUpUpDownDown5Combo, kUpUpDown5Combo]];
        //sharedMyManager.annulateDict = [NSDictionary dictionaryWithObjects:@[@[kComboPatternMad, kComboPatternTriple], @[kComboPatternTriple]] forKeys:@[kComboPatternVeryMad, kComboPatternMad]];
    });
    return sharedMyManager;
}

-(void)actionTaken:(NSString *)action
{
    NSMutableSet *achievedCombos = [NSMutableSet set];
    for (NSString *comboPattern in [_combos allKeys]) {
        NSNumber *comboIndex = [_combos objectForKey:comboPattern];
        
        if ([comboPattern characterAtIndex:comboIndex.intValue] == [action characterAtIndex:0]) {
            comboIndex = [NSNumber numberWithInt:comboIndex.intValue + 1];
        } else {
            comboIndex = @0;
        }
        
        if (comboIndex.intValue == comboPattern.length) {
            [achievedCombos addObject:comboPattern];
            comboIndex = @0;
        }
        
        [_combos setObject:comboIndex forKey:comboPattern];
    }
    
    /*NSMutableArray *selectedCombos = [achievedCombos mutableCopy];
    
    for (NSString *pattern in achievedCombos) {
        NSArray *annulatedCombos = [_annulateDict objectForKey:pattern];
        if (annulatedCombos) {
            for (NSString *annulatedPattern in annulatedCombos) {
                [selectedCombos removeObject:annulatedPattern];
                [_combos setObject:@0 forKey:annulatedPattern];
            }
        }
    }
    
    for (NSString *pattern in selectedCombos) {
        NSLog(@"Combo: %@", pattern);
    }*/
    
    //NSLog(@"Achieved: %@", achievedCombos);
    if (achievedCombos.count > 0) {
        [_delegate comboesCompleted:achievedCombos];
    }
}

@end
