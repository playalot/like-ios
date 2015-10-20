//
//  LKNotificationMiniCell.m
//  LIKE
//
//  Created by Elkins.Zhao on 15/9/29.
//  Copyright © 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKNotificationMiniCell.h"
#import "LKTime.h"
#import "UIImageView+WebCache.h"
#import "GBTagListView.h"

@interface LKNotificationMiniCell ()

LC_PROPERTY(strong) LCUIImageView *headImageView;
LC_PROPERTY(strong) LCUIImageView *icon;
LC_PROPERTY(strong) LCUILabel *nameLabel;
LC_PROPERTY(strong) LCUILabel *titleLabel;
LC_PROPERTY(strong) LCUILabel *timeLabel;
LC_PROPERTY(strong) LCUIButton *moreButton;
LC_PROPERTY(strong) GBTagListView *tagListView;
LC_PROPERTY(strong) UIView *line;
LC_PROPERTY(strong) LCUIImageView *preview;

@end

@implementation LKNotificationMiniCell

LC_IMP_SIGNAL(PushPostDetail);
LC_IMP_SIGNAL(PushUserCenter);

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        
        self.icon = LCUIImageView.view;
        self.icon.viewFrameX = 14;
        self.icon.viewCenterY = 15;
        self.icon.viewFrameWidth = 26;
        self.icon.viewFrameHeight = 26;
        self.ADD(self.icon);
        
        
        self.headImageView = LCUIImageView.view;
        self.headImageView.viewFrameX = self.icon.viewRightX + 14;
        self.headImageView.viewFrameY = 10;
        self.headImageView.viewFrameWidth = 36;
        self.headImageView.viewFrameHeight = 36;
        self.headImageView.backgroundColor = [UIColor whiteColor];
        self.headImageView.cornerRadius = 36 * 0.5;
        self.headImageView.userInteractionEnabled = YES;
        [self.headImageView addTapGestureRecognizer:self selector:@selector(handleHeadTap:)];
        self.ADD(self.headImageView);
        
        
        self.nameLabel = LCUILabel.view;
        self.nameLabel.font = LK_FONT(14);
        self.nameLabel.viewFrameX = self.headImageView.viewRightX + 14;
        self.nameLabel.viewFrameY = 10;
        self.nameLabel.viewFrameWidth = LC_DEVICE_WIDTH - self.nameLabel.viewFrameX - 35 - 20;
        self.nameLabel.viewFrameHeight = self.nameLabel.font.lineHeight;
        self.nameLabel.textColor = LC_RGB(51, 51, 51);
        self.nameLabel.numberOfLines = 0;
        self.ADD(self.nameLabel);
        
        
        self.timeLabel = LCUILabel.view;
        self.timeLabel.font = LK_FONT(10);
        self.timeLabel.textColor = LC_RGBA(171, 164, 157, 1);
        self.ADD(self.timeLabel);
        
        
        self.preview = LCUIImageView.view;
        self.preview.viewFrameWidth = 35;
        self.preview.viewFrameHeight = 35;
        self.preview.viewFrameY = 56 / 2 - 35 / 2;
        self.preview.viewFrameX = LC_DEVICE_WIDTH - 35 - self.preview.viewFrameY;
        self.preview.backgroundColor = [UIColor whiteColor];
        self.preview.contentMode = UIViewContentModeScaleAspectFill;
        self.preview.clipsToBounds = YES;
        self.ADD(self.preview);
        
        self.nameLabel.viewFrameWidth = LC_DEVICE_WIDTH - self.nameLabel.viewFrameX - self.preview.viewFrameWidth - ((self.preview.viewFrameY) * 2);
        
        self.moreButton = LCUIButton.view;
        self.moreButton.viewFrameX = LC_DEVICE_WIDTH - 25;
        self.moreButton.viewCenterY = self.headImageView.viewCenterY;
        self.moreButton.viewFrameWidth = 7;
        self.moreButton.viewFrameHeight = 12;
        self.moreButton.hidden = YES;
        self.ADD(self.moreButton);
        
        
        self.line = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TalkLine.png" useCache:YES]];
        self.line.viewFrameWidth = LC_DEVICE_WIDTH;
        self.line.viewFrameY = 55 - self.line.viewFrameHeight;
        self.ADD(self.line);
    }
    
    return self;
}


