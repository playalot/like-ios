//
//  LKMainFeedViewController.h
//  LIKE
//
//  Created by huangweifeng on 9/15/15.
//  Copyright (c) 2015 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LCUIViewController.h"
#import "LKHomeFeedViewController.h"
#import "LKFollowingFeedViewController.h"

@interface LKMainFeedViewController : LCUIViewController

LC_PROPERTY(strong) LKHomeFeedViewController *homeFeedViewController;
LC_PROPERTY(strong) LKFollowingFeedViewController *followingFeedViewController;

- (void)refresh;

@end
