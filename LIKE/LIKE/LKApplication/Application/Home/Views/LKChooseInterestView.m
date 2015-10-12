//
//  LKChooseInterestView.m
//  LIKE
//
//  Created by Elkins.Zhao on 15/10/1.
//  Copyright © 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKChooseInterestView.h"
#import "LKTagItemView.h"
#import "UIImageView+WebCache.h"

@interface LKChooseInterestView ()

LC_PROPERTY(strong) LCUIImageView *mushroomView;
LC_PROPERTY(strong) LCUIImageView *largeSatelliteView;
LC_PROPERTY(strong) LCUIImageView *smallSatelliteView;
LC_PROPERTY(strong) LCUIImageView *aeroliteView;
LC_PROPERTY(strong) LCUIImageView *jupiterView;
LC_PROPERTY(strong) LCUIImageView *meteorView;
LC_PROPERTY(strong) LCUIImageView *bottomView;
LC_PROPERTY(strong) LCUILabel *sloganLabel;
LC_PROPERTY(strong) UIScrollView *tagsView;
LC_PROPERTY(strong) LCUIButton *enterButton;

@end

@implementation LKChooseInterestView

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor whiteColor];
        [self buildUI];
    }
    
    return self;
}

- (void)buildUI {
    
    [self buildMushroomView];
    [self buildLargeSatelliteView];
    [self buildSmallSatelliteView];
    [self buildAeroliteView];
    [self buildJupiterView];
    [self buildMeteorView];
    [self buildBottomView];
    [self buildSloganLabel];
    [self buildChooseInterestView];
    [self buildEnterButton];
}

- (void)buildMushroomView {
    
    self.mushroomView = LCUIImageView.view;
    self.mushroomView.viewFrameX = 30;
    self.mushroomView.viewFrameY = 40;
    self.mushroomView.viewFrameWidth = 28;
    self.mushroomView.viewFrameHeight = 28;
    self.mushroomView.image = [UIImage imageNamed:@"Interest_mushroom.png" useCache:YES];
    self.ADD(self.mushroomView);
    
    CAKeyframeAnimation *anima = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(30, 40, 25, 25)];
    anima.path = path.CGPath;
    anima.duration = 100.0f;
    anima.repeatCount = 5;
    [self.mushroomView.layer addAnimation:anima forKey:@"pathAnimation"];
}

- (void)buildLargeSatelliteView {
    
    self.largeSatelliteView = LCUIImageView.view;
    self.largeSatelliteView.viewFrameX = self.viewFrameWidth - 55 - 20;
    self.largeSatelliteView.viewFrameY = 40;
    self.largeSatelliteView.viewFrameWidth = 55;
    self.largeSatelliteView.viewFrameHeight = 55;
    self.largeSatelliteView.image = [UIImage imageNamed:@"Interest_satellite_large.png" useCache:YES];
    self.ADD(self.largeSatelliteView);
    
    CAKeyframeAnimation *anima = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(self.largeSatelliteView.viewFrameX, 40, 25, 25)];
    anima.path = path.CGPath;
    anima.duration = 100.0f;
    anima.repeatCount = 5;
    [self.largeSatelliteView.layer addAnimation:anima forKey:@"pathAnimation"];
}

- (void)buildSmallSatelliteView {
    
    self.smallSatelliteView = LCUIImageView.view;
    self.smallSatelliteView.viewFrameX = 20;
    self.smallSatelliteView.viewFrameY = self.viewMidHeight - 100;
    self.smallSatelliteView.viewFrameWidth = 35;
    self.smallSatelliteView.viewFrameHeight = 35;
    self.smallSatelliteView.image = [UIImage imageNamed:@"Interest_satellite_small.png" useCache:YES];
    self.ADD(self.smallSatelliteView);
    
    CAKeyframeAnimation *anima = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(20, self.smallSatelliteView.viewFrameY, 25, 25)];
    anima.path = path.CGPath;
    anima.duration = 100.0f;
    anima.repeatCount = 5;
    [self.smallSatelliteView.layer addAnimation:anima forKey:@"pathAnimation"];
}

