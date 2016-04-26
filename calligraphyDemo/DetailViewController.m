//
//  DetailViewController.m
//  calligraphyDemo
//
//  Created by 蔡业文 on 16/4/24.
//  Copyright © 2016年 steven.cai. All rights reserved.
//

#import "DetailViewController.h"
#import "UIBezierPath-Points.h"

@interface DetailViewController () 
{
    CALayer* lastTappedLayer;
    CGFloat lastTappedLayerOriginalBorderWidth;
    CGColorRef lastTappedLayerOriginalBorderColor;
}

// 点集合
@property (nonatomic, strong) NSMutableArray *points;

@property (nonatomic, strong)UIBezierPath * touchPath;

@property (nonatomic, strong)UIBezierPath *originalPath;

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
    
    SVGKImage *document = [SVGKImage imageNamed:@"drawing.svg"];
    
    
    [self internalLoadedResource:svgSource parserOutput:nil createImageViewFromDocument:document];

    
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
        
        //[self.contentView removeFromSuperview];
        
        /******* swap the new contentview in ************/
        self.contentView = newContentView;
        
        /** set the border for new item */
        self.contentView.showBorder = FALSE;
        
        self.contentView.frame = CGRectMake(0, 64, 600, 600);
        
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

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
    //draw a thick red circle

    
    if ([layer isEqual:lastTappedLayer]) {
        
//        CAShapeLayer* touchLayer = [CAShapeLayer layer];
//        touchLayer.path = self.touchPath.CGPath;
//        touchLayer.fillColor = [UIColor blackColor].CGColor;
//        touchLayer.strokeColor = [UIColor redColor].CGColor;
//        touchLayer.lineWidth = 100;
        
        
        
        CGContextSetStrokeColorWithColor(ctx, [UIColor blackColor].CGColor);
        CGContextSetLineWidth(ctx, 60);
        
        CGContextAddPath(ctx, self.touchPath.CGPath);
        
        CGContextStrokePath(ctx);
        
        CGContextSaveGState(ctx);
        
    }
}

/**
 *  画图
 */
- (void)changeImage {
    
    UIGraphicsBeginImageContextWithOptions(self.view.frame.size, NO, 0);
    
    [self.lastImage drawInRect:self.view.bounds];
    
    UIImage *tempImage = UIGraphicsGetImageFromCurrentImageContext();
    
    self.lastImage = tempImage;
    
    UIGraphicsEndImageContext();
    
}


-(void) deselectTappedLayer
{
    if( lastTappedLayer != nil )
    {
        lastTappedLayer.borderWidth = lastTappedLayerOriginalBorderWidth;
        lastTappedLayer.borderColor = lastTappedLayerOriginalBorderColor;
        
        lastTappedLayer = nil;
    }
}

- (CALayer *)hitTest:(CGPoint)point
{
    
    NSArray *Identifiers= @[@"path3592", @"path4195", @"path4205", @"path4211", @"path10356", @"path4217"];

    for (int i = 0; i < 3; i++) {
        CALayer *hitLayer = [self.contentView.image layerWithIdentifier:Identifiers[i]];
        CGPoint newPoint = [hitLayer convertPoint:point fromLayer:self.view.layer];
        
        BOOL boundsContains = CGRectContainsPoint(hitLayer.bounds, newPoint);
        if (boundsContains) {
            return hitLayer;
        }
    }
    return nil;
}

