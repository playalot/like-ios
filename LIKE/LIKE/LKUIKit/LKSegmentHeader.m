//
//  LKSegmentHeader.m
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/4/15.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKSegmentHeader.h"

@implementation LKSegmentHeaderItem

-(instancetype) init
{
    if (self = [super init]) {
        
        self.title = LCUILabel.view;
        self.title.font = LK_FONT_B(14);
        self.title.textColor = LC_RGB(74, 74, 74);
        self.title.textAlignment = UITextAlignmentCenter;
        self.title.viewFrameHeight = 18;
        self.ADD(self.title);
        
        self.subTitle = LCUILabel.view;
        self.subTitle.font = LK_FONT(14);
        self.subTitle.textColor = LC_RGB(74, 74, 74);
        self.subTitle.textAlignment = UITextAlignmentCenter;
        self.subTitle.viewFrameHeight = 12;
        self.ADD(self.subTitle);
        
        self.line = UIView.view;
        self.line.viewFrameWidth = 0.5;
        self.line.backgroundColor = [LC_RGB(175, 175, 175) colorWithAlphaComponent:0.5];
        self.ADD(self.line);
        
        
//        UIView * line = UIView.view.WIDTH(LC_DEVICE_WIDTH).HEIGHT(0.5).COLOR(LKColor.backgroundColor);
//        self.ADD(line);
    }
    
    return self;
}

-(void) setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    self.title.viewFrameWidth = self.viewFrameWidth;
    self.subTitle.viewFrameWidth = self.viewFrameWidth;
    
    CGFloat height = self.title.viewFrameHeight + 5 + self.subTitle.viewFrameHeight;
    
    self.title.viewFrameY = self.viewMidHeight - height / 2;
    self.subTitle.viewFrameY = self.title.viewBottomY + 5;
    
    
    self.line.viewFrameX = self.viewFrameWidth - 1;
    self.line.viewFrameY = 10;
    self.line.viewFrameHeight = self.viewFrameHeight - 20;
}

@end

@implementation LKSegmentHeader

-(instancetype) init
{
    if (self = [super init]) {
        
        self.backgroundColor = [UIColor whiteColor];
    }
    
    return self;
}

-(void) setTitle:(NSString *)title subTitle:(NSString *)subTitle atIndex:(NSInteger)atIndex
{
    LKSegmentHeaderItem * item = self.items[atIndex];
    
    item.title.text = subTitle;
    item.subTitle.text = title;
}

-(void) addTitle:(NSString *)title subTitle:(NSString *)subTitle
{
    LKSegmentHeaderItem * item = LKSegmentHeaderItem.view;
    item.title.text = subTitle;
    item.subTitle.text = title;
    [item addTapGestureRecognizer:self selector:@selector(itemDidTap:)];
    
    self.ADD(item);
    [self.items addObject:item];
    
    [self layoutItems];
}

-(void) layoutItems
{
    CGFloat width = self.viewFrameWidth / self.items.count;
    
    for (NSInteger i = 0; i < self.items.count; i++) {
        
        LKSegmentHeaderItem * item = self.items[i];
        
        item.viewFrameWidth = width;
        item.viewFrameHeight = self.viewFrameHeight;
        item.viewFrameX = i * width;
        item.tag = i;
        
        if (i == self.items.count - 1) {
            
            item.line.hidden = YES;
        }
        else{
            
            item.line.hidden = NO;
        }
    }
}

-(void) itemDidTap:(UITapGestureRecognizer *)tap
{
    if (self.didSelected) {
        self.didSelected(tap.view.tag);
    }
}

-(NSMutableArray *) items
{
    if (!_items) {
        _items = [NSMutableArray array];
    }
    
    return _items;
}

@end
