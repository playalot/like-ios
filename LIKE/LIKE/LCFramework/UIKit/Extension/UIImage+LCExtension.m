//
//  UIImage+LCExtension.m
//  LCFrameworkDemo
//
//  Created by 王振君 on 15-4-9.
//  Copyright (c) 2015年 Licheng Guo . http://nsobject.me/. All rights reserved.
//

#import "UIImage+LCExtension.h"
#import "LCUIImageCache.h"
#import <ImageIO/ImageIO.h>

@implementation UIImage (LCExtension)

LCUIImageNamed IMAGE(NSString * imageName)
{
    LCUIImageNamed block = ^ UIImage * (NSString * name){
        
        return [UIImage imageNamed:imageName useCache:YES];
    };
    
    return block;
}

+(LCUIImageNamed) IMAGE
{
    LCUIImageNamed block = ^ UIImage * (NSString * name){
        
        return [UIImage imageNamed:name useCache:YES];
    };
    
    return block;
}

#define IS_PHONE6 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? (CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size) || CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size)) : NO)

#define IS_PHONE6PLUS ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? (CGSizeEqualToSize(CGSizeMake(1125, 2001), [[UIScreen mainScreen] currentMode].size) || CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size)) : NO)


+(UIImage *)imageNamed:(NSString *)name useCache:(BOOL)useCache
{
    if (YES == useCache) {
        
        if (LC_USE_SYSTEM_IMAGE_CACHE) {
            
            return [UIImage imageNamed:name];
            
        }else{
            
            UIImage * image = [LCUIImageCache.singleton.memoryCache objectForKey:LC_NSSTRING_FORMAT(@"Application-%@",name)];
            
            if (image) {
                
                return image;
                
            }else{
                
                image = [UIImage imageNamed:name useCache:NO];
                
                if (image) {
                    [LCUIImageCache.singleton.memoryCache setObject:image forKey:LC_NSSTRING_FORMAT(@"Application-%@",name)];
                }
                
                return image;
            }
        }
        
    }else{
        
        if (![name hasSuffix:@".png"] && ![name hasSuffix:@".jpg"]) {
            
            name = [name stringByAppendingString:@".png"];
        }
        
        NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:nil];
        
        if (!path) {
            
            NSArray *tmp = [name componentsSeparatedByString:@"."];
            
            if (tmp.count > 0) {
                
                NSMutableString *string = [[NSMutableString alloc] initWithString:[tmp objectAtIndex:0]];
                [string appendString:@"@3x"];
                
                if (tmp.count == 2) {
                    
                    [string appendFormat:@".%@", [tmp objectAtIndex:1]];
                }
                
                path = [[NSBundle mainBundle] pathForResource:string ofType:nil];
                
                if (!path) {
                    
                    NSMutableString * string = [[NSMutableString alloc] initWithString:[tmp objectAtIndex:0]];
                    [string appendString:@"@2x"];
                    
                    if (tmp.count == 2) {
                        
                        [string appendFormat:@".%@", [tmp objectAtIndex:1]];
                    }
                    
                    path = [[NSBundle mainBundle] pathForResource:string ofType:nil];
                }
            }
        }
        
        UIImage *image = [UIImage imageWithContentsOfFile:path];
        
        image = [UIImage imageWithCGImage:image.CGImage scale:3 orientation:image.imageOrientation];
        
        return image;
    }
}

-(UIImage *) scaleToWidth:(CGFloat)width height:(CGFloat)height
{
    return [[self scaleToWidth:width] scaleToHeight:height];
}

-(UIImage *) scaleToWidth:(CGFloat)width
{
    CGFloat selfWidth = self.size.width;
    CGFloat selfHeight = self.size.height;
    
    if (selfWidth > width) {
        
        selfHeight = width/selfWidth * selfHeight;
        selfWidth = width;
        
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(selfWidth, selfHeight), NO, self.scale);
        [self drawInRect:CGRectMake(0, 0, selfWidth, selfHeight)];
        UIImage * scaledImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return scaledImage;
    }
    else{
        
        return self;
    }
}

-(UIImage *) scaleToBeWidth:(CGFloat)width
{
    CGFloat selfWidth = self.size.width;
    CGFloat selfHeight = self.size.height;
    
    selfHeight = width/selfWidth * selfHeight;
    selfWidth = width;
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(selfWidth, selfHeight), NO, self.scale);
    [self drawInRect:CGRectMake(0, 0, selfWidth, selfHeight)];
    UIImage * scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledImage;
}

-(UIImage *) scaleToHeight:(CGFloat)height
{
    CGFloat selfWidth = self.size.width;
    CGFloat selfHeight = self.size.height;
    
    if (selfHeight > height) {
        
        selfWidth = height/selfHeight * selfWidth;
        selfHeight = height;
        
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(selfWidth, selfHeight), NO, self.scale);
        [self drawInRect:CGRectMake(0, 0, selfWidth, selfHeight)];
        UIImage * scaledImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return scaledImage;
    }
    else{
        
        return self;
    }
    
}

- (UIImage *) imageWithTintColor:(UIColor *)tintColor
{
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    [tintColor setFill];
    
    CGRect bounds = CGRectMake(0, 0, self.size.width, self.size.height);
    UIRectFill(bounds);
    
    [self drawInRect:bounds blendMode:kCGBlendModeDestinationIn alpha:1.0f];
    
    UIImage * tintedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return tintedImage;
}

