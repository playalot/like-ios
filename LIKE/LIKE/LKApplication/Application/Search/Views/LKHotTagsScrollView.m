//
//  LKHotTagsScrollView.m
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/7/15.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKHotTagsScrollView.h"
#import "LKTag.h"
#import "UIImageView+WebCache.h"

@interface __LKHotTagsItem : LCUIImageView

LC_PROPERTY(strong) LCUILabel * label;

@end

@implementation __LKHotTagsItem

-(instancetype) initWithTitle:(NSString *)title imageURL:(NSString *)imageURL
{
    if (self = [super initWithFrame:CGRectMake(0, 0, 80, 80)]) {
        
//        self.url = imageURL;
        [self sd_setImageWithURL:[NSURL URLWithString:imageURL] placeholderImage:nil];
        
        self.backgroundColor = LKColor.backgroundColor;
        
        UIView * view = UIView.view;
        view.frame = self.bounds;
        view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
        self.ADD(view);
        
        self.label = LCUILabel.view;
        self.label.viewFrameX = 5;
        self.label.viewFrameWidth = self.viewFrameWidth - 10;
        self.label.viewFrameHeight = self.viewFrameHeight;
        self.label.textColor = [UIColor whiteColor];
        self.label.font = LK_FONT_B(13);
        self.label.text = title;
        self.label.textAlignment = UITextAlignmentCenter;
        self.label.lineBreakMode = NSLineBreakByTruncatingMiddle;
        self.ADD(self.label);
    }
    
    return self;
}

@end

@implementation LKHotTagsScrollView

-(instancetype) init
{
    if (self = [super initWithFrame:CGRectMake(0, 0, LC_DEVICE_WIDTH - 10, 90)]) {
        
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.pagingEnabled = YES;
    }
    
    return self;
}

-(void) setTags:(NSArray *)tags
{
    _tags = tags;
    
    [self reloadData];
}

-(void) reloadData
{
    [self removeAllSubviews];
    
    CGFloat padding = 5;
    
    UIView * preview = nil;
    
    for (NSInteger i = 0; i<self.tags.count; i++) {
        
        LKTag * tag = self.tags[i];
        
        __LKHotTagsItem * item = [[__LKHotTagsItem alloc] initWithTitle:tag.tag imageURL:tag.image];
        item.userInteractionEnabled = YES;
        item.tag = i;
        [item addTapGestureRecognizer:self selector:@selector(itemTapAction:)];
        self.ADD(item);
        
        item.viewFrameX = preview.viewRightX + (i == 0 ? 0 : padding);
        item.viewFrameY = padding;
        
        preview = item;
    }
    
    self.contentSize = CGSizeMake(preview.viewRightX + padding, self.viewFrameHeight);
}

-(void) itemTapAction:(UITapGestureRecognizer *)tap
{
    LKTag * tag =  self.tags[tap.view.tag];
    
    if (self.itemDidTap) {
        self.itemDidTap(tag);
    }
}

@end
