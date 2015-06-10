//
//  LC_UIImagePickerViewController.h
//  LCFramework

//  Created by Licheng Guo . ( SUGGESTIONS & BUG titm@tom.com ) on 13-10-15.
//  Copyright (c) 2014年 Licheng Guo iOS developer ( http://nsobject.me ).All rights reserved.
//  Also see the copyright page ( http://nsobject.me/copyright.rtf ).
//
//

#import <UIKit/UIKit.h>

@class LCUIImagePickerViewController;

typedef NS_ENUM(NSInteger, LCImagePickerType)
{
    LCImagePickerTypePhotoLibrary,
    LCImagePickerTypeCamera
};

LC_BLOCK(void, LCImagePickerFinishedBlock, (NSDictionary * imageInfo));

#pragma mark -

@interface LCUIImagePickerViewController : UIImagePickerController

LC_PROPERTY(assign) BOOL autoDismiss;
LC_PROPERTY(assign) LCImagePickerType pickerType;
LC_PROPERTY(copy) LCImagePickerFinishedBlock didFinishPicking;

@end
