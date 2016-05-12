//
//  AdonitViewController.h
//  calligraphyDemo
//
//  Created by sinogz on 16/5/12.
//  Copyright © 2016年 steven.cai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AdonitSDK/AdonitSDK.h>
#import "CanvasView.h"

@interface AdonitViewController : UIViewController <UIPopoverControllerDelegate>

// Canvas to draw on for testing
@property (nonatomic, weak) IBOutlet CanvasView *canvasView;

// User Interface
@property (nonatomic, weak) IBOutlet UIButton *resetCanvasButton;
@property (weak, nonatomic) IBOutlet UISwitch *animateSwitch;
@property (weak, nonatomic) IBOutlet UILabel  *animateLabel;

- (IBAction)clear;
- (IBAction)animateSwitchValueChanged;

@end