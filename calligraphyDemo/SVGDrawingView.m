//
//  SVGDrawingView.m
//  calligraphyDemo
//
//  Created by sinogz on 16/5/10.
//  Copyright © 2016年 steven.cai. All rights reserved.
//

#import "SVGDrawingView.h"
#import "Stroke.h"
#import "OutsideStrokingView.h"

#define DASHLINE_ENABLE 0
@interface SVGDrawingView ()
{
    
    CGFloat lastTappedLayerOriginalBorderWidth;
    CGColorRef lastTappedLayerOriginalBorderColor;
    
    UIBezierPath *movingPath;
    UIBezierPath *outSidePath;
    UIImage *incrementalImage;
    
    NSUInteger strokeCount;
    NSUInteger currStep;
    
    CGPoint lastPoint;
    NSTimer *timer;
    NSSet   *mTouches; //刚超出笔划的触摸点
}

@property (nonatomic, strong) NSMutableArray *strokeArray;

@property (nonatomic, strong) PaintingView *outsideStrokingView;

@property (nonatomic, retain) CAShapeLayer *lastTappedLayer;


@end

@implementation SVGDrawingView

- (NSMutableArray *)strokeArray
{
    if (_strokeArray == nil) {
        _strokeArray = [NSMutableArray array];
    }
    return _strokeArray;
}

- (id)initWithSVGName:(NSString *)svgName
{
    SVGKImage *svgImage = [SVGKImage imageNamed:svgName];
    //svgImage.scale = 0.5;
    svgImage.size = CGSizeMake(400, 350);
    
    if (self = [super initWithSVGKImage:svgImage]) {
        self.showBorder = FALSE;
        movingPath = [UIBezierPath bezierPath];
        outSidePath = [UIBezierPath bezierPath];
        currStep = 0;
        
        UIImage *image = [UIImage imageNamed:@"paintingView_BG"];
        self.backgroundColor = [UIColor colorWithPatternImage:image];
        
        [self parseStrokeInfomation];
        
        
        
        _outsideStrokingView = [[PaintingView alloc] initWithFrame:self.bounds];
        _outsideStrokingView.backgroundColor = [UIColor clearColor];
        // Defer to the OpenGL view to set the brush color
        [_outsideStrokingView setBrushColorWithRed:0.0 green:0.0 blue:0];
        _outsideStrokingView.userInteractionEnabled = NO;
        
        [self addSubview:_outsideStrokingView];
        
        [self setupDrawingLayer];
        
        // 2s之后开始播放第一笔划的指引动画
        timer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(palyAnimation) userInfo:nil repeats:NO];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _outsideStrokingView.frame = self.bounds;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    [super drawRect:rect];
    
    /**
     *  绘制笔划填充颜色
     *
     *  @return 由于直接在SVG文件填充会遮盖住绘制的笔划，所以在这里才根据路径重新填充
     */
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    for (Stroke *stroke in self.strokeArray) {
        CGPathRef path = stroke.contourPath.CGPath;
        CGContextSetFillColorWithColor(ctx, stroke.fillColor.CGColor);
        CGContextAddPath(ctx, path);
        CGContextFillPath(ctx);
        CGContextSaveGState(ctx);
        
        if ( stroke.bShowDashLine && DASHLINE_ENABLE) {
            path = stroke.guidesPath_DL.CGPath;
            CGContextSetStrokeColorWithColor(ctx, [UIColor colorWithRed:0.50 green:0.84 blue:1. alpha:1.].CGColor);
            CGFloat lengths[] = {15,5,5,5};
            CGContextSetLineDash(ctx, 0, lengths, 4);
            CGContextAddPath(ctx, path);
            CGContextStrokePath(ctx);
            CGContextSaveGState(ctx);
        }
    }
    
    [incrementalImage drawInRect:rect];
}


/**
 *  在当前图形绘制触摸产生的笔划
 *
 *  @param layer 当前选中绘制的笔划图形所在图层
 *  @param ctx   当前图层的图形上下文
 */
//- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
//{
//    //if ([layer isEqual:lastTappedLayer])
//    {
//        
//        //        UIGraphicsPushContext(ctx);
//        //        [self.lastImage drawInRect:layer.frame];
//        //        UIGraphicsPopContext();
//        
//        CGContextSaveGState(ctx);
//        CGContextSetStrokeColorWithColor(ctx, [UIColor blackColor].CGColor);
//        CGContextSetFillColorWithColor(ctx, [UIColor blackColor].CGColor);
//        
//        CGContextSetLineJoin(ctx, kCGLineJoinBevel);
//        CGContextSetLineCap(ctx, kCGLineCapButt);
//        CGContextSetLineWidth(ctx, 1);
//        
//        UIBezierPath *drawingPath = [layer valueForKey:kDrawingPathKey];
//        CGContextAddPath(ctx, drawingPath.CGPath);
//        
//        //CGContextAddPath(ctx, movingPath.CGPath);
//        
//        
//        //CGContextStrokePath(ctx);
//        
//        
//        //CGContextSetLineJoin(ctx, kCGLineJoinRound);
//        //CGContextSetLineCap(ctx, kCGLineCapRound);
//        //CGContextSetLineWidth(ctx, 5);
//        
//        //UIBezierPath *drawingPath = [layer valueForKey:kDrawingPathKey];
//        //CGContextAddPath(ctx, drawingPath.CGPath);
//        
//        CGContextFillPath(ctx);
//        
//        //CGContextDrawPath(ctx, kCGPathFillStroke);
//        
//        CGContextSaveGState(ctx);
//        
//        //        CGImageRef imageRef = CGBitmapContextCreateImage(ctx);
//        //        self.lastImage = [UIImage imageWithCGImage:imageRef];
//        //        CFRelease(imageRef);
//        
//    }
//}

- (void) setupDrawingLayer
{
    [self.penLayer removeFromSuperlayer];
    self.penLayer = nil;
    
    UIImage *penImage = [UIImage imageNamed:@"finger.png"];
    CALayer *penLayer = [CALayer layer];
    penLayer.contents = (id)penImage.CGImage;
    penLayer.anchorPoint = CGPointMake(0.38, 0.1);
    penLayer.frame = CGRectMake(0.0f, 0.0f, penImage.size.width, penImage.size.height);
    penLayer.hidden = YES;
    [self.layer addSublayer:penLayer];
    
    self.penLayer = penLayer;
}

/**
 *  播放手势动画
 */
- (void) palyAnimation
{
    Stroke *stroke;
    [self.penLayer removeAllAnimations];
    
    for (Stroke *obj in self.strokeArray) {
        if (!obj.animPlayFlag) {
            stroke = obj;
            currStep = [self.strokeArray indexOfObject:obj];
            break;
        }
    }
    // 如果存在未播放动画的笔划
    if (stroke) {
        // 1、高亮显示当前笔划
        stroke.fillColor = [UIColor redColor];
        stroke.bShowDashLine = YES;
        [self setNeedsDisplay];
        // 2、添加动画
        self.penLayer.hidden = NO;
        CAKeyframeAnimation *penAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
        penAnimation.duration = 2.0;
        penAnimation.path = stroke.guidesPath_M.CGPath;
        penAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        penAnimation.removedOnCompletion = NO;
        penAnimation.repeatCount = MAXFLOAT;
        penAnimation.delegate = self;
        [self.penLayer addAnimation:penAnimation forKey:@"position"];
    }
}

/**
 *  停止播放手势动画
 */
- (void)stopAnimation
{
    [self.penLayer removeAllAnimations];
    self.penLayer.hidden = YES;
    if ([timer isValid]) {
        [timer invalidate];
    }
}

- (void) animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    //self.penLayer.hidden = YES;
}


/**
 *  取消当前图层的选中状态
 */
-(void) deselectTappedLayer
{
    if( _lastTappedLayer != nil )
    {
        _lastTappedLayer.borderWidth = lastTappedLayerOriginalBorderWidth;
        _lastTappedLayer.borderColor = lastTappedLayerOriginalBorderColor;
        
        _lastTappedLayer = nil;
    }
}

#pragma mark - /*** 触摸事件 ***/

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = touches.anyObject;
    CGPoint p = [touch locationInView:self];
    
    // 停止手势动画
    [self stopAnimation];
    
