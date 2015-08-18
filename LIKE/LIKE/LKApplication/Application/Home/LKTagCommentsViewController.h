//
//  LKTagCommentsViewController.h
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/5/28.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LCUITableViewController.h"
#import "LKTag.h"
#import "LKPost.h"
#import "LKTagsView.h"

LC_BLOCK(void, LKTagCommentsViewControllerWillHide, ());
LC_BLOCK(void, EZCommentDetailCellDidRemoved, (NSIndexPath * indexPath));

@interface LKTagCommentsViewController : UIView

LC_PROPERTY(copy) LKTagCommentsViewControllerWillHide willHide;

-(void) showInViewController:(UIViewController *)viewController;
-(void) hide;


-(instancetype) initWithTag:(LKTag *)tag;

-(void) update;

-(void) inputBecomeFirstResponder;
-(void) replyUserAction:(LKUser *)user;

LC_PROPERTY(copy) EZCommentDetailCellDidRemoved didRemoved;
LC_PROPERTY(strong) LKTagsView * tagsView;

@end
