//
//  Wall.m
//  OneLine
//
//  Created by Natxo Raga on 24/02/15.
//  Copyright (c) 2015 Ignacio Raga Llorens. All rights reserved.
//

#import "Wall.h"


@interface Wall()
@property (strong, nonatomic, readonly) NSString *whiteImageName;
@property (strong, nonatomic, readonly) NSString *blackImageName;
@property (strong, nonatomic, readonly) NSString *redWhiteImageName;
@property (strong, nonatomic, readonly) NSString *redBlackImageName;
@property (strong, nonatomic) SKSpriteNode *leftWallEdge;
@property (strong, nonatomic) SKShapeNode *leftWall;
@property (strong, nonatomic) SKSpriteNode *rightWallEdge;
@property (strong, nonatomic) SKShapeNode *rightWall;
@end


@implementation Wall

#pragma mark - Initialization

NSString *const WALL_NODE_NAME = @"WALL_NODE";

- (instancetype)init
{
    if (self = [super init]) {
        self.name = WALL_NODE_NAME;
    }
    return self;
}


#pragma mark - Getters & setters

static NSString *const WALL_SPRITE_WHITE_IMAGE_SUFFIX = @"-White";
static NSString *const WALL_SPRITE_BLACK_IMAGE_SUFFIX = @"-Black";
static NSString *const WALL_SPRITE_REDWHITE_IMAGE_SUFFIX = @"-RedWhite";
static NSString *const WALL_SPRITE_REDBLACK_IMAGE_SUFFIX = @"-RedBlack";
static NSString *const WALL_SPRITE_IMAGE_EXTENSION = @".png";

- (NSString *)whiteImageName
{
    return [NSString stringWithFormat:@"%@%@%@", self.edgeImageName, WALL_SPRITE_WHITE_IMAGE_SUFFIX, WALL_SPRITE_IMAGE_EXTENSION];
}

- (NSString *)blackImageName
{
    return [NSString stringWithFormat:@"%@%@%@", self.edgeImageName, WALL_SPRITE_BLACK_IMAGE_SUFFIX, WALL_SPRITE_IMAGE_EXTENSION];
}

- (NSString *)redWhiteImageName
{
    return [NSString stringWithFormat:@"%@%@%@", self.edgeImageName, WALL_SPRITE_REDWHITE_IMAGE_SUFFIX, WALL_SPRITE_IMAGE_EXTENSION];
}

- (NSString *)redBlackImageName
{
    return [NSString stringWithFormat:@"%@%@%@", self.edgeImageName, WALL_SPRITE_REDBLACK_IMAGE_SUFFIX, WALL_SPRITE_IMAGE_EXTENSION];
}

- (CGFloat)height
{
    if (self.leftWallEdge.size.height > self.rightWallEdge.size.height) return self.leftWallEdge.size.height;
    else return self.rightWallEdge.size.height;
}

- (void)setColor:(SKColor *)newColor
{
    _color = newColor;
    
    if ([newColor isEqual:[SKColor whiteColor]]) {
        self.leftWallEdge.texture = [SKTexture textureWithImageNamed:self.whiteImageName];
        self.rightWallEdge.texture = [SKTexture textureWithImageNamed:self.whiteImageName];
    }
    if ([newColor isEqual:[SKColor blackColor]]) {
        self.leftWallEdge.texture = [SKTexture textureWithImageNamed:self.blackImageName];
        self.rightWallEdge.texture = [SKTexture textureWithImageNamed:self.blackImageName];
    }
    self.leftWall.strokeColor = newColor;
    self.leftWall.fillColor = newColor;
    self.rightWall.strokeColor = newColor;
    self.rightWall.fillColor = newColor;
}

