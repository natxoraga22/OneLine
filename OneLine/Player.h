//
//  Player.h
//  OneLine
//
//  Created by Natxo Raga on 25/02/15.
//  Copyright (c) 2015 Ignacio Raga Llorens. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>


@interface Player : SKNode

extern NSString *const PLAYER_NODE_NAME;

@property (strong, nonatomic) SKColor *color;
@property (nonatomic) CGFloat realSize;
@property (nonatomic) CGVector velocity;

@property (nonatomic) uint32_t categoryBitMask;
@property (nonatomic) uint32_t collisionBitMask;
@property (nonatomic) uint32_t contactTestBitMask;

- (instancetype)initWithImageNamed:(NSString *)imageName;
- (void)computePath:(CGFloat)distanceMoved;

@end
