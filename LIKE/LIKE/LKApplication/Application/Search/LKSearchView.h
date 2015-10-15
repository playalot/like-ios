//
//  LKSearchView.h
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/5/26.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LKSearchBar.h"
#import "LKSearchPlaceholderView.h"

@interface LKSearchView : UIView <LKSearchBarDelegate>

LC_PROPERTY(copy) LKValueChanged willHide;
LC_PROPERTY(strong) LKSearchPlaceholderView *placeholderView;
LC_PROPERTY(weak) LCUIViewController *parentViewController;

- (void)refresh;

@end
