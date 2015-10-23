//
//  LKBannerView.m
//  LIKE
//
//  Created by Elkins.Zhao on 15/10/23.
//  Copyright © 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKBannerView.h"

@interface LKBannerView ()

LC_PROPERTY(strong) LCUIImageView *bannerView;
LC_PROPERTY(strong) LCUILabel *participantsLabel;

@end

@implementation LKBannerView

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
    }
    return self;
}

- (void)setTagValue:(LKTag *)tagValue {
    _tagValue = tagValue;
    
    self.bannerView = LCUIImageView.view;
    self.bannerView.viewFrameY = 3;
    self.bannerView.viewFrameWidth = LC_DEVICE_WIDTH;
    self.bannerView.viewFrameHeight = 146;
    self.bannerView.image = [UIImage imageNamed:@"BannerPlaceholder.png"];
    self.bannerView.userInteractionEnabled = YES;
    [self.bannerView addTapGestureRecognizer:self selector:@selector(bannerViewTapAction:)];
    self.ADD(self.bannerView);
    
    self.participantsLabel = LCUILabel.view;
    self.participantsLabel.viewFrameWidth = 80;
    self.participantsLabel.viewFrameHeight = 40;
    self.participantsLabel.viewFrameX = LC_DEVICE_WIDTH - self.participantsLabel.viewFrameWidth - 5;
    self.participantsLabel.viewFrameY = self.bannerView.viewFrameHeight - self.participantsLabel.viewFrameHeight - 5;
    self.participantsLabel.font = LK_FONT(10);
    self.participantsLabel.numberOfLines = 2;
    self.participantsLabel.textAlignment = UITextAlignmentCenter;
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"已有%@小伙伴\n参与此活动", @(99999)]];
    self.participantsLabel.attributedText = attrString;
    self.ADD(self.participantsLabel);
}

- (void)bannerViewTapAction:(UITapGestureRecognizer *)tap {
    
    if (self.bannerViewDidTap) {
        self.bannerViewDidTap(self.tagValue);
    }
}

@end
