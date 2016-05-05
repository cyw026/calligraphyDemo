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

@interface DetailViewController () 
{
    CAShapeLayer* lastTappedLayer;
    CGFloat lastTappedLayerOriginalBorderWidth;
    CGColorRef lastTappedLayerOriginalBorderColor;
}

// 点集合
@property (nonatomic, strong) NSMutableArray *points;

@property (nonatomic, strong) UIImage *lastImage;

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
        
        [self loadSVGFrom:_detailItem];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //[self configureView];
    
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
    PaintingViewController *vc = [[PaintingViewController alloc] initWithNibName:@"PaintingViewController" bundle:nil];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:nav animated:YES completion:^{
        
    }];
}

- (void)dealloc
{
    self.detailItem = nil;
}

-(void) willLoadNewResource
{
    // update the view
    [self.contentView removeFromSuperview];
}

- (void)loadSVGFrom:(SVGKSource *) svgSource {
    
    [self willLoadNewResource];
    
    
    //FIXME: 这里使用异步方式解析XML报错，暂时没找到原因先采用同步加载方式
    SVGKImage *document = [SVGKImage imageNamed:@"drawing.svg"];
    [self internalLoadedResource:svgSource parserOutput:nil createImageViewFromDocument:document];

    // 异步解析
//    [SVGKImage imageWithSource:svgSource
//                                       onCompletion:^(SVGKImage *loadedImage, SVGKParseResult* parseResult)
//                          {
//                              dispatch_async(dispatch_get_main_queue(), ^{
//                                  // must be on main queue since this affects the UIKit GUI!
//                                  [self internalLoadedResource:svgSource parserOutput:parseResult createImageViewFromDocument:loadedImage];
//                              });
//                          }];
    
}

/**
 Creates an appropriate SVGKImageView to display the loaded SVGKImage, and triggers the post-processing
 of on-screen displays
 */
