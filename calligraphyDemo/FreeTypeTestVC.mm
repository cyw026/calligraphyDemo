//
//  FreeTypeTestVC.m
//  calligraphyDemo
//
//  Created by 蔡业文 on 16/5/16.
//  Copyright © 2016年 steven.cai. All rights reserved.
//

#import "FreeTypeTestVC.h"
#include <ft2build.h>
#include FT_FREETYPE_H
#include "Text.h"

@interface FreeTypeTestVC ()

@end

@implementation FreeTypeTestVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    FT_Library ft;
    FT_Face face;
    FT_GlyphSlot g;
    
    if (FT_Init_FreeType(&ft)) {
        printf("couldn't init freetype\n");
        exit(1);
    }
    if (FT_New_Face(ft, "/somewhere/font.ttf", 0, &face)) {
        printf("couldn't open font\n");
        exit(1);
    }
    FT_Set_Pixel_Sizes(face, 0, 12); // 12 is the size
    g = face->glyph;
    
//    Text text = Text();
//    
//    text.init(_program, 1); // the size parameter doesn't matter now because we're going to use the fontOpt function
//    glEnable(GL_BLEND);
//    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
