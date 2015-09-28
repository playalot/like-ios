//
//  LKUserCenterUserCell.m
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/4/21.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKUserCenterUserCell.h"
#import "LKTime.h"
#import "UIImageView+WebCache.h"

@interface LKUserCenterUserCell ()

LC_PROPERTY(strong) LCUIImageView *userHead;
LC_PROPERTY(strong) LCUILabel *titleLabel;
LC_PROPERTY(strong) LCUILabel *likeLabel;
LC_PROPERTY(strong) LCUIButton *button;
LC_PROPERTY(strong) LCUIImageView *focusView;

@end

@implementation LKUserCenterUserCell

-(void) buildUI
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
    self.userHead = LCUIImageView.view;
    self.userHead.viewFrameWidth = 40;
    self.userHead.viewFrameHeight = 40;
    self.userHead.viewFrameX = 28;
    self.userHead.viewFrameY = 10;
    self.userHead.cornerRadius = 40 * 0.5;
    self.userHead.backgroundColor = [UIColor whiteColor];
    self.ADD(self.userHead);
    
    
    self.titleLabel = LCUILabel.view;
    self.titleLabel.viewFrameX = self.userHead.viewFrameX + self.userHead.viewRightX;
    self.titleLabel.viewFrameWidth = LC_DEVICE_WIDTH - self.titleLabel.viewFrameX * 2 - 40;
    self.titleLabel.viewFrameHeight = 60;
    self.titleLabel.font = LK_FONT(14);
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.textColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    self.ADD(self.titleLabel);
    
    
    self.likeLabel = LCUILabel.view;
    self.likeLabel.viewFrameWidth = 100;
    self.likeLabel.viewFrameX = LC_DEVICE_WIDTH - 20 - self.likeLabel.viewFrameWidth;
    self.likeLabel.viewFrameHeight = 60;
    self.likeLabel.font = LK_FONT(14);
    self.likeLabel.textAlignment = UITextAlignmentRight;
    self.likeLabel.textColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    self.ADD(self.likeLabel);
    
    
//    self.focusView = LCUIImageView.view;
//    self.focusView.viewFrameWidth = 22;
//    self.focusView.viewFrameHeight = 22;
//    self.focusView.viewFrameY = 19;
//    self.focusView.viewFrameX = LC_DEVICE_WIDTH - 28 - 22;
//    self.ADD(self.focusView);
    

    UIView *line = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TalkLine.png" useCache:YES]];
    line.viewFrameWidth = LC_DEVICE_WIDTH;
    line.viewFrameY = 59;
    self.ADD(line);
}

- (void)setUser:(LKUser *)user {
    _user = user;
    
    self.userHead.image = nil;
//    self.userHead.url = user.avatar;
    [self.userHead sd_setImageWithURL:[NSURL URLWithString:user.avatar] placeholderImage:nil];
    
    self.titleLabel.text = [NSString stringWithFormat:@"%@", user.name];
    
    switch (user.isFollowing.integerValue) {
        case 0:
            self.focusView.image = [UIImage imageNamed:@"FocusGray.png" useCache:YES];
            break;
        case 1:
            self.focusView.image = [UIImage imageNamed:@"AlreadyFocusGray.png" useCache:YES];
            break;
        case 2:
            self.focusView.image = [UIImage imageNamed:@"EachOtherFocusGray.png" useCache:YES];
            break;
            
        default:
            break;
    }

    self.likeLabel.text = [NSString stringWithFormat:@"%@ likes", self.user.likes];
}

@end
