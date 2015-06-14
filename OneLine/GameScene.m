//
//  GameScene.m
//  OneLine
//
//  Created by Natxo Raga on 09/02/15.
//  Copyright (c) 2015 Ignacio Raga Llorens. All rights reserved.
//

#import "GameScene.h"
#import "GameOverScene.h"
#import "GameParameters.h"
#import "Wall.h"
#import "Player.h"


@interface GameScene() <SKPhysicsContactDelegate>
// Model
@property (strong, nonatomic) GameParameters *gameParameters;
@property (nonatomic) NSUInteger score;

// Scene elements
@property (strong, nonatomic) Player *player;
@property (strong, nonatomic) NSMutableArray *walls;
@property (strong, nonatomic) NSMutableArray *collectables;
@property (strong, nonatomic) SKLabelNode *scoreLabel;

// Game state
typedef NS_ENUM(NSUInteger, GameColorState) { WhiteElementsBlackBackground, BlackElementsWhiteBackground };
@property (nonatomic) GameColorState gameColorState;
@property (nonatomic) BOOL isPlayerMoving;

// Wall & collectables spawning
@property (nonatomic) NSTimeInterval lastCurrentTime;
@property (nonatomic) NSTimeInterval wallTimer;
@end


@implementation GameScene

// Collision masks
static const uint32_t playerCategory = 1 << 0;
static const uint32_t wallsCategory = 1 << 1;
static const uint32_t collectableCategory = 1 << 2;


#pragma mark - Scene lifecycle

- (void)didMoveToView:(SKView *)view
{
    [self setupScene];
}

- (void)setupScene
{
    // Physics
    self.physicsWorld.gravity = CGVectorMake(0.0, 0.0);
    self.physicsWorld.contactDelegate = self;
    
    // Model
    self.gameParameters.wallWidth = self.size.width;
    self.score = 0;
    
    // Game state
    self.gameColorState = WhiteElementsBlackBackground;
    self.backgroundColor = [self getBackgroundColor];
    self.isPlayerMoving = YES;
    
    // Walls & collectables spawning
    self.lastCurrentTime = 0;
    self.wallTimer = 0;
    
    // Scene elements
    [self addChild:self.player];
    [self addChild:self.scoreLabel];
}


#pragma mark - Game elements lazy instantiation

- (GameParameters *)gameParameters
{
    if (!_gameParameters) {
        _gameParameters = [[GameParameters alloc] init];
    }
    return _gameParameters;
}

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

- (NSMutableArray *)walls
{
    if (!_walls) {
        _walls = [NSMutableArray array];
    }
    return _walls;
}

