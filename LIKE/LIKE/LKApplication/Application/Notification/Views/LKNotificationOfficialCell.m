//
//  LKNotificationOfficialCell.m
//  LIKE
//
//  Created by Elkins.Zhao on 15/9/18.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKNotificationOfficialCell.h"

@interface LKNotificationOfficialCell ()

//LC_PROPERTY(strong) LCUILabel *titleLbl;
//LC_PROPERTY(strong) LCUILabel *subTitleLbl;
//LC_PROPERTY(strong) LCUIView *cellBackgroundView;
//LC_PROPERTY(strong) LCUIImageView *iconView;
//LC_PROPERTY(strong) LCUIImageView *contentImage;

@end

@implementation LKNotificationOfficialCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.backgroundColor = LKColor.backgroundColor;
        
        
        self.cellBackgroundView = LCUIView.view;
        self.cellBackgroundView.backgroundColor = [UIColor whiteColor];
        self.cellBackgroundView.viewFrameX = 12;
        self.cellBackgroundView.viewFrameY = 12;
        self.cellBackgroundView.viewFrameWidth = LC_DEVICE_WIDTH - 12 * 2;
        self.ADD(self.cellBackgroundView);
        
        
        self.titleLbl = LCUILabel.view;
        self.titleLbl.font = LK_FONT_B(15);
        self.titleLbl.textColor = [UIColor blackColor];
        self.titleLbl.viewFrameX = 15;
        self.titleLbl.viewFrameY = 15;
        self.titleLbl.viewFrameWidth = self.cellBackgroundView.viewFrameWidth - 15 * 4;
        self.titleLbl.viewFrameHeight = self.titleLbl.font.lineHeight;
        self.cellBackgroundView.ADD(self.titleLbl);
        
        
        self.iconView = LCUIImageView.view;
        self.iconView.image = [UIImage imageNamed:@"NotificationOfficalMessage.png" useCache:YES];
        self.iconView.viewFrameWidth = 15;
        self.iconView.viewFrameHeight = 15;
        self.iconView.viewFrameX = self.cellBackgroundView.viewFrameWidth - self.iconView.viewFrameWidth - 15;
        self.iconView.viewCenterY = self.titleLbl.viewCenterY;
        self.cellBackgroundView.ADD(self.iconView);
        
        
        self.contentImage = LCUIImageView.view;
        self.contentImage.image = [UIImage imageNamed:@"QRCode.png" useCache:YES];
        self.contentImage.viewFrameX = self.titleLbl.viewFrameX;
        self.contentImage.viewFrameY = self.titleLbl.viewBottomY + 15;
        self.contentImage.viewFrameWidth = self.cellBackgroundView.viewFrameWidth - 15 * 2;
        self.contentImage.viewFrameHeight = 200;
        self.contentImage.contentMode = UIViewContentModeScaleAspectFill;
        self.contentImage.clipsToBounds = YES;
        self.cellBackgroundView.ADD(self.contentImage);
        
        
        self.subTitleLbl = LCUILabel.view;
        self.subTitleLbl.font = LK_FONT(10);
        self.subTitleLbl.textColor = [UIColor blackColor];
        self.subTitleLbl.viewFrameX = self.titleLbl.viewFrameX;
        self.subTitleLbl.viewFrameY = self.contentImage.viewBottomY + 20;
        self.subTitleLbl.viewFrameWidth = self.contentImage.viewFrameWidth;
        self.subTitleLbl.numberOfLines = 0;
        self.subTitleLbl.viewFrameHeight = self.subTitleLbl.font.lineHeight * 4;
        self.cellBackgroundView.ADD(self.subTitleLbl);
        
        
        self.cellBackgroundView.viewFrameHeight = self.subTitleLbl.viewBottomY + 20;
        self.cellHeight = self.cellBackgroundView.viewFrameHeight + 12;
    }
    return self;
}

@end
