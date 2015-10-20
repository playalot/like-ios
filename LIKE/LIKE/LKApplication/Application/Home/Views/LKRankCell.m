//
//  LKRankCell.m
//  LIKE
//
//  Created by Elkins.Zhao on 15/10/19.
//  Copyright © 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKRankCell.h"
#import "UIImageView+WebCache.h"

@interface LKRankCell ()

LC_PROPERTY(strong) LCUIImageView *rankIcon;
LC_PROPERTY(strong) LCUILabel *rankLabel;
LC_PROPERTY(strong) LCUIImageView *headView;
LC_PROPERTY(strong) LCUILabel *nameLabel;
LC_PROPERTY(strong) LCUILabel *likesLabel;
LC_PROPERTY(strong) LCUIImageView *hotIconView;
LC_PROPERTY(strong) LCUILabel *increaseLikesLabel;
LC_PROPERTY(strong) LCUILabel *suffixLabel;

@end

@implementation LKRankCell

LC_IMP_SIGNAL(PushUserCenter);

- (void)buildUI {
 
    self.rankIcon = LCUIImageView.view;
    self.rankIcon.viewFrameX = 12;
    self.rankIcon.viewFrameY = 7;
    self.rankIcon.viewFrameWidth = 26;
    self.rankIcon.viewFrameHeight = 37;
    self.ADD(self.rankIcon);
    
    self.rankLabel = LCUILabel.view;
    self.rankLabel.font = LK_FONT(17);
    self.rankLabel.viewFrameX = 20;
    self.rankLabel.viewFrameY = 8;
    self.rankLabel.viewFrameHeight = self.rankLabel.font.lineHeight;
    self.rankLabel.textAlignment = UITextAlignmentCenter;
    self.rankLabel.textColor = [UIColor blackColor];
    self.ADD(self.rankLabel);
    
    self.headView = LCUIImageView.view;
    self.headView.viewFrameX = self.rankIcon.viewRightX + 13;
    self.headView.viewFrameY = 6;
    self.headView.viewFrameWidth = 39;
    self.headView.viewFrameHeight = 39;
    self.headView.cornerRadius = 39 * 0.5;
    self.headView.userInteractionEnabled = YES;
    [self.headView addTapGestureRecognizer:self selector:@selector(handleHeadTap:)];
    self.ADD(self.headView);
    
    self.nameLabel = LCUILabel.view;
    self.nameLabel.font = LK_FONT(12);
    self.nameLabel.viewFrameX = self.headView.viewRightX + 16;
    self.nameLabel.viewFrameY = 12;
    self.nameLabel.viewFrameHeight = self.nameLabel.font.lineHeight;
    self.nameLabel.textColor = [UIColor blackColor];
    self.ADD(self.nameLabel);
    
    self.likesLabel = LCUILabel.view;
    self.likesLabel.font = LK_FONT(10);
    self.likesLabel.textAlignment = UITextAlignmentLeft;
    self.likesLabel.viewFrameX = self.nameLabel.viewFrameX;
    self.likesLabel.viewFrameY = self.nameLabel.viewBottomY + 2;
    self.likesLabel.viewFrameWidth = 200;
    self.likesLabel.viewFrameHeight = self.likesLabel.font.lineHeight;
    self.likesLabel.textColor = [UIColor blackColor];
    self.ADD(self.likesLabel);
    
    self.hotIconView = LCUIImageView.view;
    self.hotIconView.viewFrameWidth = 23;
    self.hotIconView.viewFrameHeight = 12;
    self.hotIconView.viewCenterY = self.nameLabel.viewCenterY;
    self.hotIconView.image = [UIImage imageNamed:@"Hot3.png"];
    self.hotIconView.hidden = YES;
    self.ADD(self.hotIconView);
    
    self.suffixLabel = LCUILabel.view;
    self.suffixLabel.text = @"LIKES";
    self.suffixLabel.font = LK_FONT(11);
    self.suffixLabel.viewFrameHeight = self.suffixLabel.font.lineHeight;
    self.suffixLabel.viewFrameWidth = [self.suffixLabel.text sizeWithFont:LK_FONT(11) byHeight:self.suffixLabel.viewFrameHeight].width;
    self.suffixLabel.viewFrameX = LC_DEVICE_WIDTH - self.suffixLabel.viewFrameWidth - 14;
    self.suffixLabel.viewFrameY = 30;
    self.suffixLabel.textColor = LC_RGB(153, 153, 153);
    self.ADD(self.suffixLabel);
    
    self.increaseLikesLabel = LCUILabel.view;
    self.increaseLikesLabel.font = LK_FONT(27);
    self.increaseLikesLabel.viewFrameHeight = self.increaseLikesLabel.font.lineHeight;
    self.increaseLikesLabel.textColor = LC_RGB(153, 153, 153);
    self.ADD(self.increaseLikesLabel);
    
    LCUIImageView *line = LCUIImageView.view;
    line.viewFrameY = 50;
    line.viewFrameWidth = LC_DEVICE_WIDTH;
    line.viewFrameHeight = 1;
    line.image = [[UIImage imageNamed:@"cellLine.png"] imageWithAlpha:0.5];
    self.ADD(line);
}

