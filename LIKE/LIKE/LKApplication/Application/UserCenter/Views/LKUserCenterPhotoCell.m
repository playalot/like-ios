//
//  LKUserCenterPhotoCell.m
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/4/15.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKUserCenterPhotoCell.h"

@interface __LKUserCenterPhotoItem : UIView

LC_PROPERTY(strong) LCUIImageView * imageView;

@end

@implementation __LKUserCenterPhotoItem

-(instancetype) init
{
    if (self = [super init]) {
        
        self.imageView = LCUIImageView.view;
        self.imageView.animationDuration = 0.35;
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.backgroundColor = LKColor.backgroundColor;
        self.ADD(self.imageView);
        
        self.clipsToBounds = YES;
    }
    
    return self;
}

-(void) setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    self.imageView.viewFrameX = 0;
    self.imageView.viewFrameY = 0;
    self.imageView.viewFrameWidth = frame.size.width;
    self.imageView.viewFrameHeight = frame.size.width;
}

@end

#pragma mark - 

@interface LKUserCenterPhotoCell ()

LC_PROPERTY(strong) NSMutableArray * items;

@end

@implementation LKUserCenterPhotoCell


LC_IMP_SIGNAL(PushPostDetail);

-(void) buildUI
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor whiteColor];
    self.contentView.backgroundColor = [UIColor whiteColor];

    self.items = [NSMutableArray array];

    CGFloat padding = 3;
    
    
    CGFloat width = (LC_DEVICE_WIDTH - padding * 4) / 3;
    
    for (NSInteger i = 0; i < 3; i++) {
        
        __LKUserCenterPhotoItem * item = __LKUserCenterPhotoItem.view;
        item.viewFrameWidth = width;
        item.viewFrameX = i * item.viewFrameWidth + padding * (i + 1);
        item.viewFrameHeight = item.viewFrameWidth;
        item.viewFrameY = padding;
        [item addTapGestureRecognizer:self selector:@selector(handleItemTap:)];
        self.ADD(item);
        [self.items addObject:item];
    }
}

-(void) setPosts:(NSArray *)posts
{
    _posts = posts;
    
    for (NSInteger i = 0; i< self.items.count; i++) {
        
        LKPost * post = nil;
        
        if (i < posts.count) {
            post = posts[i];
        }
        
        __LKUserCenterPhotoItem * item = self.items[i];
        item.imageView.image = nil;
        item.hidden = YES;
        item.tag = i;
        
        if (post) {
            
            item.hidden = NO;
            item.imageView.url = post.content;
        }
    }
}

-(void) handleItemTap:(UITapGestureRecognizer *)tap
{
    if (tap.view.tag < self.posts.count) {

        self.SEND(self.PushPostDetail).object = self.posts[tap.view.tag];
    }
}

+(CGFloat) height
{
    CGFloat padding = 3;
    
    CGFloat width = (LC_DEVICE_WIDTH - padding * 4) / 3;

    return width + padding;
}

@end
