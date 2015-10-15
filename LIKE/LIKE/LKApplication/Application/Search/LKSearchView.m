//
//  LKSearchView.m
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/5/26.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKSearchView.h"
#import "LKSearchBar.h"
#import "LKTag.h"
#import "LKSearchResultsViewController.h"
#import "AppDelegate.h"
#import "LKHotTagsSegmentView.h"
#import "LKSearchHistory.h"
#import "LKHotTagsTableView.h"
#import "LKTopSearchInterface.h"

@interface LKSearchView ()<UIScrollViewDelegate>

LC_PROPERTY(strong) UIView * blur;
LC_PROPERTY(assign) UIViewController * inViewController;
LC_PROPERTY(strong) LKSearchBar * searchBar;
LC_PROPERTY(strong) UIScrollView * scrollView;
LC_PROPERTY(strong) LKHotTagsSegmentView * hotTags;

LC_PROPERTY(assign) NSInteger page;

@end

@implementation LKSearchView

- (void)dealloc {
    [self cancelAllRequests];
}

- (instancetype)init {
    if (self = [super initWithFrame:CGRectMake(0, 0, LC_DEVICE_WIDTH, LC_DEVICE_HEIGHT + 20 - 60 + 5)]) {
        [self buildUI];
    }
    return self;
}

- (void)refresh {
    LKHotTagsTableView * pageView = self.scrollView.FIND(100 + self.page);
    if (pageView) {
        [pageView setContentOffset:LC_POINT(0, 0) animated:YES];
    }
}

- (void)buildUI {
    
    UIView * view = UIView.view;
    view.backgroundColor = LC_RGB(231, 231, 231);
    
    self.blur = view;
    self.blur.viewFrameY = 0;
    self.blur.viewFrameWidth = self.viewFrameWidth;
    self.blur.viewFrameHeight = self.viewFrameHeight;
    self.ADD(self.blur);

    self.scrollView = UIScrollView.view;
    self.scrollView.viewFrameY = 38;
    self.scrollView.viewFrameWidth = self.viewFrameWidth;
    self.scrollView.viewFrameHeight = self.blur.viewFrameHeight - 38;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.delegate = self;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.ADD(self.scrollView);

    self.hotTags = LKHotTagsSegmentView.view;
    self.ADD(self.hotTags);
    
    @weakly(self);
    
    self.hotTags.itemDidLoad = ^(NSArray * value){
        @normally(self);
        [self performSelector:@selector(buildPages:) withObject:value afterDelay:0];
    };
    
    self.hotTags.itemDidTap = ^(NSNumber * index){
        @normally(self);
        LC_FAST_ANIMATIONS_F(0.25, ^{
            [self.scrollView setContentOffset:CGPointMake(index.integerValue * self.scrollView.viewFrameWidth, 0) animated:NO];
        }, ^(BOOL finished){
        });
    };
    
    [self.hotTags performSelector:@selector(loadHotTags) withObject:nil afterDelay:0];
    
    self.placeholderView = LKSearchPlaceholderView.view;
    self.placeholderView.viewFrameWidth = self.viewFrameWidth;
    self.placeholderView.viewFrameHeight = self.viewFrameHeight;
    self.placeholderView.viewFrameY = 0;
    self.placeholderView.alpha = 0;
    self.ADD(self.placeholderView);
    
    self.placeholderView.didTap = ^(){
        @normally(self);
        [self.searchBar.searchField resignFirstResponder];
    };
    
    self.placeholderView.didSelectRow = ^(NSString * tagString){
        
        @normally(self);
        if (self.parentViewController) {
            LKSearchResultsViewController * search = [[LKSearchResultsViewController alloc] initWithSearchString:tagString];
            [self.parentViewController.navigationController pushViewController:search animated:YES];
        }
    };
}

#pragma mark - LKSearchBarDelegate

- (void)searchBarTextDidChange:(LKSearchBar *)searchBar {
    LC_FAST_ANIMATIONS(0.25, ^{
        self.placeholderView.alpha = 1;
        self.placeholderView.searchString = searchBar.searchField.text;
        [self searchPlaceHolderTags:searchBar.searchField.text];
    });
}

- (void)searchBarDidBeginEditing:(LKSearchBar *)searchBar editing:(BOOL)editing {
    [self searchBarTextDidChange:searchBar];
}

- (void)searchBarDidTapReturn:(LKSearchBar *)searchBar {
    if (LKLocalUser.singleton.isLogin) {
        [LKSearchHistory addHistory:searchBar.searchField.text];
    }
    LKSearchResultsViewController *searchResultsViewController = [[LKSearchResultsViewController alloc] initWithSearchString:searchBar.searchField.text];
    [self.parentViewController.navigationController pushViewController:searchResultsViewController animated:YES];
}

- (void)buildPages:(NSArray *)tags {
    self.scrollView.contentSize = CGSizeMake(self.scrollView.viewFrameWidth * tags.count, self.scrollView.viewFrameHeight);
    for (NSInteger i = 0; i<tags.count; i++) {
        
        LKTag * tag = tags[i];
        LKHotTagsTableView * page = [[LKHotTagsTableView alloc] initWithFrame:CGRectZero tag:tag];
        page.frame = CGRectMake(0, 0, self.scrollView.viewFrameWidth, self.scrollView.viewFrameHeight);
        page.viewFrameX = self.viewFrameWidth * i;
        page.tag = 100 + i;
        self.scrollView.ADD(page);

        if (i == 0) {
            [page performSelector:@selector(show) withObject:nil afterDelay:0];
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    int page = (scrollView.contentOffset.x + LC_DEVICE_WIDTH / 2.0) / LC_DEVICE_WIDTH;
    if (self.page == page) {
        return;
    }
    
    LKHotTagsTableView * pageView = self.scrollView.FIND(100 + page);
    if (pageView) {
        [pageView show];
    }
    
    self.page = page;
    self.hotTags.selectIndex = page;
}

- (void)searchPlaceHolderTags:(NSString *)searchString {
    [self.placeholderView cancelAllRequests];
    
    if (searchString.length == 0) {
        self.placeholderView.tags = nil;
        return;
    }
    
    LKTopSearchInterface *topSearchInterface = [[LKTopSearchInterface alloc] init];
    topSearchInterface.searchString = searchString.URLCODE();
    
    @weakly(self);
    @weakly(topSearchInterface);
    
    [topSearchInterface startWithCompletionBlockWithSuccess:^(LCBaseRequest *request) {
        @normally(self);
        @normally(topSearchInterface);
        self.placeholderView.users = topSearchInterface.users;
        self.placeholderView.tags = topSearchInterface.tags;
    } failure:^(LCBaseRequest *request) {
    }];
}

@end
