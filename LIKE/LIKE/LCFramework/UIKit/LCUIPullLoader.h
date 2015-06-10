//
//  UIPullLoader.h
//  LCFramework

//  Created by Licheng Guo . ( SUGGESTIONS & BUG titm@tom.com ) on 13-9-17.
//  Copyright (c) 2014年 Licheng Guo iOS developer ( http://nsobject.me ).All rights reserved.
//  Also see the copyright page ( http://nsobject.me/copyright.rtf ).
//
//

#import "LCUIActivityIndicatorView.h"

typedef NS_ENUM (NSInteger, LCUIPullLoaderDiretion)
{
    LCUIPullLoaderDiretionTop = 0,
    LCUIPullLoaderDiretionBottom = 1,
};

typedef NS_ENUM (NSInteger, LCUIPullLoaderStyle)
{
    LCUIPullLoaderStyleHeader = 0,
    LCUIPullLoaderStyleFooter = 1,
    LCUIPullLoaderStyleHeaderAndFooter = 2,
};

@class LCUIPullLoader;

LC_BLOCK(void, LCUIPullLoaderDidBeginRefresh, (LCUIPullLoaderDiretion diretion));

@interface LCUIPullLoader : NSObject

LC_PROPERTY(copy) LCUIPullLoaderDidBeginRefresh beginRefresh;
LC_PROPERTY(assign) UIScrollView * scrollView;
LC_PROPERTY(assign) BOOL canLoadMore;
LC_PROPERTY(assign) UIActivityIndicatorViewStyle indicatorViewStyle;

LC_PROPERTY(readonly) LCUIPullLoaderStyle style;

+ (instancetype) pullLoaderWithScrollView:(UIScrollView *)scrollView
                                pullStyle:(LCUIPullLoaderStyle)pullStyle;

- (instancetype) initWithScrollView:(UIScrollView *)scrollView
                          pullStyle:(LCUIPullLoaderStyle)pullStyle;


- (void) startRefresh;
- (void) endRefresh;
- (void) endRefreshWithAnimated:(BOOL)animated;

@end
