//
//  LKTagItemView.m
//  LIKE
//
//  Created by huangweifeng on 9/24/15.
//  Copyright © 2015 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKTagItemView.h"
#import "LKLoginViewController.h"
#import "LKTagLikeModel.h"

@interface LKTagItemView ()

LC_PROPERTY(assign) BOOL custom;

@end

@implementation LKTagItemView

- (instancetype)init {
    if (self = [super init]) {
        self.cornerRadius = 4;
        self.layer.masksToBounds = NO;
        self.showNumber = YES;
        
        self.tagLabel = LCUILabel.view;
        self.tagLabel.font = LK_FONT(14);
        self.tagLabel.textColor = [UIColor whiteColor];//LC_RGB(74, 74, 74);
        self.ADD(self.tagLabel);
        
        self.lineView = LCUIImageView.view;
        self.ADD(self.lineView);
        
        self.likesLabel = LCUILabel.view;
        self.likesLabel.font = LK_FONT_B(14);
        self.likesLabel.textColor = [UIColor whiteColor];
        self.likesLabel.textAlignment = UITextAlignmentCenter;
        self.likesLabel.layer.shouldRasterize = YES;
        self.ADD(self.likesLabel);
        
        [self addTapGestureRecognizer:self selector:@selector(like)];
    }
    
    return self;
}

- (instancetype)initWithFont:(UIFont *)font {
    if (self == [super init]) {
        self.cornerRadius = 4;
        self.layer.masksToBounds = NO;
        self.showNumber = YES;
        
        self.tagLabel = LCUILabel.view;
        self.tagLabel.font = font;
        self.tagLabel.textColor = [UIColor whiteColor];//LC_RGB(74, 74, 74);
        self.ADD(self.tagLabel);
        
        self.likesLabel = LCUILabel.view;
        self.likesLabel.font = font;
        self.likesLabel.textColor = [UIColor whiteColor];
        self.likesLabel.textAlignment = UITextAlignmentCenter;
        self.likesLabel.layer.shouldRasterize = YES;
        self.ADD(self.likesLabel);
        
        UIView *maskView = UIView.view.COLOR([[UIColor blackColor] colorWithAlphaComponent:0.2]);
        self.backgroundImageView.ADD(maskView);
        self.maskView = maskView;
        
        [self addTapGestureRecognizer:self selector:@selector(like)];
        
    }
    
    return self;
}

- (void)like {
    if (self.custom) {
        if (self.customAction) {
            self.customAction(self);
        }
        return;
    }
    
    if([LKLoginViewController needLoginOnViewController:[LCUIApplication sharedInstance].window.rootViewController]){
        return;
    };
    
    if (self.tagValue.isLiked && self.tagValue.likes.integerValue == 1) {
        
        [LCUIAlertView showWithTitle:LC_LO(@"提醒") message:LC_LO(@"确定要删除这个标签吗？") cancelTitle:LC_LO(@"确定") otherTitle:LC_LO(@"取消") didTouchedBlock:^(NSInteger integerValue) {
            
            if (integerValue == 0) {
                [self likeAction];
            }
        }];
        
        return;
    }
    else{
        
        [self likeAction];
    }
}


-(void) likeAction
{
    @weakly(self);
    
    if (self.willRequest) {
        self.willRequest(self);
    }
    
    if (self.chooseTag) {
        
        if (self.chooseTag.isLiked) {
            
            self.chooseTag.likes = @(self.chooseTag.likes.integerValue - 1);
        }
        else{
            
            self.chooseTag.likes = @(self.chooseTag.likes.integerValue + 1);
        }
        
        self.chooseTag.isLiked = !self.chooseTag.isLiked;
        
        // 新数据重新赋值
        self.chooseTag = self.chooseTag;
    } else {
        
        if (self.tagValue.isLiked) {
            
            self.tagValue.likes = @(self.tagValue.likes.integerValue - 1);
        }
        else{
            
            self.tagValue.likes = @(self.tagValue.likes.integerValue + 1);
        }
        
        self.tagValue.isLiked = !self.tagValue.isLiked;
        
        // 新数据重新赋值
        self.tagValue = self.tagValue;
    }
    
    if (self.tagValue.isLiked) {
    }
    
    self.userInteractionEnabled = NO;
    
    LC_FAST_ANIMATIONS_F(0.15, ^{
        
        self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.2, 1.2);
        
    }, ^(BOOL finished){
        
        LC_FAST_ANIMATIONS_F(0.15, ^{
            
            if (self.chooseTag) {
                
                self.transform = self.chooseTag.likes.integerValue <= 0 ? CGAffineTransformScale(CGAffineTransformIdentity, 0, 0) : CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
            } else {
                
                self.transform = self.tagValue.likes.integerValue <= 0 ? CGAffineTransformScale(CGAffineTransformIdentity, 0, 0) : CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
            }
            
        }, ^(BOOL finished){
            
            self.userInteractionEnabled = YES;
            
            if (self.requestFinished) {
                self.requestFinished(self);
            }
            
            if (self.tagValue.likes.integerValue <= 0) {
                
                if (self.didRemoved) {
                    self.didRemoved(self);
                }
            }
        });
    });
    
    if (self.maskView) {
        
        return;
    }
    
    [LKTagLikeModel likeOrUnLike:self.chooseTag ? self.chooseTag : self.tagValue requestFinished:^(LKHttpRequestResult *result, NSString *error) {
        
        @normally(self);
        
        if (error) {
            
            [self showTopMessageErrorHud:error];
        }
        else{
            
        }
    }];
}


