//
//  LikeHomeTableViewCell.m
//  Like_iOS
//
//  Created by Majunxiao on 15-1-8.
//  Copyright (c) 2015年 ZJ. All rights reserved.
//

#import "LKHomeTableViewCell.h"
#import "LKPost.h"
#import "LKTagsView.h"
#import "ADTickerLabel.h"
#import "UIImageView+WebCache.h"
#import "LKLikeTagItemView.h"

@interface LKHomeTableViewCell()

LC_PROPERTY(strong) LCUIImageView *head;
LC_PROPERTY(strong) LCUILabel *title;
LC_PROPERTY(strong) ADTickerLabel *likes;
LC_PROPERTY(strong) LCUILabel *likesTip;
LC_PROPERTY(strong) LCUIButton *friendshipButton;
LC_PROPERTY(strong) LCUIActivityIndicatorView *loadingActivity;
LC_PROPERTY(strong) LCUIButton *recommendedReason;
LC_PROPERTY(strong) LCUIButton *recommendedReasonWithTag;
LC_PROPERTY(strong) UIView *blackMask;

@end

@implementation LKHomeTableViewCell

LC_IMP_SIGNAL(PushUserCenter);
LC_IMP_SIGNAL(PushPostDetail);


+ (CGFloat)height:(LKPost *)post {
    CGSize size = [LKUIKit parsingImageSizeWithURL:post.content constSize:CGSizeMake(LC_DEVICE_WIDTH, LC_DEVICE_WIDTH)];
    if (size.width > LC_DEVICE_WIDTH) {
        
        size.height = LC_DEVICE_WIDTH / size.width * size.height;
        size.width = LC_DEVICE_WIDTH;
    }
    
    static LKTagsView * __tagsView = nil;
    if (!__tagsView) {
        __tagsView = LKTagsView.view;
        __tagsView.viewFrameWidth = LC_DEVICE_WIDTH;
    }
    
    __tagsView.tags = post.tags;
    
    return size.height + __tagsView.viewFrameHeight + 54;
}

