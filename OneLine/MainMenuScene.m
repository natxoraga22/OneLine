//
//  MainMenuScene.m
//  OneLine
//
//  Created by Natxo Raga on 01/03/15.
//  Copyright (c) 2015 Ignacio Raga Llorens. All rights reserved.
//

#import "MainMenuScene.h"
#import "GameScene.h"


@interface MainMenuScene()
@property (strong, nonatomic) SKLabelNode *gameTitle;
@property (strong, nonatomic) SKSpriteNode *playButton;
@property (nonatomic) NSUInteger playButtonTouchesCount;
@end


@implementation MainMenuScene

#pragma mark - Scene lifecycle

- (void)didMoveToView:(SKView *)view
{
    // General configuration
    self.physicsWorld.gravity = CGVectorMake(0.0, 0.0);
    self.backgroundColor = [SKColor blackColor];
    
    // Scene elements
    [self addChild:self.gameTitle];
    [self addChild:self.playButton];
}


#pragma mark - Main menu elements

static NSString *const GAME_TITLE_FONT_NAME = @"HelveticaNeue";
static NSString *const GAME_TITLE = @"One Line";
static const CGFloat GAME_TITLE_SCALE_FACTOR = 1.0/6.0;
static const CGFloat GAME_TITLE_VERTICAL_ALIGN_FACTOR = 2.0/3.0;

- (SKLabelNode *)gameTitle
{
    if (!_gameTitle) {
        _gameTitle = [[SKLabelNode alloc] initWithFontNamed:GAME_TITLE_FONT_NAME];
        _gameTitle.text = GAME_TITLE;
        _gameTitle.fontColor = [SKColor whiteColor];
        _gameTitle.fontSize = self.view.bounds.size.width*GAME_TITLE_SCALE_FACTOR;
        _gameTitle.position = CGPointMake(CGRectGetMidX(self.view.bounds),
                                         CGRectGetMinY(self.view.bounds) + CGRectGetHeight(self.view.bounds)*GAME_TITLE_VERTICAL_ALIGN_FACTOR);
    }
    return _gameTitle;
}

static NSString *const PLAY_BUTTON_IMAGE_NAME = @"Player.png";  //TODO: Change to PlayButton.png
static NSString *const PLAY_BUTTON_NAME = @"PlayButton";
static const CGFloat PLAY_BUTTON_SCALE_FACTOR = 1.0/2.0;

- (SKSpriteNode *)playButton
{
    if (!_playButton) {
        _playButton = [[SKSpriteNode alloc] initWithImageNamed:PLAY_BUTTON_IMAGE_NAME];
        _playButton.name = PLAY_BUTTON_NAME;
        _playButton.position = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
        [_playButton setSize:CGSizeMake(CGRectGetWidth(self.view.bounds)*PLAY_BUTTON_SCALE_FACTOR,
                                        CGRectGetWidth(self.view.bounds)*PLAY_BUTTON_SCALE_FACTOR)];
    }
    return _playButton;
}


#pragma mark - Buttons behaviour

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{    
    if (touches.count == 1) {
        CGPoint touchLocation = [[touches anyObject] locationInNode:self];
        SKNode *node = [self nodeAtPoint:touchLocation];
        
        if ([node.name isEqualToString:PLAY_BUTTON_NAME]) {
            [self incrementPlayButtonTouchesCount];
        }
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (touches.count == 1) {
        CGPoint previousTouchLocation = [[touches anyObject] previousLocationInNode:self];
        SKNode *previousNode = [self nodeAtPoint:previousTouchLocation];
        
        CGPoint touchLocation = [[touches anyObject] locationInNode:self];
        SKNode *node = [self nodeAtPoint:touchLocation];
            
        if ([previousNode.name isEqualToString:PLAY_BUTTON_NAME] && ![node.name isEqualToString:PLAY_BUTTON_NAME]) {
            [self decrementPlayButtonTouchesCount];
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (touches.count == 1) {
        CGPoint touchLocation = [[touches anyObject] locationInNode:self];
        SKNode *node = [self nodeAtPoint:touchLocation];
        
        if ([node.name isEqualToString:PLAY_BUTTON_NAME]) {
            [self decrementPlayButtonTouchesCount];
        }
    }
}

static const CGFloat PLAY_BUTTON_HIGHLIGHTED_SCALE = 1.15;

- (void)incrementPlayButtonTouchesCount
{
    self.playButtonTouchesCount++;
    [self.playButton setScale:PLAY_BUTTON_HIGHLIGHTED_SCALE];
}

- (void)decrementPlayButtonTouchesCount
{
    if (self.playButtonTouchesCount > 0) self.playButtonTouchesCount--;
    if (self.playButtonTouchesCount == 0) {
        [self.playButton setScale:1.0];
        
        // Present game scene
        GameScene *gameScene = [GameScene sceneWithSize:self.view.bounds.size];
        [self.view presentScene:gameScene];
    }
}

@end
