//
//  LKInputTextViewController.h
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/4/24.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LCUIViewController.h"

LC_BLOCK(void, LKInputTextViewControllerFinished, (NSString * string));

@interface LKInputTextViewController : LCUIViewController

LC_PROPERTY(copy) LKInputTextViewControllerFinished inputFinished;

@end
