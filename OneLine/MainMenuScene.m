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
// Menu elements
@property (strong, nonatomic) SKLabelNode *gameTitle;
@property (strong, nonatomic) SKSpriteNode *playButton;
// Gesture recognizers
@property (strong, nonatomic) UILongPressGestureRecognizer *playButtonTapRecognizer;
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
    
    // Gesture recognizers
    self.playButtonTapRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(playButtonTapped:)];
    self.playButtonTapRecognizer.minimumPressDuration = 0.001;
    [view addGestureRecognizer:self.playButtonTapRecognizer];
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

static NSString *const GAME_TITLE_FONT_NAME = @"DINAlternate-Bold";
static NSString *const GAME_TITLE = @"One Line";
static const CGFloat GAME_TITLE_SCALE_FACTOR = 2.0/11.0;
static const CGFloat GAME_TITLE_VERTICAL_ALIGN_FACTOR = 3.0/4.0;

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

static NSString *const PLAY_BUTTON_IMAGE_NAME = @"PlayButton.png";
static NSString *const PLAY_BUTTON_NAME = @"PlayButton";
static const CGFloat PLAY_BUTTON_SCALE_FACTOR = 2.0/5.0;

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
