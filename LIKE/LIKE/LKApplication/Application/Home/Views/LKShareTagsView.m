//
//  LKShareTagsView.m
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/5/25.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKShareTagsView.h"
#import "LKTag.h"

@interface __LKTagItem : UIView

LC_PROPERTY(strong) LCUILabel * tagLabel;
LC_PROPERTY(strong) LCUILabel * likesLabel;

@end

@implementation __LKTagItem

-(instancetype) init
{
    if (self = [super init]) {
        
        self.cornerRadius = 4;
        self.layer.masksToBounds = NO;
        
        
        self.tagLabel = LCUILabel.view;
        self.tagLabel.font = LK_FONT_B(11 * 2);
        self.tagLabel.textColor = [UIColor whiteColor];//LC_RGB(74, 74, 74);
        self.ADD(self.tagLabel);
        
        
        self.likesLabel = LCUILabel.view;
        self.likesLabel.font = LK_FONT_B(11 * 2);
        self.likesLabel.textColor = [UIColor whiteColor];
        self.likesLabel.borderWidth = 1;
        self.likesLabel.borderColor = [[UIColor whiteColor] colorWithAlphaComponent:0.4];
        self.likesLabel.textAlignment = UITextAlignmentCenter;
        self.likesLabel.layer.shouldRasterize = YES;
        self.ADD(self.likesLabel);
    }
    
    return self;
}

-(void) setTagString:(NSString *)tagString likes:(NSNumber *)likes
{
    self.tagLabel.text = tagString;
    self.tagLabel.FIT();

    
    CGFloat topPadding = 2. * 2;
    CGFloat leftPadding = 9. * 2;
    
    
    self.tagLabel.viewFrameX = leftPadding;
    self.tagLabel.viewFrameY = topPadding + 1.5;
    
    self.likesLabel.text = LC_NSSTRING_FORMAT(@"%@", likes);
    self.likesLabel.FIT();
    
    self.likesLabel.viewFrameX = self.tagLabel.viewRightX + leftPadding - 2;
    self.likesLabel.viewFrameY = topPadding / 2. + 1;
    self.likesLabel.viewFrameHeight = (self.tagLabel.viewFrameHeight + topPadding * 2.) - topPadding;
    self.likesLabel.viewFrameWidth = self.likesLabel.viewFrameWidth < self.likesLabel.viewFrameHeight ? self.likesLabel.viewFrameHeight : self.likesLabel.viewFrameWidth;
    self.likesLabel.cornerRadius = self.likesLabel.viewMidHeight;
    
    
    self.viewFrameWidth = self.likesLabel.viewRightX + topPadding;
    self.viewFrameHeight = self.likesLabel.viewBottomY + topPadding;
    
    self.cornerRadius = self.viewMidHeight;
    self.layer.masksToBounds = NO;
    
    
    self.backgroundColor = LC_RGB(245, 240, 236);
    self.likesLabel.textColor = [LC_RGB(74, 74, 74) colorWithAlphaComponent:0.9];
    self.tagLabel.textColor = [LC_RGB(74, 74, 74) colorWithAlphaComponent:0.9];
    self.likesLabel.borderColor = LC_RGB(220, 215, 209);
}

@end




@implementation LKShareTagsView

-(void) setTags:(NSMutableArray *)tags
{
    _tags = tags;
    
    [self reloadData];
}

-(void) reloadData
{
    CGFloat padding = 20 * self.proportion;
    
    [self removeAllSubviews];
    
    LC_FAST_ANIMATIONS(0.15, ^{
        
        self.alpha = self.tags.count == 0 ? 0 : 1;
    });
    
    
    __LKTagItem * preItem = nil;
    
    for (NSInteger i = 0; i< self.tags.count; i++) {
        
        LKTag * tag = self.tags[i];
        
        __LKTagItem * item = __LKTagItem.view;
        
        if (self.proportion) {
            item.tagLabel.font = LK_FONT_B(20 * self.proportion);
            item.likesLabel.font = LK_FONT_B(20 * self.proportion);
        }

        
        [item setTagString:tag.tag likes:tag.likes];
        
        self.ADD(item);
        
        if (!preItem) {
            
            item.viewFrameX = padding;
            item.viewFrameY = padding;
        }
        else{
            
            if ((preItem.viewRightX + padding + item.viewFrameWidth) * 640 / 414 > self.viewFrameWidth) {
                
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
