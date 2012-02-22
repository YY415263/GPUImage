#import "GPUImageColorMatrixFilter.h"

NSString *const kGPUImageColorMatrixFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 
 uniform lowp mat4 colorMatrix;
 uniform lowp float intensity;
 
 void main()
 {
     lowp vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
     lowp vec4 outputColor = textureColor * colorMatrix;
     
     gl_FragColor = (intensity * outputColor) + ((1.0 - intensity) * textureColor);
 }
);                                                                         

@implementation GPUImageColorMatrixFilter

- (id)init;
{
    if (!(self = [super initWithFragmentShaderFromString:kGPUImageColorMatrixFragmentShaderString]))
    {
        return nil;
    }
    
    colorMatrixUniform = [filterProgram uniformIndex:@"colorMatrix"];
    intensityUniform = [filterProgram uniformIndex:@"intensity"];
    
    self.intensity = 1.f;
    self.colorMatrix = (GPUMatrix4x4){
        {1.f, 0.f, 0.f, 0.f},
        {0.f, 1.f, 0.f, 0.f},
        {0.f, 0.f, 1.f, 0.f},
        {0.f, 0.f, 0.f, 1.f}
    };
    
    return self;
}

@synthesize intensity=_intensity;
@synthesize colorMatrix=_colorMatrix;


- (void)setIntensity:(CGFloat)newIntensity;
{
    _intensity = newIntensity;
    [GPUImageOpenGLESContext useImageProcessingContext];
    [filterProgram use];
    glUniform1f(intensityUniform, _intensity);
}

- (void)setColorMatrix:(GPUMatrix4x4)newColorMatrix;
{
    _colorMatrix = newColorMatrix;
    [GPUImageOpenGLESContext useImageProcessingContext];
    [filterProgram use];
    
    glUniformMatrix4fv(colorMatrixUniform, 1, GL_FALSE, (GLfloat *)&_colorMatrix);
}

@end
