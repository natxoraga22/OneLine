//
//  GameScene.m
//  OneLine
//
//  Created by Natxo Raga on 09/02/15.
//  Copyright (c) 2015 Ignacio Raga Llorens. All rights reserved.
//

#import "GameScene.h"
#import "GameParameters.h"
#import "Wall.h"
#import "Player.h"


@interface GameScene() <SKPhysicsContactDelegate>
@property (nonatomic) NSTimeInterval lastCurrentTime;
@property (nonatomic, readonly) CGFloat wallStartingYPosition;
@property (nonatomic, readonly) CGFloat randomGapXPosition;
// Game elements
@property (strong, nonatomic) Player *player;
@property (strong, nonatomic) NSMutableArray *walls;
// Wall actions
@property (strong, nonatomic) SKAction *moveThenRestartWall;
@property (strong, nonatomic) SKAction *moveThenRemoveCollectable;
@end


@implementation GameScene

// Collision masks
static const uint32_t playerCategory = 1 << 0;
static const uint32_t wallsCategory = 1 << 1;
static const uint32_t collectableCategory = 1 << 2;


#pragma mark - Scene lifecycle

- (void)didMoveToView:(SKView *)view
{
    self.physicsWorld.gravity = CGVectorMake(0.0, 0.0);
    self.physicsWorld.contactDelegate = self;
    self.backgroundColor = [SKColor blackColor];
    
    self.player.color = [SKColor whiteColor];
    //[self initWallSpawning];
}

- (void)initWallSpawning
{
    // Spawn a new wall each X seconds
    SKAction *spawnWall = [SKAction performSelector:@selector(spawnWall) onTarget:self];
    SKAction *delay = [SKAction waitForDuration:DELAY_BETWEEN_WALLS];
    SKAction *spawnThenDelay = [SKAction sequence:@[spawnWall, delay]];
    [self runAction:[SKAction repeatActionForever:spawnThenDelay]];
}


#pragma mark - Getters & setters

- (CGFloat)wallStartingYPosition
{
    return self.size.height + WALL_HEIGHT;
}

- (CGFloat)randomGapXPosition
{
    NSInteger gapMax = self.size.width - WALL_GAP_BORDER_OFFSET*2.0;
    return (arc4random()%gapMax) + WALL_GAP_BORDER_OFFSET;
}


#pragma mark - Game elements creation

static NSString *const PLAYER_SPRITE_IMAGE = @"Player.png";
static const CGFloat PLAYER_SIZE = 32.0;

- (Player *)player
{
    if (!_player) {
        _player = [[Player alloc] initWithImageNamed:PLAYER_SPRITE_IMAGE];
        
        // Scale and position
        _player.position = CGPointMake(self.position.x + self.size.width/2.0,
                                           self.position.y + self.size.height/3.0);
        _player.realSize = PLAYER_SIZE;
        
        // Collision masks
        _player.categoryBitMask = playerCategory;
        _player.collisionBitMask = wallsCategory | collectableCategory;
        _player.contactTestBitMask = wallsCategory | collectableCategory;

        [self addChild:_player];
    }
    return _player;
}

static const CGFloat WALL_HEIGHT = 32.0;

- (NSMutableArray *)walls
{
    if (!_walls) {
        _walls = [NSMutableArray array];
    }
    return _walls;
}

- (SKAction *)moveThenRestartWall
{
    if (!_moveThenRestartWall) {
        // Move wall down and restart it's position when it reaches the bottom
        CGFloat distanceToMove = self.size.height + WALL_HEIGHT*2.0;
        SKAction *moveWall = [SKAction moveByX:0.0 y:-distanceToMove duration:distanceToMove/WALL_SPEED];
        SKAction *restartWall = [SKAction customActionWithDuration:0.0
                                                       actionBlock:^(SKNode *node, CGFloat elapsedTime) {
                                                           Wall *wall = (Wall *)node;
                                                           [self restartWall:wall];
                                                       }];
        _moveThenRestartWall = [SKAction sequence:@[moveWall, restartWall]];
    }
    return _moveThenRestartWall;
}