- (void)setRedColorToElementWithName:(NSString *)name
{
    SKNode *element;
    for (SKNode *child in self.children) {
        if ([child.name isEqualToString:name]) element = child;
    }
    
    if ([name isEqualToString:LEFT_WALL_EDGE_NODE_NAME] || [name isEqualToString:RIGHT_WALL_EDGE_NODE_NAME]) {
        SKSpriteNode *edgeElement = (SKSpriteNode *)element;
        if ([self.color isEqual:[SKColor whiteColor]]) edgeElement.texture = [SKTexture textureWithImageNamed:self.redBlackImageName];
        if ([self.color isEqual:[SKColor blackColor]]) edgeElement.texture = [SKTexture textureWithImageNamed:self.redWhiteImageName];
    }
    else if ([name isEqualToString:LEFT_WALL_NODE_NAME] || [name isEqualToString:RIGHT_WALL_NODE_NAME]) {
        SKShapeNode *wallElement = (SKShapeNode *)element;
        wallElement.strokeColor = [SKColor redColor];
        wallElement.fillColor = [SKColor redColor];
    }
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

static NSString *const LEFT_WALL_EDGE_NODE_NAME = @"LEFT_WALL_EDGE_NODE";
static NSString *const RIGHT_WALL_EDGE_NODE_NAME = @"RIGHT_WALL_EDGE_NODE";
static NSString *const LEFT_WALL_NODE_NAME = @"LEFT_WALL_NODE";
static NSString *const RIGHT_WALL_NODE_NAME = @"RIGHT_WALL_NODE";

- (void)createLeftWallEdge
{
    if ([self.color isEqual:[SKColor whiteColor]]) self.leftWallEdge = [SKSpriteNode spriteNodeWithImageNamed:self.whiteImageName];
    if ([self.color isEqual:[SKColor blackColor]]) self.leftWallEdge = [SKSpriteNode spriteNodeWithImageNamed:self.blackImageName];
    self.leftWallEdge.name = LEFT_WALL_EDGE_NODE_NAME;
    
    // Size & position
    if (self.edgeSize != 0.0) [self.leftWallEdge setScale:self.edgeSize/self.leftWallEdge.size.width];
    self.leftWallEdge.position = CGPointMake(self.gapXPosition - self.gapSize/2.0 - self.leftWallEdge.size.width/2.0, 0.0);
    
    // Physics
    self.leftWallEdge.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:self.leftWallEdge.size.width/2.0];
    self.leftWallEdge.physicsBody.dynamic = NO;
    
    self.leftWallEdge.physicsBody.categoryBitMask = self.categoryBitMask;
    self.leftWallEdge.physicsBody.collisionBitMask = self.collisionBitMask;
    self.leftWallEdge.physicsBody.contactTestBitMask = self.contactTestBitMask;
    
    [self addChild:self.leftWallEdge];
}

- (void)createRightWallEdge
{
    if ([self.color isEqual:[SKColor whiteColor]]) self.rightWallEdge = [SKSpriteNode spriteNodeWithImageNamed:self.whiteImageName];
    if ([self.color isEqual:[SKColor blackColor]]) self.rightWallEdge = [SKSpriteNode spriteNodeWithImageNamed:self.blackImageName];
    self.rightWallEdge.name = RIGHT_WALL_EDGE_NODE_NAME;
    
    // Size & position
    if (self.edgeSize != 0.0) [self.rightWallEdge setScale:self.edgeSize/self.rightWallEdge.size.width];
    self.rightWallEdge.position = CGPointMake(self.gapXPosition + self.gapSize/2.0 + self.leftWallEdge.size.width/2.0, 0.0);
    
    // Physics
    self.rightWallEdge.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:self.rightWallEdge.size.width/2.0];
    self.rightWallEdge.physicsBody.dynamic = NO;
    
    self.rightWallEdge.physicsBody.categoryBitMask = self.categoryBitMask;
    self.rightWallEdge.physicsBody.collisionBitMask = self.collisionBitMask;
    self.rightWallEdge.physicsBody.contactTestBitMask = self.contactTestBitMask;
    
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
    self.leftWall.name = LEFT_WALL_NODE_NAME;
    
    // Color
    self.leftWall.strokeColor = self.color;
    self.leftWall.fillColor = self.color;
    
    // Physics
    self.leftWall.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:leftWallRect.size
                                                                center:CGPointMake(CGRectGetMidX(leftWallRect), CGRectGetMidY(leftWallRect))];
    self.leftWall.physicsBody.dynamic = NO;
    
    self.leftWall.physicsBody.categoryBitMask = self.categoryBitMask;
    self.leftWall.physicsBody.collisionBitMask = self.collisionBitMask;
    self.leftWall.physicsBody.contactTestBitMask = self.contactTestBitMask;
    
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
    self.rightWall.name = RIGHT_WALL_NODE_NAME;
    
    // Color
    self.rightWall.strokeColor = self.color;
    self.rightWall.fillColor = self.color;
    
    // Physics
    self.rightWall.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:rightWallRect.size
                                                                 center:CGPointMake(CGRectGetMidX(rightWallRect), CGRectGetMidY(rightWallRect))];
    self.rightWall.physicsBody.dynamic = NO;
    
    self.rightWall.physicsBody.categoryBitMask = self.categoryBitMask;
    self.rightWall.physicsBody.collisionBitMask = self.collisionBitMask;
    self.rightWall.physicsBody.contactTestBitMask = self.contactTestBitMask;
    
    [self addChild:self.rightWall];
}


#pragma mark - Utility

- (NSString *)description
{
    return [NSString stringWithFormat:@"Position: %f, %f; Gap: %f", self.position.x, self.position.y, self.gapXPosition];
}

@end