//    _lastTappedLayer = [self getTappedLayerWithPoint:p strokeWidth:3];
    NSInteger rangge;
    _lastTappedLayer = [self getCurrentStrokeLayerWithPoint:p range:&rangge];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = touches.anyObject;
    CGPoint p = [touch locationInView:self];
    CGPoint prevPoint = [touch previousLocationInView:self];
    
    
    NSInteger border = 20;
    NSInteger rangge;
    
    if (_lastTappedLayer) {
        // 判断是否还在当前笔划范围
        Stroke *stroke = [self strokeByIdentifier:[_lastTappedLayer valueForKey:kSVGElementIdentifier]];
        CGPathRef strokingPath = CGPathCreateCopyByStrokingPath(stroke.contourPath.CGPath, nil, border, kCGLineCapRound, kCGLineJoinRound, 4);
        BOOL containsStroking = CGPathContainsPoint(strokingPath, NULL, p, false);
        BOOL containsPath = CGPathContainsPoint(stroke.contourPath.CGPath, NULL, p, false);
        if (!containsPath) {
            // 超出笔划区域
            if (!containsStroking) {
                // 超出笔划边缘20像素
                _lastTappedLayer = nil;
                CAShapeLayer *nextStroke = [self getCurrentStrokeLayerWithPoint:p range:&rangge];
                if (nextStroke && ![nextStroke isEqual:_lastTappedLayer]) {
                    Stroke *stroke = [self strokeByIdentifier:[nextStroke valueForKey:kSVGElementIdentifier]];
                    NSUInteger startIndex, endIndex;
                    CGPoint mid_prev = [UIBezierPath pointAdjacent:stroke.guidesPath_M.CGPath withPoint:prevPoint index:&startIndex];
                    CGPoint mid_curr = [UIBezierPath pointAdjacent:stroke.guidesPath_M.CGPath withPoint:p index:&endIndex];
                    float distance = sqrtf((mid_curr.x - mid_prev.x) * (mid_curr.x - mid_prev.x) + (mid_curr.y - mid_prev.y) * (mid_curr.y - mid_prev.y));
                    if (distance > 5) {
                        _lastTappedLayer = nextStroke;
                    }
                }
            } else {
                mTouches = touches;
            }
        }
    }
    else {
        CAShapeLayer *nextStroke = [self getTappedLayerWithPoint:p strokeWidth:0];
        if (nextStroke && ![nextStroke isEqual:_lastTappedLayer]) {
            
            Stroke *stroke = [self strokeByIdentifier:[nextStroke valueForKey:kSVGElementIdentifier]];
            NSUInteger startIndex, endIndex;
            CGPoint mid_prev = [UIBezierPath pointAdjacent:stroke.guidesPath_M.CGPath withPoint:prevPoint index:&startIndex];
            CGPoint mid_curr = [UIBezierPath pointAdjacent:stroke.guidesPath_M.CGPath withPoint:p index:&endIndex];
            float distance = sqrtf((mid_curr.x - mid_prev.x) * (mid_curr.x - mid_prev.x) + (mid_curr.y - mid_prev.y) * (mid_curr.y - mid_prev.y));
            if (distance > 3) {
                _lastTappedLayer = nextStroke;
            }
        }
    }

    CGRect bounds = self.bounds;
    
    UIGraphicsBeginImageContextWithOptions(bounds.size, NO, 0.0);
    
    if (incrementalImage)
    {
        [incrementalImage drawAtPoint:CGPointZero];
    }
    
    [[UIColor blackColor] setStroke];
    [[UIColor blackColor] setFill];
    [[UIColor blackColor] set];
    
    // 停止手势动画，把当前笔划标记为已播放
    [self stopAnimation];
    
        if (_lastTappedLayer) {
            // 暂时不判断是否超出了笔划形状的区域
            
            Stroke *stroke = [self strokeByIdentifier:[_lastTappedLayer valueForKey:kSVGElementIdentifier]];
            stroke.animPlayFlag = 1;
            
            NSUInteger startIndex, endIndex;
            UIBezierPath *leftPath, *rightPath;
            // 滑动前后两点
            CGPoint P1 = [UIBezierPath pointAdjacent:stroke.guidesPath_M.CGPath withPoint:prevPoint index:&startIndex];
            CGPoint P2 = [UIBezierPath pointAdjacent:stroke.guidesPath_M.CGPath withPoint:p index:&endIndex];
            lastPoint = P2;
            
            NSInteger d = 10;
            if (startIndex <= endIndex) {
                // 升序
                BOOL forceStart = startIndex < d ? YES:NO;
                BOOL forceEnd   = stroke.guidesPath_M.points.count - endIndex < d ? YES:NO;
                // 靠近两端的直接取起hkok或者终点
                leftPath = [stroke.guidesPath_L pathWithStart:P2 end:P1 forceStart:forceEnd forceEnd:forceStart];
                rightPath = [stroke.guidesPath_R pathWithStart:P1 end:P2 forceStart:forceStart forceEnd:forceEnd];
                
                outSidePath.CGPath = [leftPath combineWithPath:rightPath].CGPath;
                
                if (CGPathIsEmpty(movingPath.CGPath)) {
                    movingPath  = [leftPath combineWithPath:rightPath];
                } else {
                    movingPath  = [leftPath combineWithPath:movingPath];
                    movingPath = [movingPath combineWithPath:rightPath];
                }
                
            } else {
                // 降序
                BOOL forceStart = endIndex < d ? YES:NO;
                BOOL forceEnd   = stroke.guidesPath_M.points.count - startIndex < d ? YES:NO;
                
                leftPath = [stroke.guidesPath_L pathWithStart:P1 end:P2 forceStart:forceEnd forceEnd:forceStart];
                rightPath = [stroke.guidesPath_R pathWithStart:P2 end:P1 forceStart:forceStart forceEnd:forceEnd];
                
                outSidePath.CGPath = [rightPath combineWithPath:leftPath].CGPath;
                if (CGPathIsEmpty(movingPath.CGPath)) {
                    movingPath  = [rightPath combineWithPath:leftPath];
                } else {
                    movingPath  = [rightPath combineWithPath:movingPath];
                    movingPath = [movingPath combineWithPath:leftPath];
                }
            }
            
            
            [movingPath closePath];
            
            
            
            [stroke.contourPath addClip];
            
            
//            [clipPath fill];
//
//            for (NSValue *v in clipPath.points) {
//                CGPoint point = [v CGPointValue];
//                UIBezierPath *pointPath = [UIBezierPath bezierPathWithArcCenter:point radius:1 startAngle:0 endAngle:M_PI * 2.0 clockwise:YES];
//                [[UIColor blueColor] set];
//                [pointPath stroke];
//                [pointPath fill];
//            }
            
//            for (NSValue *v in rightPath.points) {
//                CGPoint point = [v CGPointValue];
//                UIBezierPath *pointPath = [UIBezierPath bezierPathWithArcCenter:point radius:2 startAngle:0 endAngle:M_PI * 2.0 clockwise:YES];
//                [[UIColor redColor] set];
//                [pointPath stroke];
//            }
//            
//            for (NSValue *v in leftPath.points) {
//                CGPoint point = [v CGPointValue];
//                UIBezierPath *pointPath = [UIBezierPath bezierPathWithArcCenter:point radius:2 startAngle:0 endAngle:M_PI * 2.0 clockwise:YES];
//                [[UIColor greenColor] set];
//                [pointPath stroke];
//            }
            
//            for (NSValue *v in bezierPath_m.points) {
//                CGPoint point = [v CGPointValue];
//                UIBezierPath *pointPath = [UIBezierPath bezierPathWithArcCenter:point radius:1 startAngle:0 endAngle:M_PI * 2.0 clockwise:YES];
//                [[UIColor redColor] set];
//                [pointPath stroke];
//            }
            
            [movingPath stroke];
            [movingPath fill];
            
            //[self.outsideStrokingView touchesEnded:touches withEvent:event];
            //[self.outsideStrokingView touchesBegan:touches withEvent:event];

        } else {
            //NSLog(@"outOfBoundingBox");
            [movingPath removeAllPoints];
            
            //_lastTappedLayer = [self getTappedLayerWithPoint:p strokeWidth:20];
//            if (_lastTappedLayer) {
//                // 边缘过渡笔划
//                Stroke *stroke = [self strokeByIdentifier:[_lastTappedLayer valueForKey:kSVGElementIdentifier]];
//                stroke.animPlayFlag = 1;
//                
//                NSUInteger startIndex, endIndex;
//                UIBezierPath *leftPath, *rightPath;
//                // 滑动前后两点
//                CGPoint P1 = [UIBezierPath pointAdjacent:stroke.guidesPath_M.CGPath withPoint:prevPoint index:&startIndex];
//                CGPoint P2 = [UIBezierPath pointAdjacent:stroke.guidesPath_M.CGPath withPoint:p index:&endIndex];
//                lastPoint = P2;
//                
//                NSInteger d = 5;
//                if (startIndex <= endIndex) {
//                    // 升序
//                    BOOL forceStart = startIndex < d ? YES:NO;
//                    BOOL forceEnd   = stroke.guidesPath_M.points.count - endIndex < d ? YES:NO;
//                    // 靠近两端的直接取起hkok或者终点
//                    leftPath = [stroke.guidesPath_L pathWithStart:P2 end:P1 forceStart:forceEnd forceEnd:forceStart];
//                    rightPath = [stroke.guidesPath_R pathWithStart:P1 end:P2 forceStart:forceStart forceEnd:forceEnd];
//                    
//                    outSidePath.CGPath = [leftPath combineWithPath:rightPath].CGPath;
//                    
//                } else {
//                    // 降序
//                    BOOL forceStart = endIndex < d ? YES:NO;
//                    BOOL forceEnd   = stroke.guidesPath_M.points.count - startIndex < d ? YES:NO;
//                    
//                    leftPath = [stroke.guidesPath_L pathWithStart:P1 end:P2 forceStart:forceEnd forceEnd:forceStart];
//                    rightPath = [stroke.guidesPath_R pathWithStart:P2 end:P1 forceStart:forceStart forceEnd:forceEnd];
//                    
//                    outSidePath.CGPath = [rightPath combineWithPath:leftPath].CGPath;
//                }
//                
//                
//                [outSidePath closePath];
//                
//                CGPoint offset = CGPointMake(p.x - P2.x, p.y - P2.y);
//                CGAffineTransform t = CGAffineTransformMakeTranslation(offset.x/2, offset.y/2 );
//                CGPathRef strokingPath = CGPathCreateCopyByTransformingPath(outSidePath.CGPath, &t);
//                UIBezierPath *newPath = [UIBezierPath bezierPathWithCGPath:strokingPath];
//                //newPath.lineCapStyle = kCGLineCapRound;
//                //newPath.lineJoinStyle = kCGLineJoinRound;
//                [newPath setLineWidth:5];
//                [newPath stroke]; // ................. (8)
//                [newPath fill];
//            }
            
            // 模拟笔划
            
//            [stroke addPoint:p withWidth:10 andColor:[UIColor blackColor]];
//            
//            // draw each stroke element
//            AbstractBezierPathElement* previousElement = nil;
//            for(AbstractBezierPathElement* segment in stroke.segments){
//                
//                if (![segment isKindOfClass:[CurveToPathElement class]]) {
//                    continue;
//                }
//                
//                CurveToPathElement *element = (CurveToPathElement*)segment;
//                
//                
//                // setup the correct initial width
//                __block CGFloat lastWidth;
//                if(previousElement){
//                    lastWidth = previousElement.width;
//                }else{
//                    lastWidth = element.width;
//                }
//                
//                NSInteger numberOfSteps = [element numberOfSteps];
//                CGFloat realStepSize = [element lengthOfElement] / numberOfSteps;
//                
//                CGFloat prevWidth = previousElement.width;
//                CGFloat widthDiff = element.width - prevWidth;
//                
//                // calculate points along the curve that are realStepSize
//                // length along the curve. since this is fairly intensive for
//                // the CPU, we'll cache the results
//                for(int step = 0; step < numberOfSteps; step++) {
//                    // 0 <= t < 1 representing where we are in the stroke element
//                    CGFloat t = (CGFloat)step / (CGFloat)numberOfSteps;
//                    
//                    CGPoint point = [element subdivideBezierAtLength:realStepSize*step];
//                    
//                    UIBezierPath *pointPath = [UIBezierPath bezierPathWithArcCenter:point radius:5 startAngle:0 endAngle:M_PI * 2.0 clockwise:YES];
//
//                    
//                    //[pointPath setLineWidth:10];
//                    [pointPath stroke]; // ................. (8)
//                    [pointPath fill];
//                    
//                    
//                    // set vertex point size
//                    //CGFloat steppedWidth = prevWidth + widthDiff * t;
//                }
//                
//                previousElement = element;
//            }
            
                        //if(!element)
            
            if (mTouches) {
                [self.outsideStrokingView touchesMoved:mTouches withEvent:event];
                mTouches = nil;
            }
            [self.outsideStrokingView touchesMoved:touches withEvent:event];
        }
    
    incrementalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    //[movingPath removeAllPoints];
    [self setNeedsDisplay];
 }


- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [movingPath removeAllPoints];
    [outSidePath removeAllPoints];
    
    Stroke *stroke = [self.strokeArray objectAtIndex:currStep];
    stroke.fillColor = nil;
    stroke.bShowDashLine = NO;
    [self setNeedsDisplay];
    // 倒计时2s之后重新开始动画
    timer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(palyAnimation) userInfo:nil repeats:NO];
    
    _lastTappedLayer = nil;
    [self.outsideStrokingView touchesEnded:touches withEvent:event];
}

- (CAShapeLayer *)getTappedLayerWithPoint: (CGPoint)point strokeWidth:(CGFloat)strokeWidth
{
    CAShapeLayer *layer = nil;
    SVGKLayer* layerForHitTesting = (SVGKLayer*)self.layer;
    NSInteger count = self.strokeArray.count;
    
    // 重新获取触摸点所在笔划。
    for (NSInteger i = count - 1; i >= 0; i--) {
        Stroke *stroke = [self.strokeArray objectAtIndex:i];
        CGPathRef strokingPath = CGPathCreateCopyByStrokingPath(stroke.contourPath.CGPath, nil, strokeWidth*2, kCGLineCapRound, kCGLineJoinRound, 4);
        // 处于笔划轮廓内或轮廓上均视为在该笔划区域内
        if (CGPathContainsPoint(stroke.contourPath.CGPath, NULL, point, false) || CGPathContainsPoint(strokingPath, NULL, point, false)) {
            layer = (CAShapeLayer*)[layerForHitTesting.SVGImage layerWithIdentifier:stroke.identifier];
            break;
        }
    }
    return layer;
}

