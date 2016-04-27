#import "SVGClipPathElement.h"

#import "CALayerWithChildHitTest.h"

#import "SVGHelperUtilities.h"

#import "SVGKPointsAndPathsParser.h"

#import "CGPathAdditions.h"

@interface SVGClipPathElement ()

@property (nonatomic, readwrite) CGPathRef pathForShapeInRelativeCoords;

@property (nonatomic, readwrite) CGPathRef finalClipPath;

- (void) parseData:(NSString *)data;

@end

@implementation SVGClipPathElement

@synthesize clipPathUnits;
@synthesize transform; // each SVGElement subclass that conforms to protocol "SVGTransformable" has to re-synthesize this to work around bugs in Apple's Objective-C 2.0 design that don't allow @properties to be extended by categories / protocols

@synthesize pathForShapeInRelativeCoords = _pathForShapeInRelativeCoords;

@synthesize finalClipPath = _finalClipPath;

- (id)init
{
    self = [super init];
    if (self) {
        self.pathForShapeInRelativeCoords = NULL;
        self.finalClipPath = NULL;
    }
    return self;
}

- (void)dealloc {
    CGPathRelease(_pathForShapeInRelativeCoords);
    CGPathRelease(_finalClipPath);
    
}

-(void)setPathForShapeInRelativeCoords:(CGPathRef)pathForShapeInRelativeCoords
{
    if( pathForShapeInRelativeCoords == _pathForShapeInRelativeCoords )
        return;
    
    CGPathRelease( _pathForShapeInRelativeCoords ); // Apple says NULL is fine as argument
    _pathForShapeInRelativeCoords = pathForShapeInRelativeCoords;
    CGPathRetain( _pathForShapeInRelativeCoords );
}

-(void)setFinalClipPath:(CGPathRef)finalClipPath
{
    if( finalClipPath == _finalClipPath )
        return;
    
    CGPathRelease( _finalClipPath ); // Apple says NULL is fine as argument
    _finalClipPath = finalClipPath;
    CGPathRetain( _finalClipPath );
}

- (void)postProcessAttributesAddingErrorsTo:(SVGKParseResult *)parseResult {
    [super postProcessAttributesAddingErrorsTo:parseResult];
    
    NSError *error = [NSError errorWithDomain:@"SVGKit" code:1 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                         @"<clipPath> found in SVG. May render incorrectly with SVGKFastImageView due to Apple bug in CALayer .mask rendering.", NSLocalizedDescriptionKey,
                                                                         nil]];
    [parseResult addParseErrorRecoverable:error];
    
    clipPathUnits = SVG_UNIT_TYPE_USERSPACEONUSE;
    
    NSString *units = [self getAttribute:@"clipPathUnits"];
    if( units != nil && units.length > 0 ) {
        if( [units isEqualToString:@"userSpaceOnUse"] )
            clipPathUnits = SVG_UNIT_TYPE_USERSPACEONUSE;
        else if( [units isEqualToString:@"objectBoundingBox"] )
            clipPathUnits = SVG_UNIT_TYPE_OBJECTBOUNDINGBOX;
        else {
            SVGKitLogWarn(@"Unknown clipPathUnits value %@", units);
            NSError *error = [NSError errorWithDomain:@"SVGKit" code:1 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                                 [NSString stringWithFormat:@"Unknown clipPathUnits value %@", units], NSLocalizedDescriptionKey,
                                                                                 nil]];
            [parseResult addParseErrorRecoverable:error];
        }
    }
    
    //[self parseData:[self getAttribute:@"d"]];
}

