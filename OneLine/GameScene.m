//
//  GameScene.m
//  OneLine
//
//  Created by Natxo Raga on 09/02/15.
//  Copyright (c) 2015 Ignacio Raga Llorens. All rights reserved.
//

#import "GameScene.h"
#import "Wall.h"
#import "Player.h"


@interface GameScene() <SKPhysicsContactDelegate>
@property (strong, nonatomic) Player* player;
@property (strong, nonatomic) SKAction* moveAndRemoveWall;
@end


@implementation GameScene

-(void)didMoveToView:(SKView *)view
{
    self.physicsWorld.gravity = CGVectorMake(0.0, 0.0);
    self.physicsWorld.contactDelegate = self;
    
    self.backgroundColor = [SKColor blackColor];
    
    [self initPlayer];
    [self initWalls];
}

static NSString *const PLAYER_SPRITE_IMAGE = @"Player.png";

static const uint32_t playerCategory = 1 << 0;
static const uint32_t wallsCategory = 1 << 1;
static const uint32_t collectableCategory = 1 << 2;

-(void)initPlayer
{
    self.player = [[Player alloc] initWithImageNamed:PLAYER_SPRITE_IMAGE];
    
    // Scale and position
    self.player.position = CGPointMake(CGRectGetMidX(self.frame),
                                       self.frame.origin.y + self.frame.size.height/3.0);
    self.player.realSize = 32.0;
    
    self.player.physicsBody.categoryBitMask = playerCategory;
    self.player.physicsBody.collisionBitMask = wallsCategory | collectableCategory;
    self.player.physicsBody.contactTestBitMask = wallsCategory | collectableCategory;
    
    [self addChild:self.player];
}

static const CGFloat WALL_HEIGHT = 32.0;
static const CGFloat WALL_SPEED = 150.0;
static const CGFloat DELAY_BETWEEN_WALLS = 2.0;

- (void)initWalls
{
    CGFloat distanceToMove = self.frame.size.height + WALL_HEIGHT*2.0;
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
static const CGFloat WALL_GAP_SIZE = 50.0;
static const CGFloat WALL_GAP_BORDER_OFFSET = 75.0;
//static const CGFloat WALL_GAP_LIMIT_OFFSET = 16.0;

- (void)spawnWall
{
    Wall *wall = [[Wall alloc] init];
    
    // Wall parameters
    wall.position = CGPointMake(0.0, self.frame.size.height + WALL_HEIGHT);
    wall.width = self.frame.size.width;
    wall.edgeImageName = WALL_SPRITE_IMAGE;
    wall.edgeSize = 32.0;
    NSInteger gapMax = self.frame.size.width - WALL_GAP_BORDER_OFFSET*2.0;
    NSInteger gapXPosition = (arc4random() % gapMax) + WALL_GAP_BORDER_OFFSET;
    wall.gapXPosition = gapXPosition;
    wall.gapSize = WALL_GAP_SIZE;
    wall.color = [SKColor whiteColor];
    
    // Wall creation (with previous specified parameters)
    [wall createWall];
    
    [wall runAction:self.moveAndRemoveWall];
    [self addChild:wall];
    
    // Invisible collectable
    SKShapeNode *invisibleCollectable = [SKShapeNode shapeNodeWithCircleOfRadius:10.0];
    invisibleCollectable.position = CGPointMake(gapXPosition, self.frame.size.height + WALL_HEIGHT);
    invisibleCollectable.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:10.0];
    
    [invisibleCollectable runAction:self.moveAndRemoveWall];
    [self addChild:invisibleCollectable];
}

static const CGFloat PLAYER_INITIAL_VELOCITY = 200.0;

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

- (void)didBeginContact:(SKPhysicsContact *)contact
{
    // COLLISION!
    // If collision with "collectible object", increment points and change color of everything
    // If collision with anything else, lose the game
    
    NSLog(@"COLLISION DETECTED");
    
    NSLog(@"%@", self.player.color);
    NSLog(@"%@", [SKColor whiteColor]);
    NSLog(@"%@", [UIColor whiteColor]);

    CGFloat red = 0.0, green = 0.0, blue = 0.0;
    [self.player.color getRed:&red green:&green blue:&blue alpha:nil];
    
    if (red == 1.0 && green == 1.0 && blue == 1.0) {
        // PLAYER/WALLS BLACK, BACKGROUND WHITE
        self.backgroundColor = [SKColor whiteColor];
        self.player.color = [SKColor blackColor];
        for (SKNode *child in self.children) {
            if ([child isKindOfClass:[Wall class]]) ((Wall*)child).color = [SKColor blackColor];
        }
    }
    else {
        // PLAYER/WALLS WHITE, BACKGROUND BLACK
        self.backgroundColor = [SKColor blackColor];
        self.player.color = [SKColor whiteColor];
        for (SKNode *child in self.children) {
            if ([child isKindOfClass:[Wall class]]) ((Wall*)child).color = [SKColor whiteColor];
        }
    }
    
}

@end
