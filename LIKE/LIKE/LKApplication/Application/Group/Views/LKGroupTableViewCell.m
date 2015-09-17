//
//  LKGroupTableViewCell.m
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/9/16.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKGroupTableViewCell.h"
#import "LKTime.h"
#import "LKCommentsView.h"
#import "LKLikesScrollView.h"
#import "UIImageView+WebCache.h"
#import "LKTagsView.h"

@interface LKGroupTableViewCell ()

LC_PROPERTY(strong) LCUIImageView *headImageView;
LC_PROPERTY(strong) LCUILabel *contentLabel;
LC_PROPERTY(strong) LCUIImageView *contentImageView;
LC_PROPERTY(strong) LKTagsView *tagsView;
LC_PROPERTY(strong) LCUILabel *timeLabel;
LC_PROPERTY(strong) LCUIButton *showMoreButton;
LC_PROPERTY(strong) UIView *cellBackgroundView;
LC_PROPERTY(strong) LKCommentsView *commentsView;
LC_PROPERTY(strong) LKLikesScrollView *likesView;
/**
 *  是否展示更多
 */
LC_PROPERTY(assign) BOOL showMore;
LC_PROPERTY(strong) LKTag *testTag;

@end

@implementation LKGroupTableViewCell

-(void) buildUI
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = LKColor.whiteColor;
    self.contentView.backgroundColor = LKColor.backgroundColor;
    
    
    CGFloat padding = 10;
    
    self.headImageView = LCUIImageView.view;
    self.headImageView.viewFrameX = padding;
    self.headImageView.viewFrameY = padding;
    self.headImageView.viewFrameWidth = 33;
    self.headImageView.viewFrameHeight = 33;
    self.headImageView.cornerRadius = self.headImageView.viewMidWidth;
    self.headImageView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    self.headImageView.userInteractionEnabled = YES;
    self.headImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.ADD(self.headImageView);
    
    
    UIImageView * tip = UIImageView.view;
    tip.image = [UIImage imageNamed:@"TalkTip.png" useCache:YES];
    tip.viewFrameWidth = 16 / 3;
    tip.viewFrameHeight = 33 / 3;
    tip.viewFrameX = self.headImageView.viewRightX + padding;
    tip.viewCenterY =  self.headImageView.viewCenterY;
    self.ADD(tip);
    
    
    self.cellBackgroundView = UIView.view.X(tip.viewRightX).Y(padding);
    self.cellBackgroundView.viewFrameWidth = LC_DEVICE_WIDTH - self.cellBackgroundView.viewFrameX - 10;
    self.cellBackgroundView.backgroundColor = [UIColor whiteColor];
    self.ADD(self.cellBackgroundView);
    
    
    self.contentLabel = LCUILabel.view;
    self.contentLabel.viewFrameX = 10;
    self.contentLabel.viewFrameY = 10;
    self.contentLabel.viewFrameWidth = self.cellBackgroundView.viewFrameWidth - 20;
    self.contentLabel.viewFrameHeight = self.contentLabel.font.lineHeight;
    self.contentLabel.textColor = [UIColor blackColor];
    self.contentLabel.backgroundColor = [UIColor clearColor];
    self.cellBackgroundView.ADD(self.contentLabel);
    

    self.contentImageView = LCUIImageView.view;
    self.contentImageView.viewFrameX = self.contentLabel.viewFrameX;
    self.contentImageView.viewFrameY = self.contentLabel.viewBottomY + 10;
    self.contentImageView.viewFrameWidth = 100;
    self.contentImageView.viewFrameHeight = 100;
    self.cellBackgroundView.ADD(self.contentImageView);
    
    
    self.tagsView = LKTagsView.view;
    self.tagsView.scrollEnabled = NO;
    self.showMore = NO;
    self.tagsView.viewFrameX = self.contentImageView.viewRightX;
    self.tagsView.viewFrameY = self.contentImageView.viewFrameY - 10;
    self.tagsView.viewFrameWidth = self.cellBackgroundView.viewFrameWidth - self.tagsView.viewFrameX - 10;
    self.cellBackgroundView.ADD(self.tagsView);
    
    
    self.timeLabel = LCUILabel.view;
    self.timeLabel.font = LK_FONT(12);
    self.timeLabel.textColor = LC_RGB(171, 164, 157);
    self.timeLabel.viewFrameX = self.contentLabel.viewFrameX;
    self.timeLabel.viewFrameY = self.contentImageView.viewBottomY + 10;
    self.timeLabel.viewFrameWidth = self.cellBackgroundView.viewFrameWidth - 20;
    self.timeLabel.viewFrameHeight = self.timeLabel.font.lineHeight;
    self.cellBackgroundView.ADD(self.timeLabel);
    
    
    self.showMoreButton = LCUIButton.view;
    self.showMoreButton.buttonImage = [UIImage imageNamed:@"more.png" useCache:YES];
    self.showMoreButton.titleColor = LC_RGB(140, 133, 126);
    self.showMoreButton.viewFrameHeight = 33;
    self.showMoreButton.viewFrameWidth = 19;
    self.showMoreButton.viewFrameX = self.cellBackgroundView.viewFrameWidth
                                   - self.showMoreButton.viewFrameWidth
                                   - 3;
    self.showMoreButton.viewCenterY = self.timeLabel.viewCenterY;
    self.showMoreButton.transform = CGAffineTransformMakeRotation(M_PI_2);
    [self.showMoreButton addTarget:self action:@selector(showMoreTags) forControlEvents:UIControlEventTouchUpInside];
    self.cellBackgroundView.ADD(self.showMoreButton);
    
    
    self.commentsView = LKCommentsView.view;
    self.commentsView.viewFrameX = self.cellBackgroundView.viewFrameX;
    self.commentsView.viewFrameY = self.cellBackgroundView.viewBottomY;
    self.commentsView.viewFrameWidth = self.cellBackgroundView.viewFrameWidth;
    self.ADD(self.commentsView);
    
    
    self.cellBackgroundView.viewFrameHeight = self.timeLabel.viewBottomY + 10;
    
    
    self.alpha = 0;
    
    LC_FAST_ANIMATIONS(0.4, ^{
        
        self.alpha = 1;
    });
}

