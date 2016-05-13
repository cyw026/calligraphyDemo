/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import "UIBezierPath-Points.h"

#define POINTSTRING(_CGPOINT_) (NSStringFromCGPoint(_CGPOINT_))
#define VALUE(_INDEX_) [NSValue valueWithCGPoint:points[_INDEX_]]
#define POINT(_INDEX_) [(NSValue *)[points objectAtIndex:_INDEX_] CGPointValue]

// Return distance between two points
static float distance (CGPoint p1, CGPoint p2)
{
	float dx = p2.x - p1.x;
	float dy = p2.y - p1.y;
	
	return sqrt(dx*dx + dy*dy);
}

@implementation UIBezierPath (Points)

void pointsFromBezier(void *info, const CGPathElement *element)
{
    NSMutableArray *bezierPoints = (__bridge NSMutableArray *)info;
    CGPathElementType type = element->type;
    CGPoint *points = element->points;
    if (type != kCGPathElementCloseSubpath)
    {
        if ((type == kCGPathElementAddLineToPoint) ||
            (type == kCGPathElementMoveToPoint))
            [bezierPoints addObject:VALUE(0)];
        else if (type == kCGPathElementAddQuadCurveToPoint)
            [bezierPoints addObject:VALUE(1)];
        else if (type == kCGPathElementAddCurveToPoint)
            [bezierPoints addObject:VALUE(2)];
    }
}

- (NSArray *)points
{
    NSMutableArray *points = [NSMutableArray array];
    CGPathApply(self.CGPath, (__bridge void *)points, pointsFromBezier);
    return points;
}

// Return a Bezier path buit with the supplied points
+ (UIBezierPath *) pathWithPoints: (NSArray *) points
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    if (points.count == 0) return path;
    [path moveToPoint:POINT(0)];
    for (int i = 1; i < points.count; i++)
        [path addLineToPoint:POINT(i)];
    return path;
}

- (CGFloat) length
{
    NSArray *points = self.points;
    float totalPointLength = 0.0f;
    for (int i = 1; i < points.count; i++)
        totalPointLength += distance(POINT(i), POINT(i-1));
    return totalPointLength;
}

- (NSArray *) pointPercentArray
{
    // Use total length to calculate the percent of path consumed at each control point
    NSArray *points = self.points;
    int pointCount = points.count;
    
    float totalPointLength = self.length;
    float distanceTravelled = 0.0f;
    
	NSMutableArray *pointPercentArray = [NSMutableArray array];
	[pointPercentArray addObject:@(0.0)];
    
	for (int i = 1; i < pointCount; i++)
	{
		distanceTravelled += distance(POINT(i), POINT(i-1));
		[pointPercentArray addObject:@(distanceTravelled / totalPointLength)];
	}
	
	// Add a final item just to stop with. Probably not needed.
	[pointPercentArray addObject:[NSNumber numberWithFloat:1.1f]]; // 110%
    
    return pointPercentArray;
}

+ (NSArray *) pointsAdjacent: (CGPathRef) path withPoint:(CGPoint)point
{
    NSMutableArray *points = [NSMutableArray array];
    CGPathApply(path, (__bridge void *)points, pointsFromBezier);
    
    NSUInteger pointCount = points.count;
    NSUInteger nearestIndex = 0;
    float nearestDist = distance(point, POINT(0));
    
    NSMutableArray *pointPercentArray = [NSMutableArray array];
    
    for (int i = 1; i < pointCount; i++)
    {
        float tempDist = distance(point, POINT(i));
        if (distance(point, POINT(i)) < nearestDist) {
            nearestIndex = i;
            nearestDist = tempDist;
        }
    }
    if (pointCount > 2) {
        if (nearestIndex == 0) {
            [pointPercentArray addObjectsFromArray:@[points[0], points[1], points[2]]];
        } else {
            [pointPercentArray addObjectsFromArray:@[points[nearestIndex-1], points[nearestIndex]]];
        }
    }    
    return pointPercentArray;
}

