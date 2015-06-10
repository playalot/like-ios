//
//  LKUserCenterViewController.h
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/4/15.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LCUIViewController.h"

@class LKUserInfoModel;

LC_NOTIFICATION_SET(LKUserCenterViewControllerReloadingData);

@interface LKUserCenterViewController : LCUIViewController

LC_PROPERTY(strong) LKUserInfoModel * userInfoModel;;
LC_PROPERTY(strong) LKUser * user;

+(LKUserCenterViewController *) pushUserCenterWithUser:(LKUser *)user navigationController:(UINavigationController *)navigationController;

-(instancetype) initWithUser:(LKUser *)user;

@end
