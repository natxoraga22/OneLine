//
//  Wall.h
//  OneLine
//
//  Created by Natxo Raga on 24/02/15.
//  Copyright (c) 2015 Ignacio Raga Llorens. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>


@interface Wall : SKNode

@property (nonatomic) CGFloat width;
@property (strong, nonatomic) NSString* edgeImageName;
@property (nonatomic) CGFloat edgeSize;
@property (nonatomic) CGFloat gapXPosition;
@property (nonatomic) CGFloat gapSize;
@property (strong, nonatomic) SKColor* color;

@property (readonly) CGFloat height;

- (void)createWall;

@end
