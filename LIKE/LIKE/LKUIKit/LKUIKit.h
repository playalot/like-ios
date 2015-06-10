//
//  LCUIKit.h
//  LIKE
//
//  Created by Leer on 15/4/10.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "POP+MCAnimate.h"

#import "LKColor.h"
#import "LKFont.h"
#import "NSObject+LKTopHud.h"
#import "LKSegmentHeader.h"
#import "LKActionSheet.h"
#import "LKPushAnimation.h"
#import "LKPopAnimation.h"

#undef  LK_FONT
#define LK_FONT(size) [LKFont fontWithSize:size bold:NO]

#undef  LK_FONT_B
#define LK_FONT_B(size) [LKFont fontWithSize:size bold:YES]

#define UI_IS_IPHONE            ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
#define UI_IS_IPHONE4           (UI_IS_IPHONE && [[UIScreen mainScreen] bounds].size.height < 568.0)
#define UI_IS_IPHONE5           (UI_IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0)
#define UI_IS_IPHONE6           (UI_IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 667.0)
#define UI_IS_IPHONE6PLUS       (UI_IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 736.0 || [[UIScreen mainScreen] bounds].size.width == 736.0) // Both orientations

@interface LKUIKit : NSObject

+ (CGSize) parsingImageSizeWithURL:(NSString *)imageUrl;
+ (CGSize) parsingImageSizeWithURL:(NSString *)imageUrl constSize:(CGSize)constSize;

@end
