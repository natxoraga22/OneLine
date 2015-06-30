//
//  GameOverScene.m
//  OneLine
//
//  Created by Ignacio Raga Llorens on 31/5/15.
//  Copyright (c) 2015 Ignacio Raga Llorens. All rights reserved.
//

#import "GameOverScene.h"
#import "GameScene.h"


@interface GameOverScene()
// Menu elements
@property (strong, nonatomic) SKLabelNode *gameOverTitle;
@property (strong, nonatomic) SKSpriteNode *playButton;
// Gesture recognizers
@property (strong, nonatomic) UILongPressGestureRecognizer *playButtonTapRecognizer;
@end


@implementation GameOverScene

#pragma mark - Scene lifecycle

- (void)didMoveToView:(SKView *)view
{
    // General configuration
    self.physicsWorld.gravity = CGVectorMake(0.0, 0.0);
    self.backgroundColor = [SKColor blackColor];
    
    // Scene elements
    [self addChild:self.gameOverTitle];
    [self addChild:self.playButton];
}

- (void)setupGestureRecognizers
{
    self.playButtonTapRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(playButtonTapped:)];
    self.playButtonTapRecognizer.minimumPressDuration = 0.001;
    [self.view addGestureRecognizer:self.playButtonTapRecognizer];
}

- (void)willMoveFromView:(SKView *)view
{
    [self cleanScene];
}

- (void)cleanScene
{
    [self.view removeGestureRecognizer:self.playButtonTapRecognizer];
}


#pragma mark - Main menu elements

static NSString *const GAME_OVER_TITLE_FONT_NAME = @"DINAlternate-Bold";
static NSString *const GAME_OVER_TITLE = @"Game Over";
static const CGFloat GAME_OVER_TITLE_SCALE_FACTOR = 1.0/6.0;
static const CGFloat GAME_OVER_TITLE_VERTICAL_ALIGN_FACTOR = 3.0/4.0;

- (SKLabelNode *)gameOverTitle
{
    if (!_gameOverTitle) {
        _gameOverTitle = [[SKLabelNode alloc] initWithFontNamed:GAME_OVER_TITLE_FONT_NAME];
        _gameOverTitle.text = GAME_OVER_TITLE;
        _gameOverTitle.fontColor = [SKColor whiteColor];
        _gameOverTitle.fontSize = self.view.bounds.size.width*GAME_OVER_TITLE_SCALE_FACTOR;
        _gameOverTitle.position = CGPointMake(CGRectGetMidX(self.view.bounds),
                                  CGRectGetMinY(self.view.bounds) + CGRectGetHeight(self.view.bounds)*GAME_OVER_TITLE_VERTICAL_ALIGN_FACTOR);
    }
    return _gameOverTitle;
}

static NSString *const PLAY_BUTTON_IMAGE_NAME = @"PlayButton.png";
static NSString *const PLAY_BUTTON_NAME = @"PlayButton";
static const CGFloat PLAY_BUTTON_SCALE_FACTOR = 2.0/5.0;
static const CGFloat PLAY_BUTTON_VERTICAL_ALIGN_FACTOR = 1.0/3.0;

- (SKSpriteNode *)playButton
{
    if (!_playButton) {
        _playButton = [[SKSpriteNode alloc] initWithImageNamed:PLAY_BUTTON_IMAGE_NAME];
        _playButton.name = PLAY_BUTTON_NAME;
        _playButton.position = CGPointMake(CGRectGetMidX(self.view.bounds),
                                           CGRectGetMinY(self.view.bounds) + CGRectGetHeight(self.view.bounds)*PLAY_BUTTON_VERTICAL_ALIGN_FACTOR);
        [_playButton setSize:CGSizeMake(CGRectGetWidth(self.view.bounds)*PLAY_BUTTON_SCALE_FACTOR,
                                        CGRectGetWidth(self.view.bounds)*PLAY_BUTTON_SCALE_FACTOR)];
    }
    return _playButton;
}


#pragma mark - Buttons behaviour

static const CGFloat PLAY_BUTTON_HIGHLIGHTED_SCALE = 1.15;

- (void)playButtonTapped:(UILongPressGestureRecognizer *)sender
{
    CGPoint touchLocation = [sender locationInView:sender.view];
    touchLocation = [self convertPointFromView:touchLocation];
    SKNode *touchedNode = [self nodeAtPoint:touchLocation];
    
    if ([touchedNode.name isEqualToString:PLAY_BUTTON_NAME]) {
        if (sender.state == UIGestureRecognizerStateBegan || sender.state == UIGestureRecognizerStateChanged) {
            [self.playButton setScale:PLAY_BUTTON_HIGHLIGHTED_SCALE];
        }
        else if (sender.state == UIGestureRecognizerStateEnded) {
            // Present game scene
            [self cleanScene];
            GameScene *gameScene = [GameScene sceneWithSize:self.view.bounds.size];
            [self.view presentScene:gameScene];
        }
    }
    else [self.playButton setScale:1.0];
}

@end
