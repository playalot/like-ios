//
//  LKTagsView.m
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/4/15.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKTagsView.h"
#import "LKTagLikeModel.h"
#import "LKLoginViewController.h"

#define TAG_LEFT_PADDING 14.0f
#define TAG_RIGHT_PADDING 14.0f
#define TAG_TOP_PADDING 10.0f
#define TAG_BOTTOM_PADDING 5.0f

#define TAT_INNER_HORIZONTAL_MARGIN 3.0f
#define TAT_INNER_VERTICAL_MARGIN 3.0f
#define TAG_HORIZONTAL_INTERVAL 10.0f
#define TAG_VERTICAL_INTERVAL 5.0f

#define TAG_FONT_SIZE 14

@interface LKTagsView ()

LC_PROPERTY(strong) UIView * tipLine;

@end

@implementation LKTagsView

- (instancetype)init {
    if (self = [super init]) {
        self.pagingEnabled = YES;
        self.scrollsToTop = NO;
    }
    return self;
}

- (void)setTags:(NSMutableArray *)tags {
    _tags = tags;
    [self reloadData];
}

- (void)reloadData {
    [self reloadDataAndRemoveAll:YES];
}

- (void)reloadDataAndRemoveAll:(BOOL)removeAll {
    if (removeAll) {
        [self removeAllSubviews];
    }
    
    self.viewFrameHeight = 0;
    CGFloat leftMargin = 13;
    CGFloat topMargin = 15;
    CGFloat topPadding = 10;
    CGFloat leftPadding = 10;
    CGFloat maxHeight = 0;
    
    LKTagItemView *lastItem = nil;
    
    NSInteger page = 0;
    NSInteger line = 0;
    for (NSInteger i = 0; i < self.tags.count; i++) {
        
        LKTag *tag = self.tags[i];
        if(tag.likes.integerValue == 0){
            continue;
        }
        
        LKTagItemView *item = self.FIND(tag.id.integerValue);
        if (!item) {
            item = LKTagItemView.view;
        }
        
        item.tag = tag.id.integerValue;
        item.tagValue = tag;
        
        @weakly(self);
        
        item.didRemoved = ^(LKTagItemView *cache){
            @normally(self);
            
            // 重新构建
            [self.tags removeObject:cache.tagValue];
            [cache removeFromSuperview];
            if (self.didRemoveTag) {
                self.didRemoveTag(cache.tagValue);
            }
            
            LC_FAST_ANIMATIONS(1, ^{
                [self reloadDataAndRemoveAll:NO];
            });
        };
        
        item.willRequest = ^(LKTagItemView *cache){
            @normally(self);
            if (self.willRequest) {
                self.willRequest(cache);
            }
        };
        
        item.requestFinished = ^(LKTagItemView *cache){
            @normally(self);
            if (self.itemRequestFinished) {
                self.itemRequestFinished(cache);
            }
        };
        
        self.ADD(item);
        
        if (!lastItem) {
            item.frame = CGRectMake(leftMargin, topMargin, item.viewFrameWidth, item.viewFrameHeight);
        } else {
            CGFloat test = lastItem.viewRightX + leftPadding + leftMargin + item.viewFrameWidth - (page * self.viewFrameWidth);
            if (test > self.viewFrameWidth) {
                if (line == 999) {
                    page += 1;
                    line = 0;
                } else {
                    line += 1;
                }
                item.frame = CGRectMake(leftMargin + (page * self.viewFrameWidth), line * topPadding + topMargin + line * item.viewFrameHeight, item.viewFrameWidth, item.viewFrameHeight);
            } else {
                item.frame = CGRectMake(lastItem.viewFrameX + lastItem.viewFrameWidth + leftPadding, line * topPadding + topMargin + line * item.viewFrameHeight, item.viewFrameWidth, item.viewFrameHeight);
            }
        }
        lastItem = item;
        
        CGFloat height = lastItem.viewBottomY + topMargin;
        maxHeight = height > maxHeight ? height : maxHeight;
    }
    
    UIView *newItem = self.FIND(-3);
    
    if (!newItem) {
        newItem = [self buildNewActionTag];
    }
    
    newItem.tag = -3;
    
    if (!lastItem){
        newItem.frame = CGRectMake(leftMargin, topMargin, newItem.viewFrameWidth, newItem.viewFrameHeight);
    } else {
        CGFloat test = lastItem.viewRightX + newItem.viewFrameWidth + 16 + 20;
        if (test > self.viewFrameWidth) {
            if (line == 999) {
                page += 1;
                line = 0;
            } else {
                line += 1;
            }
            newItem.frame = CGRectMake(leftMargin + (page * self.viewFrameWidth) + 16, line * topPadding + topMargin + line * lastItem.viewFrameHeight + 2 - 16, newItem.viewFrameWidth, newItem.viewFrameHeight);
        } else {
            newItem.frame = CGRectMake(lastItem.viewFrameX + lastItem.viewFrameWidth + leftPadding + 16, line * topPadding + topMargin + line * lastItem.viewFrameHeight + 2 - 16, newItem.viewFrameWidth, newItem.viewFrameHeight);
        }
        
    }
    
    newItem.viewFrameX = self.viewFrameWidth - newItem.viewFrameWidth - 10 + 16;
    [newItem addTapGestureRecognizer:self selector:@selector(newTagAction)];
    lastItem = (LKTagItemView *)newItem;

    CGFloat height = lastItem.viewBottomY + topMargin - 16;
    maxHeight = height > maxHeight ? height : maxHeight;
    
    self.ADD(newItem);
    CGSize size = CGSizeMake((page + 1) * self.viewFrameWidth, maxHeight);
    
    self.contentSize = size;
    self.viewFrameHeight = size.height;
    
    if (page + 1 > 1) {
        LC_REMOVE_FROM_SUPERVIEW(self.tipLine, YES);
        self.tipLine = UIView.view;
        self.tipLine.viewFrameX = self.viewFrameWidth - 4;
        self.tipLine.viewFrameWidth = 4;
        self.tipLine.viewFrameHeight = self.viewFrameHeight;
        self.tipLine.backgroundColor = [LKColor.color colorWithAlphaComponent:0.8];
        self.tipLine.alpha = 0;
        self.ADD(self.tipLine);
        [self cancelAllTimers];
        NSTimer * timer = [self fireTimer:@"TipLine" timeInterval:1 repeat:YES];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    }
}

