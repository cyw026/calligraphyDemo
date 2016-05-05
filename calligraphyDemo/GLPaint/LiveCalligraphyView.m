//
//  LiveCalligraphyView.m
//  calligraphyDemo
//
//  Created by 蔡业文 on 16/5/5.
//  Copyright © 2016年 steven.cai. All rights reserved.
//

#import "LiveCalligraphyView.h"

@interface LiveCalligraphyView ()

@property(nonatomic, readwrite) CGPoint location;
@property(nonatomic, readwrite) CGPoint previousLocation;

@property (nonatomic, retain) UIImageView *penLayer;

@end

@implementation LiveCalligraphyView

@synthesize  location;
@synthesize  previousLocation;

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        
        
        UIImage *penImage = [UIImage imageNamed:@"brush_baby2.png"];
        UIImageView *penLayer = [[UIImageView alloc] initWithImage:penImage];
        penLayer.hidden = YES;
        
        
        [self addSubview:penLayer];
        
        self.penLayer = penLayer;
        
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    
    self.penLayer.frame = CGRectMake(0.0f, 0.0f, self.frame.size.width, self.frame.size.height);
    
}
// Handles the start of a touch
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    
    CGRect				bounds = [self bounds];
    UITouch*            touch = [[event touchesForView:self] anyObject];
    CGPoint point = [touch locationInView:self];
    
    firstTouch = YES;
//    self.penLayer.hidden = NO;
//    CGPoint position = self.penLayer.position;
//    position.x = point.x;
//    position.y = point.y;
//    self.penLayer.position = position;
    
    // Convert touch point from UIView referential to OpenGL one (upside-down flip)
    location = [touch locationInView:self];
    location.y = bounds.size.height - location.y;
    
    self.currentWidth = self.myBrush.texture.width / kBrushScale;
    
    [self renderLineFromPoint:location toPoint:location];
}
// Handles the continuation of a touch.
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGRect				bounds = [self bounds];
    UITouch*            touch = [[event touchesForView:self] anyObject];
    
    
    
    self.penLayer.hidden = NO;
    if ([event allTouches].count == 1) {
        CGPoint point = [touch locationInView:self];
        CGRect frame = self.penLayer.frame;
        frame.origin.x = point.x - 10;
        frame.origin.y = point.y - 85;
        self.penLayer.frame = frame;
    }

    
    // Convert touch point from UIView referential to OpenGL one (upside-down flip)
    if (firstTouch) {
        firstTouch = NO;
        previousLocation = location;
        //previousLocation.y = bounds.size.height - previousLocation.y;
    } else
    {
        location = [touch locationInView:self];
        location.y = bounds.size.height - location.y;
        previousLocation = [touch previousLocationInView:self];
        previousLocation.y = bounds.size.height - previousLocation.y;
    }


    // Render the stroke
    [self renderLineFromPoint2:previousLocation toPoint:location];
}

// Handles the end of a touch event when the touch is a tap.
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGRect				bounds = [self bounds];
    UITouch*            touch = [[event touchesForView:self] anyObject];
    if (firstTouch) {
        firstTouch = NO;
        previousLocation = [touch previousLocationInView:self];
        previousLocation.y = bounds.size.height - previousLocation.y;
        [self renderLineFromPoint2:previousLocation toPoint:location];
    }
    
    self.penLayer.hidden = YES;
}

// Handles the end of a touch event.
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    // If appropriate, add code necessary to save the state of the application.
    // This application is not saving state.
}

@end
