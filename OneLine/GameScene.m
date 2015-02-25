//
//  GameScene.m
//  OneLine
//
//  Created by Natxo Raga on 09/02/15.
//  Copyright (c) 2015 Ignacio Raga Llorens. All rights reserved.
//

#import "GameScene.h"
#import "Wall.h"


@interface GameScene()
@property SKSpriteNode* player;
@property SKAction* moveAndRemoveWall;
@end


@implementation GameScene

-(void)didMoveToView:(SKView *)view
{
    self.physicsWorld.gravity = CGVectorMake(0.0, 0.0);
    
    self.backgroundColor = [SKColor blackColor];
    
    [self initPlayer];
    [self initWalls];
}

static NSString *const PLAYER_SPRITE_IMAGE = @"Player.png";

-(void)initPlayer
{
    self.player = [SKSpriteNode spriteNodeWithImageNamed:PLAYER_SPRITE_IMAGE];
    
    // Scale and position
    self.player.position = CGPointMake(CGRectGetMidX(self.frame),
                                       self.frame.origin.y + self.frame.size.height/3.0);
    //[self.player setScale:0.5];
    
    // Physics
    SKPhysicsBody *playerPhysics = [SKPhysicsBody bodyWithCircleOfRadius:self.player.size.width/2.0];
    self.player.physicsBody = playerPhysics;
    
    [self addChild:self.player];
}

static const CGFloat WALL_HEIGHT = 32.0;
static const CGFloat WALL_SPEED = 300.0;
static const CGFloat DELAY_BETWEEN_WALLS = 2.0;

- (void)initWalls
{
    CGFloat distanceToMove = self.frame.size.height + WALL_HEIGHT*4.0;
    SKAction *moveWall = [SKAction repeatActionForever:[SKAction moveByX:0.0
                                                                       y:-distanceToMove
                                                                duration:distanceToMove/WALL_SPEED]];
    SKAction *removeWall = [SKAction removeFromParent];
    self.moveAndRemoveWall = [SKAction sequence:@[moveWall, removeWall]];
    
    // Spawning
    SKAction *spawnWall = [SKAction performSelector:@selector(spawnWall) onTarget:self];
    SKAction *delay = [SKAction waitForDuration:DELAY_BETWEEN_WALLS];
    SKAction *spawnThenDelay = [SKAction sequence:@[spawnWall, delay]];
    SKAction *spawnThenDelayForever = [SKAction repeatActionForever:spawnThenDelay];
    [self runAction:spawnThenDelayForever];
}

static NSString *const WALL_SPRITE_IMAGE = @"Player.png";
static const CGFloat WALL_GAP_SIZE = 100.0;
static const CGFloat WALL_GAP_BORDER_OFFSET = 150.0;
static const CGFloat WALL_GAP_LIMIT_OFFSET = 16.0;

- (void)spawnWall
{
    Wall *wall = [[Wall alloc] init];
    
    wall.position = CGPointMake(0.0, self.frame.size.height);
    wall.width = self.frame.size.width;
    
    wall.edgeImageName = WALL_SPRITE_IMAGE;
    
    NSInteger gapMax = self.frame.size.width - WALL_GAP_BORDER_OFFSET*2.0;
    wall.gapXPosition = (arc4random() % gapMax) + WALL_GAP_BORDER_OFFSET;
    
    wall.gapSize = WALL_GAP_SIZE;
    
    wall.color = [SKColor whiteColor];
    
    [wall createWall];
    
    [wall runAction:self.moveAndRemoveWall];
    [self addChild:wall];
}

/*-(void)spawnWall
{
    SKNode *wall = [SKNode node];
    wall.position = CGPointMake(0.0, self.frame.size.height + WALL_HEIGHT*2.0);
    
    NSInteger gapMax = self.frame.size.width - WALL_GAP_BORDER_OFFSET*2.0;
    CGFloat gapXPosition = (arc4random() % gapMax) + WALL_GAP_BORDER_OFFSET;
    
    // Left wall
    SKSpriteNode *leftWallLimit = [SKSpriteNode spriteNodeWithImageNamed:WALL_SPRITE_IMAGE];
    leftWallLimit.position = CGPointMake(gapXPosition - WALL_GAP_SIZE/2.0, 0.0);
    leftWallLimit.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:leftWallLimit.size.width/2.0];
    leftWallLimit.physicsBody.dynamic = NO;
    [wall addChild:leftWallLimit];
    
    CGRect leftWallRect = CGRectMake(self.frame.origin.x,
                                     -WALL_HEIGHT/4.0,
                                     leftWallLimit.position.x - WALL_GAP_LIMIT_OFFSET - self.frame.origin.x,
                                     WALL_HEIGHT/2.0);
    SKShapeNode *leftWall = [SKShapeNode shapeNodeWithRect:leftWallRect];
    leftWall.strokeColor = [UIColor whiteColor];
    leftWall.fillColor = [UIColor whiteColor];
    leftWall.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:leftWallRect.size
                                                           center:CGPointMake(CGRectGetMidX(leftWallRect), CGRectGetMidY(leftWallRect))];
    leftWall.physicsBody.dynamic = NO;
    [wall addChild:leftWall];
    
    // Right wall
    SKSpriteNode *rightWallLimit = [SKSpriteNode spriteNodeWithImageNamed:WALL_SPRITE_IMAGE];
    rightWallLimit.position = CGPointMake(gapXPosition + WALL_GAP_SIZE/2.0, 0.0);
    rightWallLimit.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:rightWallLimit.size.width/2.0];
    rightWallLimit.physicsBody.dynamic = NO;
    [wall addChild:rightWallLimit];
    
    CGRect rightWallRect = CGRectMake(rightWallLimit.position.x + WALL_GAP_LIMIT_OFFSET,
                                      -WALL_HEIGHT/4.0,
                                      self.frame.size.width - (rightWallLimit.position.x + WALL_GAP_LIMIT_OFFSET),
                                      WALL_HEIGHT/2.0);
    SKShapeNode *rightWall = [SKShapeNode shapeNodeWithRect:rightWallRect];
    rightWall.strokeColor = [UIColor whiteColor];
    rightWall.fillColor = [UIColor whiteColor];
    rightWall.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:rightWallRect.size
                                                            center:CGPointMake(CGRectGetMidX(rightWallRect), CGRectGetMidY(rightWallRect))];
    rightWall.physicsBody.dynamic = NO;
    [wall addChild:rightWall];

    [wall runAction:self.moveAndRemoveWall];
    
    [self addChild:wall];
}*/

static const CGFloat PLAYER_INITIAL_VELOCITY = 400.0;

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint location = [[touches anyObject] locationInNode:self];
    
    if (location.x < CGRectGetMidX(self.frame)) {
        self.player.physicsBody.velocity = CGVectorMake(-PLAYER_INITIAL_VELOCITY, 0.0);
    }
    else if (location.x > CGRectGetMidX(self.frame)) {
        self.player.physicsBody.velocity = CGVectorMake(PLAYER_INITIAL_VELOCITY, 0.0);
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.player.physicsBody.velocity = CGVectorMake(0.0, 0.0);
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end
