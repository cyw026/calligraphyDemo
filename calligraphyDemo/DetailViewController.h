//
//  DetailViewController.h
//  calligraphyDemo
//
//  Created by 蔡业文 on 16/4/24.
//  Copyright © 2016年 steven.cai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SVGKit.h"
#import "SVGKImage.h"
#import <QuartzCore/CALayer.h>
#import "SVGDrawingView.h"

#define kDrawingPathKey @"drawingPath"

@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;

@property (nonatomic, strong) SVGDrawingView *contentView;

@end

