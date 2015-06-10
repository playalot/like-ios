//
//  LC_UITableBar.m
//  LCFramework

//  Created by Licheng Guo . ( SUGGESTIONS & BUG titm@tom.com ) on 13-10-11.
//  Copyright (c) 2014年 Licheng Guo iOS developer ( http://nsobject.me ).All rights reserved.
//  Also see the copyright page ( http://nsobject.me/copyright.rtf ).
//
//

#import "LCUITabBar.h"

#define TABBAR_HEIGHT 49.f

#pragma mark -

@interface LCUITabBarItem ()

LC_PROPERTY(strong) UIImage * selectedImage;

@end

#pragma mark -

@implementation LCUITabBarItem

+(LCUITabBarItem *) tabBarItemWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage;
{
    LCUITabBarItem * item = [[LCUITabBarItem alloc] initWithImage:image highlightedImage:highlightedImage];

    return item;
    
}

-(instancetype) initWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage
{
    self = [super initWithFrame:CGRectZero];
    
    if (self) {
        
        self.image = image;
        self.selectedImage = highlightedImage;
    
        [self setImage:image forState:UIControlStateNormal];
        [self setImage:image forState:UIControlStateHighlighted];
        
        self.clipsToBounds = NO;

    }
    
    return self;
}

-(void) setHighlighted:(BOOL)highlighted
{
    if (highlighted) {
        [self setImage:self.selectedImage forState:UIControlStateNormal];
        [self setImage:self.selectedImage forState:UIControlStateHighlighted];
    }else{
        [self setImage:self.image forState:UIControlStateNormal];
        [self setImage:self.image forState:UIControlStateHighlighted];
    }
}


@end

#pragma mark -

@implementation LCUITabBar

-(LCUITabBar *) initWithTabBarItems:(NSArray *)items
{
    self = [super initWithFrame:LC_RECT_CREATE(0, 0, LC_DEVICE_WIDTH, TABBAR_HEIGHT)];
    
    if (self) {
        
        self.items = items;
        self.backgroundImageView.image = [UIImage imageNamed:@"LC_DefaultTabbarBkg.png" useCache:NO];
        self.clipsToBounds = NO;
    }
    
    return self;
}

-(void) setItems:(NSArray *)items
{
    if (items == _items) {
        return;
    }
    
    if (_items) {
        
        for (LCUITabBarItem * item in _items) {
            
            [item removeFromSuperview];
        }
    }
    
    _items = items;
    
    if (!_items) {
        return;
    }
    
    CGFloat itemWidth = self.viewFrameWidth / _items.count;
    CGFloat itemHeight = self.viewFrameHeight;
    
    [items enumerateObjectsUsingBlock:^(LCUITabBarItem * item ,NSUInteger idx, BOOL *stop){
        
        item.frame = LC_RECT_CREATE(itemWidth * idx, 0, itemWidth, itemHeight);
        item.tagString = LC_NSSTRING_FORMAT(@"%@",@(idx));
        [self addSubview:item];
    }];
}

-(void) setSelectedIndex:(NSInteger)selectedIndex
{
    [self.items enumerateObjectsUsingBlock:^(LCUITabBarItem * item ,NSUInteger idx, BOOL *stop){
        
        if (selectedIndex == idx) {
            [item setHighlighted:YES];
        }else{
            [item setHighlighted:NO];
        }
    }];
    
}


@end