- (void)parseData:(NSString *)data
{
    CGMutablePathRef path = CGPathCreateMutable();
    NSScanner* dataScanner = [NSScanner scannerWithString:data];
    CGPoint lastCoordinate = CGPointZero;
    SVGCurve lastCurve = SVGCurveZero;
    BOOL foundCmd;
    
    NSCharacterSet *knownCommands = [NSCharacterSet characterSetWithCharactersInString:@"MmLlCcVvHhAaSsQqTtZz"];
    NSString* command;
    
    do {
        
        command = nil;
        foundCmd = [dataScanner scanCharactersFromSet:knownCommands intoString:&command];
        
        if (command.length > 1) {
            // Take only one char (it can happen that multiple commands are consecutive, as "ZM" - so we only want to get the "Z")
            const NSUInteger tooManyChars = command.length-1;
            command = [command substringToIndex:1];
            [dataScanner setScanLocation:([dataScanner scanLocation] - tooManyChars)];
        }
        
        if (foundCmd) {
            if ([@"z" isEqualToString:command] || [@"Z" isEqualToString:command]) {
                lastCoordinate = [SVGKPointsAndPathsParser readCloseCommand:[NSScanner scannerWithString:command]
                                                                       path:path
                                                                 relativeTo:lastCoordinate];
            } else {
                NSString* cmdArgs = nil;
                BOOL foundParameters = [dataScanner scanUpToCharactersFromSet:knownCommands
                                                                   intoString:&cmdArgs];
                
                if (foundParameters) {
                    NSString* commandWithParameters = [command stringByAppendingString:cmdArgs];
                    NSScanner* commandScanner = [NSScanner scannerWithString:commandWithParameters];
                    
                    if ([@"m" isEqualToString:command]) {
                        lastCoordinate = [SVGKPointsAndPathsParser readMovetoDrawtoCommandGroups:commandScanner
                                                                                            path:path
                                                                                      relativeTo:lastCoordinate
                                                                                      isRelative:TRUE];
                        lastCurve = SVGCurveZero;
                    } else if ([@"M" isEqualToString:command]) {
                        lastCoordinate = [SVGKPointsAndPathsParser readMovetoDrawtoCommandGroups:commandScanner
                                                                                            path:path
                                                                                      relativeTo:CGPointZero
                                                                                      isRelative:FALSE];
                        lastCurve = SVGCurveZero;
                    } else if ([@"l" isEqualToString:command]) {
                        lastCoordinate = [SVGKPointsAndPathsParser readLinetoCommand:commandScanner
                                                                                path:path
                                                                          relativeTo:lastCoordinate
                                                                          isRelative:TRUE];
                        lastCurve = SVGCurveZero;
                    } else if ([@"L" isEqualToString:command]) {
                        lastCoordinate = [SVGKPointsAndPathsParser readLinetoCommand:commandScanner
                                                                                path:path
                                                                          relativeTo:CGPointZero
                                                                          isRelative:FALSE];
                        lastCurve = SVGCurveZero;
                    } else if ([@"v" isEqualToString:command]) {
                        lastCoordinate = [SVGKPointsAndPathsParser readVerticalLinetoCommand:commandScanner
                                                                                        path:path
                                                                                  relativeTo:lastCoordinate];
                        lastCurve = SVGCurveZero;
                    } else if ([@"V" isEqualToString:command]) {
                        lastCoordinate = [SVGKPointsAndPathsParser readVerticalLinetoCommand:commandScanner
                                                                                        path:path
                                                                                  relativeTo:CGPointZero];
                        lastCurve = SVGCurveZero;
                    } else if ([@"h" isEqualToString:command]) {
                        lastCoordinate = [SVGKPointsAndPathsParser readHorizontalLinetoCommand:commandScanner
                                                                                          path:path
                                                                                    relativeTo:lastCoordinate];
                        lastCurve = SVGCurveZero;
                    } else if ([@"H" isEqualToString:command]) {
                        lastCoordinate = [SVGKPointsAndPathsParser readHorizontalLinetoCommand:commandScanner
                                                                                          path:path
                                                                                    relativeTo:CGPointZero];
                        lastCurve = SVGCurveZero;
                    } else if ([@"c" isEqualToString:command]) {
                        lastCurve = [SVGKPointsAndPathsParser readCurvetoCommand:commandScanner
                                                                            path:path
                                                                      relativeTo:lastCoordinate
                                                                      isRelative:TRUE];
                        lastCoordinate = lastCurve.p;
                    } else if ([@"C" isEqualToString:command]) {
                        lastCurve = [SVGKPointsAndPathsParser readCurvetoCommand:commandScanner
                                                                            path:path
                                                                      relativeTo:CGPointZero
                                                                      isRelative:FALSE];
                        lastCoordinate = lastCurve.p;
                    } else if ([@"s" isEqualToString:command]) {
                        lastCurve = [SVGKPointsAndPathsParser readSmoothCurvetoCommand:commandScanner
                                                                                  path:path
                                                                            relativeTo:lastCoordinate
                                                                         withPrevCurve:lastCurve];
                        lastCoordinate = lastCurve.p;
                    } else if ([@"S" isEqualToString:command]) {
                        lastCurve = [SVGKPointsAndPathsParser readSmoothCurvetoCommand:commandScanner
                                                                                  path:path
                                                                            relativeTo:CGPointZero
                                                                         withPrevCurve:lastCurve];
                        lastCoordinate = lastCurve.p;
                    } else if ([@"q" isEqualToString:command]) {
                        lastCurve = [SVGKPointsAndPathsParser readQuadraticCurvetoCommand:commandScanner
                                                                                     path:path
                                                                               relativeTo:lastCoordinate
                                                                               isRelative:TRUE];
                        lastCoordinate = lastCurve.p;
                    } else if ([@"Q" isEqualToString:command]) {
                        lastCurve = [SVGKPointsAndPathsParser readQuadraticCurvetoCommand:commandScanner
                                                                                     path:path
                                                                               relativeTo:CGPointZero
                                                                               isRelative:FALSE];
                        lastCoordinate = lastCurve.p;
                    } else if ([@"t" isEqualToString:command]) {
                        lastCurve = [SVGKPointsAndPathsParser readSmoothQuadraticCurvetoCommand:commandScanner
                                                                                           path:path
                                                                                     relativeTo:lastCoordinate
                                                                                  withPrevCurve:lastCurve];
                        lastCoordinate = lastCurve.p;
                    } else if ([@"T" isEqualToString:command]) {
                        lastCurve = [SVGKPointsAndPathsParser readSmoothQuadraticCurvetoCommand:commandScanner
                                                                                           path:path
                                                                                     relativeTo:CGPointZero
                                                                                  withPrevCurve:lastCurve];
                        lastCoordinate = lastCurve.p;
                    } else if ([@"a" isEqualToString:command]) {
                        lastCurve 	=	[SVGKPointsAndPathsParser readEllipticalArcArguments:commandScanner
                                                                                     path:path relativeTo:lastCoordinate];
                        
                        lastCoordinate = lastCurve.p;
                        
                    }  else if ([@"A" isEqualToString:command]) {
                        lastCurve 	=	[SVGKPointsAndPathsParser readEllipticalArcArguments:commandScanner
                                                                                     path:path relativeTo:CGPointZero];
                        lastCoordinate = lastCurve.p;
                    } else  {
                        SVGKitLogWarn(@"unsupported command %@", command);
                    }
                }
            }
        }
        
    } while (foundCmd);
    
    
    self.pathForShapeInRelativeCoords = path;
    CGPathRelease(path);
    
    
    NSString* actualStrokeWidth = [self cascadedValueForStylableProperty:@"stroke-width"];
    
    CGFloat strokeWidth = 1.0;
    
    if (actualStrokeWidth)
    {
        SVGRect r = ((SVGSVGElement*) self.viewportElement).viewport;
        
        strokeWidth = [[SVGLength svgLengthFromNSString:actualStrokeWidth]
                       pixelsValueWithDimension: hypot(r.width, r.height)];
    }
    /** transform our LOCAL path into ABSOLUTE space */
    CGAffineTransform transformAbsolute = [SVGHelperUtilities transformAbsoluteIncludingViewportForTransformableOrViewportEstablishingElement:self];
    
    // calculate the rendered dimensions of the path
    CGRect r = CGRectInset(CGPathGetBoundingBox(self.pathForShapeInRelativeCoords), -strokeWidth/2., -strokeWidth/2.);
    CGRect transformedPathBB = CGRectApplyAffineTransform(r, transformAbsolute);
    
    CGPathRef pathToPlaceInLayer = CGPathCreateCopyByTransformingPath(self.pathForShapeInRelativeCoords, &transformAbsolute);
    
    /** find out the ABSOLUTE BOUNDING BOX of our transformed path */
    //DEBUG ONLY: CGRect unTransformedPathBB = CGPathGetBoundingBox( _pathRelative );
    
#if IMPROVE_PERFORMANCE_BY_WORKING_AROUND_APPLE_FRAME_ALIGNMENT_BUG
    transformedPathBB = CGRectIntegral( transformedPathBB ); // ridiculous but improves performance of apple's code by up to 50% !
#endif
    
    /** NB: when we set the _shapeLayer.frame, it has a *side effect* of moving the path itself - so, in order to prevent that,
     because Apple didn't provide a BOOL to disable that "feature", we have to pre-shift the path forwards by the amount it
     will be shifted backwards */
    CGPathRef finalPath = CGPathCreateByOffsettingPath( pathToPlaceInLayer, transformedPathBB.origin.x, transformedPathBB.origin.y );
    
    /** Can't use this - iOS 5 only! path = CGPathCreateCopyByTransformingPath(path, transformFromSVGUnitsToScreenUnits ); */
    
    self.finalClipPath = finalPath;
    
    CGPathRelease(finalPath);

}

