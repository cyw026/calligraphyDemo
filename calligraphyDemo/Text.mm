//
//  Text.c
//  calligraphyDemo
//
//  Created by 蔡业文 on 16/5/16.
//  Copyright © 2016年 steven.cai. All rights reserved.
//

#include "Text.h"
#include "Text.h" // include the class definition file

Text::Text() {
    // set the screen size veriables, again just incase you didn't read everything this is ofcourse platform dependent and i'm using iOS
    screenRect = [[UIScreen mainScreen] bounds];
    screenWidth = screenRect.size.width;
    screenHeight = screenRect.size.height;
}

Text::~Text() {
    // tell freetype when we're done
    FT_Done_Face(face);
    FT_Done_FreeType(ft);
}

void Text::init(GLint prog, int size) {
    // init our FT_Library object
    if (FT_Init_FreeType(&ft)) {
        printf("couldn't init freetype\n");
        exit(1);
    }
    /*
     specify your font path, incase you're not familiar with objective-c
     the next line means just same this as this char *path = "/somewhere-in-your-top-secret-files/font.ttf";
     */
    NSString *fontPath = [[NSBundle mainBundle] pathForResource:@"fonts/GillSans" ofType:@"ttc"]; // you can use ttc or ttf fonts
    /*
     now let's init our face object
     incase you're confused about the second parameter, if your path variable is just a regular char *path, then you're
     second parameter will be just 'path' like so FT_New_Face(ft, path, 0, &face)
     */
    if (FT_New_Face(ft, [fontPath UTF8String], 0, &face)) {
        printf("couldn't open font\n");
        exit(1);
    }
    // now we can finally set our font size (you can of course change this later with the fontOpt function)
    FT_Set_Pixel_Sizes(face, 0, size);
    // and then we make the g point to face->glyph
    g = face->glyph;
    
    shaderProgram = prog; // set the shader program
    
    // create and bind the vertex array object
    glGenVertexArraysOES(1, &vao);
    glBindVertexArrayOES(vao);
    
    // do the same thing to vertex buffer object
    glGenBuffers(1, &vbo);
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    
    // link out vertex data with the shader attribute
    fontCoords = glGetAttribLocation(shaderProgram, "fontCoords");
    glEnableVertexAttribArray(fontCoords);
    glVertexAttribPointer(fontCoords, 4, GL_FLOAT, GL_FALSE, 0, 0);
}

void Text::write(string text, float x, float y, int align) {
    // bind the correct vao, vbo and texture object
    glBindVertexArrayOES(vao);
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, textTex);
    
    // use the shaderProgram
    glUseProgram(shaderProgram);
    
    // we use these variables to convert pixels into screen coordinates
    float screenx = 2.0f / screenWidth, screeny = 2.0f / screenHeight;
    
    // totalWidth is used for aligning text
    float totalWidth = 0.0f;
    
    // get total width
    int index = 0;
    for (char p = text[index++]; p != 0; p = text[index++]) { // run through every character
        getGlyph(p); // the glyph data is now loaded into currentG
        totalWidth += (currentG.advance.x >> 6) * screenx; // add the horizontal advance value to the totalWidth
    }
    
    // render
    index = 0;
    for (char p = text[index++]; p != 0; p = text[index++]) { // run through every character
        getGlyph(p); // again, get the glyph and store the data into currentG
        
        // create the OpenGL texture for this glyph
        glActiveTexture(GL_TEXTURE0);
        glGenTextures(1, &textTex);
        glBindTexture(GL_TEXTURE_2D, textTex);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_ALPHA, currentG.bitmap_width, currentG.bitmap_rows, 0, GL_ALPHA, GL_UNSIGNED_BYTE, currentG.bitmap_buffer);
        
        // calculate the coordninates and width and height for the glyph
        float x2 = x + currentG.bitmap_left * screenx;
        float y2 = -y - currentG.bitmap_top * screeny;
        float w = currentG.bitmap_width * screenx;
        float h = currentG.bitmap_rows * screeny;
        
        // if align is center move the text to left by half of it's lengh
        if (align == ALIGN_CENTER)
            x2 -= totalWidth / 2;
        // if align is right move the text to left by it's whole length
        else if (align == ALIGN_RIGHT)
            x2 -= totalWidth;
        
        // create array of our screen coordninates
        GLfloat box[4][4] = {
            {x2,    -y2,    0,  0},
            {x2+w,  -y2,    1,  0},
            {x2,    -y2-h,  0,  1},
            {x2+w,  -y2-h,  1,  1}
        };
        
        // buffer the data into vbo and draw it to the screen
        glBufferData(GL_ARRAY_BUFFER, sizeof box, box, GL_DYNAMIC_DRAW);
        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
        
        // increase x and y variables by the glyph's advance values so that next glyph won't be drawn on top of this one
        x += (currentG.advance.x >> 6) * screenx;
        y += (currentG.advance.y >> 6) * screeny;
        
        // delete the texture object, which will be created again in the next run fo the loop
        glDeleteTextures(1, &textTex);
    }
}

void Text::getGlyph(char c) {
    vector<GlyphData>::iterator glyphIter = glyphs.begin(); // create iterator for the glyph data vector
    while (glyphIter != glyphs.end()) { // run through the whole vector
        // if we have matching character and size this glyph has been loaded before and we can reuse it
        if (glyphIter->c == c && glyphIter->size == currentSize) {
            currentG = *glyphIter; // set the currentG equal to the GlyphData object in our vector
            return; // we're done with this function
        }
        
        glyphIter++; // check the next object
    }
    
    /*
     Ok, we didn't find pre loaded glyphs matching the requested glyph,
     we need to load it with freetype function: FT_Load_Char
     */
    
    // load the char into the face object
    if (FT_Load_Char(face, c, FT_LOAD_RENDER))
        printf("freetype is unable to load char: %c\n", c); // this runs if error was occured
    
    GlyphData gd; // create new GlyphData object
    // init the gd.bitmap_buffer array to be the size needed
    gd.bitmap_buffer = new unsigned char[g->bitmap.rows * g->bitmap.width * 4];
    // copy the texture data from 'g' to 'gd'
    memcpy(gd.bitmap_buffer, g->bitmap.buffer, g->bitmap.rows * g->bitmap.width * 4);
    
    gd.bitmap_width = g->bitmap.width; // copy texture width
    gd.bitmap_rows = g->bitmap.rows; // copy texture height
    gd.bitmap_left = g->bitmap_left; // copy glyph width (pixels)
    gd.bitmap_top = g->bitmap_top; // copy glyph height (pixels)
    gd.advance = g->advance; // copy the advance vector (note this isn't c++ vector, this is real vector)
    gd.c = c; // set the character
    gd.size = currentSize; // set the size
    currentG = gd; // and finally set currentG equal to gd
    
    glyphs.push_back(gd); // put gd into 'glyphs' vector for later reuse
}

/*
 this function is for setting font options
 it only has the size option, but you can make
 more options if you want
 */
void Text::fontOpt(int opt, int value) {
    if (FONT_SIZE) {
        // set the font's pixel size
        FT_Set_Pixel_Sizes(face, 0, value);
        currentSize = value; // set current font size equal to 'value' parameter
    }
}