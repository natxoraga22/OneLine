//
//  Wall.h
//  OneLine
//
//  Created by Natxo Raga on 24/02/15.
//  Copyright (c) 2015 Ignacio Raga Llorens. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>


@interface Wall : SKNode

extern NSString *const WALL_NODE_NAME;

@property (strong, nonatomic) NSString *edgeImageName;
@property (nonatomic) CGFloat width;
@property (nonatomic) CGFloat edgeSize;
@property (nonatomic) CGFloat gapXPosition;
@property (nonatomic) CGFloat gapSize;
@property (strong, nonatomic) SKColor *color;

@property (readonly) CGFloat height;

// Collision handling
@property (nonatomic) uint32_t categoryBitMask;
@property (nonatomic) uint32_t collisionBitMask;
@property (nonatomic) uint32_t contactTestBitMask;

- (void)createWall;
- (void)setRedColorToElementWithName:(NSString *)name;

@end
