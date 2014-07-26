//
//  Meteor.m
//  scrollalot
//
//  Created by Ivan Borsa on 26/07/14.
//  Copyright (c) 2014 ivanborsa. All rights reserved.
//

#import "Meteor.h"
#import "CommonTools.h"

@implementation Meteor

-(id)initWithTexture:(SKTexture *)texture
{
    if (self = [super initWithTexture:texture]) {
        self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:texture.size];
        self.objectType = kObjectTypeMeteor;
        self.physicsBody.categoryBitMask = meteorCategory;
        self.physicsBody.dynamic = YES;
        self.physicsBody.affectedByGravity = NO;
        self.physicsBody.contactTestBitMask = playerCategory;
        self.physicsBody.collisionBitMask = meteorCategory;
        self.physicsBody.usesPreciseCollisionDetection = YES;
        self.physicsBody.mass = 3;
        self.physicsBody.linearDamping = 1.0;
        self.xScale = self.yScale = [CommonTools getRandomFloatFromFloat:0.7 toFloat:1.0];
    }
    return self;
}

@end
