//
//  LKHomeHeader.m
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/7/20.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKHomeHeader.h"
#import "LCBlurSearchBar.h"
#import "FXBlurView.h"
#import "LKSearchBar.h"
#import "LKLoginViewController.h"

#define kDefaultHeaderFrame CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)

static CGFloat kParallaxDeltaFactor = 0.5f;

@interface LKHomeHeader ()

LC_PROPERTY(strong) UIScrollView * scrollView;

LC_PROPERTY(strong) LCUIButton * searchTip;
LC_PROPERTY(strong) LCUIButton * doneButton;

@end

@implementation LKHomeHeader

- (instancetype)initWithCGSize:(CGSize)size
{
    if (self = [super initWithFrame:CGRectMake(0, 0, size.width, size.height)]) {
        
        [self buildUI];
    }
    
    return self;
}

- (void) buildUI
{
    [self addTapGestureRecognizer:self selector:@selector(backgroundViewTapAction)];

    
    self.scrollView = [UIScrollView viewWithFrame:self.bounds];
    self.scrollView.userInteractionEnabled = YES;
    self.scrollView.scrollsToTop = NO;
    self.ADD(self.scrollView);
    
    
    self.backgroundView = LCUIImageView.view;
    self.backgroundView.frame = self.scrollView.bounds;
    self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.backgroundView.contentMode = UIViewContentModeScaleAspectFill;
    self.backgroundView.userInteractionEnabled = YES;
    self.backgroundView.autoMask = YES;
    self.scrollView.ADD(self.backgroundView);
    
    
    
//    if (IOS8_OR_LATER) {
//        
//        self.blurView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
//        self.blurView.frame = CGRectMake(5, 5, self.viewFrameWidth - 10, 30);
//        UIView * view = UIView.view.COLOR([[UIColor whiteColor] colorWithAlphaComponent:0.35]);
//        view.frame = self.blurView.bounds;
//        self.blurView.ADD(view);
//    }
//    else{
    
        self.blurView = [[FXBlurView alloc] initWithFrame:CGRectMake(5, 5, self.viewFrameWidth - 10, 30)];
        ((FXBlurView *)self.blurView).blurRadius = 10;
//    }
    
    self.blurView.tintColor = [[UIColor whiteColor] colorWithAlphaComponent:0.15];
    self.blurView.cornerRadius = 4;
    self.blurView.layer.masksToBounds = YES;
    self.ADD(self.blurView);
    
    
    UIImage * searchIcon = [[[UIImage imageNamed:@"SearchIcon.png" useCache:YES] imageWithTintColor:[[UIColor blackColor] colorWithAlphaComponent:0.35]] scaleToWidth:20];
    
    self.searchTip = LCUIButton.view;
    self.searchTip.frame = self.blurView.frame;
    self.searchTip.titleFont = LK_FONT(12);
    self.searchTip.titleColor = [[UIColor blackColor] colorWithAlphaComponent:0.35];
    self.searchTip.title = LC_LO(@"  发现更多有趣内容");
    self.searchTip.buttonImage = searchIcon;
    [self.searchTip addTarget:self action:@selector(beginSearch) forControlEvents:UIControlEventTouchUpInside];
    self.ADD(self.searchTip);

    
    self.textField = [[LKSearchBar alloc] initWithFrame:self.searchTip.frame];
    self.textField.frame = self.searchTip.frame;
    self.textField.alpha = 0;
    self.ADD(self.textField);
    
    
//    UIView * view = UIView.view;
//    view.frame = CGRectMake(0, 0, self.viewFrameWidth, 1500);
//    view.viewCenterY = self.scrollView.viewMidHeight;
//    view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.05];
//    self.scrollView.ADD(view);
    
    
    self.doneButton = LCUIButton.view;
    self.doneButton.viewFrameX = self.viewFrameWidth;
    self.doneButton.viewFrameWidth = 55;
    self.doneButton.viewFrameHeight = 50;
    self.doneButton.titleColor = [UIColor whiteColor];
    self.doneButton.title = LC_LO(@"完成");
    self.doneButton.titleFont = LK_FONT_B(14);
    self.doneButton.showsTouchWhenHighlighted = YES;
    [self.doneButton addTarget:self action:@selector(endSearch) forControlEvents:UIControlEventTouchUpInside];
    self.ADD(self.doneButton);
    
    
    self.headImageView = LCUIImageView.view;
    self.headImageView.viewFrameHeight = 50;
    self.headImageView.viewFrameWidth = 50;
    self.headImageView.viewFrameX = 40;
    self.headImageView.viewFrameY = (self.viewFrameHeight - 40) / 2 - self.headImageView.viewMidHeight + 40;
    self.headImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.headImageView.cornerRadius =  self.headImageView.viewMidHeight;
    self.headImageView.borderWidth = 2;
    self.headImageView.borderColor = [UIColor whiteColor];
    self.headImageView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.4];
    self.headImageView.userInteractionEnabled = YES;
    [self.headImageView addTapGestureRecognizer:self selector:@selector(userHeadTapAction)];
    self.ADD(self.headImageView);
    
    
    self.nameLabel = LCUILabel.view;
    self.nameLabel.viewFrameX = self.headImageView.viewRightX + 20;
    self.nameLabel.viewFrameY = self.headImageView.viewFrameY;
    self.nameLabel.viewFrameWidth = self.viewFrameWidth - self.nameLabel.viewFrameX - 20;
    self.nameLabel.viewFrameHeight = self.headImageView.viewFrameHeight;
    self.nameLabel.font = LK_FONT_B(13);
    self.nameLabel.textColor = [UIColor whiteColor];
    self.nameLabel.numberOfLines = 0;
    self.nameLabel.text = [NSString stringWithFormat:@"%@\n%@ likes",LKLocalUser.singleton.user.name, @(LKLocalUser.singleton.user.likes.integerValue)];
    self.ADD(self.nameLabel);
}

