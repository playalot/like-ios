//
//  UIImage+GIF.h
//  LBGIFImage
//
//  Created by Laurin Brandner on 06.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (GIF)

@property (nonatomic, assign) NSNumber *animatedImageCount;

+ (UIImage *)sd_animatedGIFNamed:(NSString *)name;

+ (NSInteger)sd_animatedImageCountWithData:(NSData *)data;

+ (UIImage *)sd_animatedGIFWithData:(NSData *)data;

- (UIImage *)sd_animatedImageByScalingAndCroppingToSize:(CGSize)size;

@end