+ (CGPoint ) pointAdjacent: (CGPathRef) path withPoint:(CGPoint)point
{
    NSUInteger index = 1;
    return [self pointAdjacent:path withPoint:point index:&index];
}
+ (CGPoint ) pointAdjacent: (CGPathRef) path withPoint:(CGPoint)point index:(NSUInteger *)index
{
    NSMutableArray *points = [NSMutableArray array];
    CGPathApply(path, (__bridge void *)points, pointsFromBezier);
    
    NSUInteger pointCount = points.count;
    CGPoint nearestPoint = POINT(0);
    float nearestDist = distance(point, POINT(0));
    
    for (NSUInteger i = 1; i < pointCount; i++)
    {
        float tempDist = distance(point, POINT(i));
        if (distance(point, POINT(i)) < nearestDist) {
            nearestPoint = POINT(i);
            nearestDist = tempDist;
            *index = i;
        }
    }
    return nearestPoint;
}

- (UIBezierPath *)pathWithStart:(CGPoint)start end:(CGPoint)end forceStart:(BOOL)forceStart forceEnd:(BOOL)forceEnd
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    NSArray *elements = [self bezierElements];
    
    if (elements.count == 0) return path;
    
    float distance1 = 9999;
    float distance2 = 9999;
    NSUInteger startIndex = 0;
    NSUInteger endIndex = 0;
    
    for (NSArray *points in elements)
    {
        if (!points.count)
            continue;
        CGPathElementType elementType = (CGPathElementType)[points[0] integerValue];
        NSUInteger index = [elements indexOfObject:points];
        
        switch (elementType)
        {
            case kCGPathElementCloseSubpath:
                //[path closePath];
                break;
            case kCGPathElementMoveToPoint:
                if (points.count == 2)
                    //[path moveToPoint:POINT(1)];
                break;
            case kCGPathElementAddLineToPoint:
                if (points.count == 2)
                {
                    CGPoint LineTo = POINT(1);
                    
                    float tempDist = distance(start, LineTo);
                    if (tempDist < distance1) {
                        distance1 = tempDist;
                        startIndex = index;
                    }
                    float ED = distance(end, LineTo);
                    if (ED < distance2) {
                        distance2 = ED;
                        endIndex = index;
                    }
                }
                    //[path addLineToPoint:POINT(1)];
                break;
            case kCGPathElementAddQuadCurveToPoint:
                if (points.count == 3)
                {
                    float tempDist = distance(start, POINT(2));
                    if (tempDist < distance1) {
                        distance1 = tempDist;
                        startIndex = [elements indexOfObject:points];
                    }
                    float ED = distance(end, POINT(2));
                    if (ED < distance2) {
                        distance2 = ED;
                        endIndex = index;
                    }
                }
                    //[path addQuadCurveToPoint:POINT(2) controlPoint:POINT(1)];
                break;
            case kCGPathElementAddCurveToPoint:
                if (points.count == 4)
                {
                    float tempDist = distance(start, POINT(3));
                    if (tempDist < distance1) {
                        distance1 = tempDist;
                        startIndex = index;
                    }
                    float ED = distance(end, POINT(3));
                    if (ED < distance2) {
                        distance2 = ED;
                        endIndex = index;
                    }
                }
                    //[path addCurveToPoint:POINT(3) controlPoint1:POINT(1) controlPoint2:POINT(2)];
                break;
        }
    }
    
    NSMutableArray *newElements = [NSMutableArray array];
    
     // 距离起始点小于3，则将起始点作为路径起点
    NSArray *from = elements[startIndex];
    NSArray *to = elements[endIndex];
    
    NSArray *startPoint = elements[0];
    CGPoint endPoint = [self currentPoint]; //结束点
    if (forceStart) {
        startIndex = 0;
        from = startPoint;
    }
    
    if (forceEnd) {
        endIndex = self.bezierElements.count - 1;
    }
    
    [newElements addObject:@[@(kCGPathElementMoveToPoint), from[1]]];

    
//    if (startIndex < 5) {
//        startIndex = 0;
//        from = startPoint;
//    } else {
//        NSInteger interval = self.bezierElements.count - endIndex;
//        
//        if (interval < 5) {
//            endIndex = self.bezierElements.count - 1;
//        }
//    }
//    
//    [newElements addObject:@[@(kCGPathElementMoveToPoint), from[1]]];
    
    for (NSUInteger i = startIndex+1; i <= endIndex; i++) {
        [newElements addObject:elements[i]];
    }
    
    return [UIBezierPath pathWithElements:newElements];
}

