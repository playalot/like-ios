//
//  LKChooseTagView.m
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/9/7.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKChooseTagView.h"
#import "LKHomeHeader.h"
#import "LKTagsView.h"
#import "LKSettingsViewController.h"
#import "LKUploadAvatarAndCoverModel.h"
#import "LKChooseTag.h"

@interface LKChooseTagView ()

@property (weak, nonatomic) IBOutlet LCUIButton *headIcon;
@property (weak, nonatomic) IBOutlet UIButton *editBtn;
@property (weak, nonatomic) IBOutlet UIButton *editImg;
@property (weak, nonatomic) IBOutlet UILabel *slogan;
@property (weak, nonatomic) IBOutlet UIButton *enterBtn;
LC_PROPERTY(strong) UIScrollView *tagsView;
LC_PROPERTY(strong) LKSettingsViewController *settings;

@end

@implementation LKChooseTagView

- (IBAction)headIconClick:(id)sender {
    
    [UIView animateWithDuration:1 animations:^{
       
//        self.alpha = 0;
    }];

    @weakly(self);
    
    [LKUploadAvatarAndCoverModel chooseAvatorImage:^(NSString *error, UIImage *resultImage) {
        
        @normally(self);
        
        if (!error) {
            
            [self.headIcon setImage:resultImage forState:UIControlStateNormal];
            [self setNeedsDisplay];

            [UIView animateWithDuration:1.0 animations:^{
                
                self.alpha = 1;
            }];

        }
        else{
            
            [self showTopMessageErrorHud:error];
        }
    }];
}

- (IBAction)editUserInfo:(UIButton *)sender {
    
    [UIView animateWithDuration:0.25 animations:^{
       
        self.settings.transform = CGAffineTransformMakeTranslation(0, - (LC_DEVICE_HEIGHT + 20));
    } completion:^(BOOL finished) {
        
    }];
}

- (IBAction)enterLike:(UIButton *)sender {
    
    NSMutableArray *idArray = [NSMutableArray array];
    NSMutableArray *groupArray = [NSMutableArray array];
    for (LKTagItem *item in self.tagsView.subviews) {
        
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
            
            
        }
    }];
    
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    if (self = [super initWithCoder:aDecoder]) {
        
        // 添加scrollView
        UIScrollView *tagsView = [[UIScrollView alloc] init];
        tagsView.showsVerticalScrollIndicator = NO;
        self.tagsView = tagsView;
        self.ADD(tagsView);
        
        // 设置页面
        LKSettingsViewController *settings = LKSettingsViewController.view;
        self.settings = settings;
        settings.frame = CGRectMake(0, LC_DEVICE_HEIGHT + 20, LC_DEVICE_WIDTH, LC_DEVICE_HEIGHT + 20);
        self.ADD(settings);
    }
    return self;
}

+ (instancetype)chooseTagView {
    
    return [[[NSBundle mainBundle] loadNibNamed:@"LKChooseTagView" owner:nil options:nil] lastObject];
}

- (void)layoutSubviews {
    
    self.frame = CGRectMake(0, 0, LC_DEVICE_WIDTH, LC_DEVICE_HEIGHT + 20);
    self.tagsView.viewFrameWidth = 200;
    self.tagsView.viewFrameY = CGRectGetMaxY(self.slogan.frame) + 10;
//    self.tagsView.viewFrameHeight = self.enterBtn.viewFrameY - self.tagsView.viewFrameY - 10;
    self.tagsView.viewFrameHeight = LC_DEVICE_HEIGHT - 70 - self.tagsView.viewFrameY;
    self.tagsView.viewCenterX = LC_DEVICE_WIDTH * 0.5;
    
    self.slogan.viewFrameY = 70;
    
    // 发送网络请求,在scrollView中添加标签
    [self sendNetworkRequest];
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
        
        LKTagItem *item = [[LKTagItem alloc] initWithFont:LK_FONT_B(14)];
        
        item.chooseTag = tags[i];
        [self.tagsView addSubview:item];
        item.backgroundImageView.url = (NSString *)[tags[i] image];


        CGFloat margin = 10;
        item.viewFrameWidth = CGRectGetMaxX(item.likesLabel.frame) + 2;
        item.viewFrameX = 2 * margin + arc4random_uniform(self.tagsView.viewFrameWidth - item.viewFrameWidth - 3 * margin);
        item.viewFrameHeight = 31;
        item.viewFrameY = (i + 1) * margin + i * item.viewFrameHeight;
        
        maxItemY = item.viewFrameY;
        
        
        item.tagLabel.textColor = [UIColor whiteColor];
        item.likesLabel.textColor = [UIColor whiteColor];
    }
    
    self.tagsView.contentSize = CGSizeMake(0, maxItemY + 31 + 10);
}

@end
