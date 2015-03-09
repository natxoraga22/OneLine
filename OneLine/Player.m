//
//  Player.m
//  OneLine
//
//  Created by Natxo Raga on 25/02/15.
//  Copyright (c) 2015 Ignacio Raga Llorens. All rights reserved.
//

#import "Player.h"


@interface Player()
@property (strong, nonatomic) SKSpriteNode *body;
@property (strong, nonatomic) SKShapeNode *path;
@property (strong, nonatomic) NSMutableArray *pathPoints;
@end


@implementation Player

#pragma mark - Initialization

NSString *const PLAYER_NODE_NAME = @"PLAYER_NODE";

- (instancetype)initWithImageNamed:(NSString *)imageName
{
    if (self = [super init]) {
        self.name = PLAYER_NODE_NAME;
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


#pragma mark - Player path

- (NSMutableArray *)pathPoints
{
    if (!_pathPoints) {
        _pathPoints = [NSMutableArray array];
    }
    return _pathPoints;
}

- (void)computePath:(CGFloat)distanceMoved
{
    [self computePathPoints:distanceMoved];
    
    CGMutablePathRef pathToDraw = CGPathCreateMutable();
    CGPoint pathStartPosition = [self pathStartPosition];
    CGPathMoveToPoint(pathToDraw, NULL, pathStartPosition.x, pathStartPosition.y - distanceMoved);
    
    for (NSInteger i = self.pathPoints.count - 1; i >= 0; i--) {
        CGPoint point = [self.pathPoints[i] CGPointValue];
        CGPathAddLineToPoint(pathToDraw, NULL, point.x, point.y);
    }
    
    [self.path removeFromParent];
    self.path = [SKShapeNode shapeNodeWithPath:pathToDraw];
    self.path.strokeColor = self.color;
    self.path.lineWidth = self.realSize/3.0;
    [self addChild:self.path];
}


- (void)computePathPoints:(CGFloat)distanceMoved
{
    // "Add" the velocity to each point
    for (NSInteger i = 0; i < self.pathPoints.count; i++) {
        CGPoint point = [self.pathPoints[i] CGPointValue];
        point.y -= distanceMoved;
        self.pathPoints[i] = [NSValue valueWithCGPoint:point];
    }
    
    // Remove all the points we don't need anymore
    NSInteger indexToRemove = -1;
    for (NSInteger i = 0; i < self.pathPoints.count; i++) {
        CGPoint point = [self.pathPoints[i] CGPointValue];
        if (point.y < -self.position.y) {
            indexToRemove = i;
        }
    }
    for (NSInteger i = 0; i < indexToRemove; i++) [self.pathPoints removeObjectAtIndex:i];
}

- (CGPoint)pathStartPosition
{
    CGFloat offset = self.realSize/4.0;
    CGFloat xOffset = cosf(45.0*M_PI/180.0)*offset;
    CGFloat yOffset = sinf(45.0*M_PI/180.0)*offset;
    
    // Going up-right
    if (self.velocity.dx > 0) return CGPointMake(self.body.position.x - xOffset, self.body.position.y - yOffset);
    // Going up-left
    if (self.velocity.dx < 0) return CGPointMake(self.body.position.x + xOffset, self.body.position.y - yOffset);
    // Going up
    return CGPointMake(self.body.position.x, self.body.position.y - offset);
}


#pragma mark - Getters & setters

- (void)setPosition:(CGPoint)newPosition
{
    [super setPosition:newPosition];
    
    // Restart path
    [self.pathPoints removeAllObjects];
    [self.pathPoints addObject:[NSValue valueWithCGPoint:CGPointMake(self.body.position.x, -self.position.y)]];
}

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
    
    // Add the actual position to the path (we are changing direction)
    [self.pathPoints addObject:[NSValue valueWithCGPoint:self.body.position]];
}

- (uint32_t)categoryBitMask
{
    return self.body.physicsBody.categoryBitMask;
}

- (uint32_t)collisionBitMask
{
    return self.body.physicsBody.collisionBitMask;
}

- (uint32_t)contactTestBitMask
{
    return self.body.physicsBody.contactTestBitMask;
}

@end
