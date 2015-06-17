//
//  LKInputTextViewController.m
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/4/24.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKInputTextViewController.h"

@interface LKInputTextViewController ()

LC_PROPERTY(strong) LCUITextView * textView;

@end

@implementation LKInputTextViewController

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:[LKColor.color colorWithAlphaComponent:1] andSize:LC_SIZE(LC_DEVICE_WIDTH, 64)] forBarMetrics:UIBarMetricsDefault];
    
    [self setNavigationBarHidden:NO animated:animated];
    
    [self.textView becomeFirstResponder];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.textView resignFirstResponder];
}

-(void) buildUI
{
    self.title = @"意见与建议";
    
    [self setNavigationBarButton:LCUINavigationBarButtonTypeLeft image:[UIImage imageNamed:@"NavigationBarBack.png" useCache:YES] selectImage:nil];
    [self setNavigationBarButton:LCUINavigationBarButtonTypeRight title:@"完成" titleColor:[UIColor whiteColor]];

    
    self.view.backgroundColor = LKColor.backgroundColor;
    
    self.textView = LCUITextView.view;
    self.textView.viewFrameY = 20;
    self.textView.viewFrameWidth = LC_DEVICE_WIDTH;
    self.textView.viewFrameHeight = 250;
    self.textView.font = LK_FONT(15);
    self.textView.textColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    self.view.ADD(self.textView);
}

-(void) handleNavigationBarButton:(LCUINavigationBarButtonType)type
{
    if (type == LCUINavigationBarButtonTypeLeft) {
        
        [self dismissOrPopViewController];
    }
    else{
        
        if (self.textView.text.length && self.inputFinished) {
            
            self.inputFinished(self.textView.text);
            
            [self dismissOrPopViewController];
        }
    }
}



@end