-(void) setPost:(LKPost *)post
{
    _post = post;
    
    [self.headImageView sd_setImageWithURL:[NSURL URLWithString:post.user.avatar] placeholderImage:nil];

    self.contentLabel.text = [NSString stringWithFormat:@"%@: 来自厕所捡的iPhone6s plus", post.user.name];
    [self.contentImageView sd_setImageWithURL:[NSURL URLWithString:post.content] placeholderImage:nil];
    self.tagsView.tags = post.tags;
    self.timeLabel.text = [LKTime dateNearByTimestamp:post.timestamp];
    
    NSDictionary *dict = @{@"mark_id": @"532930",
                           @"comments": @[@{@"comment_id": @"18594",
                                            @"content": @"like更新啦!",
                                            @"created": @"1441010240",
                                            @"place": @"福州市",
                                            @"user": @{@"user_id": @"11226",
                                                       @"likes": @"9999",
                                                       @"avatar": @"http://cdn.likeorz.com/avatar_11_1422968054.jpg?imageView2/5/w/240",
                                                       @"nickname": @"Developer"}},
                                          @{@"comment_id": @"18610",
                                            @"content": @"作死小能手!",
                                            @"created": @"1941010240",
                                            @"place": @"重庆市",
                                            @"user": @{@"user_id": @"200",
                                                       @"likes": @"9999",
                                                       @"avatar": @"http://cdn.likeorz.com/avatar_11_1422968054.jpg?imageView2/5/w/240",
                                                       @"nickname": @"Buffer"}},
                                          @{@"comment_id": @"18615",
                                            @"content": @"喜闻乐见!",
                                            @"created": @"1442010240",
                                            @"place": @"New York",
                                            @"user": @{@"user_id": @"11226",
                                                       @"likes": @"9999",
                                                       @"avatar": @"http://cdn.likeorz.com/avatar_11_1422968054.jpg?imageView2/5/w/240",
                                                       @"nickname": @"Mob"}},
                                          @{@"comment_id": @"18818",
                                            @"content": @"顶二楼!",
                                            @"created": @"1443010240",
                                            @"place": @"Los Angeles",
                                            @"user": @{@"user_id": @"11226",
                                                       @"likes": @"9999",
                                                       @"avatar": @"http://cdn.likeorz.com/avatar_11_1422968054.jpg?imageView2/5/w/240",
                                                       @"nickname": @"Umeng"}}],
                           @"likes": @"5",
                           @"tag": @"测试用",
                           @"is_liked": @"0",
                           @"total_comments": @"4",
                           @"createTime": @"1442456235",
                           @"user": @{@"user_id": @"11226",
                                      @"likes": @"9999",
                                      @"avatar": @"http://cdn.likeorz.com/avatar_11_1422968054.jpg?imageView2/5/w/240",
                                      @"nickname": @"Developer"}};
    LKTag *tag = [[LKTag alloc] initWithDictionary:dict error:nil];
    self.testTag = tag;
    self.commentsView.tagValue = tag;
    
    self.cellBackgroundView.layer.mask = nil;
    self.commentsView.viewFrameY = self.cellBackgroundView.viewBottomY;
    
    // 添加圆角
//    if (self.tagDetail.comments.count == 0) {
//
//        [self roundCorners:UIRectCornerAllCorners forView:self.cellBackgroundView];
//    }
//    else{
//        
//        [self roundCorners:UIRectCornerTopLeft | UIRectCornerTopRight forView:self.cellBackgroundView];
//    }
    
    
    // 删除添加标签按钮
    [[self.tagsView.subviews lastObject] removeFromSuperview];
    // 重新计算contentSize
    LKTagItem *lastItem = [self.tagsView.subviews lastObject];
    self.tagsView.contentSize = CGSizeMake(0, lastItem.viewBottomY + 10);
}

