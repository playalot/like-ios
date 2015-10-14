//
//  LKPostDetailTagCell.m
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/4/20.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKPostDetailCell.h"
#import "LKTagsView.h"
#import "LKTime.h"
#import "LKCommentsView.h"
#import "LKLikesScrollView.h"
#import "UIImageView+WebCache.h"

@interface LKPostDetailCell ()

LC_PROPERTY(strong) LCUIImageView * headImageView;
LC_PROPERTY(strong) LKTagItemView * tagItem;
LC_PROPERTY(strong) LCUILabel * timeLabel;
LC_PROPERTY(strong) UIView * cellBackgroundView;
LC_PROPERTY(strong) LKCommentsView * commentsView;
LC_PROPERTY(strong) LKLikesScrollView * likesView;

@end

@implementation LKPostDetailCell

LC_IMP_SIGNAL(PushUserCenter);

-(void) buildUI
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = LKColor.whiteColor;
    self.contentView.backgroundColor = LKColor.backgroundColor;
    
    
    CGFloat LeftPadding = 20;
    CGFloat topPadding = 7;
    
    self.headImageView = LCUIImageView.view;
    self.headImageView.viewFrameX = LeftPadding;
    self.headImageView.viewFrameY = topPadding;
    self.headImageView.viewFrameWidth = 32;
    self.headImageView.viewFrameHeight = 32;
    self.headImageView.cornerRadius = self.headImageView.viewMidWidth;
    self.headImageView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    self.headImageView.userInteractionEnabled = YES;
    self.headImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.headImageView addTapGestureRecognizer:self selector:@selector(handleHeadTap)];
    self.ADD(self.headImageView);
    
    
//    UIImageView * tip = UIImageView.view;
//    tip.image = [UIImage imageNamed:@"TalkTip.png" useCache:YES];
//    tip.viewFrameWidth = 16 / 3;
//    tip.viewFrameHeight = 33 / 3;
//    tip.viewFrameX = self.headImageView.viewRightX + padding;
//    tip.viewCenterY =  self.headImageView.viewCenterY;
//    self.ADD(tip);
    
    
    
//    self.cellBackgroundView = UIView.view.X(tip.viewRightX).Y(padding);
    self.cellBackgroundView = UIView.view.X(self.headImageView.viewRightX).Y(0);
    self.cellBackgroundView.viewFrameWidth = LC_DEVICE_WIDTH - self.cellBackgroundView.viewFrameX - 10;
    self.cellBackgroundView.viewFrameHeight = 46;
//    self.cellBackgroundView.backgroundColor = LKColor.backgroundColor;
    
    // 取消cell的原本点击手势
//    [self.cellBackgroundView addTapGestureRecognizer:self selector:@selector(likesTapAction)];
    [self.cellBackgroundView addTapGestureRecognizer:self selector:@selector(commentTapAction)];
    self.ADD(self.cellBackgroundView);
    
    
    self.tagItem = LKTagItemView.view;
    self.tagItem.showNumber = YES;

    
    self.cellBackgroundView.ADD(self.tagItem);
    
    
//    self.likesView = LKLikesScrollView.view;
//    self.likesView.viewFrameX = self.cellBackgroundView.viewFrameX;
//    self.likesView.viewFrameWidth = self.cellBackgroundView.viewFrameWidth;
//    self.likesView.viewFrameHeight = 33;
//    self.likesView.viewFrameY = self.cellBackgroundView.viewBottomY;
//    self.likesView.backgroundColor = [UIColor whiteColor];
//    self.ADD(self.likesView);
    
    
    LCUIButton *commentButton = LCUIButton.view;
    // 修改了评论的图片
    commentButton.buttonImage = [UIImage imageNamed:@"RightArrow.png" useCache:YES];
    commentButton.viewFrameHeight = 22;
    commentButton.viewFrameWidth = 13;
//    commentButton.titleFont = LK_FONT(10);
//    commentButton.title = LC_LO(@"评论");
//    commentButton.titleColor = LC_RGB(140, 133, 126);
//    commentButton.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
//    commentButton.imageEdgeInsets = UIEdgeInsetsMake(2, 0, 0, 0);
//    commentButton.FIT();
//    commentButton.viewFrameWidth += 10;
//    commentButton.viewFrameX = self.cellBackgroundView.viewFrameWidth - commentButton.viewFrameWidth - 3;
    commentButton.viewFrameX = self.cellBackgroundView.viewFrameWidth - commentButton.viewFrameWidth - 5;
    commentButton.viewFrameY = 46 / 2 - commentButton.viewMidHeight;
    [commentButton addTarget:self action:@selector(commentTapAction) forControlEvents:UIControlEventTouchUpInside];
    self.cellBackgroundView.ADD(commentButton);

    
    self.commentsView = LKCommentsView.view;
    self.commentsView.viewFrameX = 0;
    self.commentsView.viewFrameY = self.cellBackgroundView.viewBottomY;
    self.commentsView.viewFrameWidth = LC_DEVICE_WIDTH;
    self.ADD(self.commentsView);
    
    
    [self lineInView:self.contentView];
    
    self.alpha = 0;
    
    LC_FAST_ANIMATIONS(0.4, ^{
       
        self.alpha = 1;
    });
}

- (void)lineInView:(UIView *)view
{
    UIImageView *line = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TalkLine.png" useCache:YES]];
    line.viewFrameY = 45;
    line.viewFrameWidth = LC_DEVICE_WIDTH;
    line.viewFrameHeight = 1;
    view.ADD(line);
}