- (UIBezierPath *)covertPathFromLayer:(CALayer *)from toLayer:(CALayer*)to
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    NSArray *elements = [self bezierElements];
    
    if (elements.count == 0) return path;
    
    for (NSArray *points in elements)
    {
        if (!points.count) continue;
        CGPathElementType elementType = [points[0] integerValue];
        switch (elementType)
        {
            case kCGPathElementCloseSubpath:
                [path closePath];
                break;
            case kCGPathElementMoveToPoint:
                if (points.count == 2)
                {
                    CGPoint point = [to convertPoint:POINT(1) fromLayer:from];
                    [path moveToPoint:point];
                }
                break;
            case kCGPathElementAddLineToPoint:
                if (points.count == 2)
                {
                    CGPoint point = [to convertPoint:POINT(1) fromLayer:from];
                    [path addLineToPoint:point];
                }
                break;
            case kCGPathElementAddQuadCurveToPoint:
                if (points.count == 3)
                {
                    CGPoint curveTo = [to convertPoint:POINT(2) fromLayer:from];
                    CGPoint ctrl1 = [to convertPoint:POINT(1) fromLayer:from];
                    [path addQuadCurveToPoint:curveTo controlPoint:ctrl1];
                }
                break;
            case kCGPathElementAddCurveToPoint:
                if (points.count == 4)
                {
                    CGPoint curveTo = [to convertPoint:POINT(3) fromLayer:from];
                    CGPoint ctrl1 = [to convertPoint:POINT(1) fromLayer:from];
                    CGPoint ctrl2 = [to convertPoint:POINT(2) fromLayer:from];
                    [path addCurveToPoint:curveTo controlPoint1:ctrl1 controlPoint2:ctrl2];
                }
                break;
        }
    }
    
    return path;
}


- (CGPoint) pointAtPercent: (CGFloat) percent withSlope: (CGPoint *) slope
{
    NSArray *points = self.points;
    NSArray *percentArray = self.pointPercentArray;
    CFIndex lastPointIndex = points.count - 1;
    
    if (!points.count)
        return CGPointZero;
    
    // Check for 0% and 100%
    if (percent <= 0.0f) return POINT(0);
    if (percent >= 1.0f) return POINT(lastPointIndex);

    // Find a corresponding pair of points in the path
    CFIndex index = 1;
    while ((index < percentArray.count) &&
           (percent > ((NSNumber *)percentArray[index]).floatValue))
        index++;
    
    // This should not happen.
    if (index > lastPointIndex) return POINT(lastPointIndex);
    
    // Calculate the intermediate distance between the two points
    CGPoint point1 = POINT(index -1);
    CGPoint point2 = POINT(index);
    
    float percent1 = [[percentArray objectAtIndex:index - 1] floatValue];
    float percent2 = [[percentArray objectAtIndex:index] floatValue];
    float percentOffset = (percent - percent1) / (percent2 - percent1);
    
    float dx = point2.x - point1.x;
    float dy = point2.y - point1.y;
    
    // Store dy, dx for retrieving arctan
    if (slope) *slope = CGPointMake(dx, dy);
    
    // Calculate new point
    CGFloat newX = point1.x + (percentOffset * dx);
    CGFloat newY = point1.y + (percentOffset * dy);
    CGPoint targetPoint = CGPointMake(newX, newY);
    
    return targetPoint;
}

void getBezierElements(void *info, const CGPathElement *element)
{
    NSMutableArray *bezierElements = (__bridge NSMutableArray *)info;
    CGPathElementType type = element->type;
    CGPoint *points = element->points;

    switch (type)
    {
        case kCGPathElementCloseSubpath:
            [bezierElements addObject:@[@(type)]];
            break;
        case kCGPathElementMoveToPoint:
        case kCGPathElementAddLineToPoint:
            [bezierElements addObject:@[@(type), VALUE(0)]];
            break;
        case kCGPathElementAddQuadCurveToPoint:
            [bezierElements addObject:@[@(type), VALUE(0), VALUE(1)]];
            break;
        case kCGPathElementAddCurveToPoint:
            [bezierElements addObject:@[@(type), VALUE(0), VALUE(1), VALUE(2)]];
            break;
    }   
}