- (void)roundCorners:(UIRectCorner)corners forView:(UIView *)view
{
    UIBezierPath * maskPath = [UIBezierPath bezierPathWithRoundedRect:view.bounds
                               
                                                    byRoundingCorners:corners
                               
                                                          cornerRadii:CGSizeMake(4, 4)];
    CAShapeLayer * maskLayer = [CAShapeLayer layer];
    
    maskLayer.frame = view.bounds;
    
    maskLayer.path = maskPath.CGPath;
    
    view.layer.mask = maskLayer;
}

+(CGFloat) height:(LKPost *)post
{
    static LKCommentsView *commentsView = nil;
    
    if (!commentsView) {
        commentsView = LKCommentsView.view;
        commentsView.viewFrameWidth = LC_DEVICE_WIDTH - (10 + 33 + 10 + 16 / 3) - 10;
    }
    
    commentsView.tagValue = post.tags[0];
    
    return 33 + 10 + commentsView.viewFrameHeight;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    LC_FAST_ANIMATIONS(0.25, ^{
    
        if (self.showMore) {

            self.tagsView.viewFrameHeight = self.tagsView.contentSize.height;
        } else {
            
            self.tagsView.viewFrameHeight = 110;
        }
        
        if (self.tagsView.contentSize.height < 120) {
            
            self.timeLabel.viewFrameY = self.contentImageView.viewBottomY + 10;
        } else {
            
            self.timeLabel.viewFrameY = self.tagsView.viewBottomY + 10;
        }
        self.showMoreButton.viewCenterY = self.timeLabel.viewCenterY;
        self.cellBackgroundView.viewFrameHeight = self.timeLabel.viewBottomY + 10;
        self.commentsView.viewFrameY = self.cellBackgroundView.viewBottomY;
    });
}

- (void)showMoreTags {
    
    if (self.tagsView.contentSize.height < 120) {
        return;
    }
    
    self.showMore = !self.showMore;
    LC_FAST_ANIMATIONS(0.25, ^{
        
        self.showMoreButton.transform = CGAffineTransformRotate(self.showMoreButton.transform, M_PI);
    });
    
    [self layoutSubviews];
}

@end
