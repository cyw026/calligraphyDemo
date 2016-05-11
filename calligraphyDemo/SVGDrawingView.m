//
//  SVGDrawingView.m
//  calligraphyDemo
//
//  Created by sinogz on 16/5/10.
//  Copyright © 2016年 steven.cai. All rights reserved.
//

#import "SVGDrawingView.h"

@interface SVGDrawingView ()
{
    CAShapeLayer* lastTappedLayer;
    CGFloat lastTappedLayerOriginalBorderWidth;
    CGColorRef lastTappedLayerOriginalBorderColor;
    
    UIBezierPath *movingPath;
    UIImage *incrementalImage;
}

@end

@implementation SVGDrawingView

- (id)initWithSVGName:(NSString *)svgName
{
    SVGKImage *svgImage = [SVGKImage imageNamed:svgName];
    //svgImage.scale = 0.5;
    svgImage.size = CGSizeMake(375, 300);
    
    if (self = [super initWithSVGKImage:svgImage]) {
        self.showBorder = FALSE;
        movingPath = [UIBezierPath bezierPath];
    }
    return self;
}



// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    [super drawRect:rect];
    
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
    CGPoint p = [touch locationInView:self];
    
        SVGKLayer* layerForHitTesting = (SVGKLayer*)self.layer;
        CAShapeLayer* hitLayer = (CAShapeLayer*)[layerForHitTesting hitTest:p];
    
        if ( [hitLayer isKindOfClass:[CAShapeLayerWithHitTest class]]) {
            // 判断当前选中的是否为笔画的形状图层
            //hitLayer.strokeColor = [UIColor blackColor].CGColor;
            //hitLayer.lineWidth = 0;
            
            if( hitLayer == lastTappedLayer )
                [self deselectTappedLayer];
            else {
                [self deselectTappedLayer];
            }
            lastTappedLayer = [self getPathLayerByIndex:PATHLAYER_INDEX_TOP superlayer:hitLayer.superlayer];
            //
            
            
            UIBezierPath *drawingPath = [hitLayer valueForKey:kDrawingPathKey];
            if (drawingPath == nil) {
                drawingPath = [UIBezierPath bezierPath];
                drawingPath.lineJoinStyle = kCGLineJoinBevel;
                drawingPath.lineCapStyle = kCGLineCapRound;
                [hitLayer setValue:drawingPath forKey:kDrawingPathKey];
            }
            
            //[drawingPath moveToPoint:p1];
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

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = touches.anyObject;
    CGPoint p = [touch locationInView:self];
    CGPoint prevPoint = [touch previousLocationInView:self];
    
    //NSValue *vp = [NSValue valueWithCGPoint:p];
    
    if (!lastTappedLayer) {
        SVGKLayer* layerForHitTesting = (SVGKLayer*)self.layer;
        CALayer* hitLayer = [layerForHitTesting hitTest:p];
        NSLog(@"[hitLayer class]:%@", NSStringFromClass([hitLayer class]));
        if ([hitLayer isKindOfClass:[CAShapeLayerWithHitTest class]]) {
            lastTappedLayer = [self getPathLayerByIndex:PATHLAYER_INDEX_TOP superlayer:hitLayer.superlayer];
        }
    }
        
        if (lastTappedLayer) {
            // 暂时不判断是否超出了笔划形状的区域
            
            
            
            CAShapeLayer *layer_m = [self getPathLayerByIndex:PATHLAYER_INDEX_MIDDLE superlayer:lastTappedLayer.superlayer];
            CAShapeLayer *layer_l = [self getPathLayerByIndex:PATHLAYER_INDEX_LEFT superlayer:lastTappedLayer.superlayer];
            CAShapeLayer *layer_r = [self getPathLayerByIndex:PATHLAYER_INDEX_RIGHT superlayer:lastTappedLayer.superlayer];
            
            UIBezierPath *bezierPath_m = [UIBezierPath bezierPathWithCGPath:layer_m.path];
            UIBezierPath *bezierPath_l = [UIBezierPath bezierPathWithCGPath:layer_l.path];;
            UIBezierPath *bezierPath_r = [UIBezierPath bezierPathWithCGPath:layer_r.path];;
            
            BOOL bSubdivide = [lastTappedLayer valueForKey:kSubdivideFlagKey];
            
            if (!bSubdivide) {
                
                bezierPath_m = [UIBezierPath pathWithPath:[UIBezierPath bezierPathWithCGPath:layer_m.path]];
                bezierPath_l = [UIBezierPath pathWithPath:[UIBezierPath bezierPathWithCGPath:layer_l.path]];
                bezierPath_r = [UIBezierPath pathWithPath:[UIBezierPath bezierPathWithCGPath:layer_r.path]];
                
                layer_m.path = bezierPath_m.CGPath;
                layer_l.path = bezierPath_l.CGPath;
                layer_r.path = bezierPath_r.CGPath;
                
                [lastTappedLayer setValue:@(1) forKey:kSubdivideFlagKey];
            }
            
            
            CGPathRef path_m = bezierPath_m.CGPath;
            
            CGPoint prevTouch = [layer_m convertPoint:prevPoint fromLayer:self.layer];
            CGPoint touchPoint = [layer_m convertPoint:p fromLayer:self.layer];
            
            NSUInteger startIndex, endIndex;
            UIBezierPath *leftPath, *rightPath;
            
            CGPoint P1 = [UIBezierPath pointAdjacent:path_m withPoint:prevTouch index:&startIndex];
            CGPoint P2 = [UIBezierPath pointAdjacent:path_m withPoint:touchPoint index:&endIndex];
            
            CGPoint startPointOnLeft  = [layer_l convertPoint:P1 fromLayer:layer_m];
            CGPoint endPointOnLeft  = [layer_l convertPoint:P2 fromLayer:layer_m];
            
            CGPoint startPointOnRight = [layer_r convertPoint:P1 fromLayer:layer_m];
            CGPoint endPointOnRight = [layer_r convertPoint:P2 fromLayer:layer_m];
            
            
            if (startIndex < endIndex) {
                // 升序
                leftPath = [bezierPath_l pathWithStart:endPointOnLeft end:startPointOnLeft];
                rightPath = [bezierPath_r pathWithStart:startPointOnRight end:endPointOnRight];
            } else {
                // 降序
                leftPath = [bezierPath_l pathWithStart:startPointOnLeft end:endPointOnLeft];
                rightPath = [bezierPath_r pathWithStart:endPointOnRight end:startPointOnRight];
            }
            
            leftPath  = [leftPath covertPathFromLayer:layer_l toLayer:self.layer];
            rightPath = [rightPath covertPathFromLayer:layer_r toLayer:self.layer];
            
            bezierPath_m = [bezierPath_m covertPathFromLayer:layer_m toLayer:self.layer];
            
            if (CGPathIsEmpty(movingPath.CGPath)) {
                movingPath  = [leftPath combineWithPath:rightPath];
            } else {
                movingPath  = [leftPath combineWithPath:movingPath];
                movingPath = [movingPath combineWithPath:rightPath];
            }
            
            //NSArray *startPoint = leftPath.bezierElements[0];
            //[movingPath addLineToPoint:[startPoint[1] CGPointValue]];
            
            [movingPath closePath];
            
            //UIBezierPath *drawingPath = [lastTappedLayer valueForKey:kDrawingPathKey];
            //CGMutablePathRef newPath = CGPathCreateMutable();
            
            //CGPathAddPath(newPath, NULL, movingPath.CGPath);
            //CGPathAddPath(newPath, NULL, rightPath.CGPath);
            //CGPathCloseSubpath(newPath);
            //[drawingPath appendPath:[UIBezierPath bezierPathWithCGPath:newPath]];
            
            NSLog(@"drawingPath:%@", movingPath);
            
            //lastTappedLayer.delegate = self;
            //[lastTappedLayer setNeedsDisplay];
            
            CGRect bounds = self.bounds;
            
            UIGraphicsBeginImageContextWithOptions(bounds.size, YES, 0.0);
            
            CGPathRef clipPathRef = CGPathCreateCopy(lastTappedLayer.path);
            UIBezierPath *clipPath = [UIBezierPath bezierPathWithCGPath:clipPathRef];
            
            clipPath  = [clipPath covertPathFromLayer:lastTappedLayer toLayer:self.layer];
            
            
            
            if (!incrementalImage)
            {
                UIBezierPath *rectpath = [UIBezierPath bezierPathWithRect:self.bounds];
                [[UIColor whiteColor] setFill];
                [rectpath fill];
            }
            [incrementalImage drawAtPoint:CGPointZero];
            
            
            
            [[UIColor blackColor] setStroke];
            [[UIColor blackColor] setFill];
            
            
//            [clipPath fill];
//            
//            for (NSValue *v in clipPath.points) {
//                CGPoint point = [v CGPointValue];
//                UIBezierPath *pointPath = [UIBezierPath bezierPathWithArcCenter:point radius:1 startAngle:0 endAngle:M_PI * 2.0 clockwise:YES];
//                [[UIColor blueColor] set];
//                [pointPath stroke];
//                [pointPath fill];
//            }
            
            [clipPath addClip];
            
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
            
            [[UIColor blackColor] set];
            [movingPath stroke]; // ................. (8)
            [movingPath fill];
            
            
            
            incrementalImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            //[movingPath removeAllPoints];
            [self setNeedsDisplay];
            
        } else {
            NSLog(@"outOfBoundingBox");
            //            [movingPath closePath];
            //
            //            UIBezierPath *drawingPath = [lastTappedLayer valueForKey:kDrawingPathKey];
            //            [drawingPath appendPath:movingPath];
            //            lastTappedLayer.delegate = self;
            //            [lastTappedLayer setNeedsDisplay];
            //
            [movingPath removeAllPoints];
        }
 }


- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    //    UIBezierPath *drawingPath = [lastTappedLayer valueForKey:kDrawingPathKey];
    //    [movingPath closePath];
    //    [drawingPath appendPath:movingPath];
    [movingPath removeAllPoints];
//    lastTappedLayer.delegate = self;
//    [lastTappedLayer setNeedsDisplay];
    
    lastTappedLayer = nil;
}

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

@end
