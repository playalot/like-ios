//
//  LKHotTagsTableView.h
//  LIKE
//
//  Created by huangweifeng on 9/21/15.
//  Copyright © 2015 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LKHotTagsTableView : LCUITableView

- (instancetype)initWithFrame:(CGRect)frame tag:(LKTag *)tag;

- (void)show;

@end
