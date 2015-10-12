//
//  LKProfileSettingCell.m
//  LIKE
//
//  Created by Elkins.Zhao on 15/9/28.
//  Copyright © 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKProfileSettingCell.h"

@interface LKProfileSettingCell ()

LC_PROPERTY(strong) LCUIImageView *iconView;
LC_PROPERTY(strong) LCUILabel *contentLabel;
LC_PROPERTY(strong) LCUIImageView *indicatorView;

@end

@implementation LKProfileSettingCell

- (void)buildUI {
    
    self.iconView = LCUIImageView.view;
    self.iconView.viewFrameX = 18;
    self.iconView.viewFrameY = 13;
    self.iconView.viewFrameWidth = 29;
    self.iconView.viewFrameHeight = 29;
    self.ADD(self.iconView);
    
    self.contentLabel = LCUILabel.view;
    self.contentLabel.viewFrameX = self.iconView.viewRightX + 18;
    self.contentLabel.viewFrameWidth = 150;
    self.contentLabel.viewFrameHeight = 55;
    self.ADD(self.iconView);
    
    self.indicatorView = LCUIImageView.view;
    self.indicatorView.viewFrameWidth = 11;
    self.indicatorView.viewFrameHeight = 20;
    self.indicatorView.viewFrameX = LC_DEVICE_WIDTH - 16;
    self.indicatorView.viewFrameY = 17.5;
    self.ADD(self.indicatorView);
}

@end
