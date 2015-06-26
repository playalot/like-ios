//
//  LKFilterScrollView.m
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/4/17.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKFilterScrollView.h"

@interface __LKFilterItem : UIView

LC_PROPERTY(strong) UIImageView * imageView;
LC_PROPERTY(strong) LCUILabel * filterNameLabel;

@end

@implementation __LKFilterItem

#define ITEM_WIDTH 57

-(instancetype) init
{
    if (self = [super initWithFrame:LC_RECT(0, 0, ITEM_WIDTH, ITEM_WIDTH + 20)]) {
        
        self.imageView = UIImageView.view;
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.viewFrameWidth = ITEM_WIDTH;
        self.imageView.viewFrameHeight = ITEM_WIDTH;
        self.imageView.cornerRadius = 5;
        self.ADD(self.imageView);
        
        
        self.filterNameLabel = LCUILabel.view;
        self.filterNameLabel.viewFrameY = self.imageView.viewBottomY + 10;
        self.filterNameLabel.viewFrameWidth = self.viewFrameWidth;
        self.filterNameLabel.viewFrameHeight = 12;
        self.filterNameLabel.font = LK_FONT(10);
        self.filterNameLabel.textColor = [UIColor whiteColor];
        self.filterNameLabel.textAlignment = UITextAlignmentCenter;
        self.ADD(self.filterNameLabel);
    }
    
    return self;
}

@end

@interface LKFilterScrollView ()

LC_PROPERTY(strong) NSMutableArray * items;
LC_PROPERTY(strong) UIView * line;

@end

@implementation LKFilterScrollView

-(instancetype) init
{
    if (self = [super init]) {
        
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.backgroundColor = [UIColor clearColor];
        
        
        self.line = UIView.view;
        self.line.viewFrameWidth = ITEM_WIDTH;
        self.line.viewFrameHeight = 2;
        self.line.backgroundColor = LKColor.color;
        self.ADD(self.line);
    }
    
    return self;
}

-(NSMutableArray *) items
{
    if (!_items) {
        _items = [NSMutableArray array];
    }
    
    return _items;
}

-(void) setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    self.line.viewFrameY = self.viewFrameHeight - self.line.viewFrameHeight;
}

-(void) addFilterName:(NSString *)filterName filterImage:(UIImage *)filterImage
{
    __LKFilterItem * item = __LKFilterItem.view;
    item.imageView.image = filterImage;
    item.filterNameLabel.text = filterName;
    [item addTapGestureRecognizer:self selector:@selector(didSelectedItemAction:)];
    self.ADD(item);
    
    [self.items addObject:item];
    
    [self layoutItems];
}

-(void) layoutItems
{
    CGFloat padding = 10;
    
    __LKFilterItem * tmp = nil;
    
    for (NSInteger i = 0; i < self.items.count; i++) {
        
        __LKFilterItem * item = self.items[i];
        item.viewFrameX = padding * (i + 1) + item.viewFrameWidth * i;
        item.viewFrameY = padding;
        item.tag = i;
        tmp = item;
        
        
        if (i == 0) {
            
            self.line.viewCenterX = item.viewCenterX;
        }
    }
    
    self.contentSize = LC_SIZE(tmp.viewRightX + padding, tmp.viewBottomY + padding);
}

-(void) setSelectIndex:(NSInteger)selectIndex
{
    LC_FAST_ANIMATIONS(0.25, ^{
        
        if (selectIndex == 0) {
            
            self.line.viewFrameX = 10;
        }
        else{
            
            self.line.viewCenterX = ((UIView *)self.FIND(selectIndex)).viewCenterX;
        }
    });


}

-(void) didSelectedItemAction:(UITapGestureRecognizer *)tap
{
    LC_FAST_ANIMATIONS_F(0.15, ^{
    
        tap.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.9, 0.9);
        
    }, ^(BOOL finished){
        
        LC_FAST_ANIMATIONS_F(0.15, ^{
            
            tap.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
            
        }, ^(BOOL finished){
            
        });
    });
    
    LC_FAST_ANIMATIONS(0.25, ^{
    
        self.line.viewCenterX = tap.view.viewCenterX;
    });
    
    if (self.didSelectedItem) {
        self.didSelectedItem(tap.view.tag);
    }
}

@end
