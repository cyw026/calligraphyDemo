/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIBezierPath (Points)
@property (nonatomic, readonly) NSArray *points;
@property (nonatomic, readonly) NSArray *bezierElements;
@property (nonatomic, readonly) CGFloat length;

- (NSArray *)points;
- (NSArray *) pointPercentArray;
- (CGPoint) pointAtPercent: (CGFloat) percent withSlope: (CGPoint *) slope;
+ (UIBezierPath *) pathWithPoints: (NSArray *) points;
+ (UIBezierPath *) pathWithElements: (NSArray *) elements;
+ (UIBezierPath *) pathWithPath: (UIBezierPath *) path;

+ (NSArray *) pointsAdjacent: (CGPathRef ) points withPoint:(CGPoint)point;
+ (CGPoint ) pointAdjacent: (CGPathRef) path withPoint:(CGPoint)point;
+ (CGPoint ) pointAdjacent: (CGPathRef) path withPoint:(CGPoint)point index:(NSUInteger *)index;
+ (NSArray *)curveFactorizationWithFromPoint:(CGPoint) fPoint toPoint:(CGPoint) tPoint controlPoints:(NSArray *)points count:(int) count;
- (UIBezierPath *)pathWithStart:(CGPoint)start end:(CGPoint)end;
@end
