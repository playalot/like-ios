//
//  LKSearchViewController.m
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/5/26.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKSearchViewController.h"
#import "LKSearchBar.h"
#import "LKSearchPlaceholderView.h"
#import "LKHotTagsView.h"
#import "LKTag.h"
#import "LKSearchResultsViewController.h"
#import "AppDelegate.h"

@interface LKSearchViewController ()<INSSearchBarDelegate>

LC_PROPERTY(strong) LCUITableView * tableView;
LC_PROPERTY(strong) LCUIBlurView * blur;
LC_PROPERTY(assign) UIViewController * inViewController;
LC_PROPERTY(strong) LKSearchBar * searchBar;
LC_PROPERTY(strong) LKSearchPlaceholderView * placeholderView;


@end

@implementation LKSearchViewController

-(void) dealloc
{
    [self cancelAllRequests];
}

-(instancetype) init
{
    if (self = [super initWithFrame:CGRectMake(0, 0, LC_DEVICE_WIDTH, LC_DEVICE_HEIGHT + 20)]) {
        
        [self buildUI];
    }
    
    return self;
}

-(void) buildUI
{
    UIView * header = UIView.view;
    header.frame = CGRectMake(0, 0, self.viewFrameWidth, 64);
    [header addTapGestureRecognizer:self selector:@selector(hide)];
    self.ADD(header);
    
    
    LCUIButton * backButton = LCUIButton.view;
    backButton.viewFrameWidth = 48;
    backButton.viewFrameHeight = 55 / 3 + 44;
    backButton.viewFrameY = 10;
    backButton.buttonImage = [UIImage imageNamed:@"NavigationBarDismiss.png" useCache:YES];
    backButton.showsTouchWhenHighlighted = YES;
    [backButton addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
    backButton.tag = 1002;
    [self addSubview:backButton];

    
    self.blur = LCUIBlurView.view;
    self.blur.viewFrameY = 64;
    self.blur.viewFrameWidth = self.viewFrameWidth;
    self.blur.viewFrameHeight = self.viewFrameHeight - 64;
    self.blur.tintColor = [UIColor whiteColor];
    self.ADD(self.blur);


    self.searchBar = [[LKSearchBar alloc] initWithFrame:LC_RECT(backButton.viewRightX, 20 + (22 - 90 / 3 / 2), LC_DEVICE_WIDTH - backButton.viewFrameWidth - backButton.viewMidWidth, 30)];
    self.searchBar.searchField.placeholder = LC_LO(@"搜索标签");
    self.searchBar.delegate = self;
    self.ADD(self.searchBar);

    
    [self.searchBar.searchField performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.5];

    
    self.placeholderView = LKSearchPlaceholderView.view;
    self.placeholderView.viewFrameWidth = self.viewFrameWidth;
    self.placeholderView.viewFrameHeight = self.viewFrameHeight - 64;
    self.placeholderView.viewFrameY = 64;
    self.placeholderView.alpha = 0;
    self.ADD(self.placeholderView);

    self.placeholderView.didSelectRow = ^(NSString * tagString){
        
        LKSearchResultsViewController * search = [[LKSearchResultsViewController alloc] initWithSearchString:tagString];
        
        [LC_APPDELEGATE.home.navigationController pushViewController:search animated:YES];
    };

    
    LKHotTagsView * hotTags = LKHotTagsView.view;
    hotTags.viewFrameY = 10;
    hotTags.viewFrameX = 10;
    hotTags.viewFrameWidth = self.viewFrameWidth - 20;
    self.blur.ADD(hotTags);
    
    hotTags.itemDidTap = ^(LKHotTagItem * item){
      
        LKSearchResultsViewController * search = [[LKSearchResultsViewController alloc] initWithSearchString:item.tagString];
        
        [LC_APPDELEGATE.home.navigationController pushViewController:search animated:YES];
    };
    
    [hotTags performSelector:@selector(loadHotTags) withObject:nil afterDelay:0];
}

#pragma mark -

- (void)searchBarTextDidChange:(INSSearchBar *)searchBar
{
    LC_FAST_ANIMATIONS(0.25, ^{
        
        if (searchBar.searchField.text.length) {
            
            self.placeholderView.alpha = 1;
            self.placeholderView.searchString = searchBar.searchField.text;
            [self searchPlaceHolderTags:searchBar.searchField.text];
        }
        else{
            
            self.placeholderView.alpha = 0;
        }
        
    });
}

- (void)searchBarDidTapReturn:(INSSearchBar *)searchBar
{
    LKSearchResultsViewController * search = [[LKSearchResultsViewController alloc] initWithSearchString:searchBar.searchField.text];
    
    [LC_APPDELEGATE.home.navigationController pushViewController:search animated:YES];
}

#pragma mark -

-(void) showInViewController:(UIViewController *)viewController
{
    //self.inViewController = viewController;
    
    UIView * view = self.FIND(1002);
    view.alpha = 0;
    
    
    self.searchBar.alpha = 0;
    self.blur.viewFrameY = self.viewFrameHeight;
    
    [viewController.view addSubview:self];
    
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:1 initialSpringVelocity:3 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        view.alpha = 1;
        
        self.blur.viewFrameY = 64;
        self.searchBar.alpha = 1;
        
    } completion:^(BOOL finished) {
        
    }];
    
}

-(void) hide
{
    if (self.willHide) {
        self.willHide();
    }
    
    UIView * view = self.FIND(1002);
    self.userInteractionEnabled = NO;
    
    LC_FAST_ANIMATIONS_F(0.25, ^{
    
        view.alpha = 0;
        self.searchBar.alpha = 0;
        ((UIView *)self.FIND(1002)).alpha = 0;
        
    }, ^(BOOL finished){
        
        [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:1 initialSpringVelocity:3 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            
            view.alpha = 0;
            self.searchBar.alpha = 0;
            self.blur.viewFrameY = self.viewFrameHeight;
            self.placeholderView.viewFrameY = self.viewFrameHeight;
            
            
        } completion:^(BOOL finished) {
            
            [self removeFromSuperview];
        }];

    });
    
}

#pragma mark -

-(void) searchPlaceHolderTags:(NSString *)searchString
{
    [self.placeholderView cancelAllRequests];

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
