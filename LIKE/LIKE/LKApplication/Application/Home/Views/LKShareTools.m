//
//  LKShareTools.m
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/5/20.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKShareTools.h"
#import "LKShare.h"

@interface LKShareTools ()

LC_PROPERTY(strong) LCUIImageView * icon;
LC_PROPERTY(strong) LCUILabel * title;
LC_PROPERTY(strong) NSMutableArray * shareIcons;
LC_PROPERTY(assign) BOOL isShow;

@end

@implementation LKShareTools

-(instancetype) init
{
    if (self = [super initWithFrame:CGRectMake(0, 0, LC_DEVICE_WIDTH, 33 + 20)]) {
        
        [self buildUI];
    }
    
    return self;
}

-(void) buildUI
{
    [self addTapGestureRecognizer:self selector:@selector(hideTools)];
    
    self.tapGestureRecognizer.enabled = NO;

    
    self.icon = [LCUIImageView viewWithImage:[UIImage imageNamed:@"ShareIcon.png" useCache:YES]];
    self.icon.userInteractionEnabled = YES;
    self.icon.alpha = 0.4;
    [self.icon addTapGestureRecognizer:self selector:@selector(iconTapAction)];
    self.ADD(self.icon);
    
    
    self.title = LCUILabel.view;
    self.title.textColor = LC_RGB(171, 164, 157);
    self.title.font = LK_FONT(13);
    self.title.text = LC_LO(@"分享");
    self.title.alpha = 1;
    self.title.FIT();
    self.title.viewFrameHeight = self.viewFrameHeight;
    [self.title addTapGestureRecognizer:self selector:@selector(iconTapAction)];
    self.ADD(self.title);
    
    
    self.title.viewFrameX = self.viewFrameWidth - self.title.viewFrameWidth - 40 / 3;
    self.title.viewFrameY = 0;
    
    
    self.icon.viewFrameX = self.title.viewFrameX - self.icon.viewFrameWidth - 5;
    self.icon.viewFrameY = self.viewMidHeight - self.icon.viewMidHeight;
    
    
    
    LCUIButton * actionButton = LCUIButton.view;
    actionButton.viewFrameX = self.icon.viewFrameX - 30;
    actionButton.viewFrameWidth = 200;
    actionButton.viewFrameHeight = self.viewFrameHeight;
    [actionButton addTarget:self action:@selector(iconTapAction) forControlEvents:UIControlEventTouchUpInside];
    self.ADD(actionButton);
    
    
    
    
    self.shareIcons = [NSMutableArray array];
    
    
    NSArray * imageNames = @[@"WeChatFriendIcon.png",@"WeChatFeedIcon.png",@"QQIcon.png",@"SinaIcon.png"];
    
    CGFloat padding = 26.6;

    for (NSInteger i = 0; i < 4; i++) {
        
        LCUIButton * button = LCUIButton.view;
        button.viewFrameWidth = padding + 5;
        button.viewFrameHeight = padding + 5;
        button.buttonImage = [UIImage imageNamed:imageNames[i] useCache:YES];
        button.viewFrameX = self.viewFrameWidth + 20;
        button.viewFrameY = self.viewMidHeight - button.viewMidHeight;
        button.alpha = 0;
        button.tag = i;
        [button addTarget:self action:@selector(shareIconTapAction:) forControlEvents:UIControlEventTouchUpInside];
        self.ADD(button);
        
        [self.shareIcons addObject:button];
    }
}

-(void) shareIconTapAction:(UIButton *)button
{
    UIImage * image = self.willShareImage(button.tag);
    
    if (!image) {
        return;
    }
    
    [LKShare shareImageWithType:button.tag image:image];
    
    [self performSelector:@selector(hideTools) withObject:nil afterDelay:1];
}

-(void) iconTapAction
{
    if (self.isShow) {
        [self hideTools];
    }
    else{
        
        [self showTools];
    }
}

-(void) showTools
{
    if (self.isShow) {
        return;
    }
    
    
    LC_FAST_ANIMATIONS(0.25, ^{
        
        self.title.alpha = 0;
        
        self.icon.image = [UIImage imageNamed:@"ShareIconSelect.png" useCache:YES];
        self.icon.viewFrameX = self.viewFrameWidth - self.icon.viewFrameWidth - 5 - 40 / 3;
    });
    
    
    
    CGFloat padding = 26.6;
    
    for (NSInteger i = 0; i < self.shareIcons.count; i++) {
        
        LCUIButton * button = self.shareIcons[i];
        button.pop_springBounciness = 5;
        button.pop_springSpeed = 5;
        button.pop_spring.frame = LC_RECT(40 / 3 + ((padding - 10) * i) + button.viewFrameWidth * i, button.viewFrameY, button.viewFrameWidth, button.viewFrameHeight);
        button.pop_spring.alpha = 1;
    }
    
    if (self.willShow) {
        self.willShow(nil);
    }
    
    self.tapGestureRecognizer.enabled = YES;
    self.isShow = YES;
}

-(void) hideTools
{
    if (!self.isShow) {
        return;
    }
    
    
    LC_FAST_ANIMATIONS(0.25, ^{
       
        self.title.viewFrameX = self.viewFrameWidth - self.title.viewFrameWidth - 40 / 3;
        self.title.viewFrameY = 0;
        self.title.alpha = 1;
        
        self.icon.image = [UIImage imageNamed:@"ShareIcon.png" useCache:YES];

        self.icon.viewFrameX = self.title.viewFrameX - self.icon.viewFrameWidth - 5;
        self.icon.viewFrameY = self.viewMidHeight - self.icon.viewMidHeight;
        
    });
    
    
    for (NSInteger i = 0; i < self.shareIcons.count; i++) {
        
        LCUIButton * button = self.shareIcons[i];
        button.pop_springBounciness = 5;
        button.pop_springSpeed = 5;
        button.pop_spring.frame = LC_RECT(self.viewFrameWidth + 20, button.viewFrameY, button.viewFrameWidth, button.viewFrameHeight);
        button.pop_spring.alpha = 0;
    }
    
    if (self.willHide) {
        self.willHide(nil);
    }
    
    self.tapGestureRecognizer.enabled = NO;
    self.isShow = NO;
}

@end
