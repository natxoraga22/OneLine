//
//  GameParameters.h
//  OneLine
//
//  Created by Natxo Raga on 03/03/15.
//  Copyright (c) 2015 Ignacio Raga Llorens. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface GameParameters : NSObject

#pragma mark - Constants

extern CGFloat const WALL_GAP_SIZE;


#pragma mark - Game speed

@property (nonatomic, readonly) CGFloat gameSpeed;

- (void)incrementGameSpeed;


#pragma mark - Distance and delay between walls

@property (nonatomic) CGFloat wallWidth;
@property (nonatomic, readonly) CGFloat delayBetweenWalls;
@property (nonatomic, readonly) CGFloat wallGapBorderOffset;

@end
