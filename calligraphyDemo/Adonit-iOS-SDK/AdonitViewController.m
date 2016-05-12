//
//  AdonitViewController.m
//  calligraphyDemo
//
//  Created by sinogz on 16/5/12.
//  Copyright © 2016年 steven.cai. All rights reserved.
//

#import "AdonitViewController.h"

@interface AdonitViewController()

@property (nonatomic) BOOL animationEnabled;

@property (nonatomic, weak) IBOutlet UIView *brushColorPreview;
@property (nonatomic, weak) IBOutlet UIButton *penButton;
@property (nonatomic, weak) IBOutlet UIButton *brushButton;
@property (nonatomic, weak) IBOutlet UIButton *eraserButton;
@property (nonatomic) UIColor *currentColor;
@property (nonatomic) Brush *penBrush;
@property (nonatomic) Brush *brushBrush;
@property (nonatomic) Brush *eraserBrush;

@end


@implementation AdonitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
        
    self.animationEnabled = YES;
    self.animateSwitch.on = NO;
    
    self.currentColor = [UIColor blackColor];
    [self selectBrush:self.brushButton];
    
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
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBAction

- (IBAction)selectPen:(UIButton *)sender
{
    self.canvasView.currentBrush = self.penBrush;
    [self.canvasView setupBrushTexture:[UIImage imageNamed:@"brush.png"]];
    [self.canvasView setNeedsLayout];
    [self highlightSelectedButton:sender];
}

- (IBAction)selectBrush:(UIButton *)sender
{
    self.canvasView.currentBrush = self.brushBrush;
    [self.canvasView setupBrushTexture:[UIImage imageNamed:@"brush1.png"]];
    [self.canvasView setNeedsLayout];
    [self highlightSelectedButton:sender];
}

- (IBAction)selectEraser:(UIButton *)sender
{
    self.canvasView.currentBrush = self.eraserBrush;
    [self highlightSelectedButton:sender];
}

- (IBAction)changeColor:(UIButton *)sender
{
    CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
    UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
    [self setBrushColors:color];
}

- (void)highlightSelectedButton:(UIButton *)selectedButton;
{
    NSArray *buttons = @[self.penButton, self.brushButton, self.eraserButton];
    for (UIButton *button in buttons) {
        if (button == selectedButton) {
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        } else {
            [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        }
    }
}

- (IBAction)clear
{
    [self.canvasView clear];
}

- (IBAction)animateSwitchValueChanged
{
    self.animationEnabled = self.animateSwitch.isOn;
}


#pragma mark - Brushes
- (void)setCurrentColor:(UIColor *)currentColor
{
    _currentColor = currentColor;
    [self setBrushColors:currentColor];
}

- (void)setBrushColors:(UIColor *)brushColors
{
    self.penBrush.brushColor = brushColors;
    self.brushBrush.brushColor = brushColors;
    self.eraserBrush.brushColor = brushColors;
    self.brushColorPreview.backgroundColor = brushColors;
}

- (Brush *)penBrush
{
    if (!_penBrush) {
        _penBrush = [[Brush alloc]initWithMinOpac:1.0 maxOpac:1.5 minSize:2.0 maxSize:20.0 isEraser:NO];
        _penBrush.brushColor = self.currentColor;
    }
    return _penBrush;
}

- (Brush *)brushBrush
{
    if (!_brushBrush) {
        _brushBrush = [[Brush alloc]initWithMinOpac:0.8 maxOpac:1.0 minSize:2.0 maxSize:20 isEraser:NO];
        _brushBrush.brushColor = self.currentColor;
    }
    return _brushBrush;
}

- (Brush *)eraserBrush
{
    if (!_eraserBrush) {
        _eraserBrush = [[Brush alloc]initWithMinOpac:0.40 maxOpac:0.55 minSize:4.0 maxSize:20 isEraser:YES];
        
        _brushBrush.brushColor = self.currentColor;
    }
    return _eraserBrush;
}


@end
