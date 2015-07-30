//
//  LKSearchViewController.m
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/5/26.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKSearchViewController.h"
#import "LKSearchBar.h"
#import "LKTag.h"
#import "LKSearchResultsViewController.h"
#import "AppDelegate.h"
#import "LKHotTagsSegmentView.h"
#import "LKSearchHistory.h"
#import "LKHotTagsPage.h"

@interface LKSearchViewController ()<UIScrollViewDelegate>

LC_PROPERTY(strong) LCUIBlurView * blur;
LC_PROPERTY(assign) UIViewController * inViewController;
LC_PROPERTY(strong) LKSearchBar * searchBar;
LC_PROPERTY(strong) UIScrollView * scrollView;
LC_PROPERTY(strong) LKHotTagsSegmentView * hotTags;

LC_PROPERTY(assign) NSInteger page;

@end

@implementation LKSearchViewController

-(void) dealloc
{
    [self cancelAllRequests];
}

-(instancetype) init
{
    if (self = [super initWithFrame:CGRectMake(0, 0, LC_DEVICE_WIDTH, LC_DEVICE_HEIGHT + 20 - 60 + 5)]) {
        
        [self buildUI];
    }
    
    return self;
}

-(void) buildUI
{
//    UIView * header = UIView.view;
//    header.frame = CGRectMake(0, 0, self.viewFrameWidth, 64);
//    [header addTapGestureRecognizer:self selector:@selector(hide)];
//    self.ADD(header);
//    
//    
//    LCUIButton * backButton = LCUIButton.view;
//    backButton.viewFrameWidth = 48;
//    backButton.viewFrameHeight = 55 / 3 + 44;
//    backButton.viewFrameY = 10;
//    backButton.buttonImage = [UIImage imageNamed:@"NavigationBarDismiss.png" useCache:YES];
//    backButton.showsTouchWhenHighlighted = YES;
//    [backButton addTarget:self action:@selector(hideAction) forControlEvents:UIControlEventTouchUpInside];
//    backButton.tag = 1002;
//    [self addSubview:backButton];
//
//
    UIView * view = nil;

//    if (IOS8_OR_LATER) {
//        
//        view = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight]];
//    }
//    else{
    
        view = UIView.view;
        view.backgroundColor = LC_RGB(231, 231, 231);
//    }
    
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
    
    
//    self.searchBar = [[LKSearchBar alloc] initWithFrame:LC_RECT(backButton.viewRightX, 20 + (22 - 90 / 3 / 2), LC_DEVICE_WIDTH - backButton.viewFrameWidth - backButton.viewMidWidth, 30)];
//    self.searchBar.searchField.placeholder = LC_LO(@"搜索标签");
//    self.searchBar.delegate = self;
//    self.ADD(self.searchBar);

    
    self.placeholderView = LKSearchPlaceholderView.view;
    self.placeholderView.viewFrameWidth = self.viewFrameWidth;
    self.placeholderView.viewFrameHeight = self.viewFrameHeight;
    self.placeholderView.viewFrameY = 0;
    self.placeholderView.alpha = 0;
    self.ADD(self.placeholderView);

    @weakly(self);

    self.placeholderView.didTap = ^(){
      
        @normally(self);

        [self.searchBar.searchField resignFirstResponder];
    };
    
    self.placeholderView.didSelectRow = ^(NSString * tagString){
        
        LKSearchResultsViewController * search = [[LKSearchResultsViewController alloc] initWithSearchString:tagString];
        
        [LC_APPDELEGATE.home.navigationController pushViewController:search animated:YES];
    };

    
    self.hotTags = LKHotTagsSegmentView.view;
    self.ADD(self.hotTags);
    
    
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
}

#pragma mark -

- (void)searchBarTextDidChange:(INSSearchBar *)searchBar
{
    LC_FAST_ANIMATIONS(0.25, ^{
        
        self.placeholderView.alpha = 1;
        self.placeholderView.searchString = searchBar.searchField.text;
        [self searchPlaceHolderTags:searchBar.searchField.text];
    });
}

-(void) searchBarDidBeginEditing:(INSSearchBar *)searchBar editing:(BOOL)editing
{
    [self searchBarTextDidChange:searchBar];
}

