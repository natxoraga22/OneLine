//
//  Player.m
//  OneLine
//
//  Created by Natxo Raga on 25/02/15.
//  Copyright (c) 2015 Ignacio Raga Llorens. All rights reserved.
//

#import "Player.h"


@implementation Player

- (instancetype)initWithImageNamed:(NSString *)imageName
{
    if (self = [super initWithImageNamed:imageName]) {
        // Physics
        SKPhysicsBody *playerPhysics = [SKPhysicsBody bodyWithCircleOfRadius:self.size.width/2.0];
        self.physicsBody = playerPhysics;
        
        // Color
        self.color = [SKColor whiteColor];
        self.colorBlendFactor = 1.0;
    }
    return self;
}

- (CGFloat)realSize
{
    return self.size.width;
}

- (void)setRealSize:(CGFloat)realSize
{
    [self setScale:realSize/self.size.width];
}

@end
