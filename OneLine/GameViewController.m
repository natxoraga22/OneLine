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

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Configure the view.
    SKView * spriteKitView = (SKView *)self.view;
    spriteKitView.ignoresSiblingOrder = YES;

    // DEBUG options
    spriteKitView.showsFPS = YES;
    spriteKitView.showsDrawCount = YES;
    spriteKitView.showsNodeCount = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    /*
    // Create and configure the scene.
    GameScene *scene = [[GameScene alloc] initWithSize:self.view.frame.size];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    // Present the scene.
    SKView * spriteKitView = (SKView *)self.view;
    [spriteKitView presentScene:scene];
    */
    
    // Main Menu
    MainMenuScene *mainMenu = [[MainMenuScene alloc] initWithSize:self.view.frame.size];
    mainMenu.scaleMode = SKSceneScaleModeAspectFill;
    SKView *mainMenuView = (SKView *)self.view;
    [mainMenuView presentScene:mainMenu];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

@end
