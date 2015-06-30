//
//  GameScore.m
//  OneLine
//
//  Created by Ignacio Raga Llorens on 29/6/15.
//  Copyright (c) 2015 Ignacio Raga Llorens. All rights reserved.
//

#import "GameScore.h"


@implementation GameScore

#pragma mark - High score

static NSString *const HIGH_SCORE_KEY = @"HighScore";

- (NSUInteger)highScore
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber *highScore = [userDefaults objectForKey:HIGH_SCORE_KEY];
    return [highScore unsignedIntegerValue];
}

- (void)setHighScore:(NSUInteger)score
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@(score) forKey:HIGH_SCORE_KEY];
}

- (BOOL)isHighScore:(NSUInteger)score
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSUInteger highScore = [[userDefaults objectForKey:HIGH_SCORE_KEY] unsignedIntegerValue];
    return score > highScore;
}

@end
