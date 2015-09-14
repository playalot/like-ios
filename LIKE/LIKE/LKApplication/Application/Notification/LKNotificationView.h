//
//  LKNotificationView.h
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/4/22.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LCUITableViewController.h"

LC_BLOCK(void, LKNotificationViewWillHide, ());

@interface LKNotificationView : UIView

LC_PROPERTY(assign) NSInteger fromType;
LC_PROPERTY(copy) LKNotificationViewWillHide willHide;

-(void) showInViewController:(UIViewController *)viewController;
-(void) hide;


@end
