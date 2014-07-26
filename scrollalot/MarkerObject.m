//
//  MarkerObject.m
//  scrollalot
//
//  Created by Ivan Borsa on 10/07/14.
//  Copyright (c) 2014 ivanborsa. All rights reserved.
//

#import "MarkerObject.h"

@implementation MarkerObject

-(id)initWithTexture:(SKTexture *)texture
{
    if (self = [super initWithTexture:texture]) {
        self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:texture.size];
        self.objectType = kObjectTypeMarker;
        self.physicsBody.categoryBitMask = playerCategory;
        self.physicsBody.dynamic = YES;
        self.physicsBody.affectedByGravity = NO;
        self.physicsBody.contactTestBitMask = meteorCategory;
        self.physicsBody.collisionBitMask = 0;
        self.physicsBody.mass = 3;
        self.physicsBody.linearDamping = 1.0;
    }
    return self;
}

-(id)initWithColor:(UIColor *)color size:(CGSize)size
{
    if (self = [super initWithColor:color size:size]) {
        self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:size];
        self.objectType = kObjectTypeMarker;
        self.physicsBody.categoryBitMask = playerCategory;
        self.physicsBody.dynamic = YES;
        self.physicsBody.affectedByGravity = NO;
        self.physicsBody.contactTestBitMask = meteorCategory;
        self.physicsBody.collisionBitMask = 0;
        self.physicsBody.mass = 3;
        self.physicsBody.linearDamping = 1.0;
    }
    return self;
}

@end
