//
//  MainParallaxBG.m
//  BeeGame
//
//  Created by Ivan Borsa on 23/03/14.
//  Copyright (c) 2014 aayven. All rights reserved.
//

#import "ParallaxBG.h"

#define kParallaxBackgroundAntiFlickeringAdjustment 0.05

static inline CGFloat roundFloatToTwoDecimalPlaces(CGFloat num) { return floorf(num * 100 + 0.5) / 100; }

@interface ParallaxBG()

/** The array containing the set of SKSpriteNode nodes representing the different backgrounds */
@property (nonatomic, strong) NSArray * backgrounds;

/** The array containing the set of duplicated background nodes that will appear when the background starts sliding out of the screen */
@property (nonatomic, strong) NSArray * clonedBackgrounds;

/** The array of speeds for every background */
@property (nonatomic, strong) NSArray * speeds;

/** Number of backgrounds in this parallax background set */
@property (nonatomic) NSUInteger numberOfBackgrounds;

/** The movement direction of the parallax backgrounds */
@property (nonatomic) PBParallaxBackgroundDirection direction;

/** The size of the parallax background set */
@property (nonatomic) CGSize size;

@end

@implementation ParallaxBG

- (id) initWithBackgrounds: (NSArray *) backgrounds size: (CGSize) size direction: (PBParallaxBackgroundDirection) direction fastestSpeed: (CGFloat) speed andSpeedDecrease: (CGFloat) differential andYOffsets:(NSArray *)offsets andCustomSpeeds:(NSArray *)speeds {
    self = [super init];
    if (self) {
        // initialization
        self.numberOfBackgrounds = 0;
        self.direction = direction;
        self.position = CGPointMake(size.width / 2, size.height / 2);
        self.zPosition = -100;
        
        // sanity checks
        if (speed < 0) speed = -speed;
        if (differential < 0 || differential > 1) differential = kPBParallaxBackgroundDefaultSpeedDifferential; // sanity check
        
        // initialize backgrounds
        CGFloat zPos = 1.0f / backgrounds.count;
        NSUInteger bgNumber = 0;
        NSMutableArray * bgs = [NSMutableArray array];
        NSMutableArray * cBgs = [NSMutableArray array];
        NSMutableArray * spds = [NSMutableArray array];
        CGFloat currentSpeed = roundFloatToTwoDecimalPlaces(speed);
        
        for (id obj in backgrounds) {
            // determine the type of background
            SKSpriteNode * node = nil;
            if ([obj isKindOfClass:[UIImage class]]) {
                node = [[SKSpriteNode alloc] initWithTexture:[SKTexture textureWithImage:(UIImage *) obj]];
            } else if ([obj isKindOfClass:[NSString class]])  {
                node = [[SKSpriteNode alloc] initWithImageNamed:(NSString *) obj];
            } else if ([obj isKindOfClass:[SKTexture class]]) {
                node = [[SKSpriteNode alloc] initWithTexture:(SKTexture *) obj];
            } else if ([obj isKindOfClass:[SKSpriteNode class]]) {
                node = (SKSpriteNode *) obj;
            } else continue;
            
            int bgIndex = [backgrounds indexOfObject:obj];
            NSNumber *yOffset = [offsets objectAtIndex:bgIndex];
            if (!yOffset) {
                yOffset = @0;
            }
            
            // create the duplicate and insert both at their proper locations.
            node.zPosition = self.zPosition - (zPos + (zPos * bgNumber));
            node.position = CGPointMake(0, self.size.height - yOffset.floatValue);
            SKSpriteNode * clonedNode = [node copy];
            CGFloat clonedPosX = node.position.x, clonedPosY = node.position.y;
            switch (direction) { // calculate clone's position
                case kPBParallaxBackgroundDirectionUp:
                    clonedPosY = 0;
                    break;
                case kPBParallaxBackgroundDirectionDown:
                    clonedPosY = node.size.height;
                    break;
                case kPBParallaxBackgroundDirectionRight:
                    clonedPosX = - node.size.width;
                    break;
                case kPBParallaxBackgroundDirectionLeft:
                    clonedPosX = node.size.width;
                    break;
                default:
                    break;
            }
            clonedNode.position = CGPointMake(clonedPosX, clonedPosY);
            
            // add nodes to their arrays
            [bgs addObject:node];
            [cBgs addObject:clonedNode];
            
            NSNumber *alternateSpeed = [speeds objectAtIndex:bgIndex];
            float newSpeed = currentSpeed;
            if (alternateSpeed && alternateSpeed.floatValue > 0) {
                newSpeed = alternateSpeed.floatValue;
            }
            
            // add the velocity for this node and adjust the next current velocity.
            [spds addObject:[NSNumber numberWithFloat:newSpeed]];
            currentSpeed = roundFloatToTwoDecimalPlaces(currentSpeed / (1 + differential));
            
            // add to the scene
            [self addChild:node];
            [self addChild:clonedNode];
            
            // next background
            bgNumber++;
        }
        // did we find some valid backgrounds?
        if (bgNumber > 0) {
            self.numberOfBackgrounds = bgNumber;
            self.backgrounds = [bgs copy];
            self.clonedBackgrounds = [cBgs copy];
            self.speeds = [spds copy];
        } else {
            NSLog(@"Unable to find any valid backgrounds for parallax scrolling.");
            return nil;
        }
        
    }
    
    return self;
}

