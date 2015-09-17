//
//  LKSettingsViewController.h
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/4/22.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LCUITableViewController.h"
#import "LKUserCenterHomeViewController.h"

LC_BLOCK(void, LKSettingsViewControllerWillHide, ());

@interface LKSettingsViewController : UIView

LC_PROPERTY(strong) LKUserCenterHomeViewController * fromViewController;
LC_PROPERTY(copy) LKSettingsViewControllerWillHide willHide;

-(void) showInViewController:(UIViewController *)viewController;
-(void) hide;

@end
