//
//  LC_UIImageView.h
//  LCFramework

//  Created by Licheng Guo . ( SUGGESTIONS & BUG titm@tom.com ) on 13-9-26.
//  Copyright (c) 2014年 Licheng Guo iOS developer ( http://nsobject.me ).All rights reserved.
//  Also see the copyright page ( http://nsobject.me/copyright.rtf ).
//
//

#import <UIKit/UIKit.h>
#import "M13ProgressViewRing.h"

@class LCUIImageView;

LC_BLOCK(LCUIImageView *, LCUIImageViewGetURL, (NSString * url, UIImage * placeHolder));

LC_BLOCK(void, LCUIImageViewLoadFinishedBlock, (id imageView));
LC_BLOCK(void, LCUIImageViewDownloadProgressUpdatedBlock, (CGFloat percent));

@interface LCUIImageView : UIImageView

LC_PROPERTY(assign) BOOL blur;
LC_PROPERTY(assign) BOOL showIndicator;
LC_PROPERTY(readonly) BOOL loaded;
LC_PROPERTY(assign) BOOL flipAnimation;
LC_PROPERTY(assign) CGFloat changeImageAnimationDuration;

LC_PROPERTY(strong) UIColor * imageTintColor;
LC_PROPERTY(strong) M13ProgressViewRing * indicator;
LC_PROPERTY(strong) NSString * url;
LC_PROPERTY(copy) LCUIImageViewLoadFinishedBlock loadImageFinishedBlock;
LC_PROPERTY(copy) LCUIImageViewDownloadProgressUpdatedBlock downloadProgressUpdateBlock;
LC_PROPERTY(readonly) LCUIImageViewGetURL URL;

LC_PROPERTY(assign) BOOL autoMask;

+ (instancetype)viewWithImage:(UIImage *)image;

-(void) loadURL:(NSString *)url placeHolder:(UIImage *)image;

@end