-(void) setTagValue:(LKTag *)tagValue
{
    [self setTagValue:tagValue customTag:nil customCount:nil customLiked:nil];
}

-(void) setTagValue:(LKTag *)tagValue customTag:(NSString *)customTag customCount:(NSString *)customCount customLiked:(NSNumber *)customLiked
{
    if (!tagValue) {
        return;
    }
    
    _tagValue = tagValue;
    
    self.tagLabel.text = customTag ? customTag : tagValue.tag.description;
    self.tagLabel.FIT();
    
    CGFloat tagHeight = self.tagLabel.font.lineHeight;
    CGFloat topPadding = (26 - tagHeight) * 0.5;
    CGFloat leftPadding = 8;
    
    self.tagLabel.viewFrameX = leftPadding;
    //    self.tagLabel.viewFrameY = topPadding + 1.5;
    self.tagLabel.viewFrameY = topPadding;
    
    if (self.showNumber) {
        
        self.lineView.viewFrameHeight = 16;
        self.lineView.viewFrameWidth = 1;
        self.lineView.viewFrameX = self.tagLabel.viewRightX + 6;
        self.lineView.viewFrameY = 5;
        self.lineView.image = [UIImage imageNamed:@"SeparateLine.png" useCache:YES];
        self.likesLabel.text = LC_NSSTRING_FORMAT(@"%@", customCount ? customCount : tagValue.likes);
        self.likesLabel.FIT();
        
        //        self.likesLabel.viewFrameX = self.tagLabel.viewRightX + leftPadding - 2;
        self.likesLabel.viewFrameX = self.lineView.viewRightX + 6;
        //        self.likesLabel.viewFrameY = topPadding / 2. + 1;
        self.likesLabel.viewCenterY = self.tagLabel.viewCenterY;
        //        self.likesLabel.viewFrameHeight = (self.tagLabel.viewFrameHeight + topPadding * 2.) - topPadding;
        self.likesLabel.viewFrameHeight = self.likesLabel.font.lineHeight;
        //        self.likesLabel.viewFrameWidth = self.likesLabel.viewFrameWidth < self.likesLabel.viewFrameHeight ? self.likesLabel.viewFrameHeight + 4 : self.likesLabel.viewFrameWidth + 4;
        CGSize likesLabelSize = [[tagValue.likes stringValue] sizeWithFont:self.likesLabel.font byHeight:self.likesLabel.viewFrameHeight];
        self.likesLabel.viewFrameWidth = likesLabelSize.width;
        //        self.likesLabel.cornerRadius = self.likesLabel.viewMidHeight;
        
        
        //        self.viewFrameWidth = self.likesLabel.viewRightX + topPadding;
        self.viewFrameWidth = self.likesLabel.viewRightX + 8;
        //        self.viewFrameHeight = self.likesLabel.viewBottomY + topPadding;
        self.viewFrameHeight = 26;
    }
    else{
        
        self.viewFrameWidth = self.tagLabel.viewRightX + leftPadding;
        self.viewFrameHeight = self.tagLabel.viewBottomY + topPadding;
    }
    
    
    //    self.cornerRadius = self.viewMidHeight;
    self.cornerRadius = 4;
    self.layer.masksToBounds = NO;
    
    self.custom = customLiked ? YES : NO;
    
    
    //
    if (customLiked ? customLiked.boolValue : tagValue.isLiked) {
        
        self.backgroundColor = [LKColor.color colorWithAlphaComponent:1];
        self.likesLabel.textColor = [UIColor whiteColor];
        //        self.likesLabel.borderColor = [[UIColor whiteColor] colorWithAlphaComponent:0.4];
        self.lineView.image = [UIImage imageNamed:@"SeparateLine_selected.png" useCache:YES];
        self.tagLabel.textColor = [UIColor whiteColor];
        
        if (self.maskView) {
            
            self.backgroundImageView.hidden = YES;
        }
    }
    else{
        
        self.backgroundColor = LC_RGB(229, 229, 229);
        self.likesLabel.textColor = LC_RGB(75, 75, 75);
        self.tagLabel.textColor = LC_RGB(75, 75, 75);
        //        self.likesLabel.borderColor = LC_RGB(220, 215, 209);
        
        if (self.maskView) {
            
            self.tagLabel.textColor = [UIColor whiteColor];
            self.likesLabel.textColor = [UIColor whiteColor];
            self.backgroundImageView.hidden = NO;
        }
    }
    
    self.maskView.frame = self.bounds;
    self.backgroundImageView.layer.cornerRadius = 15;
    self.backgroundImageView.layer.masksToBounds = YES;
}

