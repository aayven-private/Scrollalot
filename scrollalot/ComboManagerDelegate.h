//
//  ComboManagerDelegate.h
//  scrollalot
//
//  Created by Ivan Borsa on 18/07/14.
//  Copyright (c) 2014 ivanborsa. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ComboManagerDelegate <NSObject>

-(void)comboCompleted:(NSString *)comboName withBadgeName:(NSString *)badgeName;

@end
