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

@protocol LKPostTableViewControllerDelegate;

@interface LKPostTableViewController : LCUIViewController <UITableViewDataSource, UITableViewDelegate>

LC_PROPERTY(assign) id<LKPostTableViewControllerDelegate> delegate;
LC_PROPERTY(strong) NSMutableArray *datasource;
LC_PROPERTY(strong) LCUITableView *tableView;
LC_PROPERTY(assign) NSInteger currentIndex;
LC_PROPERTY(assign) BOOL cellHeadLineHidden;

LC_ST_SIGNAL(FavouritePost);
LC_ST_SIGNAL(UnfavouritePost);

+ (instancetype)sharedInstance;

- (void)watchForChangeOfDatasource:(id)observedDataSourceObject
                     dataSourceKey:(NSString *)observedDataSourceKeyPath;

- (void)refresh;

@end

@protocol LKPostTableViewControllerDelegate <NSObject>

- (void)willLoadData:(LCUIPullLoaderDiretion)direction;

- (void)willNavigationBack:(NSInteger)currentIndex;

@end
