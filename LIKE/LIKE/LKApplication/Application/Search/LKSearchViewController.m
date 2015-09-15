//
//  LKSearchViewController.m
//  LIKE
//
//  Created by huangweifeng on 9/13/15.
//  Copyright (c) 2015 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKSearchViewController.h"
#import "LKSearchView.h"
#import "FXBlurView.h"

@interface LKSearchViewController ()

LC_PROPERTY(strong) UIView *topBarSearchView;
LC_PROPERTY(strong) UIView * blurView;
LC_PROPERTY(strong) LCUIButton * searchTip;
LC_PROPERTY(strong) LKSearchBar * searchBar;
LC_PROPERTY(strong) LCUIButton * doneButton;
LC_PROPERTY(strong) LKSearchView * searchView;

@end

@implementation LKSearchViewController

- (void)buildUI {
    self.view.backgroundColor = [LKColor backgroundColor];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:LKColor.color andSize:CGSizeMake(LC_DEVICE_WIDTH, 64)] forBarMetrics:UIBarMetricsDefault];
    
    self.topBarSearchView = UIView.view;
    self.topBarSearchView.backgroundColor = [UIColor clearColor];
    self.topBarSearchView.frame = self.navigationController.navigationBar.frame;
    
    if (IOS8_OR_LATER) {
        
        self.blurView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
        self.blurView.frame = CGRectMake(5, 5, self.topBarSearchView.viewFrameWidth - 10, 30);
        self.blurView.cornerRadius = 4;
        self.blurView.layer.shouldRasterize = NO;
        self.blurView.layer.rasterizationScale = 1;
        
        UIView * view = UIView.view.COLOR([[UIColor whiteColor] colorWithAlphaComponent:0.15]);
        view.frame = self.blurView.bounds;
        ((UIVisualEffectView *)self.blurView).contentView.ADD(view);
    }
    else{
        
        self.blurView = [[FXBlurView alloc] initWithFrame:CGRectMake(5, 5, self.topBarSearchView.viewFrameWidth - 10, 30)];
        ((FXBlurView *)self.blurView).blurRadius = 10;
        self.blurView.cornerRadius = 4;
    }
    
    self.blurView.tintColor = [[UIColor whiteColor] colorWithAlphaComponent:0.15];
    self.blurView.layer.masksToBounds = YES;
    self.topBarSearchView.ADD(self.blurView);
    
    UIImage * searchIcon = [[[UIImage imageNamed:@"SearchIcon.png" useCache:YES] imageWithTintColor:[[UIColor blackColor] colorWithAlphaComponent:0.35]] scaleToWidth:20];
    
    self.searchTip = LCUIButton.view;
    self.searchTip.frame = self.blurView.frame;
    self.searchTip.titleFont = LK_FONT(12);
    self.searchTip.titleColor = [[UIColor blackColor] colorWithAlphaComponent:0.35];
    self.searchTip.title = LC_LO(@"  发现更多有趣内容");
    self.searchTip.buttonImage = searchIcon;
    self.searchTip.titleEdgeInsets = UIEdgeInsetsMake(2, 0, 0, 0);
    [self.searchTip addTarget:self action:@selector(beginSearch) forControlEvents:UIControlEventTouchUpInside];
    self.topBarSearchView.ADD(self.searchTip);
    
    CGRect searchBarFrame = CGRectMake(5, 5, self.view.viewFrameWidth - 10, 30);
    self.searchBar = [[LKSearchBar alloc] initWithFrame:searchBarFrame];
    self.searchBar.frame = searchBarFrame;
    self.searchBar.backgroundColor = [UIColor redColor];
    self.searchBar.alpha = 1;
    self.topBarSearchView.ADD(self.searchBar);
    
    self.doneButton = LCUIButton.view;
    self.doneButton.viewFrameX = self.topBarSearchView.viewFrameWidth;
    self.doneButton.viewFrameWidth = 55;
    self.doneButton.viewFrameHeight = 50;
    self.doneButton.titleColor = [UIColor whiteColor];
    self.doneButton.title = LC_LO(@"完成");
    self.doneButton.titleFont = LK_FONT_B(14);
    self.doneButton.showsTouchWhenHighlighted = YES;
    [self.doneButton addTarget:self action:@selector(endSearch) forControlEvents:UIControlEventTouchUpInside];
    self.topBarSearchView.ADD(self.doneButton);
    
    self.navigationController.navigationBar.topItem.titleView = self.topBarSearchView;
    
    self.searchView = LKSearchView.view;
    self.searchView.parentViewController = self;
    self.view.ADD(self.searchView);
    
    self.searchBar.delegate = self.searchView;
}

-(void) beginSearch {
    
    if ([self.blurView respondsToSelector:@selector(setDynamic:)]) {
        ((FXBlurView *)self.blurView).dynamic = NO;
    }
    
    LC_FAST_ANIMATIONS_F(0.1, ^{
        
        self.searchBar.alpha = 1;
        
        
    }, ^(BOOL finished){
        
        LC_FAST_ANIMATIONS(UINavigationControllerHideShowBarDuration, ^{
            
            self.searchBar.viewFrameWidth = self.topBarSearchView.viewFrameWidth - self.doneButton.viewFrameWidth - 10;
            self.blurView.viewFrameWidth = self.searchBar.viewFrameWidth;
            self.searchTip.viewFrameWidth = self.searchBar.viewFrameWidth;
            self.doneButton.viewFrameX = self.topBarSearchView.viewFrameWidth - self.doneButton.viewFrameWidth;
            
            self.blurView.viewFrameY = self.topBarSearchView.viewFrameHeight - self.blurView.viewFrameHeight - 10;
            self.searchTip.viewFrameY = self.blurView.viewFrameY;
            self.searchBar.viewFrameY = self.blurView.viewFrameY;
            self.doneButton.viewFrameY = self.topBarSearchView.viewFrameHeight - self.doneButton.viewFrameHeight;
            
        });
    });
}

-(void) endSearch
{
//    if (self.searchViewController.placeholderView.alpha != 0) {
//        
//        LC_FAST_ANIMATIONS(UINavigationControllerHideShowBarDuration, ^{
//            
//            self.searchViewController.placeholderView.alpha = 0;
//            self.searchViewController.placeholderView.searchString = @"";
//            self.searchViewController.placeholderView.tags = nil;
//            self.searchBar.searchField.text = @"";
//            [self.searchBar.searchField resignFirstResponder];
//        });
//        
//        return;
//    }
//    
//    if ([self.blurView respondsToSelector:@selector(setDynamic:)]) {
//        
//        ((FXBlurView *)self.blurView).dynamic = YES;
//    }
//    
//    LC_FAST_ANIMATIONS_F(UINavigationControllerHideShowBarDuration, ^{
//        
//        self.searchBar.viewFrameWidth = self.topBarSearchView.viewFrameWidth - 10;
//        self.blurView.viewFrameWidth = self.searchBar.viewFrameWidth;
//        self.searchTip.viewFrameWidth = self.searchBar.viewFrameWidth;
//        self.doneButton.viewFrameX = self.topBarSearchView.viewFrameWidth;
//        
//        self.blurView.viewFrameY = 5;
//        self.searchTip.viewFrameY = self.blurView.viewFrameY;
//        self.searchBar.viewFrameY = self.blurView.viewFrameY;
//        self.doneButton.viewFrameY = 0;
//        
//        
//    }, ^(BOOL finished){
//        
//    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
