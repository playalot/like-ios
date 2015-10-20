//
//  LKSearchViewController.m
//  LIKE
//
//  Created by huangweifeng on 9/13/15.
//  Copyright (c) 2015 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKSearchViewController.h"
#import "LKSearchView.h"
#import "FXBlurView.h"
#import "LKSearchSuggestionView.h"
#import "LKSearchResultsViewController.h"
#import "LKTag.h"
#import "LKSearchHistory.h"
#import "LKPostTableViewController.h"
#import "LKTopSearchInterface.h"
#import "LKUserCenterViewController.h"
#import "LKPostDetailViewController.h"

@interface LKSearchViewController () <LKSearchBarDelegate, LKPostDetailViewControllerDelegate>

LC_PROPERTY(strong) UIView *topBarSearchView;
LC_PROPERTY(strong) LKSearchSuggestionView *suggestionView;
LC_PROPERTY(strong) LKSearchBar *searchBar;

LC_PROPERTY(strong) UIView * blurView;
LC_PROPERTY(strong) LCUIButton *searchTip;
LC_PROPERTY(strong) LCUIButton *doneButton;

LC_PROPERTY(strong) LKSearchView *searchView;

@end

@implementation LKSearchViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.topBarSearchView setHidden:NO];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.topBarSearchView setHidden:YES];
}

- (void)buildTopSearchBar {
    
    CGRect searchBarFrame = CGRectMake(5, 5, self.navigationController.navigationBar.viewFrameWidth - 10, 30);
    self.topBarSearchView = UIView.view;
    self.topBarSearchView.backgroundColor = [UIColor clearColor];
    self.topBarSearchView.frame = searchBarFrame;
    
    if (IOS8_OR_LATER) {
        self.blurView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
        self.blurView.frame = self.topBarSearchView.bounds;
        self.blurView.cornerRadius = 4;
        self.blurView.layer.shouldRasterize = NO;
        self.blurView.layer.rasterizationScale = 1;
        UIView * view = UIView.view.COLOR([[UIColor whiteColor] colorWithAlphaComponent:1]);
        view.frame = self.blurView.bounds;
        ((UIVisualEffectView *)self.blurView).contentView.ADD(view);
    } else {
        self.blurView = [[FXBlurView alloc] initWithFrame:self.topBarSearchView.bounds];
        ((FXBlurView *)self.blurView).blurRadius = 10;
        self.blurView.cornerRadius = 4;
    }
    self.blurView.tintColor = [[UIColor whiteColor] colorWithAlphaComponent:1];
    self.blurView.layer.masksToBounds = YES;
    self.topBarSearchView.ADD(self.blurView);
    
    UIImage * searchIcon = [[[UIImage imageNamed:@"SearchIcon.png" useCache:YES] imageWithTintColor:[[UIColor blackColor] colorWithAlphaComponent:0.35]] scaleToWidth:20];
    self.searchTip = LCUIButton.view;
    self.searchTip.frame = self.topBarSearchView.bounds;
    self.searchTip.titleFont = LK_FONT(12);
    self.searchTip.titleColor = [[UIColor blackColor] colorWithAlphaComponent:0.35];
    self.searchTip.title = LC_LO(@"  发现更多有趣内容");
    self.searchTip.buttonImage = searchIcon;
    self.searchTip.titleEdgeInsets = UIEdgeInsetsMake(2, 0, 0, 0);
    [self.searchTip addTarget:self action:@selector(beginSearch) forControlEvents:UIControlEventTouchUpInside];
    self.topBarSearchView.ADD(self.searchTip);
    
    self.searchBar = [[LKSearchBar alloc] initWithFrame:self.topBarSearchView.bounds];
    self.searchBar.frame = self.topBarSearchView.bounds;
    self.searchBar.delegate = self;
    self.searchBar.backgroundColor = [UIColor clearColor];
    self.searchBar.alpha = 0;
    self.searchBar.delegate = self;
    self.topBarSearchView.ADD(self.searchBar);
    
    self.doneButton = LCUIButton.view;
    self.doneButton.viewFrameX = self.topBarSearchView.viewFrameWidth;
    self.doneButton.viewFrameWidth = 55;
    self.doneButton.viewFrameHeight = self.topBarSearchView.viewFrameHeight;
    self.doneButton.titleColor = [UIColor whiteColor];
    self.doneButton.title = LC_LO(@"取消");
    self.doneButton.titleFont = LK_FONT_B(14);
    self.doneButton.showsTouchWhenHighlighted = YES;
    [self.doneButton addTarget:self action:@selector(endSearch) forControlEvents:UIControlEventTouchUpInside];
    self.topBarSearchView.ADD(self.doneButton);
    
    self.navigationController.navigationBar.ADD(self.topBarSearchView);
}

- (void)buildHotTagsView {
    self.searchView = LKSearchView.view;
    self.searchView.parentViewController = self;
    self.view.ADD(self.searchView);
}

- (void)buildSuggestionView {
    self.suggestionView = LKSearchSuggestionView.view;
    self.suggestionView.viewFrameWidth = self.view.viewFrameWidth;
    self.suggestionView.viewFrameHeight = self.view.viewFrameHeight;
    self.suggestionView.viewFrameY = 0;
    self.suggestionView.alpha = 0;
    self.view.ADD(self.suggestionView);
}

