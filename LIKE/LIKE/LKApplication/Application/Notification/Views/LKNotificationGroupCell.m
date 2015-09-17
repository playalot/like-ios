//
//  LKNotificationGroupCell.m
//  LIKE
//
//  Created by Elkins.Zhao on 15/9/17.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKNotificationGroupCell.h"

@interface LKNotificationGroupCell ()

LC_PROPERTY(strong) UIImageView *line;

@end

@implementation LKNotificationGroupCell

-(instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        
        self.iconView = LCUIImageView.view;
        self.iconView.viewFrameX = 10;
        self.iconView.viewFrameY = 10;
        self.iconView.viewFrameWidth = 35;
        self.iconView.viewFrameHeight = 35;
        self.iconView.backgroundColor = [UIColor whiteColor];
        self.iconView.cornerRadius = 35 / 2;
        self.iconView.userInteractionEnabled = YES;
        self.ADD(self.iconView);
        
        
        self.titleLbl = LCUILabel.view;
        self.titleLbl.viewFrameWidth = 100;
        self.titleLbl.viewFrameHeight = 20;
        self.titleLbl.viewFrameX = self.iconView.viewRightX + 10;
        self.titleLbl.viewCenterY = self.iconView.viewCenterY;
        self.ADD(self.titleLbl);
        
        
        self.line = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TalkLine.png" useCache:YES]];
        self.line.viewFrameWidth = LC_DEVICE_WIDTH;
        self.line.viewFrameY = 55 - self.line.viewFrameHeight;
        self.ADD(self.line);
        
        self.titleLbl.textColor = [UIColor blackColor];
    }
    
    return self;
}

@end
