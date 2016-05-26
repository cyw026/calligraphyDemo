//
//  DetailViewController.m
//  calligraphyDemo
//
//  Created by 蔡业文 on 16/4/24.
//  Copyright © 2016年 steven.cai. All rights reserved.
//

#import "DetailViewController.h"
#import "UIBezierPath-Points.h"
#import "PaintingViewController.h"
#import "SVGDrawingView.h"
#include "CanvasView.h"
#import "AdonitViewController.h"

@interface DetailViewController () 


@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem {
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
            
        // Update the view.
        [self configureView];
    }
}

- (void)configureView {
    // Update the user interface for the detail item.
    if (self.detailItem) {
        //self.detailDescriptionLabel.text = [self.detailItem description];
        
        [self view];

        //[self loadSVGFrom:_detailItem];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //[self configureView];
    
    
    self.contentView = [[SVGDrawingView alloc] initWithSVGName:@"test.svg"];
    
    self.contentView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    [self.view addSubview:self.contentView];
    
    [self initRightBarButtonWithImage:@"brush_tool_blue" highlightedImage:@"brush_tool_blue_pressed"];
}

- (void)initRightBarButtonWithImage:(NSString *)image highlightedImage:(NSString*)highlightedImage
{
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 20, 30);
    [button addTarget:self action:@selector(handleRightBarButton:) forControlEvents:UIControlEventTouchUpInside];
    [button setImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:highlightedImage] forState:UIControlStateHighlighted];
    UIBarButtonItem * leftItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = leftItem;
}

- (void)handleRightBarButton:(UIButton *)button
{
//    AdonitViewController *vc = [[AdonitViewController alloc] initWithNibName:@"AdonitViewController" bundle:nil];
//    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
//    vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
//    vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
//    [self presentViewController:nav animated:YES completion:^{
//        
//    }];
    //[self.navigationController pushViewController:vc animated:YES];
    

    [_contentView preview];    
}

- (void)dealloc
{
    self.detailItem = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