- (void)setChooseTag:(LKTag *)chooseTag {
    
    if (!chooseTag) {
        return;
    }
    
    _chooseTag = chooseTag;
    
    self.tagLabel.text = chooseTag.tag.description;
    self.tagLabel.FIT();
    
    
    CGFloat topPadding = 5;
    CGFloat leftPadding = 15;
    
    self.tagLabel.viewFrameX = leftPadding;
    self.tagLabel.viewFrameY = topPadding + 1.5;
    
    if (self.showNumber) {
        
        self.likesLabel.text = LC_NSSTRING_FORMAT(@"%@", chooseTag.likes);
        self.likesLabel.FIT();
        
        self.likesLabel.viewFrameX = self.tagLabel.viewRightX + leftPadding - 2;
        self.likesLabel.viewFrameY = topPadding / 2. + 1;
        self.likesLabel.viewFrameHeight = (self.tagLabel.viewFrameHeight + topPadding * 2.) - topPadding;
        self.likesLabel.viewFrameWidth = self.likesLabel.viewFrameWidth < self.likesLabel.viewFrameHeight ? self.likesLabel.viewFrameHeight + 4 : self.likesLabel.viewFrameWidth + 4;
        self.likesLabel.cornerRadius = self.likesLabel.viewMidHeight;
        
        
        self.viewFrameWidth = self.likesLabel.viewRightX + topPadding;
        self.viewFrameHeight = self.likesLabel.viewBottomY + topPadding;
    }
    else{
        
        self.viewFrameWidth = self.tagLabel.viewRightX + leftPadding;
        self.viewFrameHeight = self.tagLabel.viewBottomY + topPadding;
    }
    
    
    //    self.cornerRadius = self.viewMidHeight;
    self.cornerRadius = 4;
    self.layer.masksToBounds = NO;
    self.custom = NO;
    
    //
    if (!chooseTag.isLiked) {
        
        self.backgroundColor = [LKColor.color colorWithAlphaComponent:1];
        self.likesLabel.textColor = [UIColor whiteColor];
        self.likesLabel.borderColor = [[UIColor whiteColor] colorWithAlphaComponent:0.4];
        self.tagLabel.textColor = [UIColor whiteColor];
        
        if (self.maskView) {
            
            self.backgroundImageView.hidden = YES;
        }
    }
    else{
        
        self.backgroundColor = LC_RGB(245, 240, 236);
        self.likesLabel.textColor = [LC_RGB(74, 74, 74) colorWithAlphaComponent:0.9];
        self.tagLabel.textColor = [LC_RGB(74, 74, 74) colorWithAlphaComponent:0.9];
        self.likesLabel.borderColor = LC_RGB(220, 215, 209);
        
        if (self.maskView) {
            
            self.tagLabel.textColor = [UIColor whiteColor];
            self.likesLabel.textColor = [UIColor whiteColor];
            self.backgroundImageView.hidden = NO;
        }
        
    }
    
    self.maskView.frame = self.bounds;
    self.backgroundImageView.layer.cornerRadius = 4;
    self.backgroundImageView.layer.masksToBounds = YES;
    
}

@end
