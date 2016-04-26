//
//  DetailViewController.m
//  calligraphyDemo
//
//  Created by 蔡业文 on 16/4/24.
//  Copyright © 2016年 steven.cai. All rights reserved.
//

#import "DetailViewController.h"


@interface DetailViewController () 
{
    CALayer* lastTappedLayer;
    CGFloat lastTappedLayerOriginalBorderWidth;
    CGColorRef lastTappedLayerOriginalBorderColor;
}

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
    //[self.contentView removeFromSuperview];
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
    document.size = CGSizeMake(600, 600);
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
        
        self.contentView.frame = CGRectMake(0, 100, 600, 600);
        
        self.contentView.layer.backgroundColor = [UIColor blueColor].CGColor;
        
        [self.view addSubview:self.contentView];
        
        //[self.contentView setNeedsDisplay];
        
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
    CGContextSetLineWidth(ctx, 10.0f);
    CGContextSetStrokeColorWithColor(ctx, [UIColor redColor].CGColor);
    CGContextStrokeEllipseInRect(ctx, CGRectMake(0, 0, 320, 640));
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

#pragma mark - /*** 触摸事件 ***/

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = touches.anyObject;
    CGPoint p = [touch locationInView:self.view];
    
    NSValue *vp = [NSValue valueWithCGPoint:p];
    
    //self.points = [NSMutableArray arrayWithObjects:vp,vp,vp, nil];
    
    //[self changeImage];
    
    if ([self.contentView isKindOfClass:[SVGKLayeredImageView class]]) {
        SVGKLayer* layerForHitTesting = (SVGKLayer*)self.contentView.layer;
        SVGKImage *image = layerForHitTesting.SVGImage;
        
        NSLog(@"hitLayer.DOMTree:%@", image.DOMTree);
        SVGKLayer* hitLayer = (SVGKLayer*)[layerForHitTesting hitTest:p];
        //SVGKImage *hitLayerImage = hitLayer.SVGImage;
        //NSLog(@"hitLayerImage:%@", hitLayerImage.DOMTree);
        
        if( hitLayer == lastTappedLayer )
            [self deselectTappedLayer];
        else {
            [self deselectTappedLayer];
        }
        
        lastTappedLayer = hitLayer;
        
        if (lastTappedLayer != nil) {
            lastTappedLayerOriginalBorderColor = lastTappedLayer.borderColor;
            lastTappedLayerOriginalBorderWidth = lastTappedLayer.borderWidth;
            
            lastTappedLayer.borderColor = [UIColor greenColor].CGColor;
            lastTappedLayer.borderWidth = 3.0;
        }
        
        //hitLayer.backgroundColor = [UIColor redColor].CGColor;
    }
    
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = touches.anyObject;
    CGPoint p = [touch locationInView:self.contentView];
    
    NSValue *vp = [NSValue valueWithCGPoint:p];
    
    //self.points = [NSMutableArray arrayWithObjects:_points[1],_points[2],vp, nil];
    
}


- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