-(void) backgroundViewTapAction
{
    if (self.backgroundAction) {
        self.backgroundAction(nil);
    }
}

-(void) setSearchViewController:(LKSearchViewController *)searchViewController
{
    _searchViewController = searchViewController;
    
    self.textField.delegate = searchViewController;
}

-(void) beginSearch
{
    if([LKLoginViewController needLoginOnViewController:[LCUIApplication sharedInstance].window.rootViewController]){
       
        return;
    }
    
    if ([self.blurView respondsToSelector:@selector(setDynamic:)]) {
        
        ((FXBlurView *)self.blurView).dynamic = NO;
    }
    
    LC_FAST_ANIMATIONS_F(0.1, ^{
       
        self.textField.alpha = 1;


    }, ^(BOOL finished){
        
        if (self.willBeginSearch) {
            self.willBeginSearch(nil);
        }
        
        LC_FAST_ANIMATIONS(0.2, ^{
           
            self.headImageView.alpha = 0;
            self.nameLabel.alpha = 0;
        });
        
        LC_FAST_ANIMATIONS(0.25, ^{
           
            self.textField.viewFrameWidth = self.viewFrameWidth - self.doneButton.viewFrameWidth - 10;
            self.blurView.viewFrameWidth = self.textField.viewFrameWidth;
            self.searchTip.viewFrameWidth = self.textField.viewFrameWidth;
            self.doneButton.viewFrameX = self.viewFrameWidth - self.doneButton.viewFrameWidth;
            
            
            self.blurView.viewFrameY = self.viewFrameHeight - self.blurView.viewFrameHeight - 10;
            self.searchTip.viewFrameY = self.blurView.viewFrameY;
            self.textField.viewFrameY = self.blurView.viewFrameY;
            self.doneButton.viewFrameY = self.viewFrameHeight - self.doneButton.viewFrameHeight;
            

        });
    });
}

-(void) endSearch
{
    if (self.searchViewController.placeholderView.alpha != 0) {
        
        LC_FAST_ANIMATIONS(0.25, ^{
            
            self.searchViewController.placeholderView.alpha = 0;
            self.searchViewController.placeholderView.searchString = @"";
            self.searchViewController.placeholderView.tags = nil;
            self.textField.searchField.text = @"";
            [self.textField.searchField resignFirstResponder];
        });
        
        return;
    }

    if (self.willEndSearch) {
        self.willEndSearch(nil);
    }
    
    if ([self.blurView respondsToSelector:@selector(setDynamic:)]) {
        
        ((FXBlurView *)self.blurView).dynamic = YES;
    }
    
    LC_FAST_ANIMATIONS_F(0.25, ^{
        
        self.textField.viewFrameWidth = self.viewFrameWidth - 10;
        self.blurView.viewFrameWidth = self.textField.viewFrameWidth;
        self.searchTip.viewFrameWidth = self.textField.viewFrameWidth;
        self.doneButton.viewFrameX = self.viewFrameWidth;
        
        self.blurView.viewFrameY = 5;
        self.searchTip.viewFrameY = self.blurView.viewFrameY;
        self.textField.viewFrameY = self.blurView.viewFrameY;
        self.doneButton.viewFrameY = 0;

        
    }, ^(BOOL finished){

    });
    
    LC_FAST_ANIMATIONS(0.5, ^{
        
        self.textField.alpha = 0;
        
    });
    
    LC_FAST_ANIMATIONS(0.2, ^{
        
        self.headImageView.alpha = 1;
        self.nameLabel.alpha = 1;
    });
}

- (void)layoutHeaderViewForScrollViewOffset:(CGPoint)offset
{
    CGRect frame = self.scrollView.frame;
    
    if (offset.y > 0){
        
        frame.origin.y = MAX(offset.y *kParallaxDeltaFactor, 0);
        self.scrollView.frame = frame;
        self.clipsToBounds = YES;
    }
    else
    {
        CGFloat delta = 0.0f;
        CGRect rect = kDefaultHeaderFrame;
        delta = fabs(MIN(0.0f, offset.y));
        rect.origin.y -= delta;
        rect.size.height += delta;
        self.scrollView.frame = rect;
        self.clipsToBounds = NO;
    }
}


-(void) updateWithUser:(LKUser *)user
{
    if (user) {
        
        self.user = user;
        
        self.nameLabel.text = [NSString stringWithFormat:@"%@\n%@ likes",LKLocalUser.singleton.user.name, @(LKLocalUser.singleton.user.likes.integerValue)];
        self.headImageView.url = user.avatar;
        
        if (!LC_NSSTRING_IS_INVALID(user.cover)) {
            
            CATransition * animation = [CATransition animation];
            [animation setDuration:0.15];
            [animation setType:kCATransitionFade];
            [self.backgroundView.layer addAnimation:animation forKey:@"transition"];
            
            self.backgroundView.url = user.cover;
        }
        else{
            
            self.backgroundView.url = @"http://cdn.likeorz.com/default_cover.jpg?imageView2/1/w/750/h/750/q/85";
        }
    }
    else{
        
        self.nameLabel.text = LC_LO(@"游客");
        self.headImageView.url = @"http://cdn.likeorz.com/default_avatar.jpg?imageView2/1/w/120/h/120/q/100";
        self.backgroundView.url = @"http://cdn.likeorz.com/default_cover.jpg?imageView2/1/w/750/h/750/q/85";
    }
}

-(void) userHeadTapAction
{
    if (self.headAction) {
        self.headAction(self.headImageView);
    }
}

@end
