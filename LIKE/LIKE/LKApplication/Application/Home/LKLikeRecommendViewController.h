//
//  LKLikeRecommendViewController.h
//  LIKE
//
//  Created by huangweifeng on 10/16/15.
//  Copyright © 2015 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LCUIViewController.h"

@interface LKLikeRecommendViewController : LCUITableViewController

LC_PROPERTY(strong) NSMutableArray * datasource;

- (void)loadData:(LCUIPullLoaderDiretion)diretion;

- (void)scrollToPostByIndex:(NSInteger)index;

@end