- (NSArray *) bezierElements
{
    NSMutableArray *elements = [NSMutableArray array];
    CGPathApply(self.CGPath, (__bridge void *)elements, getBezierElements);
    return elements;
}

+ (UIBezierPath *) pathWithElements: (NSArray *) elements
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    if (elements.count == 0) return path;
    
    for (NSArray *points in elements)
    {
        if (!points.count) continue;
        CGPathElementType elementType = [points[0] integerValue];
        switch (elementType)
        {
            case kCGPathElementCloseSubpath:
                [path closePath];
                break;
            case kCGPathElementMoveToPoint:
                if (points.count == 2)
                    [path moveToPoint:POINT(1)];
                break;
            case kCGPathElementAddLineToPoint:
                if (points.count == 2)
                    [path addLineToPoint:POINT(1)];
                break;
            case kCGPathElementAddQuadCurveToPoint:
                if (points.count == 3)
                    [path addQuadCurveToPoint:POINT(2) controlPoint:POINT(1)];
                break;
            case kCGPathElementAddCurveToPoint:
                if (points.count == 4)
                    [path addCurveToPoint:POINT(3) controlPoint1:POINT(1) controlPoint2:POINT(2)];
                break;
        }
    }
    
    return path;
}

- (UIBezierPath *) combineWithPath: (UIBezierPath *) path
{
    UIBezierPath *newPath = [UIBezierPath bezierPathWithCGPath:self.CGPath];
    NSArray *elements = [path bezierElements];
    
    if (elements.count == 0) return path;
    
    for (NSArray *points in elements)
    {
        if (!points.count) continue;
        CGPathElementType elementType = [points[0] integerValue];
        switch (elementType)
        {
            case kCGPathElementCloseSubpath:
                //[path closePath];
                break;
            case kCGPathElementMoveToPoint:
                if (points.count == 2)
                {
                    if (CGPathIsEmpty(self.CGPath)) {
                        [newPath moveToPoint:POINT(1)];
                    } else {
                        [newPath addLineToPoint:POINT(1)];
                    }
                }
                break;
            case kCGPathElementAddLineToPoint:
                if (points.count == 2)
                    [newPath addLineToPoint:POINT(1)];
                break;
            case kCGPathElementAddQuadCurveToPoint:
                if (points.count == 3)
                    [newPath addQuadCurveToPoint:POINT(2) controlPoint:POINT(1)];
                break;
            case kCGPathElementAddCurveToPoint:
                if (points.count == 4)
                    [newPath addCurveToPoint:POINT(3) controlPoint1:POINT(1) controlPoint2:POINT(2)];
                break;
        }
    }
    
    return newPath;
}

