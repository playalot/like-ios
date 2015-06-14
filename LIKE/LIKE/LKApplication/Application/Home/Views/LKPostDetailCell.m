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

@interface LKPostDetailCell ()

LC_PROPERTY(strong) LCUIImageView * headImageView;
LC_PROPERTY(strong) LKTagItem * tagItem;
LC_PROPERTY(strong) LCUILabel * timeLabel;
LC_PROPERTY(strong) UIView * cellBackgroundView;
LC_PROPERTY(strong) LKCommentsView * commentsView;

@end

@implementation LKPostDetailCell

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
    [self.headImageView addTapGestureRecognizer:self selector:@selector(handleHeadTap)];
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
    self.cellBackgroundView.viewFrameHeight = 33;
    self.cellBackgroundView.backgroundColor = [UIColor whiteColor];
    [self.cellBackgroundView addTapGestureRecognizer:self selector:@selector(likesTapAction)];
    self.ADD(self.cellBackgroundView);
    
    
    self.tagItem = LKTagItem.view;
    self.cellBackgroundView.ADD(self.tagItem);
    
    
    
    LCUIButton * commentButton = LCUIButton.view;
    commentButton.viewFrameWidth = 30;
    commentButton.viewFrameHeight = 33;
    commentButton.viewFrameX = self.cellBackgroundView.viewFrameWidth - commentButton.viewFrameWidth;
    commentButton.buttonImage = [UIImage imageNamed:@"TalkIcon.png" useCache:YES];
    [commentButton addTarget:self action:@selector(commentTapAction) forControlEvents:UIControlEventTouchUpInside];
    self.cellBackgroundView.ADD(commentButton);
    
    
//    self.timeLabel = LCUILabel.view;
//    self.timeLabel.viewFrameWidth = 100;
//    self.timeLabel.viewFrameX = self.cellBackgroundView.viewFrameWidth - self.timeLabel.viewFrameWidth - commentButton.viewFrameWidth;
//    self.timeLabel.viewFrameHeight = 33;
//    self.timeLabel.viewCenterY = 33 / 2;
//    self.timeLabel.font = LK_FONT(10);
//    self.timeLabel.textAlignment = UITextAlignmentRight;
//    self.timeLabel.textColor = LC_RGB(180, 180, 180);
//    self.cellBackgroundView.ADD(self.timeLabel);

    
    self.commentsView = LKCommentsView.view;
    self.commentsView.viewFrameX = self.cellBackgroundView.viewFrameX;
    self.commentsView.viewFrameY = self.cellBackgroundView.viewBottomY;
    self.commentsView.viewFrameWidth = self.cellBackgroundView.viewFrameWidth;
    self.ADD(self.commentsView);
    
    
    self.alpha = 0;
    
    LC_FAST_ANIMATIONS(0.6, ^{
       
        self.alpha = 1;
    });
}

-(void) handleHeadTap
{
    self.SEND(self.PushUserCenter).object = self.tagDetail.user;
}

-(void) setTagDetail:(LKTag *)tagDetail
{
    _tagDetail = tagDetail;
    
    self.headImageView.image = nil;
    self.headImageView.url = tagDetail.user.avatar;
    
    
    if (!self.tagItem) {
        
        self.tagItem = LKTagItem.view;
        self.cellBackgroundView.ADD(self.tagItem);
    }
    
    self.tagItem.tagValue = tagDetail;
    self.tagItem.viewFrameX = 8;
    self.tagItem.viewCenterY = 33 / 2;
    
    
    @weakly(self);
    
    self.tagItem.requestFinished = ^(LKTagItem * item){
      
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
    
    self.timeLabel.text = [LKTime dateNearByTimestamp:_tagDetail.createTime];
    
    
    self.cellBackgroundView.layer.mask = nil;
    
    

    if (self.tagDetail.comments.count == 0) {
        
        [self roundCorners:UIRectCornerAllCorners forView:self.cellBackgroundView];
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

-(void) commentTapAction
{
    if (self.commentAction) {
        self.commentAction(self.tagDetail);
    }
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

+(CGFloat) height:(LKTag *)tag
{
    static LKCommentsView * commentsView = nil;
    
    if (!commentsView) {
        commentsView = LKCommentsView.view;
        commentsView.viewFrameWidth = LC_DEVICE_WIDTH - (10 + 33 + 10 + 16 / 3) - 10;
    }
    
    commentsView.tagValue = tag;
    
    return 33 + 10 + commentsView.viewFrameHeight;
}

@end
