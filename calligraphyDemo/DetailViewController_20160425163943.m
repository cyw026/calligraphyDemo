//
//  DetailViewController.m
//  calligraphyDemo
//
//  Created by 蔡业文 on 16/4/24.
//  Copyright © 2016年 steven.cai. All rights reserved.
//

#import "DetailViewController.h"


@interface DetailViewController () 

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
    document.size = CGSizeMake(50, 50);
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
            
            //newContentView = [[SVGKLayeredImageView alloc] initWithSVGKImage:document];
            
            newContentView = [[SVGKFastImageView alloc] initWithSVGKImage:document];
            
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
        
        self.contentView.frame = CGRectMake(50, 100, self.view.frame.size.width, self.view.frame.size.height - 64);
        
        [self.view addSubview:self.contentView];
        
        [self.contentView setNeedsDisplay];
        
        self.vi
        [self.view.layer display];
        
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
    CGContextStrokeEllipseInRect(ctx, layer.bounds);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
