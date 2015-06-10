//
//  LC_WebViewController.h
//  LCFramework

//  Created by Licheng Guo . ( SUGGESTIONS & BUG titm@tom.com ) on 13-9-21.
//  Copyright (c) 2014年 Licheng Guo iOS developer ( http://nsobject.me ).All rights reserved.
//  Also see the copyright page ( http://nsobject.me/copyright.rtf ).
//
//

#import "LCUIViewController.h"

typedef NS_ENUM (NSInteger ,LCUIWebViewState)
{
    LCUIWebViewStateLoading = 0,
    LCUIWebViewStateRefresh = 1,
};

@interface LCUIWebViewController : LCUIViewController

LC_PROPERTY(strong) UIWebView * mainWebView;
LC_PROPERTY(strong) NSURL * URL;
LC_PROPERTY(assign) BOOL showDismissButton;

- (id)initWithAddress:(NSString *) urlString;
- (id)initWithURL:(NSURL *) pageURL;

- (void)setHtml:(NSString *)string;
- (void)setFile:(NSString *)path;
- (void)setResource:(NSString *)path;

@end
