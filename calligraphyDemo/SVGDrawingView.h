//
//  SVGDrawingView.h
//  calligraphyDemo
//
//  Created by sinogz on 16/5/10.
//  Copyright © 2016年 steven.cai. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "SVGKit.h"
#import "SVGKImage.h"
#import <QuartzCore/CALayer.h>
#import "UIBezierPath-Points.h"

#import "PaintingView.h"

#define kDrawingPathKey @"drawingPath"
#define kSubdivideFlagKey @"subdivideFlag"

typedef enum : NSUInteger {
    PATHLAYER_INDEX_LEFT,
    PATHLAYER_INDEX_MIDDLE,
    PATHLAYER_INDEX_RIGHT,
    PATHLAYER_INDEX_CONTOUR,
} PATHLAYER_INDEX;

@interface SVGDrawingView : SVGKLayeredImageView

@property (nonatomic, retain) CAShapeLayer *pathLayer;
@property (nonatomic, retain) CALayer *penLayer;

- (id)initWithSVGName:(NSString *)svgName;
- (void)preview;
@end