- (void)searchBarDidTapReturn:(INSSearchBar *)searchBar
{
    [LKSearchHistory addHistory:searchBar.searchField.text];

    LKSearchResultsViewController * search = [[LKSearchResultsViewController alloc] initWithSearchString:searchBar.searchField.text];
    
    [LC_APPDELEGATE.home.navigationController pushViewController:search animated:YES];
}

#pragma mark -

-(void) showInViewController:(UIViewController *)viewController
{
    if (self.willShow) {
        self.willShow(nil);
    }
    
//    [viewController.view addSubview:self];
//    
//    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:1 initialSpringVelocity:3 options:UIViewAnimationOptionCurveEaseInOut animations:^{
//        
//    } completion:^(BOOL finished) {
//        
//    }];
}

-(void) hideAction
{
    if (self.placeholderView.alpha != 0) {
        
        LC_FAST_ANIMATIONS(0.25, ^{
           
            self.placeholderView.alpha = 0;
            self.placeholderView.searchString = @"";
            self.placeholderView.tags = nil;
            self.searchBar.searchField.text = @"";
            [self.searchBar.searchField resignFirstResponder];
        });
    }
    else{
        
        [self hide];
    }
}

-(void) hide
{
    if (self.willHide) {
        self.willHide(nil);
    }
    
//    UIView * view = self.FIND(1002);
//    self.userInteractionEnabled = NO;
    
//    LC_FAST_ANIMATIONS_F(0.25, ^{
//    
//        view.alpha = 0;
//        self.searchBar.alpha = 0;
//        ((UIView *)self.FIND(1002)).alpha = 0;
//        
//    }, ^(BOOL finished){
//        
//        [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:1 initialSpringVelocity:3 options:UIViewAnimationOptionCurveEaseInOut animations:^{
//            
//            view.alpha = 0;
//            self.searchBar.alpha = 0;
//            self.blur.viewFrameY = self.viewFrameHeight;
//            self.placeholderView.viewFrameY = self.viewFrameHeight;
//            
//            
//        } completion:^(BOOL finished) {
    
            //[self removeFromSuperview];
//        }];
//
//    });
    
}

#pragma mark -

-(void) buildPages:(NSArray *)tags
{
    self.scrollView.contentSize = CGSizeMake(self.scrollView.viewFrameWidth * tags.count, self.scrollView.viewFrameHeight);
    
    for (NSInteger i = 0; i<tags.count; i++) {
        
        LKTag * tag = tags[i];
        
        LKHotTagsPage * page = [[LKHotTagsPage alloc] initWithTag:tag];
        page.frame = CGRectMake(0, 0, self.scrollView.viewFrameWidth, self.scrollView.viewFrameHeight);
        page.viewFrameX = self.viewFrameWidth * i;
        page.tag = 100 + i;
        self.scrollView.ADD(page);

        if (i == 0) {
            
            [page performSelector:@selector(show) withObject:nil afterDelay:0];
        }
    }
}

-(void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    int page = (scrollView.contentOffset.x + LC_DEVICE_WIDTH / 2.0) / LC_DEVICE_WIDTH;

    if (self.page == page) {
        return;
    }
    
    LKHotTagsPage * pageView = self.scrollView.FIND(100 + page);
    
    if (pageView) {
        [pageView show];
    }
    else{
    
    }
    
    self.page = page;
    
    self.hotTags.selectIndex = page;
}

-(void) scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    //self.paging = NO;
}

-(void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //self.paging = NO;
}

-(void) searchPlaceHolderTags:(NSString *)searchString
{
    [self.placeholderView cancelAllRequests];

    
    if (searchString.length == 0) {
        
        self.placeholderView.tags = nil;
        return;
    }
    
    
    LKHttpRequestInterface * interface = [LKHttpRequestInterface interfaceType:[NSString stringWithFormat:@"tag/guess/%@" ,searchString.URLCODE()]].AUTO_SESSION();
    
    @weakly(self);
    
    [self.placeholderView request:interface complete:^(LKHttpRequestResult *result) {
        
        @normally(self);
        
        if (result.state == LKHttpRequestStateFinished) {
            
            NSArray * array = result.json[@"data"];
            
            NSMutableArray * tags = [NSMutableArray array];
            
            for (NSDictionary * dic in array) {
                
                LKTag * tag = [LKTag objectFromDictionary:dic];
                [tags addObject:tag];
            }
            
            self.placeholderView.tags = tags;

        }
        else if (result.state == LKHttpRequestStateFailed){
            
        }
        
    }];

}

@end
