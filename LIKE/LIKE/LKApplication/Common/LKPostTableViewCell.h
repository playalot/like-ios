//
//  LKPostTableViewCell.h
//  LIKE
//
//  Created by huangweifeng on 9/9/15.
//  Copyright (c) 2015 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LCUITableViewCell.h"
#import "LKPost.h"
#import "LKTagsView.h"

LC_BLOCK(void, LKPostCellAddTag, (LKPost * post));
LC_BLOCK(void, LKPostCellRemovedTag, (LKPost * post));
LC_BLOCK(void, LKPostCellCustomAction, (LKPost * post));

@interface LKPostTableViewCell : LCUITableViewCell

LC_ST_SIGNAL(PushUserCenter);
LC_ST_SIGNAL(PushPostDetail);

LC_PROPERTY(strong) LKPost * post;
LC_PROPERTY(copy) LKPostCellAddTag addTag;
LC_PROPERTY(copy) LKPostCellRemovedTag removedTag;
LC_PROPERTY(copy) LKPostCellCustomAction customAction;
LC_PROPERTY(assign) BOOL headLineHidden;

+ (CGFloat)height:(LKPost *)post headLineHidden:(BOOL)headHidden;

- (void)reloadTags;

- (void)cellOnTableView:(UITableView *)tableView didScrollOnView:(UIView *)view;

LC_PROPERTY(strong) LCUIImageView * contentImage;
LC_PROPERTY(strong) UIView * contentBack;
LC_PROPERTY(strong) LKTagsView * tagsView;

-(void) newTagAnimation:(void (^)(BOOL finished))completion;

@end
