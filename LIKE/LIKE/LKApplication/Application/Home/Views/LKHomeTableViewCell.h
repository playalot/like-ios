//
//  LikeHomeTableViewCell.h
//  Like_iOS
//
//  Created by Majunxiao on 15-1-8.
//  Copyright (c) 2015年 ZJ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LKPost.h"
#import "LKTagsView.h"

LC_BLOCK(void, LKHomeCellAddTag, (LKPost * post));
LC_BLOCK(void, LKHomeCellRemovedTag, (LKPost * post));
LC_BLOCK(void, LKHomeCellCustomAction, (LKPost * post));

@interface LKHomeTableViewCell : LCUITableViewCell

LC_ST_SIGNAL(PushUserCenter);
LC_ST_SIGNAL(PushPostDetail);

LC_PROPERTY(strong) LKPost * post;
LC_PROPERTY(copy) LKHomeCellAddTag addTag;
LC_PROPERTY(copy) LKHomeCellRemovedTag removedTag;
LC_PROPERTY(copy) LKHomeCellCustomAction customAction;


+(CGFloat) height:(LKPost *)post;

-(void) reloadTags;

-(void)cellOnTableView:(UITableView *)tableView didScrollOnView:(UIView *)view;

//
LC_PROPERTY(strong) LCUIImageView * contentImage;
LC_PROPERTY(strong) UIView * contentBack;
LC_PROPERTY(strong) LKTagsView * tagsView;

@end
