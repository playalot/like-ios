//
//  LKCameraViewController.h
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/4/16.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LCUIViewController.h"

typedef NS_ENUM(NSInteger, LKCameraPosition)
{
    LKCameraPositionBack,
    LKCameraPositionFront
    
} ;

typedef enum : NSUInteger {
    
    LKCameraFlashOff,
    LKCameraFlashOn,
    LKCameraFlashAuto
    
} LKCameraFlash;

typedef enum : NSUInteger {
    LKCameraQualityLow,
    LKCameraQualityMedium,
    LKCameraQualityHigh,
    LKCameraQualityPhoto
    
} LKCameraQuality;

LC_BLOCK(void, LKCameraDidFinishedPickImage, (UIImage * image));

@interface LKCameraViewController : LCUIViewController

LC_PROPERTY(assign) LKCameraQuality cameraQuality;
LC_PROPERTY(assign) LKCameraFlash cameraFlash;
LC_PROPERTY(assign) LKCameraPosition cameraPosition;

LC_PROPERTY(assign) BOOL autoOrientationAfterCapture;
LC_PROPERTY(assign) BOOL tapToFocus;
LC_PROPERTY(assign) BOOL squareImage;

LC_PROPERTY(copy) LKCameraDidFinishedPickImage didFinishedPickImage;

@end
