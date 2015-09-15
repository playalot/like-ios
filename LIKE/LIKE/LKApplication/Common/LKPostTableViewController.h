//
//  LKPostTableViewController.h
//  LIKE
//
//  Created by huangweifeng on 9/9/15.
//  Copyright (c) 2015 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LCUITableViewController.h"
#import "LKPost.h"
#import "LKTagsView.h"

@interface LKPostTableViewController : LCUIViewController

LC_PROPERTY(strong) NSMutableArray * datasource;
LC_PROPERTY(strong) LCUITableView *tableView;

@end