#pragma mark - /*** 触摸事件 ***/

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = touches.anyObject;
    CGPoint p = [touch locationInView:self.view];
    
    NSValue *vp = [NSValue valueWithCGPoint:p];
    
    self.points = [NSMutableArray arrayWithObjects:vp,vp,vp, nil];
    
    
    if ([self.contentView isKindOfClass:[SVGKLayeredImageView class]]) {
        SVGKLayer* layerForHitTesting = (SVGKLayer*)self.contentView.layer;
        SVGKImage *image = layerForHitTesting.SVGImage;
        
        NSLog(@"hitLayer.DOMTree:%@", image.DOMTree);
        CAShapeLayer* hitLayer = (CAShapeLayer*)[layerForHitTesting hitTest:p];
        //SVGKImage *hitLayerImage = hitLayer.SVGImage;
        //NSLog(@"hitLayerImage:%@", hitLayerImage.DOMTree);
        
        if ([self hitTest:p]) {
            hitLayer = (CAShapeLayer*)[self hitTest:p];
        }
    
        
        if ([[hitLayer valueForKey:kSVGElementIdentifier] isEqualToString:@"path3592"] ||
            [[hitLayer valueForKey:kSVGElementIdentifier] isEqualToString:@"path10356"]||
            [[hitLayer valueForKey:kSVGElementIdentifier] isEqualToString:@"path4195"]||
            [[hitLayer valueForKey:kSVGElementIdentifier] isEqualToString:@"path4205"]||
            [[hitLayer valueForKey:kSVGElementIdentifier] isEqualToString:@"path4211"]||
            [[hitLayer valueForKey:kSVGElementIdentifier] isEqualToString:@"path4217"]) {
            //hitLayer.strokeColor = [UIColor blackColor].CGColor;
            hitLayer.lineWidth = 0;
            
            if( hitLayer == lastTappedLayer )
                [self deselectTappedLayer];
            else {
                [self deselectTappedLayer];
                
                self.originalPath = [UIBezierPath bezierPath];
                self.originalPath.CGPath = hitLayer.path;
            }
            
            lastTappedLayer = hitLayer;
            lastTappedLayer.delegate = self;
            
            //
            CGPoint touchPoint = [hitLayer convertPoint:p fromLayer:self.view.layer];
            NSLog(@"touchPoint:%@", NSStringFromCGPoint(touchPoint));
            
//            UIBezierPath *touchPath = [UIBezierPath bezierPathWithArcCenter:touchPoint radius:3 startAngle:0 endAngle:M_PI * 2.0 clockwise:YES];
//            CAShapeLayer* touchLayer = [CAShapeLayer layer];
//            touchLayer.path = touchPath.CGPath;
//            touchLayer.fillColor = [UIColor blackColor].CGColor;
//            touchLayer.strokeColor = [UIColor redColor].CGColor;
//            [hitLayer addSublayer:touchLayer];
//            [touchLayer display];
            
//            if (!self.originalPath) {
//                self.originalPath = [UIBezierPath bezierPath];
//                self.originalPath.CGPath = hitLayer.path;
//            }
            
            NSArray *nearest = [self.originalPath pointNearestArray:touchPoint];
            
            self.touchPath = [UIBezierPath bezierPath];
            if ([nearest firstObject]) {
                [self.touchPath moveToPoint:[(NSValue *)[nearest firstObject] CGPointValue]];
            }
            
            //[lastTappedLayer display];
            //hitLayer.path = self.touchPath.CGPath;
            
//            path.CGPath = hitLayer.path;
//            
//            NSArray *points = [path points];
//            
//            NSMutableArray *newPoints = [NSMutableArray array];
//            
//            for (int i = 0; i < points.count; i++) {
//                CGPoint point = [(NSValue *)[points objectAtIndex:i] CGPointValue];
//                NSLog(@"point:%@", NSStringFromCGPoint(point));
//                if (i == 5 || i == 6) {
//                    [newPoints addObject:[NSValue valueWithCGPoint:point]];
//                }
//            }
//            
//            UIBezierPath *newPath = [UIBezierPath pathWithPoints:newPoints];
//            hitLayer.path = newPath.CGPath;
            
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
        
        
        if ([[lastTappedLayer valueForKey:kSVGElementIdentifier] isEqualToString:@"path3592"] || [[lastTappedLayer valueForKey:kSVGElementIdentifier] isEqualToString:@"path10356"]|| [[lastTappedLayer valueForKey:kSVGElementIdentifier] isEqualToString:@"path4195"]||
            [[lastTappedLayer valueForKey:kSVGElementIdentifier] isEqualToString:@"path4205"]||
            [[lastTappedLayer valueForKey:kSVGElementIdentifier] isEqualToString:@"path4211"]||
            [[lastTappedLayer valueForKey:kSVGElementIdentifier] isEqualToString:@"path4217"]) {
            //
            CGPoint touchPoint = [lastTappedLayer convertPoint:p fromLayer:self.view.layer];
            
            
            NSArray *nearest = [self.originalPath pointNearestArray:touchPoint];
            
            for (int i = 0; i < nearest.count; i++) {
                
                CGPoint nearestPoint = [(NSValue *)[nearest objectAtIndex:i] CGPointValue];
                NSLog(@"nearestPoint:%@", NSStringFromCGPoint(nearestPoint));
                
                [self.touchPath addLineToPoint:nearestPoint];
            }
            
            lastTappedLayer.delegate = self;
            [lastTappedLayer setNeedsDisplay];
            
            //[self changeImage];
            
            //((CAShapeLayer*)lastTappedLayer).path = self.touchPath.CGPath;
            
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

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/**
 *  分解贝塞尔曲线
 */
- (NSArray *)curveFactorizationWithFromPoint:(CGPoint) fPoint toPoint:(CGPoint) tPoint controlPoints:(NSArray *)points count:(int) count {
    
    // 如果分解数量为0，生成默认分解数量
    if (count == 0) {
        int x1 = fabs(fPoint.x - tPoint.x);
        int x2 = fabs(fPoint.y - tPoint.y);
        count = (int)sqrt(pow(x1, 2) + pow(x2, 2));
    }
    
    // 计算贝塞尔曲线
    CGFloat s = 0.0;
    NSMutableArray *t = [NSMutableArray array];
    CGFloat pc = 1/(CGFloat)count;
    
    int power = (int)(points.count + 1);
    
    
    for (int i =0; i<= count + 1; i++) {
        
        [t addObject:[NSNumber numberWithFloat:s]];
        s = s + pc;
        
    }
    
    NSMutableArray *newPoints = [NSMutableArray array];
    
    for (int i =0; i<=count +1; i++) {
        
        CGFloat resultX = fPoint.x * [self bezMakerWithN:power K:0 T:[t[i] floatValue]] + tPoint.x * [self bezMakerWithN:power K:power T:[t[i] floatValue]];
        
        for (int j = 1; j<= power -1; j++) {
            
            resultX += [points[j-1] CGPointValue].x * [self bezMakerWithN:power K:j T:[t[i] floatValue]];
            
        }
        
        CGFloat resultY = fPoint.y * [self bezMakerWithN:power K:0 T:[t[i] floatValue]] + tPoint.y * [self bezMakerWithN:power K:power T:[t[i] floatValue]];
        
        for (int j = 1; j<= power -1; j++) {
            
            resultY += [points[j-1] CGPointValue].y * [self bezMakerWithN:power K:j T:[t[i] floatValue]];
            
        }
        
        [newPoints addObject:[NSValue valueWithCGPoint:CGPointMake(resultX, resultY)]];
    }
    return newPoints;
    
}



- (CGFloat)compWithN:(int)n andK:(int)k {
    int s1 = 1;
    int s2 = 1;
    
    if (k == 0) {
        return 1.0;
    }
    
    for (int i = n; i>=n-k+1; i--) {
        s1 = s1*i;
    }
    for (int i = k;i>=2;i--) {
        s2 = s2 *i;
    }
    
    CGFloat res = (CGFloat)s1/s2;
    return  res;
}

- (CGFloat)realPowWithN:(CGFloat)n K:(int)k {
    
    if (k == 0) {
        return 1.0;
    }
    
    return pow(n, (CGFloat)k);
}

- (CGFloat)bezMakerWithN:(int)n K:(int)k T:(CGFloat)t {
    
    return [self compWithN:n andK:k] * [self realPowWithN:1-t K:n-k] * [self realPowWithN:t K:k];
    
    
}

@end
