//
//  Header.h
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/4/15.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKUIKit.h"

@implementation LKUIKit

+(void) load
{
    [[UINavigationBar appearance] setShadowImage:[UIImage imageWithColor:[UIColor clearColor] andSize:CGSizeMake(LC_DEVICE_WIDTH, 1)]];
    [[UITextField appearance] setTintColor:LKColor.color];
}

+ (CGSize) parsingImageSizeWithURL:(NSString *)imageUrl constSize:(CGSize)constSize
{
    //限定图片宽高比
    CGSize constImageSize = [self getContentImageConstScaleSize];
    
    //获得原始图片尺寸
    NSRange rangew = [imageUrl rangeOfString:@"w_[0-9]*" options:NSRegularExpressionSearch];
    CGFloat originalImageWidth;
    
    if (rangew.length == 0) {
        originalImageWidth = constImageSize.width;
    }else{
        originalImageWidth = [[[[imageUrl substringWithRange:rangew] componentsSeparatedByString:@"_"] lastObject] floatValue];
    }
    
    NSRange rangeh = [imageUrl rangeOfString:@"h_[0-9]*" options:NSRegularExpressionSearch];
    CGFloat originalImageHeight;
    if (rangeh.length == 0) {
        originalImageHeight = 250;
    }else{
        originalImageHeight = [[[[imageUrl substringWithRange:rangeh] componentsSeparatedByString:@"_"] lastObject] floatValue];
    }
    
    //查看图片宽度缩放比例
    CGFloat scale = constImageSize.width / originalImageWidth;
    //计算等比缩放的高度
    CGFloat height = scale * originalImageHeight;
    
    //限定高度
    if((height > constImageSize.height)){
        height = constImageSize.height;
    }
    
    CGSize imageSize =  CGSizeMake(constImageSize.width, height);
    
    return imageSize;

}

+ (CGSize) parsingImageSizeWithURL:(NSString *)imageUrl
{
    CGSize constImageSize = [self getContentImageConstScaleSize];
    
    return [self parsingImageSizeWithURL:imageUrl constSize:constImageSize];
}

#define kContentImageSize_IPHONE4 CGSizeMake(640., 640. * 1.25)
#define kContentImageSize_IPHONE5 CGSizeMake(640, 640. * 1.25)
#define kContentImageSize_IPHONE6 CGSizeMake(1115, 1115. * 1.25)
#define kContentImageSize_IPHONE6PLUS CGSizeMake(1242., 1242. * 1.25)

//获得图片裁剪后的高度
+ (CGSize)getContentImageConstScaleSize
{
    CGSize imageSize = CGSizeMake(LC_DEVICE_WIDTH * 2, LC_DEVICE_WIDTH * 2 * 1.25);
    
    if (UI_IS_IPHONE4) {
        imageSize = kContentImageSize_IPHONE4;
    }else if(UI_IS_IPHONE5){
        imageSize = kContentImageSize_IPHONE5;
    }else if(UI_IS_IPHONE6){
        imageSize = kContentImageSize_IPHONE6;
    }else if(UI_IS_IPHONE6PLUS){
        imageSize = kContentImageSize_IPHONE6PLUS;
    }
        
    return imageSize;
}

@end
