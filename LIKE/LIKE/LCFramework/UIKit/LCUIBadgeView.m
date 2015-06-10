//
//  LC_UIBadgeView.m
//  LCFramework

//  Created by Licheng Guo . ( SUGGESTIONS & BUG titm@tom.com ) on 13-9-21.
//  Copyright (c) 2014年 Licheng Guo iOS developer ( http://nsobject.me ).All rights reserved.
//  Also see the copyright page ( http://nsobject.me/copyright.rtf ).
//
//

#import "LCUIBadgeView.h"

@interface LCUIBadgeView ()

@end

@implementation LCUIBadgeView

- (id)initWithFrame:(CGRect)frame valueString:(NSString *)valueString
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.valueString = valueString;
        self.userInteractionEnabled = NO;
    }
    return self;
}

-(void) findBadgeWithValueString:(NSString *)valueString
{
    UITabBar *tabBar = [[UITabBar alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    
    UITabBarItem * item = [[UITabBarItem alloc] initWithTitle:@"" image:nil tag:0];
    item.badgeValue = valueString;
    
    tabBar.items = @[item];
    
    NSArray * tabbarSubviews = tabBar.subviews;
    
    for (UIView * viewTab in tabbarSubviews) {
        
        for (UIView * subview in viewTab.subviews) {
            
            NSString * strClassName = [NSString stringWithUTF8String:object_getClassName(subview)];
            
            if ([strClassName isEqualToString:@"UITabBarButtonBadge"] ||
                [strClassName isEqualToString:@"_UIBadgeView"])
            {
                self.badgeView = subview;
                
                //从原视图上移除
                [subview removeFromSuperview];
                break;
            }
        }
    }
}

-(void) setValueString:(NSString *)valueString
{
    if (_valueString == valueString) {
        return;
    }
    
    _valueString = valueString;
    
    if (_badgeView) {
        LC_REMOVE_FROM_SUPERVIEW(_badgeView, YES);
    }
    
    if (self.hiddenWhenEmpty) {
        
        if (_valueString.length <= 0 || [_valueString isEqualToString:@"0"]) {
            return;
        }
    }

    [self findBadgeWithValueString:valueString];
    
    if (self.badgeView) {
        
        self.badgeView.viewFrameX = 0;
        self.badgeView.viewFrameY = 0;
        
        self.viewFrameWidth = self.badgeView.viewFrameWidth;
        self.viewFrameHeight = self.badgeView.viewFrameHeight;
        
        self.ADD(self.badgeView);
        
    }else{
        
        ERROR(@"%@ 该类已不适用！", [self class]);
    }
    
    [self setKawaii:_kawaii];
}

-(void) setKawaii:(BOOL)kawaii
{
    _kawaii = kawaii;
    
    if (_kawaii) {
        
        [self setValueString:@" "];
        
        self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.5, 0.5);
    }
    else{
        
        self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
    }
}

@end
