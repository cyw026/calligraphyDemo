#import "CAShapeLayerWithHitTest.h"
#import "CALayerWithChildHitTest.h"

/*! Used by the main ShapeElement (and all subclasses) to do perfect "containsPoint" calculations via Apple's API calls
 
 This will only be called if it's the root of an SVG document and the hit was in the parent view on screen,
 OR if it's inside an SVGGElement that contained the hit
 */
@implementation CAShapeLayerWithHitTest

- (BOOL) containsPoint:(CGPoint)p
{
	BOOL boundsContains = CGRectContainsPoint(CGRectInset(self.bounds, -20, -20), p); // must be BOUNDS because Apple pre-converts the point to local co-ords before running the test
	
    if (self.mask) {
        // 有遮罩层
        CALayerWithChildHitTest *mask = (CALayerWithChildHitTest *)self.mask;
        CAShapeLayerWithHitTest *clipPathLayer = (CAShapeLayerWithHitTest *)[[mask sublayers] firstObject];
        
        CGPathRef strokingPath = CGPathCreateCopyByStrokingPath(clipPathLayer.path, nil, 30, kCGLineCapRound, kCGLineJoinRound, 30);
        
        BOOL clipPathContains = CGPathContainsPoint(strokingPath, NULL, p, false);
        
        if ( clipPathContains )
        {
            return TRUE;
        }
    }
	if( boundsContains )
	{
        CGPathRef strokingPath = CGPathCreateCopyByStrokingPath(self.path, nil, 30, kCGLineCapRound, kCGLineJoinRound, 30);

        BOOL pathContains = CGPathContainsPoint(strokingPath, NULL, p, false);
		
		if( pathContains )
		{
			for( CALayer* subLayer in self.sublayers )
			{
				SVGKitLogVerbose(@"...contains point, Apple will now check sublayer: %@", subLayer);
			}
			return TRUE;
		}
	}
	return FALSE;
}

@end
