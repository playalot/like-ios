//
//  LKSearchSuggestionView.h
//  LIKE
//
//  Created by huangweifeng on 9/16/15.
//  Copyright (c) 2015 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LCUIView.h"

LC_BLOCK(void, LKSearchSuggestionViewDidSelectRow, (NSString * tagString));

@interface LKSearchSuggestionView : LCUITableView

LC_PROPERTY(strong) NSArray * tags;
LC_PROPERTY(copy) NSString * searchString;
LC_PROPERTY(copy) LKSearchSuggestionViewDidSelectRow didSelectRow;
LC_PROPERTY(strong) NSArray * users;

@end
