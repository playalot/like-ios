//
//  LKTagCommentsViewController.h
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/5/28.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LCUITableViewController.h"
#import "LKTag.h"

LC_BLOCK(void, LKTagCommentsViewControllerWillHide, ());

@interface LKTagCommentsViewController : UIView

LC_PROPERTY(copy) LKTagCommentsViewControllerWillHide willHide;

-(void) showInViewController:(UIViewController *)viewController;
-(void) hide;


-(instancetype) initWithTag:(LKTag *)tag;

-(void) update;

-(void) inputBecomeFirstResponder;
-(void) replyUserAction:(LKUser *)user;

@end