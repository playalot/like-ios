//
//  Created by 刘超 on 15/4/26.
//  Copyright (c) 2015年 Leo. All rights reserved.
//
//  Email:  leoios@sina.com
//  GitHub: http://github.com/LeoiOS
//  如有问题或建议请给我发Email, 或在该项目的GitHub主页lssues我, 谢谢:)
//

#import "TRActionSheet.h"
#import "LKShare.h"
#import "LKShareTools.h"

// 按钮高度
#define BUTTON_H 49.0f
// 屏幕尺寸
#define SCREEN_SIZE [UIScreen mainScreen].bounds.size
// 颜色
#define LCColor(r, g, b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1.0f]

@interface TRActionSheet () {
    
    /** 所有按钮 */
    NSArray *_buttonTitles;
    
    /** 暗黑色的view */
    UIView *_darkView;
    
    /** 所有按钮的底部view */
    UIView *_bottomView;
    
    /** 代理 */
}
LC_PROPERTY(strong) UIImage *shareImage;

@end

@implementation TRActionSheet

+ (instancetype)sheetWithTitle:(NSString *)title buttonTitles:(NSArray *)titles redButtonIndex:(NSInteger)buttonIndex delegate:(id<TRActionSheetDelegate>)delegate {
    
    return [[self alloc] initWithTitle:title buttonTitles:titles redButtonIndex:buttonIndex delegate:delegate];
}

- (instancetype)initWithTitle:(NSString *)title
                 buttonTitles:(NSArray *)titles
               redButtonIndex:(NSInteger)buttonIndex
                     delegate:(id<TRActionSheetDelegate>)delegate {
    
    if (self = [super init]) {
        
        _delegate = delegate;
        
        // 暗黑色的view
        UIView *darkView = [[UIView alloc] init];
        [darkView setAlpha:0];
        [darkView setUserInteractionEnabled:NO];
        [darkView setFrame:(CGRect){0, 0, SCREEN_SIZE}];
        [darkView setBackgroundColor:LCColor(46, 49, 50)];
        [self addSubview:darkView];
        _darkView = darkView;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss:)];
        [darkView addGestureRecognizer:tap];
        
        // 所有按钮的底部view
        UIView *bottomView = [[UIView alloc] init];
        [bottomView setBackgroundColor:LCColor(214, 214, 222)];
        [self addSubview:bottomView];
        _bottomView = bottomView;
        
        if (title) {
            
            // 标题
            UILabel *label = [[UILabel alloc] init];
            [label setText:title];
            [label setTextColor:LCColor(111, 111, 111)];
            [label setTextAlignment:NSTextAlignmentCenter];
            [label setFont:[UIFont systemFontOfSize:13.0f]];
            [label setBackgroundColor:[UIColor whiteColor]];
            [label setFrame:CGRectMake(0, 0, SCREEN_SIZE.width, BUTTON_H)];
            [bottomView addSubview:label];
        }
        
        if (titles.count) {
            
            _buttonTitles = titles;
            
            for (int i = 0; i < titles.count; i++) {
                
                // 所有按钮
                UIButton *btn = [[UIButton alloc] init];
                [btn setTag:i];
                [btn setBackgroundColor:[UIColor whiteColor]];
                [btn setTitle:titles[i] forState:UIControlStateNormal];
                [[btn titleLabel] setFont:[UIFont systemFontOfSize:16.0f]];
                
                UIColor *titleColor = nil;
                if (i == buttonIndex) {
                    
                    titleColor = LCColor(255, 10, 10);
                    
                } else {
                    
                    titleColor = [UIColor blackColor] ;
                }
                [btn setTitleColor:titleColor forState:UIControlStateNormal];
                
                [btn setBackgroundImage:[UIImage imageNamed:@"bgImage_HL"] forState:UIControlStateHighlighted];
                [btn addTarget:self action:@selector(didClickBtn:) forControlEvents:UIControlEventTouchUpInside];
                
                CGFloat btnY = BUTTON_H * (i + (title ? 1 : 0));
                [btn setFrame:CGRectMake(0, btnY, SCREEN_SIZE.width, BUTTON_H)];
                [bottomView addSubview:btn];
            }
            
            for (int i = 0; i < titles.count; i++) {
                
                // 所有线条
                UIImageView *line = [[UIImageView alloc] init];
                [line setImage:[UIImage imageNamed:@"cellLine"]];
                line.alpha = 0.5;
                [line setContentMode:UIViewContentModeScaleAspectFill];
                CGFloat lineY = (i + (title ? 1 : 0)) * BUTTON_H;
                [line setFrame:CGRectMake(0, lineY, SCREEN_SIZE.width, 1.0f)];
                [bottomView addSubview:line];
            }
        }
        
        // 取消按钮
        UIButton *cancelBtn = [[UIButton alloc] init];
        [cancelBtn setTag:titles.count];
        [cancelBtn setBackgroundColor:[UIColor whiteColor]];
        [cancelBtn setTitle:LC_LO(@"取消") forState:UIControlStateNormal];
        [[cancelBtn titleLabel] setFont:[UIFont systemFontOfSize:16.0f]];
        [cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [cancelBtn setBackgroundImage:[UIImage imageNamed:@"bgImage_HL"] forState:UIControlStateHighlighted];
        [cancelBtn addTarget:self action:@selector(didClickCancelBtn) forControlEvents:UIControlEventTouchUpInside];
        
        CGFloat btnY = BUTTON_H * (titles.count + (title ? 1 : 0)) + 5.0f;
        [cancelBtn setFrame:CGRectMake(0, btnY, SCREEN_SIZE.width, BUTTON_H)];
        [bottomView addSubview:cancelBtn];
        
        CGFloat bottomH = (title ? BUTTON_H : 0) + BUTTON_H * titles.count + BUTTON_H + 5.0f;
        [bottomView setFrame:CGRectMake(0, SCREEN_SIZE.height, SCREEN_SIZE.width, bottomH)];
        
        [self setFrame:(CGRect){0, 0, SCREEN_SIZE}];
        [[UIApplication sharedApplication].keyWindow addSubview:self];
    }
    
    return self;
}

