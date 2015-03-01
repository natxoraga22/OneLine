//
//  MainMenuScene.m
//  OneLine
//
//  Created by Natxo Raga on 01/03/15.
//  Copyright (c) 2015 Ignacio Raga Llorens. All rights reserved.
//

#import "MainMenuScene.h"


@interface MainMenuScene()
@property (strong, nonatomic) SKLabelNode *gameTitle;
@end


@implementation MainMenuScene

- (void)didMoveToView:(SKView *)view
{
    // General configuration
    self.physicsWorld.gravity = CGVectorMake(0.0, 0.0);
    self.backgroundColor = [SKColor blackColor];
    
    // Scene elements
    [self addChild:self.gameTitle];
}

static NSString *const GAME_TITLE_FONT_NAME = @"HelveticaNeue";
static NSString *const GAME_TITLE = @"One Line";
static const CGFloat GAME_TITLE_SIZE_SCALE_FACTOR = 1.0/6.0;
static const CGFloat GAME_TITLE_VERTICAL_ALIGN_FACTOR = 2.0/3.0;

- (SKLabelNode *)gameTitle
{
    if (!_gameTitle) {
        _gameTitle = [[SKLabelNode alloc] initWithFontNamed:GAME_TITLE_FONT_NAME];
        _gameTitle.text = GAME_TITLE;
        _gameTitle.fontColor = [SKColor whiteColor];
        _gameTitle.fontSize = self.view.bounds.size.width*GAME_TITLE_SIZE_SCALE_FACTOR;
        _gameTitle.position = CGPointMake(CGRectGetMidX(self.view.bounds),
                                         CGRectGetMinY(self.view.bounds) + CGRectGetHeight(self.view.bounds)*GAME_TITLE_VERTICAL_ALIGN_FACTOR);
    }
    return _gameTitle;
}

@end
