//
//  UIImage+LCExtension.h
//  LCFrameworkDemo
//
//  Created by 王振君 on 15-4-9.
//  Copyright (c) 2015年 Licheng Guo . http://nsobject.me/. All rights reserved.
//

#import <UIKit/UIKit.h>

LC_BLOCK(UIImage *, LCUIImageNamed, (NSString * name));

@interface UIImage (LCExtension)


+(LCUIImageNamed) IMAGE;

#define LC_USE_SYSTEM_IMAGE_CACHE ( NO )

+(UIImage *) imageNamed:(NSString *)name useCache:(BOOL)useCache;

-(UIImage *) scaleToWidth:(CGFloat)width height:(CGFloat)height;
-(UIImage *) scaleToWidth:(CGFloat)width;
-(UIImage *) scaleToBeWidth:(CGFloat)width;
-(UIImage *) scaleToHeight:(CGFloat)height;

-(UIImage *) imageWithTintColor:(UIColor *)color;
-(UIImage *) imageWithBlurValue:(CGFloat)value;

+(UIImage *) imageWithColor:(UIColor *)color andSize:(CGSize)size;

-(UIImage *) autoOrientation;

-(UIImage *) addMarkString:(NSString *)markString inRect:(CGRect)rect color:(UIColor *)color font:(UIFont *)font textAlignment:(UITextAlignment)textAlignment;

-(UIImage *) addMaskImage:(UIImage *)maskImage imageSize:(CGSize)imageSize inRect:(CGRect)rect;

-(UIImage *) imageWithAlpha:(CGFloat)alpha;
-(UIImage *) magic;

@end
