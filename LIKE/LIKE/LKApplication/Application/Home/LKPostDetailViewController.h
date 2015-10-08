//
//  LKPostDetailViewController.h
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/4/20.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LCUIViewController.h"
#import "LKPost.h"
#import "LKHomepageHeader.h"

@protocol LKPostDetailViewControllerDelegate;
@protocol LKPostDetailViewControllerCancelFavorDelegate;

@interface LKPostDetailViewController : LCUIViewController

LC_PROPERTY(strong) LKHomepageHeader * header;
LC_PROPERTY(strong) LCUITableView * tableView;
LC_PROPERTY(strong) LKPost * post;

- (instancetype)initWithPost:(LKPost *)post;

- (void)openCommentsView:(LKTag *)tag;

- (void)setPresendModelAnimationOpen;

@property (nonatomic, weak) id <LKPostDetailViewControllerDelegate> delegate;
@property (nonatomic, weak) id <LKPostDetailViewControllerCancelFavorDelegate> cancelFavordelegate;

@end

@protocol LKPostDetailViewControllerDelegate <NSObject>

- (void)postDetailViewController:(LKPostDetailViewController *)ctrl didUpdatedPost:(LKPost *)post;
- (void)postDetailViewController:(LKPostDetailViewController *)ctrl didFavouritePost:(LKPost *)post;
- (void)postDetailViewController:(LKPostDetailViewController *)ctrl didUnfavouritePost:(LKPost *)post;

@end

@protocol LKPostDetailViewControllerCancelFavorDelegate <NSObject>

- (void)postDetailViewController:(LKPostDetailViewController *)ctrl didcancelFavorWithPost:(LKPost *)post;

@end
