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

@end