- (void)buildAeroliteView {
    
    self.aeroliteView = LCUIImageView.view;
    self.aeroliteView.viewFrameX = self.viewFrameWidth - 12 - 20;
    self.aeroliteView.viewFrameY = self.viewMidHeight + 50;
    self.aeroliteView.viewFrameWidth = 12;
    self.aeroliteView.viewFrameHeight = 13;
    self.aeroliteView.image = [UIImage imageNamed:@"Interest_aerolite.png" useCache:YES];
    self.ADD(self.aeroliteView);
    
    CAKeyframeAnimation *anima = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(self.aeroliteView.viewFrameX, self.aeroliteView.viewFrameY, 25, 25)];
    anima.path = path.CGPath;
    anima.duration = 100.0f;
    anima.repeatCount = 5;
    [self.aeroliteView.layer addAnimation:anima forKey:@"pathAnimation"];
}

- (void)buildJupiterView {
    
    self.jupiterView = LCUIImageView.view;
    self.jupiterView.viewFrameX = 30;
    self.jupiterView.viewFrameY = self.viewMidHeight + 150;
    self.jupiterView.viewFrameWidth = 62;
    self.jupiterView.viewFrameHeight = 62;
    self.jupiterView.image = [UIImage imageNamed:@"Interest_Jupiter.png" useCache:YES];
    self.ADD(self.jupiterView);
    
//    CAKeyframeAnimation *anima = [CAKeyframeAnimation animationWithKeyPath:@"position"];
//    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(30, self.jupiterView.viewFrameY, 50, 50)];
//    anima.path = path.CGPath;
//    anima.duration = 100.0f;
//    anima.repeatCount = 5;
//    [self.jupiterView.layer addAnimation:anima forKey:@"pathAnimation"];
}

- (void)buildMeteorView {
    
    self.meteorView = LCUIImageView.view;
    self.meteorView.viewFrameX = self.viewFrameWidth - 70;
    self.meteorView.viewFrameY = self.viewFrameHeight - 150;
    self.meteorView.viewFrameWidth = 28;
    self.meteorView.viewFrameHeight = 28;
    self.meteorView.image = [UIImage imageNamed:@"Interest_meteor.png" useCache:YES];
    self.ADD(self.meteorView);
    
    CAKeyframeAnimation *anima = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(self.meteorView.viewFrameX, self.meteorView.viewFrameY, 25, 25)];
    anima.path = path.CGPath;
    anima.duration = 100.0f;
    anima.repeatCount = 5;
    [self.meteorView.layer addAnimation:anima forKey:@"pathAnimation"];
}

- (void)buildBottomView {
    
    self.bottomView = LCUIImageView.view;
    self.bottomView.viewFrameX = 0;
    self.bottomView.viewFrameY = self.viewFrameHeight - 105;
    self.bottomView.viewFrameWidth = LC_DEVICE_WIDTH;
    self.bottomView.viewFrameHeight = 105;
    self.bottomView.backgroundColor = [UIColor clearColor];
    self.bottomView.image = [UIImage imageNamed:@"Interest_bottom.png" useCache:YES];
    self.ADD(self.bottomView);
}

- (void)buildSloganLabel {
    
    self.sloganLabel = LCUILabel.view;
    self.sloganLabel.text = LC_LO(@"选择感兴趣的标签");
    self.sloganLabel.textColor = [UIColor blackColor];
    self.sloganLabel.font = LK_FONT(14);
    self.sloganLabel.viewFrameHeight = self.sloganLabel.font.lineHeight;
    self.sloganLabel.viewFrameWidth = [self.sloganLabel.text sizeWithFont:self.sloganLabel.font
                                                                 byHeight:self.sloganLabel.viewFrameHeight].width;
    self.sloganLabel.viewCenterX = self.viewCenterX;
    self.sloganLabel.viewFrameY = 62;
    self.ADD(self.sloganLabel);
}

- (void)buildChooseInterestView {
   
    self.tagsView = UIScrollView.view;
    self.tagsView.viewFrameWidth = 200;
    self.tagsView.viewFrameHeight = self.viewFrameHeight - 180 - 113;
    self.tagsView.viewCenterX = self.viewMidWidth;
    self.tagsView.viewFrameY = self.sloganLabel.viewBottomY + 33;
    self.tagsView.backgroundColor = [UIColor clearColor];
    self.ADD(self.tagsView);
    
    // 发送网络请求,在scrollView中添加标签
    [self sendNetworkRequest];
}

