//
//  LKHomeViewController.h
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/4/13.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LCUIViewController.h"
#import "LKHomepageHeader.h"

LC_NOTIFICATION_SET(LKHomeViewControllerAddNewPost);
LC_NOTIFICATION_SET(LKHomeViewControllerUpdateHeader);
LC_NOTIFICATION_SET(LKHomeViewControllerReloadingData);

@interface LKHomeViewController : LCUIViewController

LC_PROPERTY(strong) LKHomepageHeader * header;

-(void) notificationAction;

@end
