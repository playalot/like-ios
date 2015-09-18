//
//  LKNormalOfficialCell.m
//  LIKE
//
//  Created by Elkins.Zhao on 15/9/18.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKNormalOfficialCell.h"

@interface LKNormalOfficialCell ()

LC_PROPERTY(strong) LCUILabel *titleLbl;
LC_PROPERTY(strong) LCUILabel *subTitleLbl;
LC_PROPERTY(strong) LCUIView *cellBackgroundView;
LC_PROPERTY(strong) LCUIImageView *iconView;

@end

@implementation LKNormalOfficialCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.backgroundColor = LKColor.backgroundColor;
    
        
        self.cellBackgroundView = LCUIView.view;
        self.cellBackgroundView.backgroundColor = [UIColor whiteColor];
        self.cellBackgroundView.viewFrameX = 12;
        self.cellBackgroundView.viewFrameY = 12;
        self.cellBackgroundView.viewFrameWidth = LC_DEVICE_WIDTH - 12 * 2;
        self.cellBackgroundView.viewFrameHeight = 100;
        self.ADD(self.cellBackgroundView);
        
        
        self.titleLbl = LCUILabel.view;
        self.titleLbl.font = LK_FONT_B(15);
        self.titleLbl.viewFrameX = 15;
        self.titleLbl.viewFrameY = 15;
        self.titleLbl.viewFrameWidth = self.cellBackgroundView.viewFrameWidth - 15 * 4;
        self.titleLbl.viewFrameHeight = self.titleLbl.font.lineHeight;
        self.cellBackgroundView.ADD(self.titleLbl);
        
        
        self.iconView = LCUIImageView.view;
        self.iconView.image = [UIImage imageNamed:@"NotificationOfficalIcon.png" useCache:YES];
        self.iconView.viewFrameWidth = 15;
        self.iconView.viewFrameHeight = 15;
        self.iconView.viewFrameX = self.cellBackgroundView.viewFrameWidth - self.iconView.viewFrameWidth - 15;
        self.iconView.viewCenterY = self.titleLbl.viewCenterY;
        self.cellBackgroundView.ADD(self.iconView);
        
        
        self.subTitleLbl = LCUILabel.view;
        self.subTitleLbl.font = LK_FONT(10);
        self.subTitleLbl.viewFrameX = self.titleLbl.viewFrameX;
        self.subTitleLbl.viewFrameY = self.titleLbl.viewBottomY + 20;
        self.subTitleLbl.viewFrameWidth = self.cellBackgroundView.viewFrameWidth - 15 * 2;
        self.subTitleLbl.numberOfLines = 0;
        self.cellBackgroundView.ADD(self.subTitleLbl);
        
    }
    return self;
}

@end
