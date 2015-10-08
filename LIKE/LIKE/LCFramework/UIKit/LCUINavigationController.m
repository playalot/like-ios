//
//  LC_UINavigationController.m
//  LCFramework

//  Created by Licheng Guo . ( SUGGESTIONS & BUG titm@tom.com ) on 13-9-17.
//  Copyright (c) 2014年 Licheng Guo iOS developer ( http://nsobject.me ).All rights reserved.
//  Also see the copyright page ( http://nsobject.me/copyright.rtf ).
//
//

#import "LCUINavigationController.h"
#import "UINavigationController+PopOnSwipeRight.h"

#pragma mark -

@interface LCUINavigationController () 

@end

#pragma mark -

@implementation LCUINavigationController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:(BOOL)animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.distanceToDrag = 145;
    self.numberOfTouches = 1;

    [self setBarTitleTextColor:LC_UINAVIGATIONBAR_DEFAULT_TITLE_COLOR
                   shadowColor:LC_UINAVIGATIONBAR_DEFAULT_TITLE_SHADOW_COLOR];
    
    if (IOS7_OR_LATER) {
        
        id value = LC_UINAVIGATIONBAR_DEFAULT_IMAGE_IOS7_LATER;
        
        if (value) {
            [self setBarBackgroundImage:LC_UINAVIGATIONBAR_DEFAULT_IMAGE_IOS7_LATER];
        }
    }else{
        
        id value = LC_UINAVIGATIONBAR_DEFAULT_IMAGE_IOS7_BEFORE;
        
        if (value) {
            [self setBarBackgroundImage:LC_UINAVIGATIONBAR_DEFAULT_IMAGE_IOS7_BEFORE];
        }
    }
    
    if (IOS7_OR_LATER) {
        
        if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]){
            
            self.interactivePopGestureRecognizer.delegate = self;
            self.delegate = self;
        }
    }
}

-(void) setBarTitleTextColor:(UIColor *)color shadowColor:(UIColor *)shadowColor
{
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 60000
    NSMutableDictionary * dictText = [NSMutableDictionary dictionaryWithObjectsAndKeys:color,NSForegroundColorAttributeName, LK_FONT_B(16),NSFontAttributeName,nil];
#else
    NSMutableDictionary * dictText = [NSMutableDictionary dictionaryWithObjectsAndKeys:color,UITextAttributeTextColor,shadowColor,UITextAttributeTextShadowColor, LK_FONT_B(16),UITextAttributeFont,nil];
#endif
    
    [self.navigationBar setTitleTextAttributes:dictText];
}

-(void) setBarBackgroundImage:(UIImage *)image
{
    [self.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
}

#pragma mark -

-(id <UIViewControllerAnimatedTransitioning>) navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC
{
    if (self.animationHandler) {
        
        return self.animationHandler(operation, fromVC, toVC);
    }
    
    return nil;
}

- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated
{
    if (IOS7_OR_LATER) {
        if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)])
            self.interactivePopGestureRecognizer.enabled = YES;
    }

}

-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ( gestureRecognizer == self.interactivePopGestureRecognizer )
    {
        if ( self.viewControllers.count < 2 || self.visibleViewController == [self.viewControllers objectAtIndex:0] )
        {
            return NO;
        }
    }
    
    return YES;
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (IOS7_OR_LATER) {

        if ( [self respondsToSelector:@selector(interactivePopGestureRecognizer)] && animated == YES )
        {
            self.interactivePopGestureRecognizer.enabled = NO;
        }
    }
    
//    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
    [super pushViewController:viewController animated:animated];
    
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    
//    if (self.viewControllers.count <= 2) {
//        
//        [self.rdv_tabBarController setTabBarHidden:NO animated:YES];
//    }
    return [super popViewControllerAnimated:animated];
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated
{
    if (IOS7_OR_LATER) {

        if ( [self respondsToSelector:@selector(interactivePopGestureRecognizer)] && animated == YES )
        {
            self.interactivePopGestureRecognizer.enabled = NO;
        }
        
    }
    
    return  [super popToRootViewControllerAnimated:animated];
    
}
- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (IOS7_OR_LATER) {

        if( [self respondsToSelector:@selector(interactivePopGestureRecognizer)] )
        {
            self.interactivePopGestureRecognizer.enabled = NO;
        }
        
    }
    
    return [super popToViewController:viewController animated:animated];
    
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    
    return UIStatusBarStyleLightContent;
}

@end
