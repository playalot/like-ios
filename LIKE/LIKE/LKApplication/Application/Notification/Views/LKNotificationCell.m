//
//  LKNotificationBaseCell.m
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/4/22.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKNotificationCell.h"
#import "LKTime.h"

@interface LKNotificationCell ()

LC_PROPERTY(strong) LCUIImageView * headImageView;
LC_PROPERTY(strong) LCUIImageView * icon;
LC_PROPERTY(strong) LCUILabel * nameLabel;
LC_PROPERTY(strong) LCUILabel * titleLabel;
LC_PROPERTY(strong) LCUILabel * timeLabel;
LC_PROPERTY(strong) UIView * line;

LC_PROPERTY(strong) LCUIImageView * preview;
LC_PROPERTY(strong) UIScrollView * morePreview;

@end

@implementation LKNotificationCell


LC_IMP_SIGNAL(PushPostDetail);


-(instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        
        self.headImageView = LCUIImageView.view;
        self.headImageView.viewFrameX = 10;
        self.headImageView.viewFrameY = 10;
        self.headImageView.viewFrameWidth = 35;
        self.headImageView.viewFrameHeight = 35;
        self.headImageView.backgroundColor = [UIColor whiteColor];
        self.headImageView.cornerRadius = 35 / 2;
        self.headImageView.userInteractionEnabled = YES;
        [self.headImageView addTapGestureRecognizer:self selector:@selector(handleHeadTap:)];
        self.ADD(self.headImageView);
        
        
        self.icon = LCUIImageView.view;
        self.icon.viewFrameX = self.headImageView.viewRightX + 10;
        self.icon.viewFrameWidth = 22;
        self.icon.viewFrameHeight = 22;
        self.icon.viewCenterY = self.headImageView.viewCenterY;
        self.ADD(self.icon);
        
        
        self.nameLabel = LCUILabel.view;
        self.nameLabel.viewFrameX = self.icon.viewRightX + 10;
        self.nameLabel.viewFrameY = 10;
        self.nameLabel.viewFrameWidth = LC_DEVICE_WIDTH - self.nameLabel.viewFrameX - 35 - 20;
        self.nameLabel.viewFrameHeight = 15;
        self.nameLabel.font = LK_FONT(12);
        self.nameLabel.textColor = LC_RGB(51, 51, 51);
        self.nameLabel.numberOfLines = 0;
        self.ADD(self.nameLabel);
        
        
//        self.titleLabel = LCUILabel.view;
//        self.titleLabel.font = LK_FONT(10);
//        self.titleLabel.textColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
//        self.ADD(self.titleLabel);
        
        
        self.timeLabel = LCUILabel.view;
        self.timeLabel.font = LK_FONT(10);
        self.timeLabel.textColor = LC_RGBA(171, 164, 157, 1);
        self.ADD(self.timeLabel);
    
        
        self.preview = LCUIImageView.view;
        self.preview.viewFrameWidth = 35;
        self.preview.viewFrameHeight = 35;
        self.preview.viewFrameY = 55 / 2 - 35 / 2;
        self.preview.viewFrameX = LC_DEVICE_WIDTH - 35 - self.preview.viewFrameY;
        self.preview.backgroundColor = [UIColor whiteColor];
        self.preview.contentMode = UIViewContentModeScaleAspectFill;
        self.preview.clipsToBounds = YES;
        self.ADD(self.preview);
        
        self.nameLabel.viewFrameWidth = LC_DEVICE_WIDTH - self.nameLabel.viewFrameX - self.preview.viewFrameWidth - ((self.preview.viewFrameY) * 2);

        
        self.morePreview = UIScrollView.view;
        self.morePreview.bounces = NO;
        self.morePreview.showsHorizontalScrollIndicator = NO;
        self.morePreview.showsVerticalScrollIndicator = NO;
        self.morePreview.scrollsToTop = NO;
        self.ADD(self.morePreview);
        
        
        self.line = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TalkLine.png" useCache:YES]];
        self.line.viewFrameWidth = LC_DEVICE_WIDTH;
        self.line.viewFrameY = 55 - self.line.viewFrameHeight;
        self.ADD(self.line);
    }
    
    return self;
}


