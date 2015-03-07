//
//  Wall.m
//  OneLine
//
//  Created by Natxo Raga on 24/02/15.
//  Copyright (c) 2015 Ignacio Raga Llorens. All rights reserved.
//

#import "Wall.h"


@interface Wall()
@property (strong, nonatomic) SKSpriteNode *leftWallEdge;
@property (strong, nonatomic) SKShapeNode *leftWall;
@property (strong, nonatomic) SKSpriteNode *rightWallEdge;
@property (strong, nonatomic) SKShapeNode *rightWall;
@end


@implementation Wall

#pragma mark - Getters & setters

- (CGFloat)height
{
    if (self.leftWallEdge.size.height > self.rightWallEdge.size.height) return self.leftWallEdge.size.height;
    else return self.rightWallEdge.size.height;
}

- (void)setColor:(SKColor *)newColor
{
    _color = newColor;
    
    self.leftWallEdge.color = newColor;
    self.leftWall.strokeColor = newColor;
    self.leftWall.fillColor = newColor;
    self.rightWallEdge.color = newColor;
    self.rightWall.strokeColor = newColor;
    self.rightWall.fillColor = newColor;
}


#pragma mark - Wall creation

static const CGFloat WALL_EDGE_PROPORTION = 1.0/3.0;

- (void)createWall
{
    [self removeAllChildren];
    [self createLeftWallEdge];
    [self createLeftWall];
    [self createRightWallEdge];
    [self createRightWall];
}

- (void)createLeftWallEdge
{
    self.leftWallEdge = [SKSpriteNode spriteNodeWithImageNamed:self.edgeImageName];
    
    // Size & position
    if (self.edgeSize != 0.0) [self.leftWallEdge setScale:self.edgeSize/self.leftWallEdge.size.width];
    self.leftWallEdge.position = CGPointMake(self.gapXPosition - self.gapSize/2.0 - self.leftWallEdge.size.width/2.0, 0.0);
    
    // Color
    self.leftWallEdge.colorBlendFactor = 1.0;
    self.leftWallEdge.color = self.color;
    
    // Physics
    self.leftWallEdge.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:self.leftWallEdge.size.width/2.0];
    self.leftWallEdge.physicsBody.dynamic = NO;
    
    [self addChild:self.leftWallEdge];
}

- (void)createRightWallEdge
{
    self.rightWallEdge = [SKSpriteNode spriteNodeWithImageNamed:self.edgeImageName];
        
    // Size & position
    if (self.edgeSize != 0.0) [self.rightWallEdge setScale:self.edgeSize/self.rightWallEdge.size.width];
    self.rightWallEdge.position = CGPointMake(self.gapXPosition + self.gapSize/2.0 + self.leftWallEdge.size.width/2.0, 0.0);
    
    // Color
    self.rightWallEdge.colorBlendFactor = 1.0;
    self.rightWallEdge.color = self.color;
    
    // Physics
    self.rightWallEdge.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:self.rightWallEdge.size.width/2.0];
    self.rightWallEdge.physicsBody.dynamic = NO;
    
    [self addChild:self.rightWallEdge];
}

- (void)createLeftWall
{
    // Shape
    CGRect leftWallRect = CGRectMake(0.0,
                                     -self.leftWallEdge.size.height*(WALL_EDGE_PROPORTION/2.0),
                                     self.leftWallEdge.position.x - self.leftWallEdge.size.width/3.0,
                                     self.leftWallEdge.size.height*WALL_EDGE_PROPORTION);
    self.leftWall = [SKShapeNode shapeNodeWithRect:leftWallRect];
    
    // Color
    self.leftWall.strokeColor = self.color;
    self.leftWall.fillColor = self.color;
    
    // Physics
    self.leftWall.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:leftWallRect.size
                                                                center:CGPointMake(CGRectGetMidX(leftWallRect), CGRectGetMidY(leftWallRect))];
    self.leftWall.physicsBody.dynamic = NO;
    
    [self addChild:self.leftWall];
}

- (void)createRightWall
{
    // Shape
    CGRect rightWallRect = CGRectMake(self.rightWallEdge.position.x + self.rightWallEdge.size.width/3.0,
                                      -self.rightWallEdge.size.height*(WALL_EDGE_PROPORTION/2.0),
                                      self.width - self.rightWallEdge.position.x - self.rightWallEdge.size.width/3.0,
                                      self.rightWallEdge.size.height*WALL_EDGE_PROPORTION);
    self.rightWall = [SKShapeNode shapeNodeWithRect:rightWallRect];
    
    // Color
    self.rightWall.strokeColor = self.color;
    self.rightWall.fillColor = self.color;
    
    // Physics
    self.rightWall.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:rightWallRect.size
                                                                 center:CGPointMake(CGRectGetMidX(rightWallRect), CGRectGetMidY(rightWallRect))];
    self.rightWall.physicsBody.dynamic = NO;
    
    [self addChild:self.rightWall];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"Position: %f, %f; Gap: %f", self.position.x, self.position.y, self.gapXPosition];
}

@end
