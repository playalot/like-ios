//
//  LKRankCell.m
//  LIKE
//
//  Created by Elkins.Zhao on 15/10/19.
//  Copyright © 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKRankCell.h"

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

- (void)buildUI {
 
//    UIImage *image = [UIImage imageNamed:@"RankFirst.png" useCache:YES];
    self.rankIcon = LCUIImageView.view;
    self.rankIcon.viewFrameX = 10;
    self.rankIcon.viewFrameY = 10;
}

- (void)setRank:(LKRank *)rank {
    
    
}

@end