- (CAShapeLayer *)getCurrentStrokeLayerWithPoint: (CGPoint)point range:(NSInteger*)range
{
    CAShapeLayer *layer = nil;
    SVGKLayer* layerForHitTesting = (SVGKLayer*)self.layer;
    NSInteger count = self.strokeArray.count;
    *range = 0;
    while (*range < 10) {
        
        for (NSInteger i = count - 1; i >= 0; i--) {
            Stroke *stroke = [self.strokeArray objectAtIndex:i];
            CGPathRef strokingPath = CGPathCreateCopyByStrokingPath(stroke.contourPath.CGPath, nil, *range*2, kCGLineCapRound, kCGLineJoinRound, 4);
            // 处于笔划轮廓内或轮廓上均视为在该笔划区域内
            if (CGPathContainsPoint(stroke.contourPath.CGPath, NULL, point, false) || CGPathContainsPoint(strokingPath, NULL, point, false)) {
                layer = (CAShapeLayer*)[layerForHitTesting.SVGImage layerWithIdentifier:stroke.identifier];
                break;
            }
        }
        if (layer) {
            break;
        }
        
        *range += 1;
    }
    return layer;
}


#pragma mark -- PRIVATE METHOD

- (CAShapeLayer *)getPathLayerByIndex:(PATHLAYER_INDEX) index superlayer:(CALayer*)superlayer
{
    CAShapeLayer *shapeLayer;
    
    if (superlayer.sublayers.count == 4 && [superlayer isKindOfClass:[CALayerWithChildHitTest class]]) {
        
        CALayer *pathLayer = superlayer.sublayers[index];
        
        if ([pathLayer isKindOfClass:[CAShapeLayerWithHitTest class]]) {
            
            shapeLayer = (CAShapeLayerWithHitTest *)pathLayer;
        }
    }
    return shapeLayer;
}

