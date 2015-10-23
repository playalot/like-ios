//
//  LKNewPostViewController.h
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/4/18.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//
#import "LCUITableViewController.h"

@interface LKNewPostViewController : LCUITableViewController

LC_PROPERTY(copy) NSString *tagString;

-(instancetype) initWithImage:(UIImage *)image;

@end
