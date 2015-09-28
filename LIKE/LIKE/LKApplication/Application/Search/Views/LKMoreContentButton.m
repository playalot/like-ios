//
//  LKMoreContentButton.m
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/7/17.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKMoreContentButton.h"
#import "LKSearchResultsViewController.h"
#import "LKSearchHistory.h"
#import "AppDelegate.h"

@interface LKMoreContentButton ()

@end

@implementation LKMoreContentButton

-(instancetype) initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
    }
    
    return self;
}

-(void) setTagValue:(LKTag *)tag
{
    if (self.tagString) {
        return;
    }
    
    self.tagString = tag.tag;
    
    LCUIButton * button = LCUIButton.view;
    button.titleFont = LK_FONT(12);
//    button.title = [NSString stringWithFormat:LC_LO(@"查看关于#%@#的全部内容"), tag.tag];
    button.title = @" ";    // 隐藏按钮
    button.viewFrameHeight = 40;
    button.FIT();
    button.viewFrameWidth += 30;
    button.viewFrameX = self.viewMidWidth - button.viewMidWidth;
    button.viewFrameY = self.viewMidHeight - button.viewMidHeight;
    button.backgroundColor = [UIColor clearColor];
    button.titleColor = LKColor.color;
    button.cornerRadius = 4;
    button.showsTouchWhenHighlighted = YES;
    [button addTarget:self action:@selector(didTap) forControlEvents:UIControlEventTouchUpInside];
    self.ADD(button);
}

- (void)didTap {
    [LKSearchHistory addHistory:self.tagString];
    LKSearchResultsViewController *searchResultsViewController = [[LKSearchResultsViewController alloc] initWithSearchString:self.tagString];
    [[LKNavigator navigator] pushViewController:searchResultsViewController animated:YES];
}

@end