- (instancetype)initWithTitle:(NSString *)title buttonTitles:(NSArray *)titles shareTitles:(NSArray *)shareTitles shareImage:(UIImage *)shareImage redButtonIndex:(NSInteger)buttonIndex delegate:(id<TRActionSheetDelegate>)delegate {
    
    if (self = [super init]) {
        
        _delegate = delegate;
        
        self.shareImage = shareImage;
        
        // 暗黑色的view
        UIView *darkView = [[UIView alloc] init];
        [darkView setAlpha:0];
        [darkView setUserInteractionEnabled:NO];
        [darkView setFrame:(CGRect){0, 0, SCREEN_SIZE}];
        [darkView setBackgroundColor:LCColor(46, 49, 50)];
        [self addSubview:darkView];
        _darkView = darkView;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss:)];
        [darkView addGestureRecognizer:tap];
        
        // 所有按钮的底部view
        UIView *bottomView = [[UIView alloc] init];
        [bottomView setBackgroundColor:[UIColor whiteColor]];
        [self addSubview:bottomView];
        _bottomView = bottomView;
        
        if (title) {
            
            // 标题
            UILabel *label = [[UILabel alloc] init];
            [label setText:title];
            [label setTextColor:LC_RGB(75, 75, 75)];
            [label setTextAlignment:NSTextAlignmentCenter];
            [label setFont:[UIFont systemFontOfSize:14.0f]];
            [label setBackgroundColor:[UIColor whiteColor]];
            [label setFrame:CGRectMake(0, 12, SCREEN_SIZE.width, BUTTON_H)];
            label.viewFrameHeight = label.font.lineHeight;
            [bottomView addSubview:label];

            NSArray *shareImageNames = @[@"WeChatFriendShare.png",
                                         @"WeChatFeedShare.png",
                                         @"QQShare.png",
                                         @"WeiboShare.png"];
            CGFloat margin = (LC_DEVICE_WIDTH - 33 * 2 - 48 * 4) / 3.0;
            
            for (NSInteger i = 0; i < shareTitles.count; i++) {
                
                LCUIButton *shareButton = LCUIButton.view;
                shareButton.viewFrameWidth = 48;
                shareButton.viewFrameHeight = 48;
                shareButton.buttonImage = [UIImage imageNamed:shareImageNames[i] useCache:YES];
                shareButton.viewFrameX = 33 + i * (margin + 48);
                shareButton.viewFrameY = label.viewBottomY + 10;
                shareButton.tag = i + 5000;
                [shareButton addTarget:self action:@selector(shareIconTapAction:) forControlEvents:UIControlEventTouchUpInside];
                bottomView.ADD(shareButton);
                
                LCUILabel *shareLabel = LCUILabel.view;
                shareLabel.font = LK_FONT(10);
                shareLabel.textColor = LC_RGB(75, 75, 75);
                shareLabel.textAlignment = UITextAlignmentCenter;
                shareLabel.viewFrameWidth = 48;
                shareLabel.viewFrameHeight = shareLabel.font.lineHeight;
                shareLabel.text = LC_LO(shareTitles[i]);
                shareLabel.viewFrameX = shareButton.viewFrameX;
                shareLabel.viewFrameY = shareButton.viewBottomY + 4;
                bottomView.ADD(shareLabel);
            }
        }
        
        
        if (titles.count) {
            
            _buttonTitles = titles;
            
            for (int i = 0; i < titles.count; i++) {
                
                // 所有按钮
                UIButton *btn = [[UIButton alloc] init];
                btn.cornerRadius = 4;
                [btn setTag:i];
                [btn setBackgroundColor:LC_RGB(238, 238, 238)];
                [btn setTitle:titles[i] forState:UIControlStateNormal];
                [[btn titleLabel] setFont:[UIFont systemFontOfSize:14.0f]];
                
                UIColor *titleColor = nil;
                if (i == buttonIndex) {
                    
                    titleColor = LCColor(255, 10, 10);
                    
                } else {
                    
                    titleColor = LC_RGB(75, 75, 75);
                }
                [btn setTitleColor:titleColor forState:UIControlStateNormal];
                
//                [btn setBackgroundImage:[UIImage imageNamed:@"bgImage_HL"] forState:UIControlStateHighlighted];
                [btn addTarget:self action:@selector(didClickBtn:) forControlEvents:UIControlEventTouchUpInside];
                
                CGFloat btnY = BUTTON_H * (i + (title ? 1 : 0)) + (title ? 60 : 0);
                [btn setFrame:CGRectMake(33, btnY + 7, SCREEN_SIZE.width - 66, BUTTON_H - 7)];
                [bottomView addSubview:btn];
            }
        
//            for (int i = 0; i < titles.count; i++) {
//                
//                // 所有线条
//                UIImageView *line = [[UIImageView alloc] init];
//                [line setImage:[UIImage imageNamed:@"cellLine"]];
//                [line setContentMode:UIViewContentModeScaleAspectFill];
//                CGFloat lineY = (i + (title ? 1 : 0)) * BUTTON_H + (title ? 60 : 0);
//                [line setFrame:CGRectMake(0, lineY, SCREEN_SIZE.width, 1.0f)];
//                [bottomView addSubview:line];
//            }
        }
        
        // 取消按钮
        UIButton *cancelBtn = [[UIButton alloc] init];
        cancelBtn.cornerRadius = 4;
        [cancelBtn setTag:titles.count];
        [cancelBtn setBackgroundColor:LKColor.color];
        [cancelBtn setTitle:LC_LO(@"取 消") forState:UIControlStateNormal];
        [[cancelBtn titleLabel] setFont:[UIFont systemFontOfSize:14.0f]];
        [cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//        [cancelBtn setBackgroundImage:[UIImage imageNamed:@"bgImage_HL"] forState:UIControlStateHighlighted];
        [cancelBtn addTarget:self action:@selector(didClickCancelBtn) forControlEvents:UIControlEventTouchUpInside];
        
        CGFloat btnY = BUTTON_H * (titles.count + (title ? 1 : 0)) + 7.0f + (title ? 60 : 0);
        [cancelBtn setFrame:CGRectMake(33, btnY, SCREEN_SIZE.width - 66, BUTTON_H - 7)];
        [bottomView addSubview:cancelBtn];
        
        CGFloat bottomH = (title ? BUTTON_H + 60 : 0) + BUTTON_H * titles.count + BUTTON_H + 5.0f;
        [bottomView setFrame:CGRectMake(0, SCREEN_SIZE.height, SCREEN_SIZE.width, bottomH + 15)];
        
        [self setFrame:(CGRect){0, 0, SCREEN_SIZE}];
        [[UIApplication sharedApplication].keyWindow addSubview:self];
    }
    
    return self;
}

