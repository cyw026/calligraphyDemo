//
//  Brush.m
//  JotTouchExample
//
//  Created by Ian on 4/21/15.
//  Copyright (c) 2015 Adonit, USA. All rights reserved.
//

#import "Brush.h"

@implementation Brush

@synthesize shouldUseVelocity;

- (instancetype)init
{
    return [self initWithMinOpac:0.8 maxOpac:1.0 minSize:2 maxSize:30 isEraser:NO];
}

-(instancetype)initWithMinOpac:(CGFloat)minOpac maxOpac:(CGFloat)maxOpac minSize:(CGFloat)minSize maxSize:(CGFloat)maxSize isEraser:(BOOL)isEraser
{
    if(self = [super init]){
        _brushColor = [UIColor blueColor];
        _minOpacity = minOpac;
        _maxOpacity = maxOpac;
        _minSize = minSize;
        _maxSize = maxSize;
        _isEraser = isEraser;
        shouldUseVelocity = YES;
    }
    return self;
}

- (UIColor *)brushColor
{
//    if (self.isEraser) {
//        return [UIColor whiteColor];
//    }

    return _brushColor;
}

-(UIImage*) texture{
    return [UIImage imageNamed:@"brush1.png"];
}

/**
 * the user has moved to this new touch point, and we need
 * to specify the width of the stroke at this position
 *
 * we'll use pressure data to determine width if we can, otherwise
 * we'll fall back to use velocity data
 */
- (CGFloat) widthForPressure:(CGFloat)pressure
{
    if(shouldUseVelocity){
        CGFloat width = (_velocity - 1);
        if(width > 0) width = 0;
        width = _minSize + ABS(width) * (_maxSize - _minSize);
        if(width < 1) width = 1;
        return width;
    }else{
        CGFloat newWidth = _minSize + (_maxSize-_minSize) * pressure;
        return newWidth;
    }
}

@end
