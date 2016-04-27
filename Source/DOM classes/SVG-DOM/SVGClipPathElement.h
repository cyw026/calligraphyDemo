/**
http://www.w3.org/TR/SVG/masking.html#InterfaceSVGClipPathElement
 
 interface SVGClipPathElement : SVGElement,
 SVGTests,
 SVGLangSpace,
 SVGExternalResourcesRequired,
 SVGStylable,
 SVGTransformable,
 SVGUnitTypes {
 */

#import <UIKit/UIKit.h>

#import "SVGElement.h"
#import "SVGElement_ForParser.h"

#import "ConverterSVGToCALayer.h"
#import "SVGTransformable.h"
#import "SVGUnitTypes.h"


// Does NOT implement ConverterSVGToCALayer because <clipPath> elements are never rendered directly; they're only referenced via clip-path attributes in other elements
@interface SVGClipPathElement : SVGElement <SVGTransformable, SVGStylable>

@property(nonatomic, readonly) SVG_UNIT_TYPE clipPathUnits;

/** The actual path as parsed from the original file. THIS MIGHT NOT BE NORMALISED (TODO: perhaps an extra feature?) */
@property (nonatomic, readonly) CGPathRef pathForShapeInRelativeCoords;

@property (nonatomic, readonly) CGPathRef finalClipPath;

- (CALayer *) newLayer;
- (void)layoutLayer:(CALayer *)layer toMaskLayer:(CALayer *)maskThis;


@end
