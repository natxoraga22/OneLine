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
// Game model
@property (nonatomic) NSUInteger score;
// Game elements
@property (strong, nonatomic) Player *player;
@property (strong, nonatomic) NSMutableArray *walls;
@property (strong, nonatomic) SKLabelNode *scoreLabel;
// Game state
typedef NS_ENUM(NSUInteger, GameState) { WhiteElementsBlackBackground, BlackElementsWhiteBackground };
@property (nonatomic) GameState gameState;
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
    self.gameState = WhiteElementsBlackBackground;
    self.backgroundColor = [self getBackgroundColor];
    self.score = 0;
    
    [self addChild:self.player];
    [self initWallSpawning];
    [self addChild:self.scoreLabel];
}

- (void)initWallSpawning
{
    // Spawn a new wall each X seconds
    SKAction *spawnWall = [SKAction performSelector:@selector(spawnWall) onTarget:self];
    SKAction *delay = [SKAction waitForDuration:DELAY_BETWEEN_WALLS];
    SKAction *spawnThenDelay = [SKAction sequence:@[spawnWall, delay]];
    [self runAction:[SKAction repeatActionForever:spawnThenDelay]];
}

- (void)resetGame
{
    NSLog(@"RESET-GAME");
    
    // TODO: SOLVE THAT
    
    //[self removeAllChildren];
    
    //[self removeAllActions];
    //[self.walls removeAllObjects];
    
    //self.player.position = CGPointMake(self.position.x + self.size.width/2.0,
    //                                   self.position.y + self.size.height/3.0);
        
    //self.walls = nil;
    
    //[self addChild:self.player];
    //[self initWallSpawning];
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

static NSString *const SCORE_LABEL_FONT_NAME = @"HelveticaNeue";
static const CGFloat SCORE_LABEL_SCALE_FACTOR = 1.0/10.0;
static const CGFloat SCORE_LABEL_VERTICAL_ALIGN_FACTOR = 9.0/10.0;

- (SKLabelNode *)scoreLabel
{
    if (!_scoreLabel) {
        _scoreLabel = [[SKLabelNode alloc] initWithFontNamed:SCORE_LABEL_FONT_NAME];
        _scoreLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.score];
        _scoreLabel.fontColor = [self getElementColor];
        _scoreLabel.fontSize = self.view.bounds.size.width*SCORE_LABEL_SCALE_FACTOR;
        _scoreLabel.position = CGPointMake(CGRectGetMidX(self.view.bounds),
                                           CGRectGetMinY(self.view.bounds) + CGRectGetHeight(self.view.bounds)*SCORE_LABEL_VERTICAL_ALIGN_FACTOR);
    }
    return _scoreLabel;
}

- (SKColor *)getBackgroundColor
{
    if (self.gameState == WhiteElementsBlackBackground) return [SKColor blackColor];
    if (self.gameState == BlackElementsWhiteBackground) return [SKColor whiteColor];
    return nil;
}

- (SKColor *)getElementColor
{
    if (self.gameState == WhiteElementsBlackBackground) return [SKColor whiteColor];
    if (self.gameState == BlackElementsWhiteBackground) return [SKColor blackColor];
    return nil;
}


#pragma mark - Game elements creation

static NSString *const PLAYER_SPRITE_IMAGE = @"Player";
static const CGFloat PLAYER_SIZE = 32.0;

