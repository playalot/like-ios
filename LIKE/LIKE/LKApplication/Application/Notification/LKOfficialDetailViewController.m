//
//  LKOfficialDetailViewController.m
//  LIKE
//
//  Created by Elkins.Zhao on 15/9/18.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKOfficialDetailViewController.h"
#import <WebKit/WebKit.h>

@interface LKOfficialDetailViewController () <WKNavigationDelegate, WKUIDelegate>

LC_PROPERTY(strong) WKWebView *webView;
LC_PROPERTY(strong) UIProgressView *progressView;

@end

@implementation LKOfficialDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavigationBarButton:LCUINavigationBarButtonTypeLeft image:[UIImage imageNamed:@"NavigationBarBack.png" useCache:YES] selectImage:nil];

    self.webView = [[WKWebView alloc] initWithFrame:self.view.frame];
    self.webView.navigationDelegate = self;
    self.webView.UIDelegate = self;
    self.view.ADD(self.webView);
    
    self.progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0, LC_DEVICE_WIDTH, 1)];
    self.view.ADD(self.progressView);
    
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    
    NSURL *url = [NSURL URLWithString:@"http://www.likeorz.com"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        self.progressView.hidden = self.webView.estimatedProgress == 1;
        [self.progressView setProgress:(CGFloat)self.webView.estimatedProgress animated:YES];
    }
}

- (void)handleNavigationBarButton:(LCUINavigationBarButtonType)type {
    
    if (type == LCUINavigationBarButtonTypeLeft) {
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - ***** WKNavigationDelegate *****
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    
    NSLog(@"%@", error.debugDescription);
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    
    NSLog(@"%@", error.debugDescription);
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    
    [self.progressView setProgress:0.0 animated:NO];
}

#pragma mark - ***** WKUIDelegate *****
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)())completionHandler {
    
    [LCUIAlertView showWithTitle:LC_LO(@"提示") message:@"测试wkWebView" cancelTitle:@"取消" otherTitle:@"确定" didTouchedBlock:^(NSInteger integerValue) {
        
    }];
}

@end
