//
//  CBrush.h
//  calligraphyDemo
//
//  Created by sinogz on 16/5/4.
//  Copyright © 2016年 steven.cai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>
#import <GLKit/GLKit.h>

// Texture
typedef struct {
    GLuint id;
    GLsizei width, height;
} textureInfo_t;


@interface CBrush : NSObject
{
    //textureInfo_t texture;     // brush texture
    //GLfloat color[4];          // brush color
}
@property (nonatomic, assign) textureInfo_t texture;
@property (nonatomic, assign) GLfloat *color;

+ (instancetype)createBrushWithTexture:(NSString *)textureName;

@end
