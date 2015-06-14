//
//  LKTagCommentCell.m
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/5/28.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKTagCommentCell.h"
#import "LKTime.h"

@interface LKTagCommentCell ()

LC_PROPERTY(strong) LCUIImageView * head;
LC_PROPERTY(strong) LCUILabel * contentLabel;
LC_PROPERTY(strong) LCUILabel * timeLabel;
LC_PROPERTY(strong) UIImageView * line;

@end

@implementation LKTagCommentCell

-(void) buildUI
{
    self.backgroundColor = [UIColor whiteColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;

    CGFloat padding = 10;
    
    self.head = LCUIImageView.view;
    self.head.viewFrameX = padding;
    self.head.viewFrameY = padding;
    self.head.viewFrameWidth = 33;
    self.head.viewFrameHeight = 33;
    self.head.cornerRadius = self.head.viewMidWidth;
    self.head.backgroundColor = [UIColor whiteColor];
    self.head.userInteractionEnabled = YES;
    [self.head addTapGestureRecognizer:self selector:@selector(handleHeadTap:)];
    self.ADD(self.head);
    
    self.contentLabel = LCUILabel.view;
    self.contentLabel.viewFrameX = self.head.viewRightX + 10;
    self.contentLabel.viewFrameY = 10;
    self.contentLabel.viewFrameWidth = LC_DEVICE_WIDTH - self.contentLabel.viewFrameX - 10;
    self.contentLabel.font = LK_FONT(13);
    self.contentLabel.textColor = LC_RGB(51, 51, 51);
    self.contentLabel.numberOfLines = 0;
    self.ADD(self.contentLabel);
    
    
    self.timeLabel = LCUILabel.view;
    self.timeLabel.viewFrameX = self.contentLabel.viewFrameX;
    self.timeLabel.viewFrameWidth = LC_DEVICE_WIDTH;
    self.timeLabel.font = LK_FONT(12);
    self.timeLabel.textColor = LC_RGB(171, 164, 157);
    self.ADD(self.timeLabel);
    
    
    self.line = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TalkLine.png" useCache:YES]];
    self.line.viewFrameWidth = LC_DEVICE_WIDTH;
    self.ADD(self.line);
}

-(void) handleHeadTap:(UITapGestureRecognizer *)tap
{
    self.SEND(@"PushUserCenter").object = self.comment.user;
}

-(void) setComment:(LKComment *)comment
{
    _comment = comment;
    
    self.head.image = nil;
    self.head.url = comment.user.avatar;
    
    NSString * content = [NSString stringWithFormat:@"%@：%@%@" ,comment.user.name, comment.replyUser ? [NSString stringWithFormat:@"@%@ ", comment.replyUser.name] : @"",comment.content];

    self.contentLabel.viewFrameWidth = LC_DEVICE_WIDTH - self.contentLabel.viewFrameX - 10;
    self.contentLabel.text = content;
    self.contentLabel.FIT();
    
    self.timeLabel.viewFrameY = self.contentLabel.viewBottomY + 3;
    self.timeLabel.text = [LKTime dateNearByTimestamp:comment.timestamp];
    self.timeLabel.viewFrameWidth = 100;
    self.timeLabel.FIT();
    
    
    self.line.viewFrameY = self.timeLabel.viewBottomY + 7 - self.line.viewFrameHeight;
}

+(CGFloat) height:(LKComment *)comment
{
    CGFloat height = 10;
    
    NSString * content = [NSString stringWithFormat:@"%@：%@%@" ,comment.user.name, comment.replyUser ? [NSString stringWithFormat:@"@%@ ", comment.replyUser.name] : @"",comment.content];
    
    CGSize size = [content sizeWithFont:LK_FONT(13) byWidth:LC_DEVICE_WIDTH - 53 - 10];
    
    height += size.height;
    height += 5;
    
    size = [[LKTime dateNearByTimestamp:comment.timestamp] sizeWithFont:LK_FONT(13) byWidth:LC_DEVICE_WIDTH];
    
    height += size.height;
    height += 7;
    
    return height;
}

@end
