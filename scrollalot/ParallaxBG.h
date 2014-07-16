//
//  MainParallaxBG.h
//  BeeGame
//
//  Created by Ivan Borsa on 23/03/14.
//  Copyright (c) 2014 aayven. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "SceneObject.h"

#define kPBParallaxBackgroundDefaultSpeedDifferential   0.90
#define kPBParallaxBackgroundDefaultSpeed 0.5

typedef enum {
    kPBParallaxBackgroundDirectionUp = 0,
    kPBParallaxBackgroundDirectionDown,
    kPBParallaxBackgroundDirectionRight,
    kPBParallaxBackgroundDirectionLeft
} PBParallaxBackgroundDirection;

@interface ParallaxBG : SceneObject

@property (nonatomic) BOOL showBgStatus;

/** @brief Designated initializer for the parallax backgorund.
 * Creates and initializes a new parallax background of certain size, with some images, an initial velocity and a differential of this velocity to each background.
 * @param backgrounds a NSArray of the backgrounds, expressed as either NSStrings (containing the name of the image to use), UIImages (with the image used to build the texture), SKTexture (with the textures to build the SKNodes) or SKNodes. They must be ordered from foreground to background, i.e: the closer element must be the first one in the array.
 * @param the direction of the parallax movement (up, down, right or left).
 * @param velocity the velocity of the fastest (= nearest) backgound.
 * @param differential a differential decrease to be applied to each following background, expressed as a float from 0 (every background moves at the same speed) to 1 (each backgrounds moves at half the speed of the previous (=closer) one).
 */
- (id) initWithBackgrounds: (NSArray *) backgrounds size: (CGSize) size direction: (PBParallaxBackgroundDirection) direction fastestSpeed: (CGFloat) speed andSpeedDecrease: (CGFloat) differential andYOffsets:(NSArray *)offsets andCustomSpeeds:(NSArray *)speeds;

/** This method, called once in every game loop, will adjust the relative position of the nodes in the parallax background set */
- (void) update: (NSTimeInterval) currentTime;

/** reverse the direction of the movement, left->right, right->left, up->down, down->up */
- (void) reverseMovementDirection;

/** Debug method for watching the positions of the backgrounds at a given time. */
- (void) showBackgroundPositions;

@end
