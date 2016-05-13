//
//  Stroke.m
//  calligraphyDemo
//
//  Created by sinogz on 16/5/13.
//  Copyright © 2016年 steven.cai. All rights reserved.
//

#import "Stroke.h"

@implementation Stroke

- (UIColor *)fillColor
{
    if (_fillColor == nil) {
        return [UIColor colorWithRed:0.98 green:0.51 blue:0.51 alpha:1.0];
    }
    return _fillColor;
}

- (UIColor *)defaultColor
{
    return [UIColor colorWithRed:0.98 green:0.51 blue:0.51 alpha:1.0];
}

@end