- (Stroke *)strokeByIdentifier:(NSString *)identifier
{
    for (Stroke *stroke in self.strokeArray) {
        if ([stroke.identifier isEqualToString:identifier]) {
            return stroke;
        }
    }
    return nil;
}

- (void)parseStrokeInfomation
{
    SVGKLayer* selfLayer = (SVGKLayer*)self.layer;
    CALayer *groupLayer = [selfLayer.SVGImage layerWithIdentifier:@"stroke_group"];
    
    
    
    NSDate* tmpStartData = [NSDate date];
    
    for (CALayer *child in groupLayer.sublayers) {
        
        Stroke *stroke = [[Stroke alloc] init];
        
        // 根据索引分别得到笔划轮廓的路径和左中右三条辅助线
        CAShapeLayer *layer_l = [self getPathLayerByIndex:PATHLAYER_INDEX_LEFT superlayer:child];
        CAShapeLayer *layer_m = [self getPathLayerByIndex:PATHLAYER_INDEX_MIDDLE superlayer:child];
        CAShapeLayer *layer_r = [self getPathLayerByIndex:PATHLAYER_INDEX_RIGHT superlayer:child];
        CAShapeLayer *layer_c = [self getPathLayerByIndex:PATHLAYER_INDEX_CONTOUR superlayer:child];
        
        // 记录轮廓路径的ID
        stroke.identifier = [layer_c valueForKey:kSVGElementIdentifier];
        
        NSLog(@"l:%@, m:%@, r:%@, c:%@", [layer_l valueForKey:kSVGElementIdentifier], [layer_m valueForKey:kSVGElementIdentifier], [layer_r valueForKey:kSVGElementIdentifier], [layer_c valueForKey:kSVGElementIdentifier]);
        
        stroke.guidesPath_L = [UIBezierPath bezierPathWithCGPath:layer_l.path];
        stroke.guidesPath_M = [UIBezierPath bezierPathWithCGPath:layer_m.path];
        stroke.guidesPath_R = [UIBezierPath bezierPathWithCGPath:layer_r.path];
        stroke.contourPath  = [UIBezierPath bezierPathWithCGPath:layer_c.path];
        
        [self generateAuxiliaryLine:stroke layer:layer_c];
        
        // 把原始左中右三条辅助线拆分重新赋值给对应图层
        stroke.guidesPath_L = [UIBezierPath pathWithPath:stroke.guidesPath_L];
        stroke.guidesPath_M = [UIBezierPath pathWithPath:stroke.guidesPath_M];
        stroke.guidesPath_R = [UIBezierPath pathWithPath:stroke.guidesPath_R];
            
        layer_m.path = stroke.guidesPath_M.CGPath;
        layer_l.path = stroke.guidesPath_L.CGPath;
        layer_r.path = stroke.guidesPath_R.CGPath;
        
        // 把所有路径的坐标信息都转换到绘制图层
        stroke.guidesPath_L  = [stroke.guidesPath_L covertPathFromLayer:layer_l toLayer:self.layer];
        stroke.guidesPath_M  = [stroke.guidesPath_M covertPathFromLayer:layer_m toLayer:self.layer];
        stroke.guidesPath_R  = [stroke.guidesPath_R covertPathFromLayer:layer_r toLayer:self.layer];
        stroke.contourPath   = [stroke.contourPath covertPathFromLayer:layer_c toLayer:self.layer];
        
        [self.strokeArray addObject:stroke];
    }
    
    double deltaTime = [[NSDate date] timeIntervalSinceDate:tmpStartData];
    NSLog(@">>>>>>>>>>cost time = %f ms", deltaTime*1000);
    
}

