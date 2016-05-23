//
//  Text.h
//  calligraphyDemo
//
//  Created by 蔡业文 on 16/5/16.
//  Copyright © 2016年 steven.cai. All rights reserved.
//

#ifndef __TextRender__Text__
#define __TextRender__Text__

#include <iostream>         // for string
#include <vector>           // for vector (u don't say? :D)
#include <GLKit/GLKit.h>    // for OpenGL. If you're not developing for iOS you will have some other header file in here
#import <OpenGLES/ES2/glext.h>
#include <ft2build.h>       // freetype headers
#include FT_FREETYPE_H      // also freetype header

// let's use std namespace so we don't need to write it every time
using namespace std;

// here we have some enums for align and font size settings
enum {
    ALIGN_LEFT, ALIGN_CENTER, ALIGN_RIGHT,
    FONT_SIZE
};

// this class contains all the glyph data that we use
class GlyphData {
public:
    char c;     // the character of this glyph
    int size;   // font size
    
    int bitmap_width;   // texture width
    int bitmap_rows;    // texture height
    unsigned char *bitmap_buffer;   // texture data
    FT_Vector advance;  // this variable contains the information of how much we need to move to the right from the last character
    int bitmap_left;    // width of the glyph in pixels
    int bitmap_top;     // height of the glyph in pixels
};

class Text {
public:
    Text();     // constructor
    ~Text();    // deconstructor
    
    void init(GLint prog, int size); // init method
    void write(string text, float x, float y, int align); // this method will be used for rendering text
    void fontOpt(int opt, int value); // font option method. i have included only font size option to this method but you can do more
    
private:
    
    // our freetype objects
    FT_Library ft; // the library object
    FT_Face face;  // the face (font) object
    FT_GlyphSlot g;// the glyph
    
    int currentSize; // current size of text
    
    void getGlyph(char c); // get glyph for the 'c' char
    
    GLint shaderProgram; // the shader program. this will be set in the init method
    GLuint vao; // vertex array object for the text
    GLuint vbo; // vertex buffer object for the text
    GLint fontCoords; // shader attribute for text coordinates
    GLuint textTex; // texture object for the text
    
    vector<GlyphData> glyphs; // vector of all loaded glyphs. with this we can reuse the glyphs that has already been loaded
    GlyphData currentG; // current glyph
    
    // these variables are used for getting screen size, if you're not developing for iOS you need to find out your screen size someway else
    CGRect screenRect;      // the rect
    CGFloat screenWidth;    // width of the screen
    CGFloat screenHeight;   // height of the screen
    
};

#endif /* defined(__TextRender__Text__) */
