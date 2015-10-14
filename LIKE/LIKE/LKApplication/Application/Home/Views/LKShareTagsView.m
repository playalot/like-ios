//
//  LKShareTagsView.m
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/5/25.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKShareTagsView.h"
#import "LKTag.h"

@interface __LKTagItemView : UIView

LC_PROPERTY(strong) LCUILabel *tagLabel;
LC_PROPERTY(strong) LCUILabel *likesLabel;
LC_PROPERTY(strong) LCUIImageView *lineView;

@end

@implementation __LKTagItemView

- (instancetype)init {
    
    if (self = [super init]) {
        self.cornerRadius = 6;
        self.layer.masksToBounds = NO;
        
        self.tagLabel = LCUILabel.view;
        self.tagLabel.font = LK_FONT_B(22);
        self.tagLabel.textColor = [UIColor whiteColor];//LC_RGB(74, 74, 74);
        self.ADD(self.tagLabel);
        
        self.lineView = LCUIImageView.view;
        self.ADD(self.lineView);
        
        self.likesLabel = LCUILabel.view;
        self.likesLabel.font = LK_FONT_B(22);
        self.likesLabel.textColor = [UIColor whiteColor];
        self.likesLabel.textAlignment = UITextAlignmentCenter;
        self.likesLabel.layer.shouldRasterize = YES;
        self.ADD(self.likesLabel);
    }
    return self;
}

- (void)setTagString:(NSString *)tagString likes:(NSNumber *)likes {

    self.tagLabel.text = tagString;
    self.tagLabel.FIT();

    CGFloat topPadding = 3;
    CGFloat leftPadding = 12;
    
    self.tagLabel.viewFrameX = leftPadding;
    self.tagLabel.viewFrameY = topPadding + 1.5;
    
    self.lineView.viewFrameHeight = 29;
    self.lineView.viewFrameWidth = 2;
    self.lineView.viewFrameX = self.tagLabel.viewRightX + 8;
    self.lineView.viewFrameY = 5;
    self.lineView.image = [[UIImage imageNamed:@"SeparateLine.png" useCache:YES] imageWithTintColor:[UIColor whiteColor]];
    self.likesLabel.text = LC_NSSTRING_FORMAT(@"%@", likes);
    self.likesLabel.FIT();
    
    self.likesLabel.viewFrameX = self.lineView.viewRightX + 5;
    self.likesLabel.viewFrameY = topPadding / 2. + 1;
    self.likesLabel.viewFrameHeight = (self.tagLabel.viewFrameHeight + topPadding * 2.) - topPadding;
    self.likesLabel.viewFrameWidth = self.likesLabel.viewFrameWidth < self.likesLabel.viewFrameHeight ? self.likesLabel.viewFrameHeight : self.likesLabel.viewFrameWidth;
    
    self.viewFrameWidth = self.likesLabel.viewRightX + leftPadding - 3;
    self.viewFrameHeight = self.likesLabel.viewBottomY + topPadding;
    
    self.cornerRadius = 6;
    self.layer.masksToBounds = NO;
    
    
    self.backgroundColor = LC_RGB(245, 240, 236);
    self.likesLabel.textColor = [LC_RGB(74, 74, 74) colorWithAlphaComponent:0.9];
    self.tagLabel.textColor = [LC_RGB(74, 74, 74) colorWithAlphaComponent:0.9];
}

@end




@implementation LKShareTagsView

- (void)setTags:(NSMutableArray *)tags {
    
    _tags = tags;
    
    [self reloadData];
}

- (void)reloadData {

    CGFloat padding = 15 * self.proportion;
    CGFloat leftPadding = 31 * self.proportion;
    CGFloat topPadding = 26 * self.proportion;
    CGFloat bottomPadding = 29 * self.proportion;
    
    [self removeAllSubviews];
    
    LC_FAST_ANIMATIONS(0.15, ^{
        
        self.alpha = self.tags.count == 0 ? 0 : 1;
    });
    
    
    __LKTagItemView *preItem = nil;
    
    for (NSInteger i = 0; i < self.tags.count; i++) {
        
        LKTag *tag = self.tags[i];
        
        __LKTagItemView *item = __LKTagItemView.view;
        
        if (self.proportion) {
            item.tagLabel.font = LK_FONT_B(22 * self.proportion);
            item.likesLabel.font = LK_FONT_B(22 * self.proportion);
        }

        
        [item setTagString:tag.tag likes:tag.likes];
        
        self.ADD(item);
        
        if (!preItem) {
            
            item.viewFrameX = leftPadding;
            item.viewFrameY = topPadding;
        }
        else{
            
            if ((preItem.viewRightX + padding + item.viewFrameWidth + leftPadding) * 640 / 414 > self.viewFrameWidth) {
                
                item.viewFrameX = leftPadding;
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
        self.viewFrameHeight = preItem.viewBottomY + bottomPadding;
    }
}

@end
