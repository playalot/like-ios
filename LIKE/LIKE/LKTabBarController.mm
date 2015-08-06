//
//  LKTabBarController.m
//  LIKE
//
//  Created by Leer on 15/4/10.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKTabBarController.h"
#import "AppDelegate.h"
#import "LKLoginViewController.h"
#import "LKAssistiveTouchButton.h"
#import "MMMaterialDesignSpinner.h"
#import "LKCameraRollViewController.h"

@interface LKTabBarController () <RDVTabBarControllerDelegate>

@end

@implementation LKTabBarController

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!self.assistiveTouchButton) {
        
        CGFloat width = 100;
        
        self.assistiveTouchButton = [[LKAssistiveTouchButton alloc] initWithFrame:CGRectMake(LC_DEVICE_WIDTH / 2 - width / 2, LC_DEVICE_HEIGHT + 20 - width, width, width) inView:self.view];
        
        self.view.ADD(self.assistiveTouchButton);
        

        if (LKUserDefaults.singleton[@"LKAssistiveTouchButton"]) {
            
            CGRect frame = CGRectFromString(LKUserDefaults.singleton[@"LKAssistiveTouchButton"]);

            self.assistiveTouchButton.frame = frame;
        }
        
        
        MMMaterialDesignSpinner * tip = [[MMMaterialDesignSpinner alloc] initWithFrame:CGRectZero];
        tip.bounds = CGRectMake(0, 0, 212. / 3. - 4., 212. / 3. - 4.); //LC_RGB(255, 59, 54)
        tip.tintColor = LKColor.color;
        tip.center = LC_POINT(self.assistiveTouchButton.viewMidWidth, self.assistiveTouchButton.viewMidHeight);
        tip.tag = 100;
        tip.translatesAutoresizingMaskIntoConstraints = NO;
        tip.alpha = 0;
        tip.userInteractionEnabled = NO;
        [tip startAnimating];

        self.assistiveTouchButton.ADD(tip);
        
        
        @weakly(self);
        
        self.assistiveTouchButton.touchDown = ^(){
            
            @normally(self);
            
            [self touchDown:tip];
            [self touchDown:self.assistiveTouchButton.view];
        };
        
        self.assistiveTouchButton.touchEnd = ^(){
            
            @normally(self);
            
            [self touchEnd:tip];
            [self touchEnd:self.assistiveTouchButton.view];
        };
        
        self.assistiveTouchButton.didSelected = ^(){
          
            @normally(self);
            
            [self didTap];
        };
    }
    
    [self setTabBarHidden:YES];

    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}


-(instancetype) initWithViewControllers:(NSArray *)viewControllers
{
    if (self = [super init]) {
        
        self.viewControllers = viewControllers;
        self.delegate = self;
    }
    
    return self;
}

-(void) setLoading:(BOOL)loading
{
    _loading = loading;

    MMMaterialDesignSpinner * tip = (MMMaterialDesignSpinner *)[self.assistiveTouchButton viewWithTag:100];

    if (loading) {
        
        // 旋转
        LC_FAST_ANIMATIONS_F(0.25, ^{
        
            tip.alpha = 0.8;
            
        }, ^(BOOL finished){
        
        });
    }
    else{
        
        [UIView animateWithDuration:1 animations:^{
            
            tip.alpha = 0;
            
        } completion:^(BOOL finished) {
            
        }];
    }
}

//-(BOOL) loading
//{
//    return _loading;
//}

-(void) didTap
{
    if(![LKLoginViewController needLoginOnViewController:self]){

        [LCUIApplication presentViewController:LC_UINAVIGATION([LKCameraRollViewController viewController]) animation:YES];
    }
}

-(void) touchDown:(UIView *)button
{
    [@[button] pop_sequenceWithInterval:0 animations:^(UIView *circle, NSInteger index){
        
        button.pop_springBounciness = 10;
        button.pop_springSpeed = 12;
        button.pop_spring.pop_scaleXY = CGPointMake(1.2, 1.2);
        
    } completion:^(BOOL finished){
     

    }];
}

-(void) touchEnd:(UIView *)button
{
    [@[button] pop_sequenceWithInterval:0 animations:^(id object, NSInteger index) {

        button.pop_springBounciness = 10;
        button.pop_springSpeed = 12;
        button.pop_spring.pop_scaleXY = CGPointMake(1, 1);

    } completion:^(BOOL finished) {
        ;
    }];
}

-(void) showBar
{
    LC_FAST_ANIMATIONS(0.15, ^{
        
        self.assistiveTouchButton.alpha = 1;
    });
}

-(void) hideBar
{
    LC_FAST_ANIMATIONS(0.15, ^{
        
        self.assistiveTouchButton.alpha = 0;
    });
}

#pragma mark - 

-(void) $setItemIcon:(NSString *)imageName superView:(UIView *)superView
{
    LCUIImageView * icon = [LCUIImageView viewWithImage:[UIImage imageNamed:imageName useCache:YES]];
    icon.viewFrameX = superView.viewMidWidth - icon.viewMidWidth;
    icon.viewFrameY = superView.viewMidWidth - icon.viewMidHeight;
    superView.ADD(icon);
}

#pragma mark -

+(UIViewController *) hiddenBottomBarWhenPushed:(UIViewController *)viewController
{
    [LC_APPDELEGATE.tabBarController hideBar];
    
    return viewController;
}

@end
