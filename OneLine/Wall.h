//
//  Wall.h
//  OneLine
//
//  Created by Natxo Raga on 24/02/15.
//  Copyright (c) 2015 Ignacio Raga Llorens. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>


@interface Wall : SKNode

@property CGFloat width;
@property (strong, nonatomic) NSString* edgeImageName;
@property CGFloat gapXPosition;
@property CGFloat gapSize;
@property (strong, nonatomic) SKColor* color;

- (void)createWall;

@end
