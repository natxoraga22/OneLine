//
//  GameScore.h
//  OneLine
//
//  Created by Ignacio Raga Llorens on 29/6/15.
//  Copyright (c) 2015 Ignacio Raga Llorens. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface GameScore : NSObject

@property (nonatomic) NSUInteger highScore;

- (BOOL)isHighScore:(NSUInteger)score;

@end
