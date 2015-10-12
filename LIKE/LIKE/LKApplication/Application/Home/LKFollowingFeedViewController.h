//
//  LKFollowingFeedViewController.h
//  LIKE
//
//  Created by huangweifeng on 9/15/15.
//  Copyright (c) 2015 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LCUIViewController.h"
#import "LCUIViewController.h"
#import "LKPost.h"

@interface LKFollowingFeedViewController : LCUIViewController

- (void)updatePostFeed:(LKPost *)post;

- (void)scrollViewScrollToTop;

@end