- (void)buildEnterButton {
    
    self.enterButton = LCUIButton.view;
    self.enterButton.viewFrameWidth = 85;
    self.enterButton.viewFrameHeight = 30;
    self.enterButton.viewCenterX = self.viewCenterX;
    self.enterButton.viewFrameY = self.tagsView.viewBottomY + 21;
    self.enterButton.backgroundColor = LKColor.color;
    self.enterButton.cornerRadius = 4;
    self.enterButton.title = LC_LO(@"进入like");
    self.enterButton.titleFont = LK_FONT(14);
    [self.enterButton addTarget:self action:@selector(enter) forControlEvents:UIControlEventTouchUpInside];
    self.ADD(self.enterButton);
}

- (void)sendNetworkRequest {
    
    LKHttpRequestInterface *interface = [LKHttpRequestInterface interfaceType:@"welcome/tags"].GET_METHOD();
    
    [self request:interface complete:^(LKHttpRequestResult *result) {
        
        if (result.state == LKHttpRequestStateFinished) {
            
            id tmp = result.json[@"data"][@"tags"];
            NSMutableArray *tagsArrayM = [NSMutableArray array];
            
            for (NSDictionary *tag in tmp) {
                
                [tagsArrayM addObject:[LKTag objectFromDictionary:tag]];
            }
            
            [self addSubViewsWithTags:tagsArrayM.copy];
            
        } else if (result.state == LKHttpRequestStateFailed) {
            
            [self showTopMessageErrorHud:result.error];
        }
    }];
}

/**
 *  根据标签添加子控件
 */
- (void)addSubViewsWithTags:(NSArray *)tags {
    
    [self.tagsView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    CGFloat maxItemY = 0;
    for (NSInteger i = 0; i < tags.count; i++) {
        
        LKTagItemView *item = [[LKTagItemView alloc] initWithFont:LK_FONT(18)];
        
        item.chooseTag = tags[i];
        [self.tagsView addSubview:item];
        //        item.backgroundImageView.url = (NSString *)[tags[i] image];
        [item.backgroundImageView sd_setImageWithURL:[NSURL URLWithString:(NSString *)[tags[i] image]] placeholderImage:nil];
        
        CGFloat margin = 10;
        item.viewFrameWidth = item.likesLabel.viewRightX + 15;
        item.viewFrameX = 2 * margin + arc4random_uniform(self.tagsView.viewFrameWidth - item.viewFrameWidth - 3 * margin);
        item.viewFrameHeight = 32;
        item.viewFrameY = (i + 1) * margin + i * item.viewFrameHeight;
        
        maxItemY = item.viewFrameY;
        
        
//        item.tagLabel.textColor = [UIColor whiteColor];
//        item.likesLabel.textColor = [UIColor whiteColor];
    }
    
    self.tagsView.contentSize = CGSizeMake(0, maxItemY + 31 + 10);
}

- (void)enter {
    
    NSMutableArray *idArray = [NSMutableArray array];
    NSMutableArray *groupArray = [NSMutableArray array];
    for (LKTagItemView *item in self.tagsView.subviews) {
        
        if (item.backgroundImageView.isHidden) {
            
            [idArray addObject:item.chooseTag.chooseTagId];
            [groupArray addObject:item.chooseTag.group];
        }
    }
    
    LKHttpRequestInterface *interface = [LKHttpRequestInterface interfaceType:@"welcome/preference"].POST_METHOD();
    [interface addParameter:idArray.copy key:@"tags"];
    [interface addParameter:groupArray.copy key:@"groups"];
    
    [self request:interface complete:^(LKHttpRequestResult *result) {
        
        if (result.state == LKHttpRequestStateFinished) {
            
            [UIView animateWithDuration:1.0 animations:^{
                
                self.alpha = 0;
            } completion:^(BOOL finished) {
                
                [self removeFromSuperview];
            }];
            
        } else if (result.state == LKHttpRequestStateFailed) {
            
            [self showTopMessageErrorHud:result.error];
        }
    }];
}

@end
