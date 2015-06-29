//
//  LKHotTagsView.m
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/5/26.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKHotTagsView.h"
#import "LKTag.h"

@interface LKHotTagItem ()

LC_PROPERTY(strong) UIView * maskView;

@end

@implementation LKHotTagItem

-(instancetype) init
{
    if (self = [super init]) {
        
        self.contentMode = UIViewContentModeScaleAspectFill;
        self.userInteractionEnabled = YES;
        self.layer.masksToBounds = NO;
        self.backgroundColor = LC_RGB(245, 240, 236);

        
        self.maskView = UIView.view.COLOR([[UIColor blackColor] colorWithAlphaComponent:0.12]);
        self.ADD(self.maskView);
        
        
        self.tagLabel = LCUILabel.view;
        self.tagLabel.font = LK_FONT_B(11);
        self.tagLabel.textColor = [UIColor whiteColor];
        self.ADD(self.tagLabel);

        
        self.maskView.hidden = YES;
        
        
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
    CGFloat leftPadding = 12.;
    
    self.tagLabel.text = _tagString;
    self.tagLabel.FIT();
    self.tagLabel.viewFrameX = leftPadding;
    self.tagLabel.viewFrameY = topPadding;
    
    self.viewFrameWidth = self.tagLabel.viewRightX + leftPadding;
    self.viewFrameHeight = self.tagLabel.viewBottomY + topPadding;
    self.viewFrameWidth = self.viewFrameWidth < self.viewFrameHeight ? self.viewFrameHeight : self.viewFrameWidth;

    
    self.cornerRadius = self.viewMidHeight;
    self.maskView.frame = self.bounds;
}

-(void) setUrl:(NSString *)url
{
    [super setUrl:url];
    
    self.maskView.hidden = NO;
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

@implementation LKHotTagsView

-(void) dealloc
{
    [self cancelAllRequests];
}

-(instancetype) init
{
    if (self = [super init]) {
        
        _tags = [NSMutableArray array];
        
        self.highlight = YES;
    }
    
    return self;
}

-(void) loadHotTags
{
    self.alpha = 0;
    
    LKHttpRequestInterface * interface = [LKHttpRequestInterface interfaceType:@"tag/hot"].AUTO_SESSION();
    
    @weakly(self);
    
    [self request:interface complete:^(LKHttpRequestResult *result) {
        
        @normally(self);
        
        if (result.state == LKHttpRequestStateFinished) {
            
            NSArray * array = result.json[@"data"];
            
            NSMutableArray * tags = [NSMutableArray array];
            
            for (NSDictionary * dic in array) {
                
                LKTag * tag = [LKTag objectFromDictionary:dic];
                [tags addObject:tag];
            }
            
            self.tags = tags;
            
            if (self.itemDidLoad) {
                self.itemDidLoad();
            }
            
            LC_FAST_ANIMATIONS(1, ^{
                
                self.alpha = 1;
            });
        }
        else if (result.state == LKHttpRequestStateFailed){
            
            LC_FAST_ANIMATIONS(1, ^{
                
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
    
    
    LKHotTagItem * preItem = nil;
    
    for (NSInteger i = 0; i< self.tags.count; i++) {
        
        LKTag * tag = self.tags[i];
        
        LKHotTagItem * item = LKHotTagItem.view;
        
        item.tag = i;
        item.tagString = tag.tag;
        
        if (!LC_NSSTRING_IS_INVALID(tag.image)) {
            
            item.url = tag.image;
        }
        
        item.selected = self.highlight;
        
        @weakly(self);
        
        item.didTap = ^(LKHotTagItem * cache){
            
            @normally(self);
            
            if (self.itemDidTap) {
                self.itemDidTap(cache);
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