- (NSMutableArray *)collectables
{
    if (!_collectables) {
        _collectables = [NSMutableArray array];
    }
    return _collectables;
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


#pragma mark - Getters & setters

static const CGFloat WALL_HEIGHT = 32.0;

- (CGFloat)getWallStartingYPosition
{
    return self.size.height + WALL_HEIGHT;
}

- (CGFloat)getRandomGapXPosition
{
    NSInteger gapMax = self.size.width - self.gameParameters.wallGapBorderOffset*2.0;
    return (arc4random()%gapMax) + self.gameParameters.wallGapBorderOffset;
}

- (SKColor *)getBackgroundColor
{
    if (self.gameColorState == WhiteElementsBlackBackground) return [SKColor blackColor];
    if (self.gameColorState == BlackElementsWhiteBackground) return [SKColor whiteColor];
    return nil;
}

- (SKColor *)getElementColor
{
    if (self.gameColorState == WhiteElementsBlackBackground) return [SKColor whiteColor];
    if (self.gameColorState == BlackElementsWhiteBackground) return [SKColor blackColor];
    return nil;
}


#pragma mark - Wall & collectable actions

- (SKAction *)getMoveFromTopToBottomAction
{
    CGFloat distanceToMove = self.size.height + WALL_HEIGHT*2.0;
    return [SKAction moveByX:0.0 y:-distanceToMove duration:distanceToMove/self.gameParameters.gameSpeed];
}

- (SKAction *)getMoveThenRestartWallAction
{
    NSLog(@"GAME SPEED: %f", self.gameParameters.gameSpeed);
    
    // Move wall down and restart it's position when it reaches the bottom
    SKAction *restartWall = [SKAction customActionWithDuration:0.0
                                                   actionBlock:^(SKNode *node, CGFloat elapsedTime) {
                                                       Wall *wall = (Wall *)node;
                                                       wall.position = CGPointMake(0.0, [self getWallStartingYPosition]);
                                                       wall.gapXPosition = [self getRandomGapXPosition];
                                                       [wall createWall];
                                                   }];
    
    return [SKAction sequence:@[[self getMoveFromTopToBottomAction], restartWall]];
}

- (SKAction *)getMoveThenRemoveCollectableAction
{
    // Move collectable down with the wall and remove it when it reaches the bottom
    SKAction *removeCollectable = [SKAction customActionWithDuration:0.0
                                                         actionBlock:^(SKNode *node, CGFloat elapsedTime) {
                                                             SKShapeNode *collectable = (SKShapeNode *)node;
                                                             [self.collectables removeObject:collectable];
                                                             [collectable removeFromParent];
                                                         }];
        
    return [SKAction sequence:@[[self getMoveFromTopToBottomAction], removeCollectable]];
}


#pragma mark - Update method

- (void)update:(NSTimeInterval)currentTime
{
    NSTimeInterval deltaTime = currentTime - self.lastCurrentTime;
    
    // Player path
    if (self.isPlayerMoving) {
        CGFloat distanceMoved = self.gameParameters.gameSpeed*deltaTime;
        [self.player computePath:distanceMoved];
    }
    
    // Wall spawning
    self.wallTimer -= deltaTime;
    if (self.wallTimer <= 0) {
        [self spawnWall];
        self.wallTimer = self.gameParameters.delayBetweenWalls;
    }
    
    self.lastCurrentTime = currentTime;
}


#pragma mark - Wall spawning

static NSString *const WALL_SPRITE_IMAGE = @"Player";

- (void)spawnWall
{
    // Look for a wall to start moving down
    BOOL found = NO;
    for (Wall *wall in self.walls) {
        if (!found && wall.position.y == [self getWallStartingYPosition]) {
            found = YES;
            
            [wall removeAllActions];
            wall.speed = 1.0;
            
            [wall runAction:[self getMoveThenRestartWallAction]];
            [self spawnCollectableAtPosition:CGPointMake(wall.gapXPosition, wall.position.y)];
        }
    }
    // If there's no wall waiting, create a new one
    if (!found) {
        Wall *wall = [self wall];
        [self.walls addObject:wall];
        [self addChild:wall];
        
        [wall runAction:[self getMoveThenRestartWallAction]];
        [self spawnCollectableAtPosition:CGPointMake(wall.gapXPosition, wall.position.y)];
    }
}

- (Wall *)wall
{
    Wall *wall = [[Wall alloc] init];
    
    // Wall creation
    wall.position = CGPointMake(0.0, [self getWallStartingYPosition]);
    wall.width = self.size.width;
    wall.edgeImageName = WALL_SPRITE_IMAGE;
    wall.edgeSize = WALL_HEIGHT;
    wall.gapXPosition = [self getRandomGapXPosition];
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
    
    [self.collectables addObject:invisibleCollectable];
    [self addChild:invisibleCollectable];
    
    [invisibleCollectable runAction:[self getMoveThenRemoveCollectableAction]];
}


#pragma mark - User interaction

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.isPlayerMoving) {
        CGPoint location = [[touches anyObject] locationInNode:self];
    
        if (location.x < self.position.x + self.size.width/2.0) {
            self.player.velocity = CGVectorMake(-self.gameParameters.gameSpeed, 0.0);
        }
        else if (location.x > self.position.x + self.size.width/2.0) {
            self.player.velocity = CGVectorMake(self.gameParameters.gameSpeed, 0.0);
        }
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
    self.isPlayerMoving = NO;
    
    // Stop wall spawning
    [self removeAllActions];
    
    // Stop walls and collectables
    for (SKNode *child in self.children) {
        if ([child.name isEqualToString:WALL_NODE_NAME] || [child.name isEqualToString:COLLECTABLE_NODE_NAME]) {
            [child removeAllActions];
        }
    }
    
    [self.player setRedColorToBody];
    
    Wall *wall = (Wall *)node.parent;
    [wall setRedColorToElementWithName:node.name];
    
    [self showGameOver];
}

- (void)showGameOver
{
    // Present game over scene
    GameOverScene *gameOverScene = [GameOverScene sceneWithSize:self.view.bounds.size];
    
    SKTransition* fade = [SKTransition fadeWithColor:[SKColor blackColor] duration:5.0];
    [self.view presentScene:gameOverScene transition:fade];
}

- (void)collectableCollected:(SKNode *)collectable
{
    [collectable removeFromParent];
    
    // Increase score
    [self increaseScore];
    
    // Change colors
    [self changeGameState];

    CGFloat oldSpeed = self.gameParameters.gameSpeed;
    
    // Increase game speed
    [self.gameParameters incrementGameSpeed];
    
    CGFloat newSpeed = self.gameParameters.gameSpeed;
    
    // Increase created walls & collectables speed
    for (Wall *wall in self.walls) {
        if (wall.position.y != [self getWallStartingYPosition]) {
            [wall runAction:[SKAction speedBy:(newSpeed/oldSpeed) duration:0.0]];
        }
    }
    for (SKShapeNode *collectable in self.collectables) {
        if (collectable.position.y != [self getWallStartingYPosition]) {
            [collectable runAction:[SKAction speedBy:(newSpeed/oldSpeed) duration:0.0]];
        }
    }
}

- (void)changeGameState
{
    if (self.gameColorState == WhiteElementsBlackBackground) self.gameColorState = BlackElementsWhiteBackground;
    else if (self.gameColorState == BlackElementsWhiteBackground) self.gameColorState = WhiteElementsBlackBackground;
    
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
