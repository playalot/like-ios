//
//  LKRecommendTagsView.m
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/4/20.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKRecommendTagsView.h"
#import "NSArray+Ext.h"

@implementation LKRecommendTagItem

-(instancetype) init
{
    if (self = [super init]) {
        
        self.cornerRadius = 4;
        self.layer.masksToBounds = NO;
        self.backgroundColor = LC_RGB(245, 240, 236);
        
        self.tagLabel = LCUILabel.view;
        self.tagLabel.font = LK_FONT(11);
        self.tagLabel.textColor = [UIColor whiteColor];
        self.ADD(self.tagLabel);
        
        
        [self addTapGestureRecognizer:self selector:@selector(didTapAction)];
    }
    
    return self;
}

-(void) didTapAction
{
    if (self.didTap) {
        self.didTap(self);
    }
}

-(void) setTagValue:(__LKTagS *)tagValue
{
    _tagValue = tagValue;
    
    CGFloat topPadding = 5.;
    CGFloat leftPadding = 10.;
    
    self.tagLabel.text = tagValue.tag;
    self.tagLabel.FIT();
    self.tagLabel.viewFrameX = leftPadding;
    self.tagLabel.viewFrameY = topPadding;
    
    self.viewFrameWidth = self.tagLabel.viewRightX + leftPadding;
    self.viewFrameHeight = self.tagLabel.viewBottomY + topPadding;
    self.cornerRadius = self.viewMidHeight;
    self.layer.masksToBounds = NO;
}

-(void) setSelected:(BOOL)selected
{
    if (selected) {
        
        self.backgroundColor = LKColor.color;
        self.tagLabel.textColor = [UIColor whiteColor];
    }
    else{
        
        self.backgroundColor = LC_RGB(245, 240, 236);
        self.tagLabel.textColor = [LC_RGB(74, 74, 74) colorWithAlphaComponent:0.9];
    }
}

@end

@implementation __LKTagS

@end

@interface LKRecommendTagsView ()
/**
 *  服务器预置的标签
 */
@property (nonatomic, strong) NSArray *suggests;

@end

@implementation LKRecommendTagsView

-(void) dealloc
{
    [self cancelAllRequests];
}

-(instancetype) init
{
    if (self = [super init]) {
        
        _tags = [NSMutableArray array];
    }
    
    return self;
}

-(void) loadRecommendTags
{
    self.alpha = 0;

    LKHttpRequestInterface * interface = [LKHttpRequestInterface interfaceType:@"user/suggest"].AUTO_SESSION();
    
    @weakly(self);
    
    [self request:interface complete:^(LKHttpRequestResult *result) {
       
        @normally(self);
        
        if (result.state == LKHttpRequestStateFinished) {
            
            NSArray * array = result.json[@"data"][@"suggests"];
            NSArray * array1 = result.json[@"data"][@"defaults"];
            
            // 保存预置标签
            self.suggests = array;

            NSMutableArray * tags = [NSMutableArray array];
            
            for (NSDictionary * dic in array) {
                
                __LKTagS * tag = [__LKTagS objectFromDictionary:dic];
                tag.type = 0;
                [tags addObject:tag];
            }
            
            for (NSDictionary * dic in array1) {
                
                __LKTagS * tag = [__LKTagS objectFromDictionary:dic];
                tag.type = 1;
                [tags addObject:tag];
            }
            
            self.tags = tags;
            
            [self reloadData:YES];

            if (self.itemDidLoad) {
                self.itemDidLoad();
            }
            
            LC_FAST_ANIMATIONS(1, ^{
               
                self.alpha = 1;
            });
        }
        else if (result.state == LKHttpRequestStateFailed){
            
            LC_FAST_ANIMATIONS(0.5, ^{
                
                self.alpha = 1;
            });
        }
        
    }];
}

-(void) setTags:(NSMutableArray *)tags
{
    _tags = tags;
}

-(void) reloadData:(BOOL)animation
{
    
    CGFloat padding = 10;
    
    
    NSArray * subViews = self.subviews;
    
    for (UIView * view in subViews) {
        
        if ([view isKindOfClass:[LKRecommendTagItem class]]) {
            
            [view removeFromSuperview];
        }
    }
    
    
    LC_FAST_ANIMATIONS(0.15, ^{
       
        self.alpha = self.tags.count == 0 ? 0 : 1;
    });

    
    // preItem为添加的上一个标签
    LKRecommendTagItem * preItem = nil;
    
    for (NSInteger i = 0; i< self.tags.count; i++) {
        
        __LKTagS * tag = self.tags[i];
                
        LKRecommendTagItem * item = LKRecommendTagItem.view;
        
        item.tag = i;
        item.tagValue = tag;
        item.selected = self.highlight;
        
        @weakly(self);
        
        item.didTap = ^(LKRecommendTagItem * cache){
            
            @normally(self);
            
            LKRecommendTagItem * tmp = cache;

            if (self.tapRemove) {
                
                // 重新构建
                [self.tags removeObjectAtIndex:cache.tag];
                                
                [self reloadData:NO];
            }
            
            if (self.itemDidTap) {
                self.itemDidTap(tmp, tmp.tagValue.type);
            }
            
        };
        
        self.ADD(item);
        
        if (!preItem) {
            
            item.viewFrameX = padding;
            item.viewFrameY = padding;
        }
        else{
            
            if (preItem.viewRightX + padding + item.viewFrameWidth > self.viewFrameWidth) {
                
                item.viewFrameX = padding;
                item.viewFrameY = preItem.viewBottomY + padding;
            }
            else{
                
                item.viewFrameX = preItem.viewRightX + padding;
                item.viewFrameY = preItem.viewFrameY;
            }
        }
        
        if (animation) {
            
            item.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.01, 0.01);
            item.alpha = 0;
            
            [UIView animateWithDuration:0.5 delay:0.001 * i usingSpringWithDamping:0.7 initialSpringVelocity:3 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                
                item.transform = CGAffineTransformIdentity;
                item.alpha = 1;
                
            } completion:^(BOOL finished) {
                
            }];
        }
        
        preItem = item;
    }
    
    if (self.tags.count == 0) {
        
        self.viewFrameHeight = 0;
    }
    else{
        self.viewFrameHeight = preItem.viewBottomY + padding;
    }
}


@end
