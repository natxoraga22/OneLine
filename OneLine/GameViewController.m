//
//  GameViewController.m
//  OneLine
//
//  Created by Natxo Raga on 09/02/15.
//  Copyright (c) 2015 Ignacio Raga Llorens. All rights reserved.
//

#import "GameViewController.h"
#import "MainMenuScene.h"
#import "GameScene.h"


@implementation GameViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Configure the view.
    SKView *spriteKitView = (SKView *)self.view;
    spriteKitView.ignoresSiblingOrder = YES;

    // DEBUG options
    /*
    spriteKitView.showsFPS = YES;
    spriteKitView.showsNodeCount = YES;
    spriteKitView.showsDrawCount = YES;
    spriteKitView.showsQuadCount = YES;
    spriteKitView.showsFields = YES;
    spriteKitView.showsPhysics = YES;
    */
}

- (void)viewWillAppear:(BOOL)animated
{
    // Main Menu
    MainMenuScene *mainMenu = [[MainMenuScene alloc] initWithSize:self.view.bounds.size];
    mainMenu.scaleMode = SKSceneScaleModeAspectFill;
    SKView *mainMenuView = (SKView *)self.view;
    [mainMenuView presentScene:mainMenu];
}


#pragma mark - Orientation

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}


#pragma mark - Utility

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

@end
