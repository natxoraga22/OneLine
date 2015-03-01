//
//  Player.h
//  OneLine
//
//  Created by Natxo Raga on 25/02/15.
//  Copyright (c) 2015 Ignacio Raga Llorens. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>


@interface Player : SKSpriteNode

@property (nonatomic) CGFloat realSize;

- (instancetype)initWithImageNamed:(NSString *)imageName;

@end
