//
//  LKPostTableViewCell.m
//  LIKE
//
//  Created by huangweifeng on 9/9/15.
//  Copyright (c) 2015 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKPostTableViewCell.h"
#import "LKPost.h"
#import "LKTagsView.h"
#import "ADTickerLabel.h"
#import "UIImageView+WebCache.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"

@interface LKPostTableViewCell ()

LC_PROPERTY(strong) UIView *headerBack;
LC_PROPERTY(strong) LCUIImageView * head;
LC_PROPERTY(strong) LCUILabel * title;
LC_PROPERTY(strong) ADTickerLabel * likes;
LC_PROPERTY(strong) LCUILabel * likesTip;
LC_PROPERTY(strong) LCUIButton * friendshipButton;
LC_PROPERTY(strong) LCUIActivityIndicatorView * loadingActivity;

LC_PROPERTY(strong) UIView * blackMask;

@end

@implementation LKPostTableViewCell

LC_IMP_SIGNAL(PushUserCenter);
LC_IMP_SIGNAL(PushPostDetail);

+ (CGFloat)height:(LKPost *)post headLineHidden:(BOOL)headHidden {
    CGSize size = [LKUIKit parsingImageSizeWithURL:post.preview constSize:CGSizeMake(LC_DEVICE_WIDTH - 10, LC_DEVICE_WIDTH - 10)];
    if (size.width > LC_DEVICE_WIDTH - 10) {
        size.height = (LC_DEVICE_WIDTH - 10) / size.width * size.height;
        size.width = (LC_DEVICE_WIDTH - 10);
    }
    static LKTagsView * __tagsView = nil;
    if (!__tagsView) {
        __tagsView = LKTagsView.view;
        __tagsView.viewFrameWidth = LC_DEVICE_WIDTH - 10;
    }
    __tagsView.tags = post.tags;
    return size.height + __tagsView.viewFrameHeight + (headHidden ? 10 : 55);
}

- (void)buildUI {
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [self buildHeadLine];
    [self buildContentView];
    [self buildTagsView];
    
    @weakly(self);
    
    self.tagsView.itemRequestFinished = ^(LKTagItemView * item){
        @normally(self);
        if (item.tagValue.isLiked) {
            self.post.user.likes = @(self.post.user.likes.integerValue + 1);
        } else {
            self.post.user.likes = @(self.post.user.likes.integerValue - 1);
        }
        self.likes.text = LC_NSSTRING_FORMAT(@"%@", self.post.user.likes);
        CGSize likeSize = [self.post.user.likes.description sizeWithFont:LK_FONT(13) byWidth:200];
        [UIView animateWithDuration:0.25 animations:^{
            self.likesTip.viewFrameX = self.likes.viewFrameX + likeSize.width + 3;
        }];
    };
}

- (void)hideHeadLine {
    self.headerBack.alpha = 0;
    self.head.alpha = 0;
    self.title.alpha = 0;
    self.likes.alpha = 0;
    self.likesTip.alpha = 0;
}

- (void)buildTagsView {
    self.tagsView = LKTagsView.view;
    self.tagsView.viewFrameX = 5;
    self.tagsView.viewFrameWidth = LC_DEVICE_WIDTH - 10;
    self.tagsView.backgroundColor = [UIColor whiteColor];
    self.contentView.ADD(self.tagsView);
}

- (void)buildContentView {
    // 内容北京View
    self.contentBack = UIView.view;
    self.contentBack.clipsToBounds = YES;
    self.contentView.ADD(self.contentBack);
    
    // 内容图片
    self.contentImageView = LCUIImageView.view;
    self.contentImageView.viewFrameY = -30;
    self.contentImageView.backgroundColor = [UIColor whiteColor];
    self.contentImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.contentImageView.userInteractionEnabled = YES;
    self.contentImageView.showIndicator = YES;
    self.contentImageView.showActivityIndicatorView = YES;
    [self.contentImageView addTapGestureRecognizer:self selector:@selector(contentImageTapAction)];
    self.contentBack.ADD(self.contentImageView);
}

