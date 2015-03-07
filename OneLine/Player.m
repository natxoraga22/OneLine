//
//  Player.m
//  OneLine
//
//  Created by Natxo Raga on 25/02/15.
//  Copyright (c) 2015 Ignacio Raga Llorens. All rights reserved.
//

#import "Player.h"


@interface Player()
@property (strong, nonatomic) SKSpriteNode* body;
@end


@implementation Player

#pragma mark - Initialization

- (instancetype)initWithImageNamed:(NSString *)imageName
{
    if (self = [super init]) {
        self.body = [SKSpriteNode spriteNodeWithImageNamed:imageName];
        [self addChild:self.body];
        
        // Physics
        SKPhysicsBody *bodyPhysics = [SKPhysicsBody bodyWithCircleOfRadius:self.body.size.width/2.0];
        self.body.physicsBody = bodyPhysics;
        
        // Color
        self.body.color = [SKColor whiteColor];
        self.body.colorBlendFactor = 1.0;
    }
    return self;
}


#pragma mark - Getters & setters

- (void)setColor:(SKColor *)newColor
{
    _color = newColor;
    
    self.body.color = newColor;
}

- (CGFloat)realSize
{
    return self.body.size.width;
}

- (void)setRealSize:(CGFloat)newRealSize
{
    [self.body setScale:newRealSize/self.body.size.width];
}

- (CGVector)velocity
{
    return self.body.physicsBody.velocity;
}

- (void)setVelocity:(CGVector)newVelocity
{
    self.body.physicsBody.velocity = newVelocity;
}

@end
