//
//  Wall.m
//  OneLine
//
//  Created by Natxo Raga on 24/02/15.
//  Copyright (c) 2015 Ignacio Raga Llorens. All rights reserved.
//

#import "Wall.h"


@interface Wall()
@property (strong, nonatomic) SKSpriteNode* leftWallEdge;
@property (strong, nonatomic) SKShapeNode* leftWall;
@property (strong, nonatomic) SKSpriteNode* rightWallEdge;
@property (strong, nonatomic) SKShapeNode* rightWall;
@end


@implementation Wall

- (instancetype)init
{
    if (self = [super init]) {
        // Initialization
        //[self addChild:self.leftWallEdge];
        //[self addChild:self.leftWall];
        //[self addChild:self.rightWallEdge];
        //[self addChild:self.rightWall];
    }
    return self;
}

- (CGFloat)height
{
    if (self.leftWallEdge.size.height > self.rightWallEdge.size.height) return self.leftWallEdge.size.height;
    else return self.rightWallEdge.size.height;
}

static const CGFloat WALL_EDGE_PROPORTION = 1.0/3.0;

- (void)createWall
{
    // Left wall edge
    self.leftWallEdge = [SKSpriteNode spriteNodeWithImageNamed:self.edgeImageName];
    if (self.edgeSize != 0.0) [self.leftWallEdge setScale:self.edgeSize/self.leftWallEdge.size.width];
    self.leftWallEdge.position = CGPointMake(self.gapXPosition - self.gapSize/2.0 - self.leftWallEdge.size.width/2.0, 0.0);
    self.leftWallEdge.colorBlendFactor = 1.0;
    self.leftWallEdge.color = self.color;
    self.leftWallEdge.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:self.leftWallEdge.size.width/2.0];
    self.leftWallEdge.physicsBody.dynamic = NO;
    
    // Left wall
    CGRect leftWallRect = CGRectMake(0.0,
                                     -self.leftWallEdge.size.height*(WALL_EDGE_PROPORTION/2.0),
                                     self.leftWallEdge.position.x - self.leftWallEdge.size.width/3.0,
                                     self.leftWallEdge.size.height*WALL_EDGE_PROPORTION);
    self.leftWall = [SKShapeNode shapeNodeWithRect:leftWallRect];
    self.leftWall.strokeColor = self.color;
    self.leftWall.fillColor = self.color;
    self.leftWall.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:leftWallRect.size
                                                                center:CGPointMake(CGRectGetMidX(leftWallRect), CGRectGetMidY(leftWallRect))];
    self.leftWall.physicsBody.dynamic = NO;
    
    // Right wall edge
    self.rightWallEdge = [SKSpriteNode spriteNodeWithImageNamed:self.edgeImageName];
    if (self.edgeSize != 0.0) [self.rightWallEdge setScale:self.edgeSize/self.rightWallEdge.size.width];
    self.rightWallEdge.position = CGPointMake(self.gapXPosition + self.gapSize/2.0 + self.leftWallEdge.size.width/2.0, 0.0);
    self.rightWallEdge.colorBlendFactor = 1.0;
    self.rightWallEdge.color = self.color;
    self.rightWallEdge.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:self.rightWallEdge.size.width/2.0];
    self.rightWallEdge.physicsBody.dynamic = NO;
    
    // Right wall
    CGRect rightWallRect = CGRectMake(self.rightWallEdge.position.x + self.rightWallEdge.size.width/3.0,
                                      -self.rightWallEdge.size.height*(WALL_EDGE_PROPORTION/2.0),
                                      self.width - self.rightWallEdge.position.x - self.rightWallEdge.size.width/3.0,
                                      self.rightWallEdge.size.height*WALL_EDGE_PROPORTION);
    self.rightWall = [SKShapeNode shapeNodeWithRect:rightWallRect];
    self.rightWall.strokeColor = self.color;
    self.rightWall.fillColor = self.color;
    self.rightWall.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:rightWallRect.size
                                                                 center:CGPointMake(CGRectGetMidX(rightWallRect), CGRectGetMidY(rightWallRect))];
    self.rightWall.physicsBody.dynamic = NO;
    
    
    [self addChild:self.leftWallEdge];
    [self addChild:self.leftWall];
    [self addChild:self.rightWallEdge];
    [self addChild:self.rightWall];
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



@end
