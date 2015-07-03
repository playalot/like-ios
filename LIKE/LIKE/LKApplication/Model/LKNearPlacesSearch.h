//
//  LKNearPlacesSearch.h
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/7/2.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

LC_BLOCK(void, LKNearPlacesSearchBlock, (NSArray * places, NSError * error));

@interface LKNearPlacesSearch : NSObject

LC_PROPERTY(copy) LKNearPlacesSearchBlock block;

-(void) requestNearPlacesWithLocation:(CLLocation *)location page:(NSInteger)page block:(LKNearPlacesSearchBlock)block;
-(void) requestNearPlacesWithLocation:(CLLocation *)location name:(NSString *)name block:(LKNearPlacesSearchBlock)block;

@end