- (void)buildUI {
    self.view.backgroundColor = [LKColor backgroundColor];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:LKColor.color andSize:CGSizeMake(LC_DEVICE_WIDTH, 64)] forBarMetrics:UIBarMetricsDefault];
    
    [self buildTopSearchBar];
    [self buildHotTagsView];
    [self buildSuggestionView];
    
    @weakly(self);
    self.suggestionView.didTap = ^(){
        @normally(self);
        [self.searchBar.searchField resignFirstResponder];
    };
    
    self.suggestionView.didSelectSearchTag = ^(NSString * tagString){
        @normally(self);
        LKSearchResultsViewController * searchViewController = [[LKSearchResultsViewController alloc] initWithSearchString:tagString];
        [self.navigationController pushViewController:searchViewController animated:YES];
    };
    
    self.suggestionView.didSelectUser = ^(LKUser *user){
        @normally(self);
        [LKUserCenterViewController pushUserCenterWithUser:user navigationController:self.navigationController];
    };
}

- (void)beginSearch {
    
    [self.searchBar.searchField becomeFirstResponder];
    
    LC_FAST_ANIMATIONS_F(0.1, ^{
        
        self.searchBar.alpha = 1;
        self.searchTip.alpha = 0;
        self.blurView.alpha = 0;
        self.suggestionView.alpha = 1;
        
    }, ^(BOOL finished){
        
        LC_FAST_ANIMATIONS(UINavigationControllerHideShowBarDuration, ^{
            self.searchBar.viewFrameWidth = self.topBarSearchView.viewFrameWidth - self.doneButton.viewFrameWidth;
            self.blurView.viewFrameWidth = self.searchBar.viewFrameWidth;
            self.searchTip.viewFrameWidth = self.searchBar.viewFrameWidth;
            self.doneButton.viewFrameX = self.topBarSearchView.viewFrameWidth - self.doneButton.viewFrameWidth;
            
        });
    });
}

- (void)endSearch {
    
    [self.searchBar.searchField resignFirstResponder];
    
    LC_FAST_ANIMATIONS_F(0.1, ^{
        
        self.searchBar.alpha = 0;
        self.searchTip.alpha = 1;
        self.blurView.alpha = 1;
        self.suggestionView.alpha = 0;
        
    }, ^(BOOL finished){
        
        LC_FAST_ANIMATIONS(UINavigationControllerHideShowBarDuration, ^{
            self.searchBar.viewFrameWidth = self.topBarSearchView.viewFrameWidth;
            self.blurView.viewFrameWidth = self.searchBar.viewFrameWidth;
            self.searchTip.viewFrameWidth = self.searchBar.viewFrameWidth;
            self.doneButton.viewFrameX = self.topBarSearchView.viewFrameWidth;
            
        });
    });
}

- (void)searchAction {
    [self.inputView resignFirstResponder];
    [self setNavigationBarHidden:YES animated:YES];
    LC_FAST_ANIMATIONS(UINavigationControllerHideShowBarDuration, ^{
    });
}

#pragma mark - LKSearchBarDelegate

- (void)searchBarTextDidChange:(LKSearchBar *)searchBar {
    LC_FAST_ANIMATIONS(0.25, ^{
        self.suggestionView.alpha = 1;
        self.suggestionView.searchString = searchBar.searchField.text;
        [self searchSuggestionTags:searchBar.searchField.text];
    });
}

- (void)searchBarDidBeginEditing:(LKSearchBar *)searchBar editing:(BOOL)editing {
    [self searchBarTextDidChange:searchBar];
}

- (void)searchBarDidTapReturn:(LKSearchBar *)searchBar {
    [searchBar.searchField resignFirstResponder];
    if (LKLocalUser.singleton.isLogin) {
        [LKSearchHistory addHistory:searchBar.searchField.text];
    }
    LKSearchResultsViewController * searchResultsViewController = [[LKSearchResultsViewController alloc] initWithSearchString:searchBar.searchField.text];
    [self.navigationController pushViewController:searchResultsViewController animated:YES];
}

- (void)searchSuggestionTags:(NSString *)searchString {
    [self.suggestionView cancelAllRequests];
    
    if (searchString.length == 0) {
        self.suggestionView.tags = nil;
        return;
    }
    
    LKTopSearchInterface *searchInterface = [[LKTopSearchInterface alloc] initWithSearchString:searchString.URLCODE()];
    @weakly(self);
    @weakly(searchInterface);
    [searchInterface startWithCompletionBlockWithSuccess:^(LCBaseRequest *request) {
        @normally(self);
        @normally(searchInterface);
        
        self.suggestionView.users = searchInterface.users;
        self.suggestionView.tags = searchInterface.tags;
        
    } failure:^(LCBaseRequest *request) {
    }];
}

- (void)refresh {
    [self.searchView refresh];
}

LC_HANDLE_UI_SIGNAL(PushPostDetail, signal) {
    LKPostDetailViewController * detail = [[LKPostDetailViewController alloc] initWithPost:signal.object];
    detail.delegate = self;
    [self.navigationController pushViewController:detail animated:YES];
}

- (void)postDetailViewController:(LKPostDetailViewController *)ctrl didUpdatedPost:(LKPost *)post {
    
}

- (void)postDetailViewController:(LKPostDetailViewController *)ctrl didFavouritePost:(LKPost *)post {
    
}

- (void)postDetailViewController:(LKPostDetailViewController *)ctrl didUnfavouritePost:(LKPost *)post {
    
}

@end
