//
//  LKNotificationModel.m
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/4/22.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKNotificationModel.h"
#import "LKNotificationInterface.h"

@implementation LKNotificationModel

- (void)dealloc
{
    [self cancelAllRequests];
}

- (instancetype)init
{
    if (self = [super init]) {
        
        NSArray *tmp = LKUserDefaults.singleton[self.class.description];

        self.datasource = [NSMutableArray array];

        for (NSDictionary *data in tmp) {
            
            [self.datasource addObject:[[LKNotification alloc] initWithDictionary:data error:nil]];
        }
            
    }
    return self;
}

- (void)getNotificationsAtFirstPage:(BOOL)firstPage requestFinished:(LKNotificationModelRequestFinished)requestFinished
{
    @weakly(self);
    
    LKNotificationInterface *notificationInterface = [[LKNotificationInterface alloc] initWithTimestamp:self.timestamp firstPage:firstPage];
    
    @weakly(notificationInterface);
    
    [notificationInterface startWithCompletionBlockWithSuccess:^(LCBaseRequest *request) {
        
        @normally(notificationInterface);
        @normally(self);

        NSArray *tmp = notificationInterface.notifications;
        
        NSMutableArray *datasource = [NSMutableArray array];
        
        for (NSDictionary *dic in tmp) {
            
            [datasource addObject:[[LKNotification alloc] initWithDictionary:dic error:nil]];
        }
        
        if (firstPage) {
            
            self.datasource = datasource;
            
            // save cache...
            LKUserDefaults.singleton[self.class.description] = tmp;
        }
        else{
            
            [self.datasource addObjectsFromArray:datasource];
        }
        
        self.timestamp = ((LKComment *)self.datasource.lastObject).timestamp.integerValue;
        
        if (requestFinished) {
            requestFinished(nil);
        }

    } failure:^(LCBaseRequest *request) {
        
//        if (requestFinished) {
//            requestFinished(result.error);
//        }
    }];
    
//    LKHttpRequestInterface * interface = [LKHttpRequestInterface interfaceType:@"notification"].AUTO_SESSION();
//    
//    if (!firstPage) {
//        
//        [interface addParameter:@(self.timestamp) key:@"ts"];
//    }
//    
//    @weakly(self);
//    
//    [self request:interface complete:^(LKHttpRequestResult *result) {
//       
//        @normally(self);
//        
//        if (result.state == LKHttpRequestStateFinished) {
//                        
//            NSArray *tmp = result.json[@"data"][@"notifications"];
//            
//            NSMutableArray *datasource = [NSMutableArray array];
//            
//            for (NSDictionary *dic in tmp) {
//
//                [datasource addObject:[[LKNotification alloc] initWithDictionary:dic error:nil]];
//            }
//            
//            if (firstPage) {
//                
//                self.datasource = datasource;
//                
//                // save cache...
//                LKUserDefaults.singleton[self.class.description] = tmp;
//            }
//            else{
//                
//                [self.datasource addObjectsFromArray:datasource];
//            }
//            
//            self.timestamp = ((LKComment *)self.datasource.lastObject).timestamp.integerValue;
//            
//            if (requestFinished) {
//                requestFinished(nil);
//            }
//        }
//        else if (result.state == LKHttpRequestStateFailed){
//            
//            if (requestFinished) {
//                requestFinished(result.error);
//            }
//        }
//        
//    }];
}

@end