- (void) update:(NSTimeInterval)currentTime {
    for (NSUInteger i = 0; i < self.numberOfBackgrounds; i++) {
        // determine the speed of each node
        CGFloat speed = [[self.speeds objectAtIndex:i] floatValue];
        
        // adjust positions
        SKSpriteNode * bg = [self.backgrounds objectAtIndex:i];
        SKSpriteNode * cBg = [self.clonedBackgrounds objectAtIndex:i];
        CGFloat newBgX = bg.position.x, newBgY = bg.position.y, newCbgX = cBg.position.x, newCbgY = cBg.position.y;
        // position depends on direction.
        switch (self.direction) {
            case kPBParallaxBackgroundDirectionUp:
                newBgY += speed;
                newCbgY += speed;
                if (newBgY >= (bg.size.height * 2)) newBgY = newCbgY - cBg.size.height + kParallaxBackgroundAntiFlickeringAdjustment;
                if (newCbgY >= (cBg.size.height * 2)) newCbgY = newBgY - bg.size.height + kParallaxBackgroundAntiFlickeringAdjustment;
                
                break;
            case kPBParallaxBackgroundDirectionDown:
                newBgY -= speed;
                newCbgY -= speed;
                if (newBgY <= -bg.size.height) newBgY = newCbgY + cBg.size.height - kParallaxBackgroundAntiFlickeringAdjustment;
                if (newCbgY <= -cBg.size.height) newCbgY = newBgY + bg.size.height - kParallaxBackgroundAntiFlickeringAdjustment;
                
                break;
            case kPBParallaxBackgroundDirectionRight:
                newBgX += speed;
                newCbgX += speed;
                if (newBgX >= bg.size.width) newBgX = newCbgX - cBg.size.width + kParallaxBackgroundAntiFlickeringAdjustment;
                if (newCbgX >= cBg.size.width) newCbgX =  newBgX - bg.size.width + kParallaxBackgroundAntiFlickeringAdjustment;
                
                break;
            case kPBParallaxBackgroundDirectionLeft:
                newBgX = newBgX - speed;
                newCbgX = newCbgX - speed;
                if (newBgX <= -bg.size.width) newBgX = newCbgX + cBg.size.width - kParallaxBackgroundAntiFlickeringAdjustment;
                if (newCbgX <= -cBg.size.width) newCbgX = newBgX + bg.size.width - kParallaxBackgroundAntiFlickeringAdjustment;
                break;
            default:
                break;
        }
        // update positions with the right coordinates.
        bg.position = CGPointMake(newBgX, newBgY);
        cBg.position = CGPointMake(newCbgX, newCbgY);
        if (_showBgStatus) [self showBackgroundPositions];
    }
}

- (void) reverseMovementDirection {
    PBParallaxBackgroundDirection newDirection = self.direction;
    switch (self.direction) {
        case kPBParallaxBackgroundDirectionDown:
            newDirection = kPBParallaxBackgroundDirectionUp;
            break;
            
        case kPBParallaxBackgroundDirectionUp:
            newDirection = kPBParallaxBackgroundDirectionDown;
            break;
            
        case kPBParallaxBackgroundDirectionLeft:
            newDirection = kPBParallaxBackgroundDirectionRight;
            break;
            
        case kPBParallaxBackgroundDirectionRight:
            newDirection = kPBParallaxBackgroundDirectionLeft;
            break;
            
        default:
            break;
    }
    self.direction = newDirection;
}

- (void) showBackgroundPositions {
    NSLog(@"Parallax background state:");
    for (NSUInteger i = 0; i < self.numberOfBackgrounds; i++) {
        // determine the speed of each node
        CGFloat speed = [[self.speeds objectAtIndex:i] floatValue];
        
        // adjust positions
        SKSpriteNode * bg = [self.backgrounds objectAtIndex:i];
        SKSpriteNode * cBg = [self.clonedBackgrounds objectAtIndex:i];
        NSLog(@"Layer %u: background at (%f, %f), background_clone at (%f, %f), speed: %f", i, bg.position.x,bg.position.y, cBg.position.x, cBg.position.y, speed);
        
    }
}

@end
