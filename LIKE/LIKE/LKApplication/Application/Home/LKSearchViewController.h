//
//  LKSearchViewController.h
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/5/26.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import <UIKit/UIKit.h>

LC_BLOCK(void, LKSearchViewControllerWillHide, ());

@interface LKSearchViewController : UIView

LC_PROPERTY(copy) LKSearchViewControllerWillHide willHide;

-(void) showInViewController:(UIViewController *)viewController;
-(void) hide;


@end
