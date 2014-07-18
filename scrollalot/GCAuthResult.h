//
//  GCAuthResult.h
//  scrollalot
//
//  Created by Ivan Borsa on 18/07/14.
//  Copyright (c) 2014 ivanborsa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GCAuthResult : NSObject

@property (nonatomic) BOOL wasSuccessul;
@property (nonatomic) UIViewController *authViewController;

@end
