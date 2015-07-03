//
//  LKSearchPlacesViewController.h
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/7/2.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LCUITableViewController.h"
#import <CoreLocation/CoreLocation.h>


LC_BLOCK(void, LKSearchPlacesDidSelected, (NSString * name, CLLocation * location));

@interface LKSearchPlacesViewController : LCUITableViewController

LC_PROPERTY(copy) LKSearchPlacesDidSelected didSelected;

@end
