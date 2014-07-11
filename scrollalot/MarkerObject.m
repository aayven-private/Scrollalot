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
        self.physicsBody.dynamic = YES;
        self.physicsBody.affectedByGravity = NO;
        self.physicsBody.contactTestBitMask = 0;
        self.physicsBody.collisionBitMask = 0;
    }
    return self;
}

@end