-(void) handleHeadTap
{
    self.SEND(self.PushUserCenter).object = self.tagDetail.user;
}

-(void) userHeadTap:(LKUser *)user
{
    self.SEND(self.PushUserCenter).object = user;
}

-(void) setTagDetail:(LKTag *)tagDetail
{
    _tagDetail = tagDetail;
    
    self.headImageView.image = nil;
//    self.headImageView.url = tagDetail.user.avatar;
    [self.headImageView sd_setImageWithURL:[NSURL URLWithString:tagDetail.user.avatar] placeholderImage:nil];
    
    
    if (!self.tagItem) {
        
        self.tagItem = LKTagItemView.view;
        self.tagItem.showNumber = YES;
//        self.cellBackgroundView.ADD(self.tagItem);
    }
    
    self.tagItem.tagValue = tagDetail;
    self.tagItem.viewFrameX = 18;
    self.tagItem.viewCenterY = 46 / 2;
    
    
    // 获取tag的宽度
    CGFloat maxItemX = CGRectGetMaxX(self.tagItem.frame);
    
    // 获取点赞区域
    CGRect tagItemRect = CGRectMake(0, 0, maxItemX, self.viewFrameHeight - 10);
    UIView *coverView = [[UIView alloc] initWithFrame:tagItemRect];
    self.cellBackgroundView.ADD(coverView);
    
    if (self.viewFrameX < maxItemX) {
        
        [coverView addTapGestureRecognizer:self selector:@selector(tagTapAction)];
    }
    
    coverView.ADD(self.tagItem);
    

    
    @weakly(self);
    
    self.tagItem.requestFinished = ^(LKTagItemView * item){
      
        @normally(self);
        
        if (self.didChanged) {
            self.didChanged(item.tagValue);
        }
    };
    
    self.tagItem.didRemoved = ^(id value){
        
        @normally(self);
        
        [self.tagItem removeFromSuperview];
        self.tagItem = nil;
        
        if (self.didRemoved) {
            self.didRemoved(self.cellIndexPath);
        }
    };
    
    self.tagItem.willRequest = ^(LKTagItemView * item){
      
        @normally(self);
        
        if (self.willRequest) {
            self.willRequest(item);
        }
    };
    
    self.timeLabel.text = [LKTime dateNearByTimestamp:_tagDetail.createTime];
    
    
//    [self.likesView setLikers:self.tagDetail.likers allLikersNumber:@(self.tagDetail.likes.integerValue - 1)];
//    
//    self.likesView.didSelectUser = ^(LKUser * user){
//    
//        @normally(self);
//        
//        [self userHeadTap:user];
//    };

    self.cellBackgroundView.layer.mask = nil;
    self.commentsView.viewFrameY = self.cellBackgroundView.viewBottomY;
    
//    if (self.tagDetail.likers.count > 0) {
//        
//        self.commentsView.viewFrameY = self.likesView.viewBottomY;
//    }
//    else{
    
        self.commentsView.viewFrameY = self.cellBackgroundView.viewBottomY;
//    }
    
    
    // 添加圆角
    if (self.tagDetail.comments.count == 0) {
        
//        //
//        if (self.tagDetail.likers.count > 0) {
//            
//            [self roundCorners:UIRectCornerTopLeft | UIRectCornerTopRight forView:self.cellBackgroundView];
//            [self roundCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight forView:self.likesView];
//        }
//        else{
//            
            [self roundCorners:UIRectCornerAllCorners forView:self.cellBackgroundView];
//        }
    }
    else{
        
        [self roundCorners:UIRectCornerTopLeft | UIRectCornerTopRight forView:self.cellBackgroundView];
    }
    
    
    self.commentsView.tagValue = _tagDetail;
    
    
    self.commentsView.reply = ^(LKComment * comment){
      
        @normally(self);
        
        if(self.replyAction){
            self.replyAction(self.tagDetail, comment);
        }
    };
    
    self.commentsView.showMore = ^(id value){
        
        @normally(self);

        if (self.showMoreAction) {
            self.showMoreAction(self.tagDetail);
        }
    };
}

/**
 *  点击评论的时候调用
 */
-(void) commentTapAction
{
    if (self.commentAction) {
        
        self.commentAction(self.tagDetail);
    }
}

- (void)tagTapAction {
    
    [self.tagItem like];
}

-(void) likesTapAction
{
    if (self.showLikesAction) {
        self.showLikesAction(self.tagDetail);
    }
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

+ (CGFloat)height:(LKTag *)tag
{
    static LKCommentsView *commentsView = nil;
    //static LKLikesScrollView * likesView = nil;

    // 以下数字仅用于计算 不用细究
    if (!commentsView){
        commentsView = LKCommentsView.view;
//        commentsView.viewFrameWidth = LC_DEVICE_WIDTH - (16 + 40 + 14 + 16 / 3) - 10;
        commentsView.viewFrameWidth = LC_DEVICE_WIDTH;
    }
    
//    if (!likesView) {
//        likesView = LKLikesScrollView.view;
//        likesView.viewFrameWidth = commentsView.viewFrameWidth;
//    }
//    
//    [likesView setLikers:tag.likers allLikersNumber:@(tag.likes.integerValue - 1)];
    
    commentsView.tagValue = tag;
    
    return 32 + 14 + commentsView.viewFrameHeight;// + (tag.likers.count > 0 ? 33 : 0);
}

@end
