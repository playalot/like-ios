//
//  LC_WebViewController.m
//  LCFramework

//  Created by Licheng Guo . ( SUGGESTIONS & BUG titm@tom.com ) on 13-9-21.
//  Copyright (c) 2014年 Licheng Guo iOS developer ( http://nsobject.me ).All rights reserved.
//  Also see the copyright page ( http://nsobject.me/copyright.rtf ).
//
//

#import "LCUIWebViewController.h"

#pragma mark - 

@interface LCUIWebViewController () <UIWebViewDelegate,UIActionSheetDelegate>

@end

#pragma mark -

@implementation LCUIWebViewController

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.navigationController setToolbarHidden:YES animated:animated];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setToolbarHidden:NO animated:animated];
}

- (id)initWithAddress:(NSString *)urlString
{
    return [self initWithURL:[NSURL URLWithString:urlString]];
}

- (id)initWithURL:(NSURL*)pageURL
{
    LC_SUPER_INIT({
            
        self.URL = pageURL;
    });
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.navigationController.viewControllers.count)
    {
        [self setNavigationBarButton:LCUINavigationBarButtonTypeLeft image:[UIImage imageNamed:@"NavigationBarBack.png" useCache:YES] selectImage:nil];
    }
    
    [self setupToolBar];
    
    self.mainWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.viewFrameWidth, self.view.viewFrameHeight - 44 - 40)];
    self.mainWebView.delegate = self;
    self.mainWebView.scalesPageToFit = YES;
    
    if (self.URL) {
        [self.mainWebView performSelector:@selector(loadRequest:) withObject:[NSURLRequest requestWithURL:self.URL] afterDelay:0];
    }
    
    self.view = self.mainWebView;
}

-(void) setShowDismissButton:(BOOL)showDismissButton
{
    if (showDismissButton){
        
        [self setNavigationBarButton:LCUINavigationBarButtonTypeLeft image:[UIImage imageNamed:@"navbar_btn_back.png" useCache:YES] selectImage:[UIImage imageNamed:@"navbar_btn_back_pressed.png" useCache:YES]];

    }else{
        
        self.navigationItem.leftBarButtonItem = nil;
    }
}

-(void) setupToolBar
{
    UIBarButtonItem * backItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"LC_WebBack.png" useCache:NO]
                                                                           style:UIBarButtonItemStylePlain
                                                                          target:self
                                                                          action:@selector(goBackClicked)];
    
    UIBarButtonItem * forwardItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"LC_WebForward.png" useCache:NO]
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(goForwardClicked)];
    
    UIBarButtonItem * actionItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                                          target:self
                                                                                          action:@selector(actionButtonClicked)];

    UIBarButtonItem * flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];

    
    
    NSArray * items = @[flexItem,backItem,flexItem,forwardItem,flexItem,actionItem,flexItem];
    LC_RELEASE(backItem);
    LC_RELEASE(forwardItem);
    LC_RELEASE(actionItem);
    LC_RELEASE(flexItem);
    
    self.toolbarItems = items;
    
    [self.navigationController setToolbarHidden:NO animated:YES];
    
    [self setLoadingState:LCUIWebViewStateRefresh];
}

-(void) setLoadingState:(LCUIWebViewState)type
{
    switch (type) {
            
        case LCUIWebViewStateLoading:
        {
            LCUIActivityIndicatorView * activity = [LCUIActivityIndicatorView grayView];
            [activity startAnimating];

            [self setNavigationBarButton:LCUINavigationBarButtonTypeRight customView:activity];
        }
            break;
            
        case LCUIWebViewStateRefresh:
        {
            UIImageView * refreshImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"crop_rotate.png" useCache:NO]];
            refreshImage.userInteractionEnabled = YES;
            
            UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(refreshWebView)];
            [refreshImage addGestureRecognizer:tap];
            LC_RELEASE(tap);
            
            [self setNavigationBarButton:LCUINavigationBarButtonTypeRight customView:refreshImage];
        }
            break;
            
        default:
            break;
    }
}

LC_HANDLE_NAVIGATION_BUTTON(type)
{
    if (type == LCUINavigationBarButtonTypeLeft) {
        
        [self dismissOrPopViewController];
    }
}

#pragma mark -

-(void) goBackClicked
{
    [_mainWebView goBack];

}

-(void) goForwardClicked
{
    [_mainWebView goForward];
}

-(void) actionButtonClicked
{
    LCUIActionSheet.VIEW.TITLE(@"More").ADD(@"Copy URL").ADD(@"Open in safari").SHOW(self.view).DID_SELECTED = ^(NSInteger index){
        
        if (index == 0) {
            
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            [pasteboard setString:[self.mainWebView.request.URL absoluteString]];
            
        }
        else if (index == 1){
            
            [[UIApplication sharedApplication] openURL:self.mainWebView.request.URL];
        }
    };
}

-(void) refreshWebView
{
    if (self.mainWebView.request.URL) {
        [self setURL:self.mainWebView.request.URL];
    }
}

- (void)setHtml:(NSString *)string
{
	[_mainWebView loadHTMLString:string baseURL:nil];
}

- (void)setFile:(NSString *)path
{
	NSData * data = [NSData dataWithContentsOfFile:path];
    
	if ( data )
	{
		[_mainWebView loadData:data MIMEType:@"text/html" textEncodingName:@"UTF8" baseURL:nil];
	}
}

- (void)setResource:(NSString *)path
{
	NSString * extension = [path pathExtension];
	NSString * fullName = [path substringToIndex:(path.length - extension.length - 1)];
    
	NSString * path2 = [[NSBundle mainBundle] pathForResource:fullName ofType:extension];
	NSData * data = [NSData dataWithContentsOfFile:path2];
    
	if ( data )
	{
		[_mainWebView loadData:data MIMEType:@"text/html" textEncodingName:@"UTF8" baseURL:nil];
	}
}

- (void)setURL:(NSURL *)URL
{
	if ( nil == URL )
		return;
	
    
    NSString * obsolute = URL.absoluteString;
    
    if ([obsolute rangeOfString:@"://"].length) {
        
    }else{

        URL = [NSURL URLWithString:LC_NSSTRING_FORMAT(@"http://%@",obsolute)];
    }

    _URL = URL;
    
	NSArray * cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];

	for ( NSHTTPCookie * cookie in cookies ){
		[[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
	}
	   
	[_mainWebView loadRequest:[NSURLRequest requestWithURL:URL]];
}

#pragma mark -

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self setLoadingState:LCUIWebViewStateLoading];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self setLoadingState:LCUIWebViewStateRefresh];
    
    self.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self setLoadingState:LCUIWebViewStateRefresh];
}



@end
