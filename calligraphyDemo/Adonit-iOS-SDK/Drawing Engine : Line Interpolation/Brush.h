//
//  Brush.h
//  JotTouchExample
//
//  Created by Ian on 4/21/15.
//  Copyright (c) 2015 Adonit, USA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AdonitSDK/JotConstants.h>
#import <AdonitSDK/JotStylusManager.h>

#define           VELOCITY_CLAMP_MIN 20
#define           VELOCITY_CLAMP_MAX 8000

@interface Brush : NSObject
{
    BOOL shouldUseVelocity;
    
    int numberOfTouches;
    CGPoint lastLoc;
    NSDate* lastDate;
}

@property (nonatomic) UIColor *brushColor;
@property (nonatomic) UIImage* texture;

@property CGFloat minOpacity;
@property CGFloat maxOpacity;

@property CGFloat minSize;
@property CGFloat maxSize;

@property BOOL isEraser;

/**
 * the velocity of the last touch, between 0 and 1
 *
 * a value of 0 means the pen is moving less than or equal to
 * the VELOCITY_CLAMP_MIN
 * a value of 1 means the pen is moving faster than or equal to
 * the VELOCITY_CLAMP_MAX
 **/
@property (nonatomic) CGFloat velocity;

@property (nonatomic) BOOL shouldUseVelocity;


-(instancetype)init;
-(instancetype)initWithMinOpac:(CGFloat)minOpac maxOpac:(CGFloat)maxOpac minSize:(CGFloat)minSize maxSize:(CGFloat)maxSize isEraser:(BOOL)isEraser;

- (CGFloat) widthForPressure:(CGFloat)pressure;
@end
