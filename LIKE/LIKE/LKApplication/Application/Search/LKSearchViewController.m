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

@interface LKSearchViewController () <LKSearchBarDelegate>

LC_PROPERTY(strong) UIView *topBarSearchView;
LC_PROPERTY(strong) LKSearchSuggestionView *suggestionView;
LC_PROPERTY(strong) LKSearchBar * searchBar;
LC_PROPERTY(strong) LCUIButton * doneButton;
LC_PROPERTY(strong) LKSearchView * searchView;

@end

@implementation LKSearchViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.searchBar.alpha = 1;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.searchBar.alpha = 0;
}

- (void)buildUI {
    self.view.backgroundColor = [LKColor backgroundColor];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:LKColor.color andSize:CGSizeMake(LC_DEVICE_WIDTH, 64)] forBarMetrics:UIBarMetricsDefault];
    
    CGRect searchBarFrame = CGRectMake(0, 0, self.navigationController.navigationBar.viewFrameWidth - 10, 30);
    
    self.topBarSearchView = UIView.view;
    self.topBarSearchView.backgroundColor = [UIColor randomColor];
    self.topBarSearchView.frame = searchBarFrame;
    
    CGRect testFrame = CGRectMake(0, 0, self.navigationController.navigationBar.viewFrameWidth - 100, 30);
    self.searchBar = [[LKSearchBar alloc] initWithFrame:testFrame];
    self.searchBar.frame = testFrame; //self.topBarSearchView.bounds;
    self.searchBar.delegate = self;
    self.searchBar.backgroundColor = [UIColor clearColor];
    self.searchBar.alpha = 1;
    self.searchBar.delegate = self;
    self.topBarSearchView.ADD(self.searchBar);
    
    self.doneButton = LCUIButton.view;
    self.doneButton.viewFrameX = self.topBarSearchView.viewFrameWidth;
    self.doneButton.viewFrameWidth = 55;
    self.doneButton.viewFrameHeight = 50;
    self.doneButton.titleColor = [UIColor whiteColor];
    self.doneButton.title = LC_LO(@"完成");
    self.doneButton.titleFont = LK_FONT_B(14);
    self.doneButton.showsTouchWhenHighlighted = YES;
    [self.doneButton addTarget:self action:@selector(endSearch) forControlEvents:UIControlEventTouchUpInside];
    self.topBarSearchView.ADD(self.doneButton);
    
    self.titleView = self.topBarSearchView;
    
    self.searchView = LKSearchView.view;
    self.searchView.parentViewController = self;
    self.view.ADD(self.searchView);
    
    self.suggestionView = LKSearchSuggestionView.view;
    self.suggestionView.viewFrameWidth = self.view.viewFrameWidth;
    self.suggestionView.viewFrameHeight = self.view.viewFrameHeight;
    self.suggestionView.viewFrameY = 0;
    self.suggestionView.alpha = 0;
    self.view.ADD(self.suggestionView);
    
    @weakly(self);
    self.suggestionView.didTap = ^(){
        @normally(self);
        [self.searchBar.searchField resignFirstResponder];
    };
    
    self.suggestionView.didSelectRow = ^(NSString * tagString){
        @normally(self);
        LKSearchResultsViewController * searchViewController = [[LKSearchResultsViewController alloc] initWithSearchString:tagString];
        [self.navigationController pushViewController:searchViewController animated:YES];
    };
}

-(void) beginSearch {
    
    LC_FAST_ANIMATIONS_F(0.1, ^{
        self.searchBar.alpha = 1;
        
    }, ^(BOOL finished){
        
        LC_FAST_ANIMATIONS(UINavigationControllerHideShowBarDuration, ^{
            self.searchBar.viewFrameWidth = self.topBarSearchView.viewFrameWidth - self.doneButton.viewFrameWidth - 10;
            self.doneButton.viewFrameX = self.topBarSearchView.viewFrameWidth - self.doneButton.viewFrameWidth;
            
        });
    });
}

-(void) endSearch {
}

#pragma mark - LKSearchBarDelegate

- (void)searchBar:(LKSearchBar *)searchBar willStartTransitioningToState:(LKSearchBarState)destinationState {
    NSLog(@"search bar willStartTransitioningToState");
}

- (void)searchBarTextDidChange:(LKSearchBar *)searchBar {
    LC_FAST_ANIMATIONS(0.25, ^{
        self.suggestionView.alpha = 1;
        self.suggestionView.searchString = searchBar.searchField.text;
        [self searchSuggestionTags:searchBar.searchField.text];
    });
}

-(void) searchBarDidBeginEditing:(LKSearchBar *)searchBar editing:(BOOL)editing {
    [self searchBarTextDidChange:searchBar];
}

- (void)searchBarDidTapReturn:(LKSearchBar *)searchBar {
    if (LKLocalUser.singleton.isLogin) {
        [LKSearchHistory addHistory:searchBar.searchField.text];
    }
    LKSearchResultsViewController * searchResultsViewController = [[LKSearchResultsViewController alloc] initWithSearchString:searchBar.searchField.text];
    [LC_APPDELEGATE.homeViewController.navigationController pushViewController:searchResultsViewController animated:YES];
}

-(void) searchSuggestionTags:(NSString *)searchString
{
    [self.suggestionView cancelAllRequests];
    
    if (searchString.length == 0) {
        self.suggestionView.tags = nil;
        return;
    }
    
    LKHttpRequestInterface * interface = [LKHttpRequestInterface interfaceType:[NSString stringWithFormat:@"search/topsearch/%@" ,searchString.URLCODE()]].AUTO_SESSION();
    @weakly(self);
    [self.suggestionView request:interface complete:^(LKHttpRequestResult *result) {
        @normally(self);
        
        if (result.state == LKHttpRequestStateFinished) {
            NSArray * array0 = result.json[@"data"][@"users"];
            NSMutableArray * users = [NSMutableArray array];
            for (NSDictionary * dic in array0) {
                [users addObject:[LKUser objectFromDictionary:dic]];
            }
            self.suggestionView.users = users;
            NSArray * array = result.json[@"data"][@"tags"];
            NSMutableArray * tags = [NSMutableArray array];
            for (NSDictionary * dic in array) {
                LKTag * tag = [LKTag objectFromDictionary:dic];
                [tags addObject:tag];
            }
            self.suggestionView.tags = tags;
            
        } else if (result.state == LKHttpRequestStateFailed){
            
        }
    }];
    
}


@end
