//
//  LKTagLikesCell.m
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/4/21.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKTagLikesCell.h"
#import "LKTime.h"

@interface LKTagLikesCell ()

LC_PROPERTY(strong) LCUIImageView * userHead;
LC_PROPERTY(strong) LCUILabel * userName;
LC_PROPERTY(strong) LCUILabel * tagName;
LC_PROPERTY(strong) LCUILabel * timeLabel;

LC_PROPERTY(strong) LCUILabel * likesLabel;

LC_PROPERTY(strong) UIView * usersView;

@end

@implementation LKTagLikesCell


LC_IMP_SIGNAL(PushUserInfo);


-(void) buildUI
{
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
    self.userHead = LCUIImageView.view;
    self.userHead.viewFrameX = 40 / 3;
    self.userHead.viewFrameY = 9;
    self.userHead.viewFrameWidth = 40;
    self.userHead.viewFrameHeight = 40;
    self.userHead.cornerRadius = 20;
    self.userHead.backgroundColor = [UIColor whiteColor];
    self.userHead.userInteractionEnabled = YES;
    [self.userHead addTapGestureRecognizer:self selector:@selector(handleUserHeadTapAction)];
    self.ADD(self.userHead);
    
    
    self.userName = LCUILabel.view;
    self.userName.viewFrameX = self.userHead.viewRightX + self.userHead.viewFrameX;
    self.userName.viewFrameHeight = 58;
    self.userName.font = LK_FONT(15);
    self.userName.textColor = LC_RGB(74, 74, 74);
    [self.userName addTapGestureRecognizer:self selector:@selector(handleUserHeadTapAction)];
    self.ADD(self.userName);
    
    
    self.tagName = LCUILabel.view;
    self.tagName.viewFrameHeight = 58;
    self.tagName.font = LK_FONT(13);
    self.tagName.textColor = LC_RGB(153, 153, 153);
    [self.tagName addTapGestureRecognizer:self selector:@selector(handleUserHeadTapAction)];
    self.ADD(self.tagName);
    
    
    self.timeLabel = LCUILabel.view;
    self.timeLabel.viewFrameWidth = 100;
    self.timeLabel.viewFrameX = LC_DEVICE_WIDTH - 20 - self.timeLabel.viewFrameWidth;
    self.timeLabel.viewFrameHeight = 58;
    self.timeLabel.font = LK_FONT(13);
    self.timeLabel.textAlignment = UITextAlignmentRight;
    self.timeLabel.textColor = LC_RGB(153, 153, 153);
    self.ADD(self.timeLabel);
    
    
    UIView * line = UIView.VIEW.Y(57).WIDTH(LC_DEVICE_WIDTH).HEIGHT(0.5).COLOR(LC_RGB(175, 175, 175));
    self.ADD(line);
    
    
    self.likesLabel = LCUILabel.view;
    self.likesLabel.viewFrameX = 50 / 3;
    self.likesLabel.viewFrameY = line.viewBottomY;
    self.likesLabel.viewFrameHeight = 108 / 3;
    self.likesLabel.viewFrameWidth = LC_DEVICE_WIDTH - self.likesLabel.viewFrameX * 2;
    self.likesLabel.textAlignment = UITextAlignmentRight;
    self.likesLabel.font = LK_FONT(13);
    self.likesLabel.textColor = LC_RGB(153, 153, 153);
    self.ADD(self.likesLabel);
    
    
    self.usersView = UIView.view;
    self.ADD(self.usersView);
}

-(void) handleUserHeadTapAction
{
    self.SEND(self.PushUserInfo).object = self.tagValue.user;
}

-(void) handleLikesHeadTapAction:(UITapGestureRecognizer *)tap
{
    self.SEND(self.PushUserInfo).object = self.likes[tap.view.tag];
}

-(void) setTagValue:(LKTag *)tagValue
{
    _tagValue = tagValue;
    
    self.userHead.image = nil;
    self.userHead.url = tagValue.user.avatar;
    
    self.userName.text = tagValue.user.name;
    self.userName.FIT();
    self.userName.viewFrameHeight = 58;
    
    self.tagName.text = LC_LO(@"添加了该标签");
    self.tagName.FIT();
    self.tagName.viewFrameHeight = 58;
    self.tagName.viewFrameX = self.userName.viewRightX + self.userHead.viewFrameX;
    
    
    self.timeLabel.text = [LKTime dateNearByTimestamp:tagValue.createTime];
}

-(void) setLikes:(NSArray *)likes
{
    self.likesLabel.text = [NSString stringWithFormat:@"%@%@", @(likes.count), LC_LO(@"人赞了这个标签")];
    self.likesLabel.hidden = likes.count == 0;
    
    CGFloat padding = 10;
    NSInteger maxCount = 0;
    
    for (NSInteger i = 0; i < 999; i++) {
        
        CGFloat width = padding * (i + 1) + 33 * i + padding;
        
        if (width > LC_DEVICE_WIDTH) {
            
            maxCount = i - 1;
            break;
        }
    }
    
    CGFloat inv = (LC_DEVICE_WIDTH - (maxCount * 33)) / (maxCount + 1);
    
    
    _likes = likes;
    
    [self.usersView removeAllSubviews];
    
    LCUIImageView * lastUserHead = nil;
    
    for (NSInteger i = 0; i < likes.count; i++) {
        
        LKUser * user = likes[i];
        
        LCUIImageView * userHead = LCUIImageView.view;
        userHead.viewFrameWidth = 33;
        userHead.viewFrameHeight = 33;
        userHead.viewFrameX = inv * (i%maxCount) + inv + 33 * (i%maxCount);
        userHead.viewFrameY = inv * (i/maxCount) + 33 * (i/maxCount);
        userHead.cornerRadius = 33 / 2;
        userHead.url = user.avatar;
        userHead.backgroundColor = [UIColor whiteColor];
        userHead.userInteractionEnabled = YES;
        userHead.tag = i;
        [userHead addTapGestureRecognizer:self selector:@selector(handleLikesHeadTapAction:)];
        self.usersView.ADD(userHead);
        
        lastUserHead = userHead;
    }
    
    self.usersView.viewFrameWidth = LC_DEVICE_WIDTH;
    self.usersView.viewFrameHeight = lastUserHead.viewBottomY + inv;
    self.usersView.viewFrameY = self.likesLabel.viewBottomY;
}

-(void) setTagValue:(LKTag *)tagValue andLikes:(NSArray *)likes
{
    self.tagValue = tagValue;
    self.likes = likes;
}

@end
