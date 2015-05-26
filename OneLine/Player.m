//
//  Player.m
//  OneLine
//
//  Created by Natxo Raga on 25/02/15.
//  Copyright (c) 2015 Ignacio Raga Llorens. All rights reserved.
//

#import "Player.h"


@interface Player()
@property (strong, nonatomic) NSString *whiteImageName;
@property (strong, nonatomic) NSString *blackImageName;
@property (strong, nonatomic) NSString *redImageName;
@property (strong, nonatomic) SKSpriteNode *body;
@property (strong, nonatomic) SKShapeNode *path;
@property (strong, nonatomic) NSMutableArray *pathPoints;
@end


@implementation Player

#pragma mark - Initialization

NSString *const PLAYER_NODE_NAME = @"PLAYER_NODE";

static NSString *const PLAYER_SPRITE_WHITE_IMAGE_SUFFIX = @"-White";
static NSString *const PLAYER_SPRITE_BLACK_IMAGE_SUFFIX = @"-Black";
static NSString *const PLAYER_SPRITE_RED_IMAGE_SUFFIX = @"-Red";
static NSString *const PLAYER_SPRITE_IMAGE_EXTENSION = @".png";

- (instancetype)initWithImageNamed:(NSString *)imageName
{
    if (self = [super init]) {
        self.name = PLAYER_NODE_NAME;
        self.whiteImageName = [NSString stringWithFormat:@"%@%@%@", imageName, PLAYER_SPRITE_WHITE_IMAGE_SUFFIX, PLAYER_SPRITE_IMAGE_EXTENSION];
        self.blackImageName = [NSString stringWithFormat:@"%@%@%@", imageName, PLAYER_SPRITE_BLACK_IMAGE_SUFFIX, PLAYER_SPRITE_IMAGE_EXTENSION];
        self.redImageName = [NSString stringWithFormat:@"%@%@%@", imageName, PLAYER_SPRITE_RED_IMAGE_SUFFIX, PLAYER_SPRITE_IMAGE_EXTENSION];
        self.color = [SKColor whiteColor];
        
        [self setupBody];
    }
    return self;
}

- (void)setupBody
{
    self.body = [SKSpriteNode spriteNodeWithImageNamed:self.whiteImageName];
    [self addChild:self.body];
    
    [self setupBodyPhysics];
}

- (void)setupBodyPhysics
{
    SKPhysicsBody *bodyPhysics = [SKPhysicsBody bodyWithCircleOfRadius:self.body.size.width/2.0];
    self.body.physicsBody = bodyPhysics;
}


#pragma mark - Getters & setters

- (void)setPosition:(CGPoint)newPosition
{
    self.body.physicsBody = nil;
    
    //NSLog(@"Before: %f, %f; %f, %f", self.position.x, self.position.y, self.body.position.x, self.body.position.y);
    [super setPosition:newPosition];
    self.body.position = CGPointZero;
    //NSLog(@"After: %f, %f; %f, %f", self.position.x, self.position.y, self.body.position.x, self.body.position.y);

    // Body physics
    [self setupBodyPhysics];
    
    // Restart path
    [self.pathPoints removeAllObjects];
    [self.pathPoints addObject:[NSValue valueWithCGPoint:CGPointMake(self.body.position.x, -self.position.y)]];
}

- (void)setColor:(SKColor *)newColor
{
    _color = newColor;
    
    if ([newColor isEqual:[SKColor whiteColor]]) self.body.texture = [SKTexture textureWithImageNamed:self.whiteImageName];
    if ([newColor isEqual:[SKColor blackColor]]) self.body.texture = [SKTexture textureWithImageNamed:self.blackImageName];
}

- (void)setRedColorToBody
{
    self.body.texture = [SKTexture textureWithImageNamed:self.redImageName];
    
    // TODO: STOP PATH
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


#pragma mark - Collision handling

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


#pragma mark - Player path

- (NSMutableArray *)pathPoints
{
    if (!_pathPoints) {
        _pathPoints = [NSMutableArray array];
    }
    return _pathPoints;
}

static const CGFloat BODY_PATH_PROPORTION = 1.0/3.0;

- (void)computePath:(CGFloat)distanceMoved
{
    [self computePathPoints:distanceMoved];
    
    CGMutablePathRef pathToDraw = CGPathCreateMutable();
    CGPathMoveToPoint(pathToDraw, NULL, self.body.position.x, self.body.position.y - distanceMoved);
    
    for (NSInteger i = self.pathPoints.count - 1; i >= 0; i--) {
        CGPoint point = [self.pathPoints[i] CGPointValue];
        CGPathAddLineToPoint(pathToDraw, NULL, point.x, point.y);
    }
    
    [self.path removeFromParent];
    self.path = [SKShapeNode shapeNodeWithPath:pathToDraw];
    self.path.strokeColor = self.color;
    self.path.lineWidth = self.realSize*BODY_PATH_PROPORTION;
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

@end
