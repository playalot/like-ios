//
//  LCUIActivityIndicatorView.h
//  LCFrameworkDemo
//
//  Created by 王振君 on 15-4-7.
//  Copyright (c) 2015年 Licheng Guo . http://nsobject.me/. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LCUIActivityIndicatorView : UIActivityIndicatorView

LC_PROPERTY(readonly) BOOL animating;

+(LCUIActivityIndicatorView *) whiteView;
+(LCUIActivityIndicatorView *) grayView;

@end
