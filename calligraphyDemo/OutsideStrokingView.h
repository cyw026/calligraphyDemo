//
//  OutsideStrokingView.h
//  calligraphyDemo
//
//  Created by 蔡业文 on 16/5/24.
//  Copyright © 2016年 steven.cai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <AdonitSDK/AdonitSDK.h>
#import "Brush.h"

@interface OutsideStrokingView : UIView

@property (nonatomic, strong) Brush *currentBrush;

// erase the screen
- (IBAction) clear;

- (void)setupBrushTexture:(UIImage*)brushImage;
- (UIImage*)snapshot;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
@end
