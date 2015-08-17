//
//  LC_UIViewController.h
//  LCFramework

//  Created by Licheng Guo . ( SUGGESTIONS & BUG titm@tom.com ) on 13-9-21.
//  Copyright (c) 2014年 Licheng Guo iOS developer ( http://nsobject.me ).All rights reserved.
//  Also see the copyright page ( http://nsobject.me/copyright.rtf ).
//
//

#import <UIKit/UIKit.h>

@interface LCUIViewController : UIViewController
/**
 *  是否是当前显示的控制器
 */
LC_PROPERTY(assign) BOOL isCurrentDisplayController;

-(void) buildUI;

@end
