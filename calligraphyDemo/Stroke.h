//
//  Stroke.h
//  calligraphyDemo
//
//  Created by sinogz on 16/5/13.
//  Copyright © 2016年 steven.cai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Stroke : NSObject

@property (nonatomic, assign) NSUInteger index;
@property (nonatomic, assign) NSUInteger animPlayFlag;     // 动画播放标记

@property (nonatomic, strong) UIBezierPath* contourPath;
@property (nonatomic, strong) UIBezierPath* guidesPath_L;
@property (nonatomic, strong) UIBezierPath* guidesPath_M;
@property (nonatomic, strong) UIBezierPath* guidesPath_R;

@end
