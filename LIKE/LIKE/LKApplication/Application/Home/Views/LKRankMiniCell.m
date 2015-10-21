//
//  LKRankMiniCell.m
//  LIKE
//
//  Created by Elkins.Zhao on 15/10/20.
//  Copyright © 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKRankMiniCell.h"
#import "UIImageView+WebCache.h"

@interface LKRankMiniCell ()

LC_PROPERTY(strong) LCUIImageView *rankIcon;
LC_PROPERTY(strong) LCUILabel *rankLabel;
LC_PROPERTY(strong) LCUIImageView *headView;
LC_PROPERTY(strong) LCUILabel *nameLabel;
LC_PROPERTY(strong) LCUILabel *likesLabel;
LC_PROPERTY(strong) LCUIImageView *hotIconView;
LC_PROPERTY(strong) LCUILabel *increaseLikesLabel;
//LC_PROPERTY(strong) LCUILabel *suffixLabel;

@end

@implementation LKRankMiniCell

LC_IMP_SIGNAL(PushUserCenter);

- (void)buildUI {
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.rankIcon = LCUIImageView.view;
    self.rankIcon.viewFrameX = 8;
    self.rankIcon.viewFrameY = 16;
    self.rankIcon.viewFrameWidth = 19;
    self.rankIcon.viewFrameHeight = 20;
    self.ADD(self.rankIcon);
    
    self.rankLabel = LCUILabel.view;
    self.rankLabel.font = LK_FONT(17);
    self.rankLabel.viewFrameX = 7;
    self.rankLabel.viewFrameY = 8;
    self.rankLabel.viewFrameWidth = 21;
    self.rankLabel.viewFrameHeight = self.rankLabel.font.lineHeight;
    self.rankLabel.textAlignment = UITextAlignmentCenter;
    self.rankLabel.textColor = LC_RGB(127, 127, 127);
    self.ADD(self.rankLabel);
    
    self.headView = LCUIImageView.view;
    self.headView.viewFrameX = self.rankIcon.viewRightX + 8;
    self.headView.viewFrameY = 8;
    self.headView.viewFrameWidth = 35;
    self.headView.viewFrameHeight = 35;
    self.headView.cornerRadius = 35 * 0.5;
    self.headView.userInteractionEnabled = YES;
    [self.headView addTapGestureRecognizer:self selector:@selector(handleHeadTap:)];
    self.ADD(self.headView);
    
    self.nameLabel = LCUILabel.view;
    self.nameLabel.font = LK_FONT(12);
    self.nameLabel.viewFrameX = self.headView.viewRightX + 12;
    self.nameLabel.viewFrameY = 12;
    self.nameLabel.viewFrameHeight = self.nameLabel.font.lineHeight;
    self.nameLabel.textColor = [UIColor blackColor];
    self.ADD(self.nameLabel);
    
    self.likesLabel = LCUILabel.view;
    self.likesLabel.font = LK_FONT(10);
    self.likesLabel.textAlignment = UITextAlignmentLeft;
    self.likesLabel.viewFrameX = self.nameLabel.viewFrameX;
    self.likesLabel.viewFrameY = self.nameLabel.viewBottomY + 2;
    self.likesLabel.viewFrameHeight = self.likesLabel.font.lineHeight;
    self.likesLabel.textColor = [UIColor blackColor];
    self.ADD(self.likesLabel);
    
    self.hotIconView = LCUIImageView.view;
    self.hotIconView.viewFrameWidth = 23;
    self.hotIconView.viewFrameHeight = 12;
    self.hotIconView.viewCenterY = self.likesLabel.viewCenterY;
    self.hotIconView.image = [UIImage imageNamed:@"Hot3.png"];
    self.hotIconView.hidden = YES;
    self.ADD(self.hotIconView);
    
//    self.suffixLabel = LCUILabel.view;
//    self.suffixLabel.text = @"likes";
//    self.suffixLabel.font = LK_FONT(11);
//    self.suffixLabel.viewFrameHeight = self.suffixLabel.font.lineHeight;
//    self.suffixLabel.viewFrameWidth = [self.suffixLabel.text sizeWithFont:LK_FONT(11) byHeight:self.suffixLabel.viewFrameHeight].width;
//    self.suffixLabel.viewFrameX = LC_DEVICE_WIDTH - self.suffixLabel.viewFrameWidth - 8;
//    self.suffixLabel.viewFrameY = 51 - 9 - self.suffixLabel.viewFrameHeight;
//    self.suffixLabel.textColor = LC_RGB(156, 156, 156);
//    self.ADD(self.suffixLabel);
    
    self.increaseLikesLabel = LCUILabel.view;
    self.increaseLikesLabel.font = LK_FONT_B(27);
    self.increaseLikesLabel.viewFrameHeight = self.increaseLikesLabel.font.lineHeight;
    self.increaseLikesLabel.textColor = LC_RGB(156, 156, 156);
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
    
    [self.headView sd_setImageWithURL:[NSURL URLWithString:rank.user.avatar] placeholderImage:nil options:SDWebImageRetryFailed];
    
    self.nameLabel.text = rank.user.name;
    CGSize nameSize = [self.nameLabel.text sizeWithFont:LK_FONT(12) byHeight:self.nameLabel.viewFrameHeight];
    self.nameLabel.viewFrameWidth = nameSize.width > 150 ? 150 : nameSize.width;
    
    self.likesLabel.text = [NSString stringWithFormat:@"%@  likes", rank.user.likes];
    CGSize likesSize = [self.likesLabel.text sizeWithFont:LK_FONT(10) byHeight:self.likesLabel.viewFrameHeight];
    self.likesLabel.viewFrameWidth = likesSize.width;
    self.hotIconView.viewFrameX = self.likesLabel.viewRightX + 4;
    
    //    self.increaseLikesLabel.text = [rank.likes stringValue];
    NSAttributedString *attributedString =[[NSAttributedString alloc] initWithString:[rank.likes stringValue] attributes:@{NSKernAttributeName : @(-1.3f)}];
    
    [self.increaseLikesLabel setAttributedText:attributedString];
    CGSize increaseLabelSize = [self.increaseLikesLabel.text sizeWithFont:LK_FONT_B(27) byHeight:self.increaseLikesLabel.viewFrameHeight];
    
    switch ([rankString integerValue]) {
        case 1: {
            self.rankIcon.image = [UIImage imageNamed:@"RankFirst_mini.png"];
            self.rankLabel.hidden = YES;
            self.rankLabel.viewFrameY = 8;
            self.hotIconView.hidden = NO;
//            self.suffixLabel.textColor = LKColor.color;
            self.increaseLikesLabel.textColor = LKColor.color;
            
            self.increaseLikesLabel.font = LK_FONT_B(30);
            increaseLabelSize = [self.increaseLikesLabel.text sizeWithFont:LK_FONT_B(30) byHeight:self.increaseLikesLabel.viewFrameHeight];
            break;
        }
            
        case 2: {
            self.rankIcon.image = [UIImage imageNamed:@"RankSecond_mini.png"];
            self.rankLabel.hidden = YES;
            self.rankLabel.viewFrameY = 8;
            self.hotIconView.hidden = NO;
//            self.suffixLabel.textColor = LC_RGB(126, 211, 33);
            self.increaseLikesLabel.textColor = LC_RGB(126, 211, 33);
            
            self.increaseLikesLabel.font = LK_FONT_B(29);
            increaseLabelSize = [self.increaseLikesLabel.text sizeWithFont:LK_FONT_B(29) byHeight:self.increaseLikesLabel.viewFrameHeight];
            break;
        }
            
        case 3: {
            self.rankIcon.image = [UIImage imageNamed:@"RankThird_mini.png"];
            self.rankLabel.hidden = YES;
            self.rankLabel.viewFrameY = 8;
            self.hotIconView.hidden = NO;
//            self.suffixLabel.textColor = LC_RGB(245, 166, 35);
            self.increaseLikesLabel.textColor = LC_RGB(245, 166, 35);
            
            self.increaseLikesLabel.font = LK_FONT_B(28);
            increaseLabelSize = [self.increaseLikesLabel.text sizeWithFont:LK_FONT_B(28) byHeight:self.increaseLikesLabel.viewFrameHeight];
            break;
        }
            
        default: {
            self.rankIcon.image = nil;
            self.rankLabel.hidden = NO;
            self.rankLabel.viewFrameY = (51 - self.rankLabel.viewFrameHeight) * 0.5;
            self.hotIconView.hidden = YES;
//            self.suffixLabel.textColor = LC_RGB(156, 156, 156);
            self.increaseLikesLabel.textColor = LC_RGB(156, 156, 156);
            
            self.increaseLikesLabel.font = LK_FONT_B(27);
            increaseLabelSize = [self.increaseLikesLabel.text sizeWithFont:LK_FONT_B(27) byHeight:self.increaseLikesLabel.viewFrameHeight];
            break;
        }
    }
    
    self.increaseLikesLabel.viewFrameWidth = increaseLabelSize.width;
    self.increaseLikesLabel.viewFrameX = LC_DEVICE_WIDTH - self.increaseLikesLabel.viewFrameWidth - 10;
    self.increaseLikesLabel.viewFrameY = 51 - 9 - self.increaseLikesLabel.viewFrameHeight;
}

-(void) handleHeadTap:(UITapGestureRecognizer *)tap {
    self.SEND(self.PushUserCenter).object = self.rank.user;
}

@end
