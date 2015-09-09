//
//  LKUserCenterBrowsingCell.h
//  LIKE
//
//  Created by huangweifeng on 9/6/15.
//  Copyright (c) 2015 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LCUITableViewCell.h"
#import <UIKit/UIKit.h>
#import "LKPost.h"
#import "LKTagsView.h"

@protocol LKHomeTableViewCellDelegate;

@interface LKUserCenterBrowsingCell : LCUITableViewCell

LC_ST_SIGNAL(PushUserCenter);
LC_ST_SIGNAL(PushPostDetail);

LC_PROPERTY(strong) LKPost * post;


+(CGFloat) height:(LKPost *)post;

-(void) reloadTags;

-(void)cellOnTableView:(UITableView *)tableView didScrollOnView:(UIView *)view;

//
LC_PROPERTY(strong) LCUIImageView * contentImage;
LC_PROPERTY(strong) UIView * contentBack;
LC_PROPERTY(strong) LKTagsView * tagsView;

-(void) newTagAnimation:(void (^)(BOOL finished))completion;

@property (nonatomic, weak) id <LKHomeTableViewCellDelegate> delegate;

@end
