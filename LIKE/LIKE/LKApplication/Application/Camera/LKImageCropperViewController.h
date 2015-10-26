//
//  LKImageCropperViewController.h
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/4/17.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LCUIViewController.h"

LC_BLOCK(void, LKImageCropperDidFinishedPickImage, (UIImage * image));

@interface LKImageCropperViewController : LCUIViewController

LC_PROPERTY(assign) NSInteger tag;
LC_PROPERTY(assign) CGRect buttonFrame;
LC_PROPERTY(assign) CGRect cropFrame;
LC_PROPERTY(assign) CGRect filterFrame;
LC_PROPERTY(assign) CGRect filterScrollFrame;
LC_PROPERTY(assign) BOOL squareImage;
LC_PROPERTY(assign) BOOL dontSaveToAblum;
LC_PROPERTY(strong) NSString * fromPreviewFrameString;
LC_PROPERTY(copy) LKImageCropperDidFinishedPickImage didFinishedPickImage;
LC_PROPERTY(copy) NSString *tagString;

- (id)initWithImage:(UIImage *)originalImage;
- (id)initWithImage:(UIImage *)originalImage filterIndex:(NSInteger)filterIndex;

-(void) showBackButton;
-(void) showDismissButton;

-(UIImage *) currentImage;

@end
