//
//  LKHotTagsUsersView.m
//  LIKE
//
//  Created by huangweifeng on 9/22/15.
//  Copyright © 2015 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKHotTagsUsersView.h"
#import "UIImageView+WebCache.h"

@interface LKHotTagsUsersView ()

LC_PROPERTY(strong) UIScrollView * scrollView;

@end

@implementation LKHotTagsUsersView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.scrollView = UIScrollView.view;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.showsVerticalScrollIndicator = NO;
        self.scrollView.alwaysBounceVertical = NO;
        self.scrollView.pagingEnabled = YES;
        self.scrollView.viewFrameX = 5;
        self.scrollView.viewFrameY = 5;
        self.scrollView.viewFrameWidth = self.viewFrameWidth - 10;
        self.scrollView.viewFrameHeight = self.viewFrameHeight - 10;
        self.scrollView.backgroundColor = [UIColor whiteColor];
        self.scrollView.cornerRadius = 2;
        self.ADD(self.scrollView);
        
    }
    return self;
}

- (void)setHotUsers:(NSArray *)hotUsers {
    _hotUsers = hotUsers;
    
    [self.scrollView removeAllSubviews];
    
//    LCUILabel * hot = LCUILabel.view;
//    hot.viewFrameX = 10;
//    hot.viewFrameY = 10;
//    hot.viewFrameWidth = 100;
//    hot.viewFrameHeight = 14;
//    hot.textColor = LC_RGB(184, 177, 171);
//    hot.font = LK_FONT(12);
//    hot.text = LC_LO(@"热门用户");
//    self.scrollView.ADD(hot);
    
    CGFloat padding = 5;
    UIView *preview = nil;
    
    for (NSInteger i = 0; i < self.hotUsers.count; i++) {
        LKUser *user = self.hotUsers[i];
        LCUIImageView * item = LCUIImageView.view;
        item.viewFrameWidth = 40;
        item.viewFrameHeight = 40;
        item.cornerRadius = 20;
        [item sd_setImageWithURL:[NSURL URLWithString:user.avatar] placeholderImage:nil];
        item.backgroundColor = LKColor.backgroundColor;
        item.userInteractionEnabled = YES;
        item.tag = i;
        [item addTapGestureRecognizer:self selector:@selector(itemTapAction:)];
        self.scrollView.ADD(item);
        
        item.viewFrameX = preview.viewRightX + 10;
        item.viewFrameY = 10;
        
        preview = item;
    }
    
    self.scrollView.contentSize = CGSizeMake(preview.viewRightX + padding, self.scrollView.viewFrameHeight);
}

-(void) itemTapAction:(UITapGestureRecognizer *)tap {
    self.SEND(@"PushUserCenter").object = self.hotUsers[tap.view.tag];
}

@end