-(void) buildUI {
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.contentBack = UIView.view;
    self.contentBack.clipsToBounds = YES;
    self.ADD(self.contentBack);
    
    
    // 内容图片
    self.contentImage = LCUIImageView.view;
    self.contentImage.viewFrameY = -30;
    self.contentImage.backgroundColor = [UIColor whiteColor];
    self.contentImage.contentMode = UIViewContentModeScaleAspectFill;
    self.contentImage.userInteractionEnabled = YES;
    self.contentImage.showIndicator = YES;
    [self.contentImage addTapGestureRecognizer:self selector:@selector(contentImageTapAction)];
    self.contentBack.ADD(self.contentImage);
//    self.ADD(self.contentImage);
    
//    UIView *headerBack = UIView.view.X(0).Y(0).WIDTH(LC_DEVICE_WIDTH).HEIGHT(66);
//    headerBack.backgroundColor = [UIColor whiteColor];
//    self.ADD(headerBack);
    
    
//    [LKHomeTableViewCell roundCorners:UIRectCornerTopLeft | UIRectCornerTopRight forView:headerBack];
    
    // 头像
    self.head = LCUIImageView.view;
    self.head.viewFrameX = 14;
//    self.head.viewFrameY = 55 / 2 - 35 / 2 + 5;
    self.head.viewFrameY = 10;
    self.head.viewFrameWidth = 34;
    self.head.viewFrameHeight = 34;
    self.head.cornerRadius = 34 * 0.5;
    self.head.layer.shouldRasterize = NO;
    self.head.backgroundColor = LKColor.backgroundColor;
    self.head.userInteractionEnabled = YES;
    [self.head addTapGestureRecognizer:self selector:@selector(handleHeadTap:)];
    self.ADD(self.head);
    
    // 昵称
    self.title = LCUILabel.view;
    self.title.viewFrameX = self.head.viewRightX + 12;
    self.title.viewFrameY = self.head.viewFrameY;
    self.title.viewFrameWidth = LC_DEVICE_WIDTH - 150;
    self.title.viewFrameHeight = LK_FONT(13).lineHeight;
    self.title.font = LK_FONT(14);
    self.title.textColor = LC_RGB(51, 51, 51);
    [self.title addTapGestureRecognizer:self selector:@selector(handleHeadTap:)];
    self.ADD(self.title);
    
    // like数量
    self.likes = ADTickerLabel.view;
    self.likes.viewFrameWidth = LC_DEVICE_WIDTH / 2 - 10 - 5;
    self.likes.viewFrameX = self.title.viewFrameX;
    self.likes.viewFrameHeight = LK_FONT(10).lineHeight;
    self.likes.viewFrameY = self.title.viewBottomY + 2;
    self.likes.font = LK_FONT(10);
    self.likes.textAlignment = UITextAlignmentLeft;
    self.likes.textColor = LC_RGB(51, 51, 51);
    self.likes.changeTextAnimationDuration = 0.25;
    [self.likes addTapGestureRecognizer:self selector:@selector(handleHeadTap:)];
    self.ADD(self.likes);
    
    // like数量后缀
    self.likesTip = LCUILabel.view;
    self.likesTip.viewFrameY = self.likes.viewFrameY;
    self.likesTip.font = LK_FONT(10);
    self.likesTip.textAlignment = UITextAlignmentLeft;
    self.likesTip.textColor = LC_RGB(51, 51, 51);
    self.likesTip.text = @"likes";
    self.likesTip.FIT();
    self.likesTip.viewFrameHeight = LK_FONT(10).lineHeight;
    [self.likesTip addTapGestureRecognizer:self selector:@selector(handleHeadTap:)];
    self.ADD(self.likesTip);
    
    // 推荐理由
    self.recommendedReason = LCUIButton.view;
    self.recommendedReason.title = LC_LO(@"共同兴趣");
    self.recommendedReason.titleFont = LK_FONT(13);
    self.recommendedReason.titleColor = LC_RGB(217, 217, 217);
    self.recommendedReason.buttonImage = [UIImage imageNamed:@"LittleTag" useCache:YES];
    self.recommendedReason.viewFrameHeight = LK_FONT(13).lineHeight;
    self.recommendedReason.viewFrameY = (54 - self.recommendedReason.viewFrameHeight) * 0.5;
    self.recommendedReason.viewFrameX = LC_DEVICE_WIDTH - self.recommendedReasonWithTag.viewFrameWidth - 15;
    self.recommendedReason.titleEdgeInsets = UIEdgeInsetsMake(1, 0, 0, 0);
    [self.recommendedReason addTarget:self action:@selector(recommendedReasonBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    self.ADD(self.recommendedReason);
    
    // 推荐理由标签
    self.recommendedReasonWithTag = LCUIButton.view;
    self.recommendedReasonWithTag.viewFrameWidth = LC_DEVICE_WIDTH / 2;
    self.recommendedReasonWithTag.viewFrameHeight = LK_FONT(10).lineHeight;
    self.recommendedReasonWithTag.viewFrameX = LC_DEVICE_WIDTH / 2 - 15;
    self.recommendedReasonWithTag.viewFrameY = self.likesTip.viewFrameY + 2;
    self.recommendedReasonWithTag.title = LC_LO(@"有故事的人");
    self.recommendedReasonWithTag.titleColor = LC_RGB(217, 217, 217);
//    self.recommendedReasonWithTag.font = LK_FONT(11);
    self.recommendedReasonWithTag.titleFont = LK_FONT(10);
//    self.recommendedReasonWithTag.textAlignment = UITextAlignmentRight;
    self.recommendedReasonWithTag.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    self.recommendedReasonWithTag.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 1);
    [self.recommendedReasonWithTag addTarget:self action:@selector(recommendedReasonBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    self.ADD(self.recommendedReasonWithTag);
    
    self.tagsView = LKTagsView.view;
    self.tagsView.viewFrameX = 0;
    self.tagsView.viewFrameWidth = LC_DEVICE_WIDTH;
    self.tagsView.backgroundColor = LC_RGB(245, 245, 245);
    self.ADD(self.tagsView);
    
    @weakly(self);
    
    self.tagsView.itemRequestFinished = ^(LKTagItemView * item){
        
        @normally(self);
        
        if (item.tagValue.isLiked) {
            self.post.user.likes = @(self.post.user.likes.integerValue + 1);
        } else {
            self.post.user.likes = @(self.post.user.likes.integerValue - 1);
        }
        
        self.likes.text = LC_NSSTRING_FORMAT(@"%@", self.post.user.likes);
        CGSize likeSize = [self.post.user.likes.description sizeWithFont:LK_FONT(10) byWidth:200];
        [UIView animateWithDuration:0.25 animations:^{
            self.likesTip.viewFrameX = self.likes.viewFrameX + likeSize.width + 3;
        }];
    };
    
    LKLikeTagItemView *tagsView = [[LKLikeTagItemView alloc] initWithFrame:CGRectMake(100, 100, 200, 50)];
    self.ADD(tagsView);
}

-(void) addTagAction {
    if (self.addTag) {
        self.addTag(self.post);
    }
}

-(void) handleHeadTap:(UITapGestureRecognizer *)tap {
    self.SEND(self.PushUserCenter).object = self.post.user;
}

/**
 *  点击主页cell里面的图片就会执行此方法
 */
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
    
    CGSize likeSize = [post.user.likes.description sizeWithFont:LK_FONT(10) byWidth:200];
    
    self.likesTip.viewFrameX = self.likes.viewFrameX + likeSize.width + 3;
    
    CGSize size = [LKUIKit parsingImageSizeWithURL:post.content constSize:CGSizeMake(LC_DEVICE_WIDTH - 10, LC_DEVICE_WIDTH - 10)];
    
    if (size.width > LC_DEVICE_WIDTH) {
        size.height = LC_DEVICE_WIDTH / size.width * size.height;
        size.width = LC_DEVICE_WIDTH;
    }
    
    // 设置图片的frame
    self.contentBack.viewFrameX = 0;
    self.contentBack.viewFrameY = 54;
    self.contentBack.viewFrameWidth = size.width;
    self.contentBack.viewFrameHeight = size.height;
    
    self.contentImage.clipsToBounds = YES;
    self.contentImage.frame = self.contentBack.bounds;
    self.contentImage.image = nil;

    [self.contentImage sd_setImageWithURL:[NSURL URLWithString:post.content] placeholderImage:nil options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        
        if (self.contentImage.indicator.progress == 0) {
            [self.contentImage.indicator setProgress:receivedSize * 1.0 / expectedSize animated:YES];
            self.contentImage.indicator.alpha = 1;
        }
        
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {

        self.contentImage.indicator.alpha = 0;
        [self.contentImage.indicator removeFromSuperview];
    }];
    
    // 设置标签的frame
    self.tagsView.tags = post.tags;
    self.tagsView.viewFrameY = self.contentBack.viewBottomY;
    
    [LKHomeTableViewCell roundCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight forView:self.tagsView];
    
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
    
    // 设置'推荐理由'相关属性
    NSString * reason = [NSString stringWithFormat:@"RecommentReason%@", @(post.reason)];
    
    self.recommendedReason.buttonImage = [self getIconImage:post.reason];
    self.recommendedReason.viewFrameWidth = 2000;
    self.recommendedReason.viewFrameY = self.title.viewFrameY + 2;
    self.recommendedReason.title = [NSString stringWithFormat:@"  %@", LC_LO(reason)];
    self.recommendedReason.FIT();
    self.recommendedReason.viewFrameX = LC_DEVICE_WIDTH - self.recommendedReason.viewFrameWidth - 15;
    self.recommendedReason.hidden = post.reason <= 0;
    self.recommendedReasonWithTag.title = post.reasonTag;
    self.recommendedReasonWithTag.hidden = LC_NSSTRING_IS_INVALID(post.reasonTag);
    
    if (self.recommendedReasonWithTag.hidden == YES) {
        self.recommendedReason.viewFrameY = (54 - self.recommendedReason.viewFrameHeight) * 0.5;
        self.recommendedReasonWithTag.viewFrameY = CGRectGetMaxY(self.recommendedReason.frame) - 5;
        self.recommendedReasonWithTag.viewFrameX = CGRectGetMaxX(self.recommendedReason.frame) - self.recommendedReasonWithTag.viewFrameWidth;
    }
}

/**
 *  点击标签就会执行动画
 */
- (void) newTagAnimation:(void (^)(BOOL finished))completion {
    if (!self.blackMask) {
        
        self.blackMask = UIView.view;
        self.blackMask.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        self.contentImage.ADD(self.blackMask);
    }
    
    self.blackMask.frame = self.contentImage.bounds;
    self.blackMask.alpha = 0;
    
    LCUILabel * label = [[LCUILabel alloc] init];
    label.text = @"+1";
    label.font = [UIFont fontWithName:@"AvenirNext-Bold" size:60];
    label.textColor = [UIColor whiteColor];
    label.FIT();
    label.viewCenterX = self.contentImage.viewMidWidth;
    label.viewCenterY = self.contentImage.viewMidHeight;
    label.alpha = 0;
    label.transform = CGAffineTransformScale(CGAffineTransformIdentity, 2, 2);
    self.contentImage.ADD(label);
    
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
//    LC_FAST_ANIMATIONS(1, ^{
//
//        [self.tagsView reloadDataAndRemoveAll:NO];
//    });
}


- (void)cellOnTableView:(UITableView *)tableView didScrollOnView:(UIView *)view {
//        CGRect rectInSuperview = [tableView convertRect:self.frame toView:view];
//    
//        CGFloat distanceFromCenter = CGRectGetHeight(view.frame)/2 - CGRectGetMinY(rectInSuperview);
//        CGFloat difference = CGRectGetHeight(self.contentImage.frame) - CGRectGetHeight(self.frame);
//        CGFloat move = (distanceFromCenter / CGRectGetHeight(view.frame)) * difference;
//    
//        CGRect imageRect = self.contentImage.frame;
//        imageRect.origin.y = -(difference/2)+move;
//        self.contentImage.frame = imageRect;
}

/**
 *  裁剪圆角
 */
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
    } else if(type == 4){
        return [UIImage imageNamed:@"LittleFollowing.png" useCache:YES];
    }
    return nil;
}

- (void)recommendedReasonBtnClick:(LCUIButton *)reasonBtn {
    if ([self.delegate respondsToSelector:@selector(homeTableViewCell:didClickReasonBtn:)]) {
        [self.delegate homeTableViewCell:self didClickReasonBtn:self.recommendedReasonWithTag];
    }
}

- (void)prepareForReuse {
    
    [self.contentImage sd_cancelCurrentImageLoad];
}

@end