-(void) internalLoadedResource:(SVGKSource*) source parserOutput:(SVGKParseResult*) parseResult createImageViewFromDocument:(SVGKImage*) document
{
    
    SVGKImageView* newContentView = nil;
    //document.scale = 0.5;
    document.size = CGSizeMake(375, 300);
    if( document == nil )
    {
        if( parseResult == nil )
        {
            [[[UIAlertView alloc] initWithTitle:@"SVG parse failed" message:@"Total failure. See console log" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
        else
        {
            [[[UIAlertView alloc] initWithTitle:@"SVG parse failed" message:[NSString stringWithFormat:@"Summary: %@",parseResult] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
        newContentView = nil; // signals to the rest of this method: the load failed
    }
    else
    {
        if( document.parseErrorsAndWarnings.rootOfSVGTree != nil )
        {
            //NSLog(@"[%@] Freshly loaded document (name = %@) has size = %@", [self class], name, NSStringFromCGSize(document.size) );
            newContentView = [[SVGKLayeredImageView alloc] initWithSVGKImage:document];
            
            //newContentView = [[SVGKFastImageView alloc] initWithSVGKImage:document];
            
            //((SVGKFastImageView*)newContentView).disableAutoRedrawAtHighestResolution = TRUE;
        }
        
        if( parseResult.errorsFatal.count > 0 )
        {
            [[[UIAlertView alloc] initWithTitle:@"SVG parse failed" message:[NSString stringWithFormat:@"%@",parseResult] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            newContentView = nil; // signals to the rest of this method: the load failed
        }
    }
    
    [self didLoadNewResourceCreatingImageView:newContentView];
}

/**
 Reconfigures the view to display the newly-loaded image, and display meta info
 about how long it took to parse, etc
 */
-(void) didLoadNewResourceCreatingImageView:(SVGKImageView*) newContentView
{
    if( newContentView != nil )
    {
        /**
         * NB: at this point we're guaranteed to have a "new" replacemtent ready for self.contentView
         */
        
        /******* swap the new contentview in ************/
        self.contentView = newContentView;
        
        /** set the border for new item */
        self.contentView.showBorder = FALSE;
        
        self.contentView.frame = CGRectMake(0, 64, 600, 300);
        
        self.contentView.layer.backgroundColor = [UIColor blueColor].CGColor;
        
        [self.view addSubview:self.contentView];
        
        [self.contentView setNeedsLayout];
        
        //create sublayer
        CALayer *blueLayer = [CALayer layer];
        blueLayer.frame = CGRectMake(50.0f, 50.0f, 100.0f, 100.0f);
        blueLayer.backgroundColor = [UIColor blueColor].CGColor;
        
        //set controller as layer delegate
        blueLayer.delegate = self;
        
        //ensure that layer backing image uses correct scale
        blueLayer.contentsScale = [UIScreen mainScreen].scale; //add layer to our view
        //[self.contentView.layer addSublayer:blueLayer];
        
        //force layer to redraw
        //[blueLayer display];
        
        /**
         EXAMPLE:
         
         How to find particular nodes in the tree, after parsing.
         
         In this case, we search for all SVG <g> tags, which usually mean grouped-objects in Inkscape etc:
         NodeList* elementsUsingTagG = [document.DOMDocument getElementsByTagName:@"g"];
         NSLog( @"[%@] checking for SVG standard set of elements with XML tag/node of <g>: %@", [self class], elementsUsingTagG.internalArray );
         */
    }
}

/**
 *  在当前图形绘制触摸产生的笔划
 *
 *  @param layer 当前选中绘制的笔划图形所在图层
 *  @param ctx   当前图层的图形上下文
 */
- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
    if ([layer isEqual:lastTappedLayer]) {
        
//        UIGraphicsPushContext(ctx);
//        [self.lastImage drawInRect:layer.frame];
//        UIGraphicsPopContext();
        
        CGContextSaveGState(ctx);
        CGContextSetStrokeColorWithColor(ctx, [UIColor blackColor].CGColor);
        CGContextSetLineWidth(ctx, 60);
        
        UIBezierPath *drawingPath = [layer valueForKey:kDrawingPathKey];
        CGContextAddPath(ctx, drawingPath.CGPath);
        
        CGContextStrokePath(ctx);
        
        CGContextSaveGState(ctx);
        
//        CGImageRef imageRef = CGBitmapContextCreateImage(ctx);
//        self.lastImage = [UIImage imageWithCGImage:imageRef];
//        CFRelease(imageRef);
        
    }
}

/**
 *  取消当前图层的选中状态
 */
-(void) deselectTappedLayer
{
    if( lastTappedLayer != nil )
    {
        lastTappedLayer.borderWidth = lastTappedLayerOriginalBorderWidth;
        lastTappedLayer.borderColor = lastTappedLayerOriginalBorderColor;
        
        lastTappedLayer = nil;
    }
}

#pragma mark - /*** 触摸事件 ***/

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = touches.anyObject;
    CGPoint p = [touch locationInView:self.view];
    
    NSValue *vp = [NSValue valueWithCGPoint:p];
    
    self.points = [NSMutableArray arrayWithObjects:vp,vp,vp, nil];
    //[self changeImage];
    
    if ([self.contentView isKindOfClass:[SVGKLayeredImageView class]]) {
        SVGKLayer* layerForHitTesting = (SVGKLayer*)self.contentView.layer;
        SVGKImage *image = layerForHitTesting.SVGImage;
        
        NSLog(@"hitLayer.DOMTree:%@", image.DOMTree);
        CAShapeLayer* hitLayer = (CAShapeLayer*)[layerForHitTesting hitTest:p];
        //SVGKImage *hitLayerImage = hitLayer.SVGImage;
        //NSLog(@"hitLayerImage:%@", hitLayerImage.DOMTree);
        
#if 0
        CALayerWithChildHitTest *mask = (CALayerWithChildHitTest *)hitLayer.mask;
        CAShapeLayerWithHitTest *clipPathLayer = (CAShapeLayerWithHitTest *)[[mask sublayers] firstObject];
        UIBezierPath *clipPath = [UIBezierPath bezierPath];
        clipPath.CGPath = clipPathLayer.path;
        
        for (int i = (int)clipPath.points.count - 1; i > 0; i--) {

            NSValue *pointV = clipPath.points[i];
            CGPoint Point = [self.view.layer convertPoint:[pointV CGPointValue] fromLayer:hitLayer];

            UIBezierPath *pointPath = [UIBezierPath bezierPathWithArcCenter:Point radius:8 startAngle:0 endAngle:M_PI * 2.0 clockwise:YES];
            CAShapeLayer* clipLayer = [CAShapeLayer layer];
            clipLayer.path = pointPath.CGPath;
            clipLayer.fillColor = [UIColor blackColor].CGColor;
            clipLayer.strokeColor = [UIColor redColor].CGColor;
            [self.view.layer addSublayer:clipLayer];
            
            CATextLayer *textLayer = [CATextLayer layer];
            textLayer.string = [NSString stringWithFormat:@"%d", i];
            textLayer.font = (__bridge CFTypeRef _Nullable)(@"HiraKakuProN-W3");
            textLayer.fontSize = 10.f;
            textLayer.alignmentMode = kCAAlignmentCenter;//字体的对齐方式
            textLayer.position = Point;
            textLayer.foregroundColor = [UIColor greenColor].CGColor;//字体的颜色
            textLayer.bounds = CGRectMake(0, 0, 10, 10);
            [clipLayer addSublayer:textLayer];
        }
#endif
        
    
        
        if ( [hitLayer isKindOfClass:[CAShapeLayerWithHitTest class]] && hitLayer.mask) {
            // 判断当前选中的是否为笔画的形状图层
            //hitLayer.strokeColor = [UIColor blackColor].CGColor;
            hitLayer.lineWidth = 0;
            
            if( hitLayer == lastTappedLayer )
                [self deselectTappedLayer];
            else {
                [self deselectTappedLayer];
            }
            
            lastTappedLayer = hitLayer;
            lastTappedLayer.delegate = self;
            
            //
            CGPoint touchPoint = [hitLayer convertPoint:p fromLayer:self.view.layer];
            NSLog(@"touchPoint:%@", NSStringFromCGPoint(touchPoint));
            NSArray *nearest = [UIBezierPath pointsAdjacent:hitLayer.path withPoint:touchPoint];
            
            UIBezierPath *drawingPath = [hitLayer valueForKey:kDrawingPathKey];
            if (drawingPath == nil) {
                drawingPath = [UIBezierPath bezierPath];
                [hitLayer setValue:drawingPath forKey:kDrawingPathKey];
            }
            if ([nearest firstObject]) {
                [drawingPath moveToPoint:[(NSValue *)[nearest firstObject] CGPointValue]];
            }
        }
//        else {
//            if (lastTappedLayer != nil) {
//                lastTappedLayerOriginalBorderColor = lastTappedLayer.borderColor;
//                lastTappedLayerOriginalBorderWidth = lastTappedLayer.borderWidth;
//                
//                lastTappedLayer.borderColor = [UIColor greenColor].CGColor;
//                lastTappedLayer.borderWidth = 3.0;
//            }
//        }
    }
    
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = touches.anyObject;
    CGPoint p = [touch locationInView:self.view];
    
    NSValue *vp = [NSValue valueWithCGPoint:p];
    
    self.points = [NSMutableArray arrayWithObjects:_points[1],_points[2],vp, nil];
    
    // 设置贝塞尔曲线的起始点和末尾点
    CGPoint p0 = [self.points[0] CGPointValue];
    CGPoint p1 = [self.points[1] CGPointValue];
    CGPoint p2 = [self.points[2] CGPointValue];
    
    CGPoint tempPoint1 = CGPointMake((p0.x + p1.x) * 0.5, (p0.y + p1.y) * 0.5);
    CGPoint tempPoint2 = CGPointMake((p1.x + p2.x) * 0.5, (p1.y + p2.y) * 0.5);
    
    // 估算贝塞尔曲线长度
    int x1 = fabs(tempPoint1.x - tempPoint2.x);
    int x2 = fabs(tempPoint1.y - tempPoint2.y);
    int len = (int)(sqrt(pow(x1, 2) + pow(x2, 2))*10);
    
    if ([self.contentView isKindOfClass:[SVGKLayeredImageView class]]) {
        
//        SVGKLayer* layerForHitTesting = (SVGKLayer*)self.contentView.layer;
//        
//        CALayer* hitLayer = [layerForHitTesting hitTest:p];
        
        if (lastTappedLayer) {
            // 暂时不判断是否超出了笔划形状的区域
            CGPoint touchPoint = [lastTappedLayer convertPoint:p fromLayer:self.view.layer];
            
            
            NSArray *nearest = [UIBezierPath pointsAdjacent:lastTappedLayer.path withPoint:touchPoint];
            
            UIBezierPath *drawingPath = [lastTappedLayer valueForKey:kDrawingPathKey];
            
            for (int i = 0; i < nearest.count; i++) {
                CGPoint nearestPoint = [(NSValue *)[nearest objectAtIndex:i] CGPointValue];
                NSLog(@"nearestPoint:%@", NSStringFromCGPoint(nearestPoint));
                [drawingPath addLineToPoint:nearestPoint];
            }
            
            lastTappedLayer.delegate = self;
            [lastTappedLayer setNeedsDisplay];
            
            //[self changeImage];
                        
//            NSArray * curvePoints = [self curveFactorizationWithFromPoint:tempPoint1 toPoint:tempPoint2 controlPoints:[NSArray arrayWithObject: self.points[1]] count:len];
//            
//            // 画每条线段
//            CGPoint lastPoint = tempPoint1;
//            
//            for (int i = 0; i< len ; i++) {
//                
//                // 省略多余点
//                CGFloat delta = sqrt(pow([curvePoints[i] CGPointValue].x - lastPoint.x, 2)+ pow([curvePoints[i] CGPointValue].y - lastPoint.y, 2));
//                
//                if (delta <1) {
//                    continue;
//                }
//                
//                lastPoint = CGPointMake([curvePoints[i] CGPointValue].x, [curvePoints[i]CGPointValue].y);
//                CGPoint touchPoint = [hitLayer convertPoint:p fromLayer:self.view.layer];
//                
//                [self.touchPath addLineToPoint:touchPoint];                
//            }
//            hitLayer.path = self.touchPath.CGPath;
        }
    }
}


- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    lastTappedLayer = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
