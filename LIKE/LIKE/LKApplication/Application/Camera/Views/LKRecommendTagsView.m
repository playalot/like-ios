//
//  LKRecommendTagsView.m
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/4/20.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKRecommendTagsView.h"

@implementation LKRecommendTagItem

-(instancetype) init
{
    if (self = [super init]) {
        
        self.cornerRadius = 4;
        self.layer.masksToBounds = NO;
        self.backgroundColor = LC_RGB(245, 240, 236);
        self.tagLabel.textColor = [LC_RGB(74, 74, 74) colorWithAlphaComponent:0.9];
        
        self.tagLabel = LCUILabel.view;
        self.tagLabel.font = LK_FONT_B(11);
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

-(void) setTagString:(NSString *)tagString
{
    _tagString = tagString;
    
    CGFloat topPadding = 5.;
    CGFloat leftPadding = 10.;
    
    self.tagLabel.text = _tagString;
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
            
            NSMutableArray * tags = [NSMutableArray array];
            
            for (NSDictionary * dic in array) {
                
                LKTag * tag = [LKTag objectFromDictionary:dic];
                [tags addObject:tag];
            }
            
            self.tags = tags;
            
            if (self.itemDidLoad) {
                self.itemDidLoad();
            }
            
            LC_FAST_ANIMATIONS(0.5, ^{
               
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
    
    [self reloadData];
}

-(void) reloadData
{
    CGFloat padding = 10;
    
    [self removeAllSubviews];
    
    LC_FAST_ANIMATIONS(0.15, ^{
       
        self.alpha = self.tags.count == 0 ? 0 : 1;
    });

    
    LKRecommendTagItem * preItem = nil;
    
    for (NSInteger i = 0; i< self.tags.count; i++) {
        
        LKTag * tag = self.tags[i];
        
        LKRecommendTagItem * item = LKRecommendTagItem.view;
        
        item.tag = i;
        item.tagString = tag.tag;
        item.selected = self.highlight;
        
        @weakly(self);
        
        item.didTap = ^(LKRecommendTagItem * cache){
            
            @normally(self);
            
            // 重新构建
            [self.tags removeObjectAtIndex:cache.tag];
            
            LKRecommendTagItem * tmp = cache;
            
            [self reloadData];
            
            if (self.itemDidTap) {
                self.itemDidTap(tmp);
            }
            
        };
        
        self.ADD(item);
        
        if (!preItem) {
            
            item.viewFrameX = padding;
            item.viewFrameY = padding;
        }
        else{
            
            if (preItem.viewRightX + padding * 2 + item.viewFrameWidth > self.viewFrameWidth) {
                
                item.viewFrameX = padding;
                item.viewFrameY = preItem.viewBottomY + padding;
            }
            else{
                
                item.viewFrameX = preItem.viewRightX + padding;
                item.viewFrameY = preItem.viewFrameY;
            }
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
