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

LC_PROPERTY(strong) LCUIImageView * headImageView;
LC_PROPERTY(strong) LCUILabel * contentLabel;
LC_PROPERTY(strong) LCUIImageView * contentImageView;
LC_PROPERTY(strong) LKTagsView *tagsView;
LC_PROPERTY(strong) LCUILabel * timeLabel;
LC_PROPERTY(strong) UIView * cellBackgroundView;
LC_PROPERTY(strong) LKCommentsView * commentsView;
LC_PROPERTY(strong) LKLikesScrollView * likesView;

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
    self.tagsView.viewFrameX = self.contentImageView.viewRightX + 10;
    self.tagsView.viewFrameY = self.contentImageView.viewFrameY;
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
    
    
    LCUIButton *showMoreButton = LCUIButton.view;
    showMoreButton.buttonImage = [UIImage imageNamed:@"more.png" useCache:YES];
    showMoreButton.titleColor = LC_RGB(140, 133, 126);
    showMoreButton.viewFrameHeight = 33;
    showMoreButton.viewFrameWidth = 19;
    showMoreButton.viewFrameX = self.cellBackgroundView.viewFrameWidth - showMoreButton.viewFrameWidth - 3;
    showMoreButton.viewCenterY = self.timeLabel.viewCenterY;
    showMoreButton.transform = CGAffineTransformMakeRotation(M_PI_2);
    self.cellBackgroundView.ADD(showMoreButton);
    
    
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
    self.commentsView.tagValue =
    
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
    
    
//    self.commentsView.tagValue = _tagDetail;
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
    
    self.tagsView.viewFrameHeight = 100;
}

@end