-(void) setNotification:(LKNotification *)notification
{
    _notification = notification;
    
    self.headImageView.image = nil;
    self.headImageView.url = notification.user.avatar;
    
    self.nameLabel.text = [NSString stringWithFormat:@"%@%@", notification.user.name, [LKNotificationCell getTitle:notification]];
    
    NSMutableAttributedString * attString = [[NSMutableAttributedString alloc] initWithString:self.nameLabel.text];
    [attString addAttribute:NSFontAttributeName value:LK_FONT_B(12) range:[self.nameLabel.text rangeOfString:notification.user.name]];
    
    self.nameLabel.attributedText = attString;
    
    self.nameLabel.viewFrameX = self.icon.viewRightX + 10;
    self.nameLabel.viewFrameWidth = LC_DEVICE_WIDTH - self.nameLabel.viewFrameX - 35 - ((self.preview.viewFrameY) * 2);
    self.nameLabel.viewFrameHeight = 1000;
    self.nameLabel.FIT();
    

    self.timeLabel.text = [LKTime dateNearByTimestamp:notification.timestamp];
    self.timeLabel.FIT();
    self.timeLabel.viewFrameX = self.nameLabel.viewFrameX;
    self.timeLabel.viewFrameY = self.nameLabel.viewBottomY + 5;
    
    
    self.icon.image = [LKNotificationCell getIcon:notification];
    
    
    // images...
    [self.morePreview removeAllSubviews];

    if (notification.posts.count >= 2) {
        
        self.preview.hidden = YES;
        self.morePreview.hidden = NO;
        
        self.morePreview.viewFrameX = self.timeLabel.viewFrameX;
        self.morePreview.viewFrameY = 55;
        self.morePreview.viewFrameWidth = LC_DEVICE_WIDTH - self.morePreview.viewFrameX;
        self.morePreview.viewFrameHeight = 55;
        
        CGFloat padding = 5;
        
        
        // add subviews..
        for (NSInteger i = 0; i<notification.posts.count; i++) {
            
            LKPost * post = notification.posts[i];
            
            LCUIImageView * image = LCUIImageView.view;
            image.viewFrameX = self.morePreview.viewFrameWidth - (padding * (i + 1) + 35 * (i + 1));
            image.viewFrameY = 55 / 2 - 35 / 2;
            image.viewFrameWidth = 35;
            image.viewFrameHeight = 35;
            image.url = post.content;
            image.tag = i;
            image.userInteractionEnabled = YES;
            [self.morePreview addSubview:image];
        }
        
        self.morePreview.contentSize = LC_SIZE(35 * notification.posts.count + padding * notification.posts.count, 55);
    }
    else if(notification.posts.count == 1){
        
        self.preview.hidden = NO;
        self.preview.image = nil;
        self.preview.tag = 0;
        self.preview.url = ((LKPost *)notification.posts[0]).content;
        self.morePreview.hidden = YES;
    }
    else{
        
        self.preview.hidden = YES;
        self.preview.image = nil;
        self.preview.tag = 0;
        self.morePreview.hidden = YES;
    }

    
    CGFloat y = self.timeLabel.viewBottomY - self.line.viewFrameHeight + 10 < 55 ? 55 : self.timeLabel.viewBottomY - self.line.viewFrameHeight + 10;
    
    self.line.viewFrameY = y;
}

//-(void) handlePostImageTap:(UITapGestureRecognizer *)tap
//{
//    self.SEND(self.PushPostDetail).object = self.notification.posts[tap.view.tag];
//}

/**
 *  点击头像执行
 */
-(void) handleHeadTap:(UITapGestureRecognizer *)tap
{
    self.SEND(@"PushUserCenter").object = self.notification.user;
}

+(NSString *) getTitle:(LKNotification *)notification
{
    switch (notification.type) {
        case LKNotificationTypeNewTag:
            
            return [NSString stringWithFormat:@" %@#%@#", LC_LO(@"为你图片添加了标签"), notification.tag];
            
            break;
        case LKNotificationTypeFocus:
            
            return [NSString stringWithFormat:@" %@", LC_LO(@"关注了你")];

            break;
        case LKNotificationTypeLikeTag:
            
            return [NSString stringWithFormat:@" %@#%@#", LC_LO(@"赞了标签"), notification.tag];

            break;
        case LKNotificationTypeReply:
            
            return [[NSString stringWithFormat:@" %@", LC_LO(@"在#%@#中回复了你")] stringByReplacingOccurrencesOfString:@"%@" withString:notification.tag];;

            break;
        case LKNotificationTypeComment:
            
            return [NSString stringWithFormat:@" %@#%@#", LC_LO(@"评论了"), notification.tag];

            break;
        default:
            break;
    }
}

+(UIImage *) getIcon:(LKNotification *)notification
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
            
            return [UIImage imageNamed:@"NotificationCommentIcon.png" useCache:YES];
            
            break;
        case LKNotificationTypeComment:
            
            return [UIImage imageNamed:@"NotificationCommentIcon.png" useCache:YES];
            
            break;
        default:
            break;
    }
}

+(CGFloat) height:(LKNotification *)notification
{
    static LCUILabel * label = nil;
    
    if (!label) {
        label = [LCUILabel new];
        label.font = LK_FONT(12);
        label.numberOfLines = 0;
    }
    
    label.text = [NSString stringWithFormat:@"%@%@", notification.user.name, [self getTitle:notification]];
    
    NSMutableAttributedString * attString = [[NSMutableAttributedString alloc] initWithString:label.text];
    [attString addAttribute:NSFontAttributeName value:LK_FONT_B(12) range:[label.text rangeOfString:notification.user.name]];
    
    label.attributedText = attString;
    
    label.viewFrameWidth = LC_DEVICE_WIDTH - 55 - 35 - 20 - 22 - 10;
    label.viewFrameHeight = 1000;
    label.FIT();
    
    CGFloat height = 10 + label.viewFrameHeight + 5 + 12 + 10;
    
    height = height < 55 ? 55 : height;
    
    return height;
}

@end
