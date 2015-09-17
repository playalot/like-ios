//
//  LKUserCenterBrowsingViewController.h
//  LIKE
//
//  Created by huangweifeng on 9/15/15.
//  Copyright (c) 2015 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKPostTableViewController.h"
#import "LKUserCenterHomeViewController.h"

@class LKUserCenterHomeViewController;

@interface LKUserCenterBrowsingViewController : LKPostTableViewController

LC_PROPERTY(weak) LKUserCenterHomeViewController *parentUserCenterViewController;

- (void)reloadData;

@end
