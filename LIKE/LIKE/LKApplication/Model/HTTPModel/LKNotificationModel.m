//
//  LKNotificationModel.m
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/4/22.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKNotificationModel.h"

@implementation LKNotificationModel

- (void)dealloc
{
    [self cancelAllRequests];
}

- (instancetype)init
{
    if (self = [super init]) {
        
        NSArray * tmp = LKUserDefaults.singleton[self.class.description];

        self.datasource = [NSMutableArray array];
        self.likesArray = [NSMutableArray array];
        self.followsArray = [NSMutableArray array];
        
        for (NSDictionary *data in tmp) {
            
            NSString *type = data[@"type"];
            
            if ([type isEqualToString:@"LIKE"]) {
                
                [self.likesArray addObject:[[LKNotification alloc] initWithDictionary:data error:nil]];
                
            } else if ([type isEqualToString:@"FOLLOW"]) {
                
                [self.followsArray addObject:[[LKNotification alloc] initWithDictionary:data error:nil]];
                
            } else if ([type isEqualToString:@"MESSAGE"]) {
                
                
            } else {
                
                [self.datasource addObject:[[LKNotification alloc] initWithDictionary:data error:nil]];
            }
        }
    }
    
    return self;
}

- (void)getNotificationsAtFirstPage:(BOOL)firstPage requestFinished:(LKNotificationModelRequestFinished)requestFinished type:(LKNotificationModelType)type
{
    LKHttpRequestInterface * interface = [LKHttpRequestInterface interfaceType:@"notification"].AUTO_SESSION();
    
    if (!firstPage) {
        
        if (type == LKNotificationModelTypeLike) {
            
            [interface addParameter:@(self.likeTimestamp) key:@"ts"];
            
        } else if (type == LKNotificationModelTypeFollow) {
            
            [interface addParameter:@(self.followTimestamp) key:@"ts"];

        } else if (type == LKNotificationModelTypeOther) {
            
            [interface addParameter:@(self.timestamp) key:@"ts"];
        }
    }
    
    
    @weakly(self);
    
    [self request:interface complete:^(LKHttpRequestResult *result) {
       
        @normally(self);
        
        if (result.state == LKHttpRequestStateFinished) {
                        
            NSArray * tmp = result.json[@"data"][@"notifications"];
            
            NSMutableArray *datasource = [NSMutableArray array];
            NSMutableArray *likesArray = [NSMutableArray array];
            NSMutableArray *followsArray = [NSMutableArray array];
            
            for (NSDictionary * dic in tmp) {
                
                NSString *type = dic[@"type"];
                
                if ([type isEqualToString:@"LIKE"]) {
                    
                    [likesArray addObject:[[LKNotification alloc] initWithDictionary:dic error:nil]];
                    
                } else if ([type isEqualToString:@"FOLLOW"]) {
                    
                    [followsArray addObject:[[LKNotification alloc] initWithDictionary:dic error:nil]];

                } else if ([type isEqualToString:@"MESSAGE"]) {
                    
                } else {
                    
                    [datasource addObject:[[LKNotification alloc] initWithDictionary:dic error:nil]];
                }
            }
            
            if (firstPage) {
                
                self.datasource = datasource;
                self.likesArray = likesArray;
                self.followsArray = followsArray;
                
                // save cache...
                LKUserDefaults.singleton[self.class.description] = tmp;
            }
            else{
                
                [self.datasource addObjectsFromArray:datasource];
                [self.likesArray addObjectsFromArray:likesArray];
                [self.followsArray addObjectsFromArray:followsArray];
            }
            
            self.timestamp = ((LKComment *)self.datasource.lastObject).timestamp.integerValue;
            self.likeTimestamp = ((LKComment *)self.likesArray.lastObject).timestamp.integerValue;
            self.followTimestamp = ((LKComment *)self.followsArray.lastObject).timestamp.integerValue;
            
            if (requestFinished) {
                requestFinished(nil);
            }
        }
        else if (result.state == LKHttpRequestStateFailed){
            
            if (requestFinished) {
                requestFinished(result.error);
            }
        }
        
    }];
}

@end