-(UIImage *) imageWithBlurValue:(CGFloat)value
{
    CIContext * context   = [CIContext contextWithOptions:nil];
    CIImage * sourceImage = [CIImage imageWithCGImage:self.CGImage];
    
    NSString *clampFilterName = @"CIAffineClamp";
    CIFilter *clamp = [CIFilter filterWithName:clampFilterName];
    
    if (!clamp) {
        return nil;
    }
    
    [clamp setValue:sourceImage
             forKey:kCIInputImageKey];
    
    CIImage * clampResult = [clamp valueForKey:kCIOutputImageKey];
    
    NSString * gaussianBlurFilterName = @"CIGaussianBlur";
    CIFilter * gaussianBlur           = [CIFilter filterWithName:gaussianBlurFilterName];
    
    if (!gaussianBlur) {
        
        return nil;
    }
    
    [gaussianBlur setValue:[NSNumber numberWithFloat:value] forKey:@"inputRadius"];
    [gaussianBlur setValue:clampResult forKey:kCIInputImageKey];
    
    CIImage * gaussianBlurResult = [gaussianBlur valueForKey:kCIOutputImageKey];
    
    CGImageRef cgImage = [context createCGImage:gaussianBlurResult fromRect:[sourceImage extent]];
    
    UIImage * blurredImage = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    
    return blurredImage;
}

+ (UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)size
{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    
    UIGraphicsBeginImageContext(rect.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context,
                                   
                                   color.CGColor);
    
    CGContextFillRect(context, rect);
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}

- (UIImage *) autoOrientation
{
    
    // No-op if the orientation is already correct
    if (self.imageOrientation == UIImageOrientationUp) return self;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (self.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (self.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
                                             CGImageGetBitsPerComponent(self.CGImage), 0,
                                             CGImageGetColorSpace(self.CGImage),
                                             CGImageGetBitmapInfo(self.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

- (UIImage *) addMarkString:(NSString *)markString inRect:(CGRect)rect color:(UIColor *)color font:(UIFont *)font textAlignment:(UITextAlignment)textAlignment
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 4.0)
    {
        UIGraphicsBeginImageContextWithOptions(LC_SIZE(self.size.width, self.size.height), NO, self.scale); // 0.0 for scale means "scale for device's main screen".
    }
#else
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 4.0)
    {
        UIGraphicsBeginImageContext([self size]);
    }
#endif
    
    //原图
    [self drawInRect:CGRectMake(0, 0, self.size.width, self.size.height)];
    
    //文字颜色
    [color set];
    


    NSMutableDictionary * dic = [NSMutableDictionary dictionary];
    
    [dic setObject:font forKey:NSFontAttributeName];
    [dic setObject:color forKey:NSForegroundColorAttributeName];
    
    
    /// Make a copy of the default paragraph style
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    /// Set line break mode
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    /// Set text alignment
    paragraphStyle.alignment = textAlignment;
    
    [dic setObject:paragraphStyle forKey:NSParagraphStyleAttributeName];
    
    
    
    //水印文字
    [markString drawInRect:rect withAttributes:dic];
    
    UIImage *newPic = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newPic;
}


- (UIImage *) addMaskImage:(UIImage *)maskImage imageSize:(CGSize)imageSize inRect:(CGRect)rect
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 4.0)
    {
        UIGraphicsBeginImageContextWithOptions(imageSize, NO, self.scale); // 0.0 for scale means "scale for device's main screen".
    }
#else
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 4.0)
    {
        UIGraphicsBeginImageContext(imageSize);
    }
#endif
    
    //原图
    [self drawInRect:CGRectMake(0, 0, self.size.width, self.size.height)];
    

    //水印文字
    [maskImage drawInRect:rect];
    
    UIImage * newPic = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newPic;
}


- (UIImage *)imageWithAlpha:(CGFloat)alpha
{
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect area = CGRectMake(0, 0, self.size.width, self.size.height);
    CGContextScaleCTM(ctx, 1, -1);
    CGContextTranslateCTM(ctx, 0, -area.size.height);
    CGContextSetBlendMode(ctx, kCGBlendModeMultiply);
    CGContextSetAlpha(ctx, alpha);
    CGContextDrawImage(ctx, area, self.CGImage);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

-(UIImage *) magic
{
    CIImage * ciImage = [[CIImage alloc] initWithCGImage:self.CGImage];
    
   // NSDictionary *options = @{CIDetectorImageOrientation : [[ciImage properties] valueForKey:(NSString *)kCGImagePropertyOrientation]};
    
    // Get the filters and apply them to the image
    NSArray * filters = [ciImage autoAdjustmentFiltersWithOptions:nil];
    
    for (CIFilter * filter in filters){
        
        [filter setValue:ciImage forKey:kCIInputImageKey];
        ciImage = filter.outputImage;
    }
    
    // Create the corrected image
    CIContext* ctx = [CIContext contextWithOptions:nil];
    CGImageRef cgImage = [ctx createCGImage:ciImage fromRect:[ciImage extent]];
    UIImage* final = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    return final;
}

@end
