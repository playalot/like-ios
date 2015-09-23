//
//  LKUserCenterViewController.h
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/4/15.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LCUIViewController.h"
#import "LKUserCenterModel.h"
#import "LKUserInfoModel.h"

LC_NOTIFICATION_SET(LKUserCenterViewControllerReloadingData);

@interface LKUserCenterViewController : LCUIViewController

LC_PROPERTY(assign) BOOL needBackButton;
LC_PROPERTY(strong) LKUserInfoModel *userInfoModel;;
LC_PROPERTY(strong) LKUser *user;

- (void)scrollToPostByIndex:(NSInteger)index;
- (void)loadData:(LKUserCenterModelType)type diretion:(LCUIPullLoaderDiretion)diretion;
- (void)updateUserMetaInfo;
- (instancetype)initWithUser:(LKUser *)user;

+ (LKUserCenterViewController *)pushUserCenterWithUser:(LKUser *)user navigationController:(UINavigationController *)navigationController;

@end
