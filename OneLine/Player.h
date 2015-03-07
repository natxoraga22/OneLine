//
//  Player.h
//  OneLine
//
//  Created by Natxo Raga on 25/02/15.
//  Copyright (c) 2015 Ignacio Raga Llorens. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>


@interface Player : SKNode

@property (strong, nonatomic) SKColor *color;
@property (nonatomic) CGFloat realSize;
@property (nonatomic) CGVector velocity;

- (instancetype)initWithImageNamed:(NSString *)imageName;

@end
