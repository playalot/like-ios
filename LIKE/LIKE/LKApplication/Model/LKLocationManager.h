//
//  LKLocationManager.h
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/7/1.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <AMapSearchKit/AMapSearchObj.h>

LC_BLOCK(void, LKLocationManagerBlock, (CLLocation * location, AMapReGeocode * regeocode, NSError * error));

@interface LKLocationManager : NSObject

LC_PROPERTY(copy) LKLocationManagerBlock block;

LC_PROPERTY(strong) CLLocation * location;

-(void) requestCurrentLocationWithBlock:(LKLocationManagerBlock)block;

@end
