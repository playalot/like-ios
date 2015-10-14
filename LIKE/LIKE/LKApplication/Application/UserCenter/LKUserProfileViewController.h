//
//  LKUserProfileViewController.h
//  LIKE
//
//  Created by huangweifeng on 10/9/15.
//  Copyright © 2015 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LCUIViewController.h"
#import "LKUserCenterModel.h"
#import "LKUserInfoModel.h"

@interface LKUserProfileViewController : LCUIViewController

LC_PROPERTY(assign) BOOL needBackButton;
LC_PROPERTY(assign) BOOL settingButtonHidden;

LC_PROPERTY(strong) LKUserInfoModel *userInfoModel;;
LC_PROPERTY(strong) LKUser *user;

- (void)scrollToPostByIndex:(NSInteger)index;
- (void)loadData:(LKUserCenterModelType)type diretion:(LCUIPullLoaderDiretion)diretion;
- (void)updateUserMetaInfo;
- (instancetype)initWithUser:(LKUser *)user;

- (void)refresh;

@end