- (void)shareIconTapAction:(UIButton *)button {
    
    [LKShare shareImageWithType:(button.tag - 5000) image:self.shareImage];
    [self dismiss:nil];
}

- (void)didClickBtn:(UIButton *)btn {
    
    [self dismiss:nil];
    
    if ([_delegate respondsToSelector:@selector(actionSheet:didClickedButtonAtIndex:)]) {
        
        [_delegate actionSheet:self didClickedButtonAtIndex:btn.tag];
    }
}

- (void)dismiss:(UITapGestureRecognizer *)tap {
    
    [UIView animateWithDuration:0.3f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         
                         [_darkView setAlpha:0];
                         [_darkView setUserInteractionEnabled:NO];
                         
                         CGRect frame = _bottomView.frame;
                         frame.origin.y += frame.size.height;
                         [_bottomView setFrame:frame];
                         
                     } completion:^(BOOL finished) {
                         
                         [self removeFromSuperview];
                     }];
}

- (void)didClickCancelBtn {
    
    [UIView animateWithDuration:0.3f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         
                         [_darkView setAlpha:0];
                         [_darkView setUserInteractionEnabled:NO];
                         
                         CGRect frame = _bottomView.frame;
                         frame.origin.y += frame.size.height;
                         [_bottomView setFrame:frame];
                         
                     } completion:^(BOOL finished) {
                         
                         [self removeFromSuperview];
                         
                         if ([_delegate respondsToSelector:@selector(actionSheet:didClickedButtonAtIndex:)]) {
                             
                             [_delegate actionSheet:self didClickedButtonAtIndex:_buttonTitles.count];
                         }
                     }];
}

- (void)show {
    
    [UIView animateWithDuration:0.35 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:3 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        [_darkView setAlpha:0.4f];
        [_darkView setUserInteractionEnabled:YES];
        
        CGRect frame = _bottomView.frame;
        frame.origin.y -= frame.size.height;
        [_bottomView setFrame:frame];

        
    } completion:^(BOOL finished) {
        
    }];

    
//    [UIView animateWithDuration:0.3f
//                          delay:0
//                        options:UIViewAnimationOptionCurveEaseOut
//                     animations:^{
//                         
//                         
//                     } completion:nil];
}

@end