+ (UIBezierPath *) pathWithPath: (UIBezierPath *) path
{
    UIBezierPath *newPath = [UIBezierPath bezierPath];
    NSArray *elements = [path bezierElements];
    if (elements.count == 0) return newPath;
    
    for (NSArray *points in elements)
    {
        if (!points.count) continue;
        CGPathElementType elementType = [points[0] integerValue];
        switch (elementType)
        {
            case kCGPathElementCloseSubpath:
                [newPath closePath];
                break;
            case kCGPathElementMoveToPoint:
                if (points.count == 2)
                    [newPath moveToPoint:POINT(1)];
                break;
            case kCGPathElementAddLineToPoint:
                if (points.count == 2)
                {
                    CGPoint startPoint = [newPath currentPoint];
                    CGPoint lineTo =  POINT(1);
                    
                    float dist = distance([newPath currentPoint], POINT(1));
                    NSInteger steps = MAX(floor(dist / 2), 1);
                    
                    if (steps < 2) {
                        [newPath addLineToPoint:lineTo];
                    } else {
                        
                        for(NSInteger step = 0; step < steps; step++) {
                            // 0 <= t < 1
                            CGFloat t = (CGFloat)step / (CGFloat)steps;
                            
                            // calculate the point along the line
                            CGPoint point = CGPointMake(startPoint.x + (lineTo.x - startPoint.x) * t,
                                                        startPoint.y + (lineTo.y - startPoint.y) * t);
                            [newPath addLineToPoint:point];
                        }
                        [newPath addLineToPoint:lineTo];
                    }
                }
                break;
            case kCGPathElementAddQuadCurveToPoint:
                if (points.count == 3)
                    [newPath addQuadCurveToPoint:POINT(2) controlPoint:POINT(1)];
                break;
            case kCGPathElementAddCurveToPoint:
                if (points.count == 4)
                {
//                    CGPoint startPoint = [path currentPoint];
//                    CGPoint curveTo =  POINT(3);
//                    
//                    CGPoint rightBez[4], leftBez[4];
//                    CGPoint bez[4];
//                    bez[0] = startPoint;
//                    bez[1] = POINT(1);
//                    bez[2] = POINT(2);
//                    bez[3] = curveTo;
//                    
//                    CGFloat length = lengthOfBezier(bez, .1);
//                    NSInteger numberOfSteps = MAX(floor(length / 1), 1);
//                    CGFloat realStepSize = length / numberOfSteps;
//                    
//                    for(int step = 0; step < numberOfSteps; step++) {
//                        // calculate the point that is realStepSize distance
//                        // along the curve * which step we're on
//                        
//                        subdivideBezierAtLength(bez, leftBez, rightBez, realStepSize*step, .05);
//                        CGPoint point = rightBez[0];
//                        [path addLineToPoint:point];
//                    }
                    [newPath addCurveToPoint:POINT(3) controlPoint1:POINT(1) controlPoint2:POINT(2)];
                }
                
                break;
        }
    }
    
    return newPath;
}

#pragma mark - Helper

/**
 * will divide a bezier curve into two curves at time t
 * 0 <= t <= 1.0
 *
 * these two curves will exactly match the former single curve
 */
static inline void subdivideBezierAtT(const CGPoint bez[4], CGPoint bez1[4], CGPoint bez2[4], CGFloat t){
    CGPoint q;
    CGFloat mt = 1 - t;
    
    bez1[0].x = bez[0].x;
    bez1[0].y = bez[0].y;
    bez2[3].x = bez[3].x;
    bez2[3].y = bez[3].y;
    
    q.x = mt * bez[1].x + t * bez[2].x;
    q.y = mt * bez[1].y + t * bez[2].y;
    bez1[1].x = mt * bez[0].x + t * bez[1].x;
    bez1[1].y = mt * bez[0].y + t * bez[1].y;
    bez2[2].x = mt * bez[2].x + t * bez[3].x;
    bez2[2].y = mt * bez[2].y + t * bez[3].y;
    
    bez1[2].x = mt * bez1[1].x + t * q.x;
    bez1[2].y = mt * bez1[1].y + t * q.y;
    bez2[1].x = mt * q.x + t * bez2[2].x;
    bez2[1].y = mt * q.y + t * bez2[2].y;
    
    bez1[3].x = bez2[0].x = mt * bez1[2].x + t * bez2[1].x;
    bez1[3].y = bez2[0].y = mt * bez1[2].y + t * bez2[1].y;
}

/**
 * divide the input curve at its halfway point
 */
static inline void subdivideBezier(const CGPoint bez[4], CGPoint bez1[4], CGPoint bez2[4]){
    subdivideBezierAtT(bez, bez1, bez2, .5);
}

/**
 * calculates the distance between two points
 */
static inline CGFloat distanceBetween(CGPoint a, CGPoint b){
    return hypotf( a.x - b.x, a.y - b.y );
}


/**
 *  分解贝塞尔曲线
 */
+ (NSArray *)curveFactorizationWithFromPoint:(CGPoint) fPoint toPoint:(CGPoint) tPoint controlPoints:(NSArray *)points count:(int) count {
    
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



+ (CGFloat)compWithN:(int)n andK:(int)k {
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

+ (CGFloat)realPowWithN:(CGFloat)n K:(int)k {
    
    if (k == 0) {
        return 1.0;
    }
    
    return pow(n, (CGFloat)k);
}

+ (CGFloat)bezMakerWithN:(int)n K:(int)k T:(CGFloat)t {
    
    return [self compWithN:n andK:k] * [self realPowWithN:1-t K:n-k] * [self realPowWithN:t K:k];
    
    
}

@end
