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

@end

@implementation LKProfileSettingCell

- (void)buildUI {
    
    self.iconView = LCUIImageView.view;
    self.iconView.viewFrameX = 27;
    self.iconView.viewFrameY = 15;
    self.iconView.viewFrameWidth = 29;
}

@end