/**
 *  生成对应笔划的辅助虚线
 *
 *  @param stroke 笔划
 *  @param layer  笔划图层
 */
- (void)generateAuxiliaryLine:(Stroke *)stroke layer:(CAShapeLayer *)layer
{
    CGRect rect = [layer convertRect:layer.frame toLayer:self.layer];
    
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, rect.origin.y)];
    [path addLineToPoint:CGPointMake(self.frame.size.width, rect.origin.y)];
    //[path closePath];
    
    [path moveToPoint:CGPointMake(0, rect.origin.y + rect.size.height)];
    [path addLineToPoint:CGPointMake(self.frame.size.width, rect.origin.y + rect.size.height)];
    //[path closePath];
    
    
    [path moveToPoint:CGPointMake(rect.origin.x, 0)];
    [path addLineToPoint:CGPointMake(rect.origin.x, self.frame.size.height)];
    //[path closePath];
    
    [path moveToPoint:CGPointMake(rect.origin.x + rect.size.width, 0)];
    [path addLineToPoint:CGPointMake(rect.origin.x + rect.size.width, self.frame.size.height)];
    //[path closePath];
    
    stroke.guidesPath_DL = path;
}
/**
 *  生成预览图片
 */
- (void)preview
{
    UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, 0);

//    UIGraphicsBeginImageContext(CGSizeMake(self.frame.size.width, self.frame.size.height));
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    [self.layer renderInContext:contextRef];
    
    UIImage *glImage = [self.outsideStrokingView snapshot];
    [glImage drawAtPoint:CGPointMake(0,0)];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImageWriteToSavedPhotosAlbum(image, self, nil, nil);
}

- (void)dealloc
{
    NSLog(@"dealloc");
}

@end
