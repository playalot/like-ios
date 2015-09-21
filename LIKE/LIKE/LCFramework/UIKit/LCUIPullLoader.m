//
//  UIPullLoader.m
//  LCFramework

//  Created by Licheng Guo . ( SUGGESTIONS & BUG titm@tom.com ) on 13-9-17.
//  Copyright (c) 2014年 Licheng Guo iOS developer ( http://nsobject.me ).All rights reserved.
//  Also see the copyright page ( http://nsobject.me/copyright.rtf ).
//
//

#import "LCUIPullLoader.h"

#import "UIScrollView+SVPullToRefresh.h"
#import "UIScrollView+SVInfiniteScrolling.h"

#pragma mark -

#undef	ANIMATION_DURATION
#define ANIMATION_DURATION	(0.3f)

#pragma mark -

@interface LCUIPullLoader()

LC_PROPERTY(assign) LCUIPullLoaderStyle style;

@end

#pragma mark -

@implementation LCUIPullLoader

-(void) dealloc
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

+ (id) pullLoaderWithScrollView:(UIScrollView *)scrollView
                      pullStyle:(LCUIPullLoaderStyle)pullStyle
{
    LCUIPullLoader * pull = [[LCUIPullLoader alloc] initWithScrollView:scrollView pullStyle:pullStyle];
    
    return pull;
}

- (id) initWithScrollView:(UIScrollView *)scrollView pullStyle:(LCUIPullLoaderStyle)pullStyle
{
    LC_SUPER_INIT({
        
        self.indicatorViewStyle = UIActivityIndicatorViewStyleGray;
        self.scrollView = scrollView;
        
        [self initSelf:@(pullStyle)];
        //[self performSelector:@selector(initSelf:) withObject:[NSNumber numberWithInteger:pullStyle] afterDelay:0];

    });
}

-(void) initSelf:(NSNumber *)pullStyle
{
    [self doInit:pullStyle.integerValue];
}

-(void) doInit:(NSInteger)index
{
    self.style = index;
    
    @weakly(self);
    
    switch (self.style) {
            
        case LCUIPullLoaderStyleHeader:
        {
            [self.scrollView addPullToRefreshWithActionHandler:^{
                
                @normally(self);
                
                [self handRefresh:LCUIPullLoaderDiretionTop];
            }];
            
            self.scrollView.pullToRefreshView.activityIndicatorViewStyle = self.indicatorViewStyle;
        }
            break;
            
        case LCUIPullLoaderStyleFooter:
        {
            [self.scrollView addInfiniteScrollingWithActionHandler:^{
                
                @normally(self);
                
                [self handRefresh:LCUIPullLoaderDiretionBottom];
                
            }];
            
            self.scrollView.infiniteScrollingView.activityIndicatorViewStyle = self.indicatorViewStyle;
        }
            break;
            
        case LCUIPullLoaderStyleHeaderAndFooter:
        {
            [self.scrollView addPullToRefreshWithActionHandler:^{
                
                @normally(self);
                
                [self handRefresh:LCUIPullLoaderDiretionTop];
            }];
            
            [self.scrollView addInfiniteScrollingWithActionHandler:^{
                
                @normally(self);
                
                [self handRefresh:LCUIPullLoaderDiretionBottom];
                
            }];
            
            self.scrollView.pullToRefreshView.activityIndicatorViewStyle = self.indicatorViewStyle;
            self.scrollView.infiniteScrollingView.activityIndicatorViewStyle = self.indicatorViewStyle;
        }
            break;
    }
}

-(void)handRefresh:(LCUIPullLoaderDiretion)diretion {
    if (self.beginRefresh) {
        self.beginRefresh(diretion);
    }
}

- (void) startRefresh
{
    if (self.scrollView.pullToRefreshView) {
        
        [self.scrollView triggerPullToRefresh];
    }
}

- (void) endRefresh
{
    [self endRefreshWithAnimated:YES];
}

- (void) endRefreshWithAnimated:(BOOL)animated
{
    if (self.scrollView.pullToRefreshView.state == SVPullToRefreshStateLoading) {
        [self.scrollView.pullToRefreshView stopAnimating];
    }
    
    if (self.scrollView.infiniteScrollingView.state == SVPullToRefreshStateLoading) {
        [self.scrollView.infiniteScrollingView stopAnimating];
    }
    
}

-(void) setCanLoadMore:(BOOL)canLoadMore
{
    _canLoadMore = canLoadMore;
    
    self.scrollView.infiniteScrollingView.enabled = _canLoadMore;
}


@end