- (void)buildHeadLine {
    
    // White Header Bar
    self.headerBack = UIView.view.X(5).Y(5).WIDTH(LC_DEVICE_WIDTH - 10).HEIGHT(55);
    self.headerBack.backgroundColor = [UIColor whiteColor];
    self.contentView.ADD(self.headerBack);
    
    [LKPostTableViewCell roundCorners:UIRectCornerTopLeft | UIRectCornerTopRight forView:self.headerBack];
    
    // 头像
    self.head = LCUIImageView.view;
    self.head.viewFrameX = 15;
    self.head.viewFrameY = 55 / 2 - 35 / 2 + 5;
    self.head.viewFrameWidth = 35;
    self.head.viewFrameHeight = 35;
    self.head.cornerRadius = 35. / 2.;
    self.head.layer.shouldRasterize = NO;
    self.head.backgroundColor = LKColor.backgroundColor;
    self.head.userInteractionEnabled = YES;
    [self.head addTapGestureRecognizer:self selector:@selector(handleHeadTap:)];
    self.contentView.ADD(self.head);
    
    // 昵称
    self.title = LCUILabel.view;
    self.title.viewFrameX = self.head.viewRightX + 10;
    self.title.viewFrameY = self.head.viewFrameY;
    self.title.viewFrameWidth = LC_DEVICE_WIDTH - 150;
    self.title.viewFrameHeight = LK_FONT(13).lineHeight;
    self.title.font = LK_FONT(13);
    self.title.textColor = LC_RGB(51, 51, 51);
    [self.title addTapGestureRecognizer:self selector:@selector(handleHeadTap:)];
    self.contentView.ADD(self.title);
    
    // like数量
    self.likes = ADTickerLabel.view;
    self.likes.viewFrameWidth = LC_DEVICE_WIDTH / 2 - 10 - 5;
    self.likes.viewFrameX = self.title.viewFrameX;
    self.likes.viewFrameHeight = LK_FONT(13).lineHeight;
    self.likes.viewFrameY = self.title.viewBottomY;
    self.likes.font = LK_FONT(13);
    self.likes.textAlignment = UITextAlignmentLeft;
    self.likes.textColor = LC_RGB(51, 51, 51);
    self.likes.changeTextAnimationDuration = 0.25;
    [self.likes addTapGestureRecognizer:self selector:@selector(handleHeadTap:)];
    self.contentView.ADD(self.likes);
    
    // like数量后缀
    self.likesTip = LCUILabel.view;
    self.likesTip.viewFrameY = self.likes.viewFrameY;
    self.likesTip.font = LK_FONT(13);
    self.likesTip.textAlignment = UITextAlignmentLeft;
    self.likesTip.textColor = LC_RGB(51, 51, 51);
    self.likesTip.text = @"likes";
    self.likesTip.FIT();
    self.likesTip.viewFrameHeight = LK_FONT(13).lineHeight;
    [self.likesTip addTapGestureRecognizer:self selector:@selector(handleHeadTap:)];
    self.contentView.ADD(self.likesTip);
}

- (void)addTagAction {
    if (self.addTag) {
        self.addTag(self.post);
    }
}

- (void)handleHeadTap:(UITapGestureRecognizer *)tap {
    self.SEND(self.PushUserCenter).object = self.post.user;
}

- (void)contentImageTapAction {
    self.SEND(self.PushPostDetail).object = self.post;
}