- (void)restartWall:(Wall *)wall
{
    wall.position = CGPointMake(0.0, self.wallStartingYPosition);
    wall.gapXPosition = self.randomGapXPosition;
    [wall createWall];
}

- (SKAction *)moveThenRemoveCollectable
{
    if (!_moveThenRemoveCollectable) {
        // Move collectable down with the wall and remove it when it reaches the bottom
        CGFloat distanceToMove = self.size.height + WALL_HEIGHT*2.0;
        SKAction *moveCollectable = [SKAction moveByX:0.0 y:-distanceToMove duration:distanceToMove/WALL_SPEED];
        SKAction *removeCollectable = [SKAction removeFromParent];
        
        _moveThenRemoveCollectable = [SKAction sequence:@[moveCollectable, removeCollectable]];
    }
    return _moveThenRemoveCollectable;
}

- (void)update:(NSTimeInterval)currentTime
{
    NSTimeInterval deltaTime = currentTime - self.lastCurrentTime;
    
    CGFloat distanceMoved = WALL_SPEED*deltaTime;
    [self.player computePath:distanceMoved];
    
    self.lastCurrentTime = currentTime;
}


#pragma mark - Wall spawning

static NSString *const WALL_SPRITE_IMAGE = @"Player.png";
static CGFloat COLLECTABLE_RADIUS = 10.0;

- (void)spawnWall
{
    // Look for a wall to start moving down
    BOOL found = NO;
    for (Wall *wall in self.walls) {
        if (!found && wall.position.y == self.wallStartingYPosition) {
            found = YES;
            
            [wall runAction:self.moveThenRestartWall];
            [self spawnCollectableAtPosition:CGPointMake(wall.gapXPosition, wall.position.y)];
        }
    }
    // If there's no wall waiting, create a new one
    if (!found) {
        Wall *wall = [self wall];
        [self.walls addObject:wall];
        [self addChild:wall];
        
        [wall runAction:self.moveThenRestartWall];
        [self spawnCollectableAtPosition:CGPointMake(wall.gapXPosition, wall.position.y)];
    }
}

- (Wall *)wall
{
    Wall *wall = [[Wall alloc] init];
    
    // Wall creation
    wall.position = CGPointMake(0.0, self.wallStartingYPosition);
    wall.width = self.size.width;
    wall.edgeImageName = WALL_SPRITE_IMAGE;
    wall.edgeSize = WALL_HEIGHT;
    wall.gapXPosition = self.randomGapXPosition;
    wall.gapSize = WALL_GAP_SIZE;
    wall.color = [SKColor whiteColor];
    [wall createWall];
    
    return wall;
}

- (void)spawnCollectableAtPosition:(CGPoint)position
{
    // Invisible collectable in order to know when we go through the wall
    SKShapeNode *invisibleCollectable = [SKShapeNode shapeNodeWithCircleOfRadius:COLLECTABLE_RADIUS];
    invisibleCollectable.fillColor = [SKColor whiteColor];
    invisibleCollectable.position = position;
    invisibleCollectable.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:COLLECTABLE_RADIUS];
    
    [self addChild:invisibleCollectable];
    
    [invisibleCollectable runAction:self.moveThenRemoveCollectable];
}


#pragma mark - User interaction

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint location = [[touches anyObject] locationInNode:self];
    
    // TODO: apply the force to the BODY of the player
    if (location.x < self.position.x + self.size.width/2.0) {
        self.player.velocity = CGVectorMake(-PLAYER_SPEED, 0.0);
    }
    else if (location.x > self.position.x + self.size.width/2.0) {
        self.player.velocity = CGVectorMake(PLAYER_SPEED, 0.0);
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.player.velocity = CGVectorMake(0.0, 0.0);
}


#pragma mark - Collision handling

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