- (void)setNotification:(LKNotification *)notification
{
    
    for (UIView *view in self.subviews) {
        
        if (IOS8_OR_LATER) {
            
            if ([view isKindOfClass:[GBTagListView class]]) {
                
                [view removeFromSuperview];
            }
        } else {
            
            for (UIView *subView in view.subviews) {
                
                if ([subView isKindOfClass:[GBTagListView class]]) {
                    
                    [subView removeFromSuperview];
                }
            }
        }
    }
    
    _notification = notification;
    
    self.headImageView.image = nil;
    [self.headImageView sd_setImageWithURL:[NSURL URLWithString:notification.user.avatar] placeholderImage:nil];
    
    self.nameLabel.text = [NSString stringWithFormat:@"%@   %@", notification.user.name, [LKNotificationMiniCell getTitle:notification]];
    
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:self.nameLabel.text];
    [attString addAttribute:NSFontAttributeName value:LK_FONT_B(14) range:[self.nameLabel.text rangeOfString:notification.user.name]];
    
    self.nameLabel.attributedText = attString;
    
    self.nameLabel.viewFrameX = self.headImageView.viewRightX + 14;
    self.nameLabel.viewFrameWidth = LC_DEVICE_WIDTH - self.nameLabel.viewFrameX - 35 - ((self.preview.viewFrameY) * 2);
    self.nameLabel.viewFrameHeight = 1000;
    self.nameLabel.FIT();
    
    
    self.moreButton.image = [UIImage imageNamed:@"more" useCache:YES];
    
    
    if (notification.type == LKNotificationTypeNewTag || notification.type == LKNotificationTypeLikeTag || notification.type == LKNotificationTypeReply || notification.type == LKNotificationTypeComment || notification.type == LKNotificationTypeUpdate) {
        
        self.tagListView = GBTagListView.view;
        self.tagListView.viewFrameX = self.headImageView.viewFrameX - 10;
        self.tagListView.viewFrameWidth = LC_DEVICE_WIDTH - self.tagListView.viewFrameX - 37;
        self.ADD(self.tagListView);
        [self.tagListView setTagWithTagArray:notification.tags];
        
    } else if (notification.type == LKNotificationTypeFocus) {
        
        self.moreButton.hidden = NO;
        self.cellHeight = [[self class] height:notification];
    }
    
    
    self.timeLabel.text = [LKTime dateNearByTimestamp:notification.timestamp];
    self.timeLabel.FIT();
    self.timeLabel.viewFrameX = self.nameLabel.viewFrameX;
    self.timeLabel.viewFrameY = self.nameLabel.viewBottomY + 2;
    
    self.tagListView.viewFrameY = self.timeLabel.viewBottomY + 10;
    
    if (notification.tags.count) {
        
        self.cellHeight = self.tagListView.viewBottomY + 10;
    }
    
    self.icon.image = [LKNotificationMiniCell getIcon:notification];
    
    if (notification.type == LKNotificationTypeFocus) {
        
        self.preview.hidden = YES;
        
    } else {
        
        self.preview.hidden = NO;
        [self.preview sd_setImageWithURL:[NSURL URLWithString:((LKPost *)notification.post).thumbnail] placeholderImage:nil options:SDWebImageRetryFailed];
    }
    
    if (notification.tags.count) {
        
        self.line.viewFrameY = self.tagListView.viewBottomY + 10;
        
    } else {
        
        self.line.viewFrameY = self.timeLabel.viewBottomY + 10;
    }
}

/**
 *  点击头像执行
 */
- (void)handleHeadTap:(UITapGestureRecognizer *)tap
{
    self.SEND(self.PushUserCenter).object = self.notification.user;
}

+ (NSString *)getTitle:(LKNotification *)notification
{
    switch (notification.type) {
            
        case LKNotificationTypeNewTag:
            
            return [NSString stringWithFormat:@" %@ ", LC_LO(@"添加了标签")];
            
            break;
        case LKNotificationTypeFocus:
            
            return [NSString stringWithFormat:@" %@", LC_LO(@"关注了你")];
            
            break;
        case LKNotificationTypeLikeTag:
            
            return [NSString stringWithFormat:@" %@ ", LC_LO(@"赞了标签")];
            
            break;
        case LKNotificationTypeReply:
            
            return [NSString stringWithFormat:@" %@ ", LC_LO(@"回复了你的评论")];
            
            break;
        case LKNotificationTypeComment:
            
            return [NSString stringWithFormat:@" %@ ", LC_LO(@"评论了标签")];
            
            break;
        case LKNotificationTypeUpdate:
            
            return [NSString stringWithFormat:@" %@ ", LC_LO(@"更新了一张新Like")];
            
            break;
        case LKNotificationTypeOfficial:
            
            return [NSString stringWithFormat:@" %@ ", LC_LO(@"给你发了一条消息")];
            
            break;
        default:
            break;
    }
}

+ (UIImage *)getIcon:(LKNotification *)notification
{
    switch (notification.type) {
        case LKNotificationTypeNewTag:
            
            return [UIImage imageNamed:@"NotificationTagIcon.png" useCache:YES];
            
            break;
        case LKNotificationTypeFocus:
            
            return [UIImage imageNamed:@"NotificationFocusIcon.png" useCache:YES];
            
            break;
        case LKNotificationTypeLikeTag:
            
            return [UIImage imageNamed:@"NotificationLikeIcon.png" useCache:YES];
            
            break;
        case LKNotificationTypeReply:
            
            return [UIImage imageNamed:@"NotificationReplyIcon.png" useCache:YES];
            
            break;
        case LKNotificationTypeComment:
            
            return [UIImage imageNamed:@"NotificationCommentIcon.png" useCache:YES];
            
            break;
        case LKNotificationTypeUpdate:
            
            return [UIImage imageNamed:@"NotificationCommentIcon.png" useCache:YES];
            
            break;
        case LKNotificationTypeOfficial:
            
            return [UIImage imageNamed:@"NotificationOfficalIcon.png" useCache:YES];
            
            break;
        default:
            break;
    }
}

+ (CGFloat)height:(LKNotification *)notification
{
    static LCUILabel *label = nil;
    
    if (!label) {
        label = [LCUILabel new];
        label.font = LK_FONT(14);
        label.numberOfLines = 0;
    }
    
    label.text = [NSString stringWithFormat:@"%@   %@", notification.user.name, [self getTitle:notification]];
    
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:label.text];
    [attString addAttribute:NSFontAttributeName value:LK_FONT_B(14) range:[label.text rangeOfString:notification.user.name]];
    
    label.attributedText = attString;
    
    label.viewFrameWidth = LC_DEVICE_WIDTH - 54 - 36 - 12 - 35 - 20;
    label.viewFrameHeight = 1000;
    label.FIT();
    
    CGFloat height = 10 + label.viewFrameHeight + 2 + 12 + 10;
    
    height = height < 56 ? 56 : height;
    
    return height;
}

@end