- (void)setPost:(LKPost *)post {
    _post = post;
    
    if (post.user.id.integerValue == LKLocalUser.singleton.user.id.integerValue) {
        post.user = LKLocalUser.singleton.user;
    }
    
    // 设置cell内容
    self.head.image = nil;
    [self.head sd_setImageWithURL:[NSURL URLWithString:post.user.avatar] placeholderImage:nil];
    
    self.title.text = LC_NSSTRING_FORMAT(@"%@", post.user.name);
    [self.likes setText:LC_NSSTRING_FORMAT(@"%@", post.user.likes) animated:NO];
    
    CGSize likeSize = [post.user.likes.description sizeWithFont:LK_FONT(13) byWidth:200];
    
    self.likesTip.viewFrameX = self.likes.viewFrameX + likeSize.width + 3;
    CGSize size = [LKUIKit parsingImageSizeWithURL:post.preview constSize:CGSizeMake(LC_DEVICE_WIDTH - 10, LC_DEVICE_WIDTH - 10)];
    
    if (size.width > LC_DEVICE_WIDTH - 10) {
        size.height = (LC_DEVICE_WIDTH - 10) / size.width * size.height;
        size.width = (LC_DEVICE_WIDTH - 10);
    }
    
    self.contentBack.viewFrameX = 5 + (LC_DEVICE_WIDTH - 10) / 2 - size.width / 2;
    self.contentBack.viewFrameY = self.headLineHidden ? 10 : 55;
    self.contentBack.viewFrameWidth = size.width;
    self.contentBack.viewFrameHeight = size.height;
    
    self.contentImageView.clipsToBounds = YES;
    self.contentImageView.frame = self.contentBack.bounds;
    self.contentImageView.image = nil;
    
    for (UIView *view in self.contentImageView.subviews) {
        
        if ([view isKindOfClass:[M13ProgressViewRing class]]) {
            
            [view removeFromSuperview];
        }
    }
    
    [self.contentImageView setImageWithURL:[NSURL URLWithString:post.preview] placeholderImage:nil options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        
        
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
        
    } usingActivityIndicatorStyle:0];
    
    self.tagsView.tags = post.tags;
    self.tagsView.viewFrameY = self.contentBack.viewBottomY;
    
    [LKPostTableViewCell roundCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight forView:self.tagsView];
    
    @weakly(self);
    self.tagsView.didRemoveTag = ^(LKTag * tag){
        @normally(self);
        if (self.removedTag) {
            self.removedTag(self.post);
        }
    };
    
    self.tagsView.customAction = ^(id value){
        @normally(self);
        if (self.addTag) {
            self.addTag(self.post);
        }
    };
    
    self.tagsView.willRequest = ^(LKTagItemView * item){
        @normally(self);
        if (item.tagValue.isLiked) {
            return;
        }
        [self newTagAnimation:nil];
    };
}

- (void)newTagAnimation:(void (^)(BOOL finished))completion {
    if (!self.blackMask) {
        self.blackMask = UIView.view;
        self.blackMask.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        self.contentImageView.ADD(self.blackMask);
    }
    
    self.blackMask.frame = self.contentImageView.bounds;
    self.blackMask.alpha = 0;
    
    LCUILabel * label = [[LCUILabel alloc] init];
    label.text = @"+1";
    label.font = [UIFont fontWithName:@"AvenirNext-Bold" size:60];
    label.textColor = [UIColor whiteColor];
    label.FIT();
    label.viewCenterX = self.contentImageView.viewMidWidth;
    label.viewCenterY = self.contentImageView.viewMidHeight;
    label.alpha = 0;
    label.transform = CGAffineTransformScale(CGAffineTransformIdentity, 2, 2);
    self.contentImageView.ADD(label);
    
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction animations:^{
        label.alpha = 1;
        label.transform = CGAffineTransformIdentity;
        self.blackMask.alpha = 1;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.25 delay:0.5 options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction animations:^{
            label.alpha = 0;
            self.blackMask.alpha = 0;
        } completion:^(BOOL finished) {
            [label removeFromSuperview];
            if (completion) {
                completion(YES);
            }
        }];
    }];
    
}

-(void) reloadTags {
}

- (void)cellOnTableView:(UITableView *)tableView didScrollOnView:(UIView *)view {
}

+ (void)roundCorners:(UIRectCorner)corners forView:(UIView *)view {
    UIBezierPath * maskPath = [UIBezierPath bezierPathWithRoundedRect:view.bounds
                                                    byRoundingCorners:corners
                                                          cornerRadii:CGSizeMake(2, 2)];
    CAShapeLayer * maskLayer = [CAShapeLayer layer];
    maskLayer.frame = view.bounds;
    maskLayer.path = maskPath.CGPath;
    view.layer.mask = maskLayer;
}

/**
 *  获取推荐理由图片
 */
-(UIImage *) getIconImage:(NSInteger)type {
    if (type == 1) {
        return [UIImage imageNamed:@"LittleTag.png" useCache:YES];
    } else if (type == 2) {
        return [UIImage imageNamed:@"LittleSP.png" useCache:YES];
    } else if(type == 3) {
        return [UIImage imageNamed:@"LittleYouLike.png" useCache:YES];
    } else if(type == 4) {
        return [UIImage imageNamed:@"LittleFollowing.png" useCache:YES];
    }
    return nil;
}

- (void)layoutSubviews {
    if (self.headLineHidden) {
        [self hideHeadLine];
    }
    [super layoutSubviews];
}

@end
