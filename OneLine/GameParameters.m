//
//  GameParameters.m
//  OneLine
//
//  Created by Natxo Raga on 03/03/15.
//  Copyright (c) 2015 Ignacio Raga Llorens. All rights reserved.
//

#import "GameParameters.h"


@interface GameParameters()
@property (nonatomic, readwrite) CGFloat gameSpeed;
@end


@implementation GameParameters

#pragma mark - Constants

const CGFloat WALL_GAP_SIZE = 50.0;


#pragma mark - Game speed

static const CGFloat INITIAL_GAME_SPEED = 200.0;
static const CGFloat MAX_GAME_SPEED = 350.0;
static const CGFloat GAME_SPEED_STEP = 3.0;

- (CGFloat)gameSpeed
{
    if (_gameSpeed == 0.0) _gameSpeed = INITIAL_GAME_SPEED;
    return _gameSpeed;
}

- (void)incrementGameSpeed
{
    self.gameSpeed += GAME_SPEED_STEP;
    if (self.gameSpeed > MAX_GAME_SPEED) self.gameSpeed = MAX_GAME_SPEED;
}


#pragma mark - Distance and delay between walls

- (CGFloat)delayBetweenWalls
{
    return (self.wallWidth - self.wallGapBorderOffset)/self.gameSpeed;
}

static const CGFloat WALL_GAP_BORDER_OFFSET_FACTOR = 1.0/5.0;

- (CGFloat)wallGapBorderOffset
{
    return self.wallWidth*WALL_GAP_BORDER_OFFSET_FACTOR;
}

@end
