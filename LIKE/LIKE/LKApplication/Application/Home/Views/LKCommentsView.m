//
//  LKCommentsView.m
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/5/28.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKCommentsView.h"
#import "LKComment.h"
#import "LKTime.h"
#import "LKPostDetailCell.h"

@implementation LKCommentsView

-(void) setTagValue:(LKTag *)tagValue
{
    _tagValue = tagValue;
    
    [self removeAllSubviews];
    
    NSInteger maxComments = 3;
    
    UIView * lastView = nil;
    
    
    NSInteger count = tagValue.comments.count < maxComments ? tagValue.comments.count : maxComments;
    
    for (NSInteger i = 0; i < count; i++) {
        
        LKComment * comment = tagValue.comments[i];
        
        
        UIView * contentView = UIView.view;
        contentView.viewFrameY = lastView.viewBottomY;
        contentView.viewFrameWidth = self.viewFrameWidth;
        contentView.viewFrameHeight = 53;
        contentView.backgroundColor = [UIColor whiteColor];
        self.ADD(contentView);
        
        
        LCUIImageView * head = LCUIImageView.view;
        head.viewFrameX = 10;
        head.viewFrameY = 10;
        head.viewFrameWidth = 33;
        head.viewFrameHeight = 33;
        head.cornerRadius = 33 / 2;
        head.url = comment.user.avatar;
        head.userInteractionEnabled = YES;
        [head addTapGestureRecognizer:self selector:@selector(headTapAction:)];
        head.tag = i + 100;
        contentView.ADD(head);
        
        
        LCUILabel * contentLabel = LCUILabel.view;
        contentLabel.viewFrameX = head.viewRightX + 10;
        contentLabel.viewFrameY = 10;
        contentLabel.viewFrameWidth = self.viewFrameWidth - contentLabel.viewFrameX - 10;
        contentLabel.font = LK_FONT(12);
        contentLabel.textColor = LC_RGB(51, 51, 51);
        
        NSString * content = [NSString stringWithFormat:@"%@：%@%@" ,comment.user.name, comment.replyUser ? [NSString stringWithFormat:@"@%@ ", comment.replyUser.name] : @"",comment.content];

        contentLabel.text = content;
        contentLabel.numberOfLines = 0;
        contentLabel.FIT();
        contentView.ADD(contentLabel);
        
        
        LCUILabel * timeLabel = LCUILabel.view;
        timeLabel.viewFrameX = contentLabel.viewFrameX;
        timeLabel.viewFrameY = contentLabel.viewBottomY + 3;
        timeLabel.viewFrameWidth = self.viewFrameWidth;
        timeLabel.font = LK_FONT(10);
        timeLabel.textColor = LC_RGB(180, 180, 180);
        timeLabel.text = [LKTime dateNearByTimestamp:comment.timestamp];
        timeLabel.FIT();
        contentView.ADD(timeLabel);
        
        contentView.viewFrameHeight = timeLabel.viewBottomY + 7;
        contentView.tag = i + 100;
        [contentView addTapGestureRecognizer:self selector:@selector(replyAction:)];
        
        
        if (i == count - 1) {
            
        }
        
        
        [self lineInView:contentView];
        
        lastView = contentView;
    }
    
    if (tagValue.totalComments.integerValue > maxComments) {
        
        UIView * moreView = UIView.view;
        moreView.viewFrameWidth = self.viewFrameWidth;
        moreView.viewFrameHeight = 33;
        moreView.viewFrameY = lastView.viewBottomY;
        moreView.backgroundColor = [UIColor whiteColor];
        self.ADD(moreView);
        
        
        UIImageView * moreIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TalkMore.png" useCache:YES]];
        moreIcon.viewFrameX = 20;
        moreIcon.viewFrameY = moreView.viewMidHeight - moreIcon.viewMidHeight;
        moreView.ADD(moreIcon);
        
        
        LCUILabel * tipLabel = LCUILabel.view;
        tipLabel.viewFrameX = moreIcon.viewRightX + 20;
        tipLabel.viewFrameWidth = self.viewFrameWidth;
        tipLabel.viewFrameHeight = moreView.viewFrameHeight;
        tipLabel.font = LK_FONT(12);
        tipLabel.textColor = [UIColor blackColor];
        tipLabel.text = [NSString stringWithFormat:@"阅读全部%@条评论", @(tagValue.totalComments.integerValue)];
        moreView.ADD(tipLabel);
        
        [self lineInView:moreView];
        
        [moreView addTapGestureRecognizer:self selector:@selector(showMoreAction)];
        
        
        lastView = moreView;
    }
    
    [self roundCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight forView:lastView];

    
    self.viewFrameHeight = lastView.viewBottomY;
}

-(void) lineInView:(UIView *)view
{
    UIImageView * line = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TalkLine.png" useCache:YES]];
    line.viewFrameWidth = view.viewFrameWidth;
    view.ADD(line);
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

-(void) headTapAction:(UITapGestureRecognizer *)tap
{
    LKComment * comment = self.tagValue.comments[tap.view.tag - 100];
    
    self.SEND(LKPostDetailCell.PushUserCenter).object = comment.user;
}

-(void) showMoreAction
{
    if (self.showMore) {
        self.showMore(nil);
    }
}

-(void) replyAction:(UITapGestureRecognizer *)tap
{
    if (self.reply) {
        self.reply(self.tagValue.comments[tap.view.tag - 100]);
    }
}

@end
