//
//  LKSearchResultsBrowsingViewController.h
//  LIKE
//
//  Created by huangweifeng on 9/16/15.
//  Copyright (c) 2015 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKPostTableViewController.h"
#import "LKSearchResultsViewController.h"

@interface LKSearchResultsBrowsingViewController : LKPostTableViewController

LC_PROPERTY(assign) LKSearchResultsViewController *parentSearchResultsViewController;

- (void)reloadData;

@end
