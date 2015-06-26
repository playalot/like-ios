//
//  UIViewController+UINavigationBar.m
//  LCFramework

//  Created by 郭历成 ( titm@tom.com ) on 13-9-16.
//  Copyright (c) 2014年 Licheng Guo iOS developer ( http://nsobject.me ).All rights reserved.
//  Also see the copyright page ( http://nsobject.me/copyright.rtf ).
//
//

#import "UIViewController+LCUINavigationBar.h"

#pragma mark -

#undef	BUTTON_MIN_WIDTH
#define	BUTTON_MIN_WIDTH	(20)

#undef	BUTTON_MIN_HEIGHT
#define	BUTTON_MIN_HEIGHT	(20)

#pragma mark -

@implementation UIViewController(LCUINavigationBar)

+(instancetype) viewController
{
    return [[[self class] alloc] init];
}

- (void)setNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated
{    
	[self.navigationController setNavigationBarHidden:hidden animated:animated];
}

- (void)didLeftBarButtonTouched
{
    [self handleNavigationBarButton:LCUINavigationBarButtonTypeLeft];
}

- (void)didRightBarButtonTouched
{
    [self handleNavigationBarButton:LCUINavigationBarButtonTypeRight];
}

// Overwrite
-(void) handleNavigationBarButton:(LCUINavigationBarButtonType)type
{
    
}

- (void)setNavigationBarButton:(LCUINavigationBarButtonType)type image:(UIImage *)image selectImage:(UIImage *)selectImage
{
    CGRect buttonFrame = CGRectMake(0, 0, image.size.width, image.size.height);
    
    
    LCUIButton * button = LCUIButton.view;
    button.frame = buttonFrame;
    button.contentMode = UIViewContentModeScaleAspectFit;
    button.showsTouchWhenHighlighted = YES;
    
    if (image) {
        [button setImage:image forState:UIControlStateNormal];
    }
    
    if (selectImage) {
        [button setImage:selectImage forState:UIControlStateHighlighted];
    }
    
    if (LCUINavigationBarButtonTypeLeft == type){
        
        [button addTarget:self action:@selector(didLeftBarButtonTouched) forControlEvents:UIControlEventTouchUpInside];
        
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:(UIView *)button];
    }
    else{
        
        [button addTarget:self action:@selector(didRightBarButtonTouched) forControlEvents:UIControlEventTouchUpInside];
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:(UIView *)button];
    }
    
}

- (void)setNavigationBarButton:(LCUINavigationBarButtonType)type title:(NSString *)title titleColor:(UIColor *)titleColor;
{
    CGSize size = [title sizeWithFont:LK_FONT_B(15) byWidth:999];
    
    LCUIButton * button = LCUIButton.view;
    button.frame =  LC_RECT_CREATE(0, 0, size.width, size.height);
    button.contentMode = UIViewContentModeScaleAspectFit;
    button.showsTouchWhenHighlighted = YES;
    button.titleFont = LK_FONT_B(15);
    button.titleColor = titleColor;
    button.title = title;
    
    if (LCUINavigationBarButtonTypeLeft == type){
        
        [button addTarget:self action:@selector(didLeftBarButtonTouched) forControlEvents:UIControlEventTouchUpInside];
        
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:(UIView *)button];
    }
    else{
        
        [button addTarget:self action:@selector(didRightBarButtonTouched) forControlEvents:UIControlEventTouchUpInside];
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:(UIView *)button];
    }
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:(UIView *)button];
}

- (void)setNavigationBarButton:(LCUINavigationBarButtonType)type customView:(UIView *)view
{
    if (LCUINavigationBarButtonTypeLeft == type){
        
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:(UIView *)view];
    }
    else{
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:(UIView *)view];
    }
}

- (void)setNavigationBarButtonHidden:(LCUINavigationBarButtonType)type animated:(BOOL)animated
{
    if (animated) {
     
        LC_FAST_ANIMATIONS_F(0.15, ^{
            
            if (type == LCUINavigationBarButtonTypeLeft) {
                
                self.navigationItem.leftBarButtonItem.customView.alpha = 0;
            }
            else{
                
                self.navigationItem.rightBarButtonItem.customView.alpha = 0;
            }
            
        }, ^(BOOL finished){
            
            if (type == LCUINavigationBarButtonTypeLeft) {
                
                self.navigationItem.leftBarButtonItem = nil;
            }
            else{
                
                self.navigationItem.rightBarButtonItem = nil;
            }
        });
    }
    else{
    
        if (type == LCUINavigationBarButtonTypeLeft) {
            
            self.navigationItem.leftBarButtonItem = nil;
        }
        else{
            
            self.navigationItem.rightBarButtonItem = nil;
        }
    }
}

@end

