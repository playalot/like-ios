//
//  LKHotTagsTableView.h
//  LIKE
//
//  Created by huangweifeng on 9/21/15.
//  Copyright © 2015 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LKTag.h"

@interface LKHotTagsTableView : LCUITableView

LC_PROPERTY(strong) NSMutableArray *posts;

- (instancetype)initWithFrame:(CGRect)frame tag:(LKTag *)tag;

- (void)show;

@end