- (void)setRank:(LKRank *)rank {
    
    _rank = rank;
    
    NSString *rankString = [rank.rank stringValue];
    self.rankLabel.text = rankString;
    CGSize rankLabelSize = [rankString sizeWithFont:LK_FONT(17) byHeight:self.rankLabel.viewFrameHeight];
    self.rankLabel.viewFrameWidth = rankLabelSize.width;
    
    [self.headView sd_setImageWithURL:[NSURL URLWithString:rank.user.avatar] placeholderImage:nil options:SDWebImageRetryFailed];
    
    self.nameLabel.text = rank.user.name;
    CGSize nameSize = [self.nameLabel.text sizeWithFont:LK_FONT(12) byHeight:self.nameLabel.viewFrameHeight];
    self.nameLabel.viewFrameWidth = nameSize.width > 80 ? 80 : nameSize.width;
    
    self.hotIconView.viewFrameX = self.nameLabel.viewRightX + 8;
    
    self.likesLabel.text = [NSString stringWithFormat:@"%@  likes", rank.user.likes];
    
    self.increaseLikesLabel.text = [rank.likes stringValue];
    CGSize increaseLabelSize = [self.increaseLikesLabel.text sizeWithFont:LK_FONT(27) byHeight:self.increaseLikesLabel.viewFrameHeight];
    
    switch ([rankString integerValue]) {
        case 1: {
            self.rankIcon.image = [[UIImage imageNamed:@"RankFirst.png"] imageWithTintColor:[UIColor redColor]];
            self.rankLabel.textColor = LKColor.color;
            self.rankLabel.viewFrameY = 8;
            self.hotIconView.hidden = NO;
            self.suffixLabel.textColor = LKColor.color;
            self.increaseLikesLabel.textColor = LKColor.color;
            
            self.increaseLikesLabel.font = LK_FONT(35);
            increaseLabelSize = [self.increaseLikesLabel.text sizeWithFont:LK_FONT(35) byHeight:self.increaseLikesLabel.viewFrameHeight];
            break;
        }
            
        case 2: {
            self.rankIcon.image = [[UIImage imageNamed:@"RankFirst.png"] imageWithTintColor:[UIColor orangeColor]];
            self.rankLabel.textColor = LKColor.color;
            self.rankLabel.viewFrameY = 8;
            self.hotIconView.hidden = NO;
            self.suffixLabel.textColor = LC_RGB(74, 74, 74);
            self.increaseLikesLabel.textColor = LC_RGB(74, 74, 74);
            
            self.increaseLikesLabel.font = LK_FONT(32);
            increaseLabelSize = [self.increaseLikesLabel.text sizeWithFont:LK_FONT(32) byHeight:self.increaseLikesLabel.viewFrameHeight];
            break;
        }

        case 3: {
            self.rankIcon.image = [[UIImage imageNamed:@"RankFirst.png"] imageWithTintColor:[UIColor greenColor]];
            self.rankLabel.textColor = LKColor.color;
            self.rankLabel.viewFrameY = 8;
            self.hotIconView.hidden = NO;
            self.suffixLabel.textColor = LC_RGB(112, 112, 112);
            self.increaseLikesLabel.textColor = LC_RGB(112, 112, 112);
            
            self.increaseLikesLabel.font = LK_FONT(30);
            increaseLabelSize = [self.increaseLikesLabel.text sizeWithFont:LK_FONT(30) byHeight:self.increaseLikesLabel.viewFrameHeight];
            break;
        }
            
        default: {
            self.rankIcon.image = nil;
            self.rankLabel.textColor = [UIColor blackColor];
            self.rankLabel.viewFrameY = (51 - self.rankLabel.viewFrameHeight) * 0.5;
            self.hotIconView.hidden = YES;
            self.suffixLabel.textColor = LC_RGB(153, 153, 153);
            self.increaseLikesLabel.textColor = LC_RGB(153, 153, 153);
            
            self.increaseLikesLabel.font = LK_FONT(27);
            increaseLabelSize = [self.increaseLikesLabel.text sizeWithFont:LK_FONT(27) byHeight:self.increaseLikesLabel.viewFrameHeight];
            break;
        }
    }
    
    self.increaseLikesLabel.viewFrameWidth = increaseLabelSize.width;
    self.increaseLikesLabel.viewFrameX = self.suffixLabel.viewFrameX - self.increaseLikesLabel.viewFrameWidth - 5;
    self.increaseLikesLabel.viewFrameY = self.suffixLabel.viewFrameY + self.suffixLabel.viewFrameHeight - self.increaseLikesLabel.viewFrameHeight + 5;
}

-(void) handleHeadTap:(UITapGestureRecognizer *)tap {
    self.SEND(self.PushUserCenter).object = self.rank.user;
}

@end
