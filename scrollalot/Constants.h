//
//  Constants.h
//  scrollalot
//
//  Created by Ivan Borsa on 10/07/14.
//  Copyright (c) 2014 ivanborsa. All rights reserved.
//

#import <Foundation/Foundation.h>

#define IS_PHONEPOD5() ([UIScreen mainScreen].bounds.size.height == 568.0f && [UIScreen mainScreen].scale == 2.f && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)

static inline CGPoint rwAdd(CGPoint a, CGPoint b) {
    return CGPointMake(a.x + b.x, a.y + b.y);
}

static inline CGPoint rwSub(CGPoint a, CGPoint b) {
    return CGPointMake(a.x - b.x, a.y - b.y);
}

static inline CGPoint rwMult(CGPoint a, float b) {
    return CGPointMake(a.x * b, a.y * b);
}

static inline float rwLength(CGPoint a) {
    return sqrtf(a.x * a.x + a.y * a.y);
}

// Makes a vector have a length of 1
static inline CGPoint rwNormalize(CGPoint a) {
    float length = rwLength(a);
    if (length == 0.0) {
        length = FLT_MIN;
    }
    return CGPointMake(a.x / length, a.y / length);
}

static NSString *kObjectTypeMarker = @"object_type_marker";
static NSString *kObjectTypeMeteor = @"meteor";

static NSString *kGlobalDistanceKey = @"global_distance";
static NSString *kMaxSpeedKey = @"max_speed";
static NSString *kWasHelpShownKey = @"scrollalot_help_was_shown";

static const uint32_t playerCategory        =  0x1 << 0;
static const uint32_t meteorCategory      =  0x1 << 1;

static CGFloat degreeInRadians = 0.0174532925;

static NSString *fontName = @"TektonPro-Bold";
