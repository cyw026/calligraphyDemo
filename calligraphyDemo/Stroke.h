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

@property (nonatomic, copy) NSString* identifier;
@property (nonatomic, assign) NSUInteger animPlayFlag;     // 动画播放标记
@property (nonatomic, strong) UIColor* fillColor;          // 填充颜色
@property (nonatomic, strong) UIColor* defaultColor;        //默认填充颜色

@property (nonatomic, strong) UIBezierPath* contourPath;
@property (nonatomic, strong) UIBezierPath* guidesPath_L;
@property (nonatomic, strong) UIBezierPath* guidesPath_M;
@property (nonatomic, strong) UIBezierPath* guidesPath_R;

@end