- (CALayer *) newLayer
{
    
    CALayer* _layer = [CALayerWithChildHitTest layer];
    
    [SVGHelperUtilities configureCALayer:_layer usingElement:self];
    
    return _layer;
}

- (void)layoutLayer:(CALayer *)layer toMaskLayer:(CALayer *)maskThis
{
    // null rect union any other rect will return the other rect
    CGRect mainRect = CGRectNull;
    
    /** make mainrect the UNION of all sublayer's frames (i.e. their individual "bounds" inside THIS layer's space) */
    for ( CALayer *currentLayer in [layer sublayers] )
    {
        mainRect = CGRectUnion(mainRect, currentLayer.frame);
    }
    
    /** Changing THIS layer's frame now means all DIRECT sublayers are offset by too much (because when we change the offset
     of the parent frame (this.frame), Apple *does not* shift the sublayers around to keep them in same place.
     
     NB: there are bugs in some Apple code in Interface Builder where it attempts to do exactly that (incorrectly, as the API
     is specifically designed NOT to do this), and ... Fails. But in code, thankfully, Apple *almost* never does this (there are a few method
     calls where it appears someone at Apple forgot how their API works, and tried to do the offsetting automatically. "Paved
     with good intentions...".
     */
    if (CGRectIsNull(mainRect))
    {
        // TODO what to do when mainRect is null rect? i.e. no sublayer or all sublayers have null rect frame
    } else {
        for (CALayer *currentLayer in [layer sublayers])
            currentLayer.frame = CGRectOffset(currentLayer.frame, -mainRect.origin.x, -mainRect.origin.y);
    }
    
    // unless we're working in bounding box coords, subtract the owning layer's origin
    if( self.clipPathUnits == SVG_UNIT_TYPE_USERSPACEONUSE )
        mainRect = CGRectOffset(mainRect, -maskThis.frame.origin.x, -maskThis.frame.origin.y);
    layer.frame = mainRect;
}

@end
