//
//  LKSearchPlaceholderView.h
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/5/26.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import <UIKit/UIKit.h>

LC_BLOCK(void, LKSearchPlaceholderViewDidSelectRow, (NSString * tagString));

@interface LKSearchPlaceholderView : LCUITableView

LC_PROPERTY(strong) NSArray * tags;
LC_PROPERTY(copy) NSString * searchString;
LC_PROPERTY(copy) LKSearchPlaceholderViewDidSelectRow didSelectRow;

@end