- (Player *)player
{
    if (!_player) {
        _player = [[Player alloc] initWithImageNamed:PLAYER_SPRITE_IMAGE];
        _player.color = [self getElementColor];
        
        // Scale and position
        _player.position = CGPointMake(self.position.x + self.size.width/2.0,
                                       self.position.y + self.size.height/3.0);
        _player.realSize = PLAYER_SIZE;
        
        // Collision masks
        _player.categoryBitMask = playerCategory;
        _player.collisionBitMask = wallsCategory | collectableCategory;
        _player.contactTestBitMask = wallsCategory | collectableCategory;
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

static NSString *const WALL_SPRITE_IMAGE = @"Player";

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
    wall.color = [self getElementColor];
    
    // Collision masks
    wall.categoryBitMask = wallsCategory;
    wall.collisionBitMask = playerCategory;
    wall.contactTestBitMask = playerCategory;
    
    [wall createWall];
    
    return wall;
}

static NSString *const COLLECTABLE_NODE_NAME = @"COLLECTABLE_NODE";
static CGFloat COLLECTABLE_RADIUS = 5.0;

- (void)spawnCollectableAtPosition:(CGPoint)position
{
    // Invisible collectable in order to know when we go through the wall
    SKShapeNode *invisibleCollectable = [SKShapeNode shapeNodeWithCircleOfRadius:COLLECTABLE_RADIUS];
    invisibleCollectable.name = COLLECTABLE_NODE_NAME;
    invisibleCollectable.fillColor = [SKColor greenColor];
    invisibleCollectable.strokeColor = [SKColor greenColor];
    invisibleCollectable.alpha = 0.0f;
    invisibleCollectable.position = position;
    invisibleCollectable.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:COLLECTABLE_RADIUS];
    
    // Collision masks
    invisibleCollectable.physicsBody.categoryBitMask = collectableCategory;
    invisibleCollectable.physicsBody.collisionBitMask = playerCategory;
    invisibleCollectable.physicsBody.contactTestBitMask = playerCategory;
    
    [self addChild:invisibleCollectable];
    
    [invisibleCollectable runAction:self.moveThenRemoveCollectable];
}


#pragma mark - User interaction

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint location = [[touches anyObject] locationInNode:self];
    
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
    
    SKNode *nodeA = contact.bodyA.node;
    SKNode *nodeB = contact.bodyB.node;
    
    if ([nodeA.parent.name isEqualToString:WALL_NODE_NAME]) {
        NSLog(@"COLLISION WITH WALL");
        [self collisionWithNode:nodeA];
    }
    else if ([nodeB.parent.name isEqualToString:WALL_NODE_NAME]) {
        NSLog(@"COLLISION WITH WALL");
        [self collisionWithNode:nodeB];
    }
    else if ([nodeA.name isEqualToString:COLLECTABLE_NODE_NAME]) {
        NSLog(@"COLLISION WITH COLLECTABLE");
        [self collectableCollected:nodeA];
    }
    else if ([nodeB.name isEqualToString:COLLECTABLE_NODE_NAME]) {
        NSLog(@"COLLISION WITH COLLECTABLE");
        [self collectableCollected:nodeB];
    }
}

- (void)collisionWithNode:(SKNode *)node
{
    // Stop wall spawning
    [self removeAllActions];
    
    // Stop walls and collectables
    for (SKNode *child in self.children) {
        if ([child.name isEqualToString:WALL_NODE_NAME] || [child.name isEqualToString:COLLECTABLE_NODE_NAME]) {
            [child removeAllActions];
        }
    }
    // TODO: Disable touch events
    
    
    // TODO: Stop player path
    
    [self.player setRedColorToBody];
    
    Wall *wall = (Wall *)node.parent;
    [wall setRedColorToElementWithName:node.name];
    
    [self resetGame];
}

- (void)collectableCollected:(SKNode *)collectable
{
    [collectable removeFromParent];
    
    // Increase score
    [self increaseScore];
    
    // Change colors
    [self changeGameState];
}

- (void)changeGameState
{
    if (self.gameState == WhiteElementsBlackBackground) self.gameState = BlackElementsWhiteBackground;
    else if (self.gameState == BlackElementsWhiteBackground) self.gameState = WhiteElementsBlackBackground;
    
    // Change color for everything
    self.backgroundColor = [self getBackgroundColor];
    self.player.color = [self getElementColor];
    self.scoreLabel.fontColor = [self getElementColor];
    for (SKNode *child in self.children) {
        if ([child isKindOfClass:[Wall class]]) ((Wall*)child).color = [self getElementColor];
    }
}

- (void)increaseScore
{
    self.score++;
    self.scoreLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.score];
}

@end