-(void) addNewItem:(LKTagItemView *)item {
}

-(void) removeFromSuperview {
    [super removeFromSuperview];
}

- (void)handleTimer:(NSTimer *)timer {

    LC_FAST_ANIMATIONS(0.5, ^{
        if (self.tipLine.alpha == 0) {
            self.tipLine.alpha = 0.2;
        } else if (self.tipLine.alpha == 0.2) {
            self.tipLine.alpha = 1;
        } else {
            self.tipLine.alpha = 0.2;
        }
    });
}

- (UIView *)buildNewActionTag {
    UIView *newTagView = UIView.view;
    UIImage *icon = [[UIImage imageNamed:@"AddNewTag.png" useCache:YES] imageWithTintColor:LKColor.color];
    LCUIImageView *imageView = [LCUIImageView viewWithImage:icon];
    imageView.viewFrameX = 16;
    imageView.viewFrameY = 16;
    imageView.viewFrameHeight = 24;
    imageView.viewFrameWidth = 24;
    newTagView.ADD(imageView);
    newTagView.viewFrameWidth = imageView.viewFrameWidth + 32;
    newTagView.viewFrameHeight = imageView.viewFrameHeight + 32;
    return newTagView;
}

-(void) newTagAction
{
    if (self.customAction) {
        self.customAction(nil);
    }
}

@end
