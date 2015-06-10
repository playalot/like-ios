//
//  LKNotificationCount.m
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/4/24.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKNotificationCount.h"

@interface LKNotificationCount ()

LC_PROPERTY(strong) UIView * bindView;

@end

@implementation LKNotificationCount

+(void) bindView:(UIView *)bindView
{
    [LKNotificationCount.singleton setBindView:bindView];
}

+(void) cleanBadge
{
    [LKNotificationCount.singleton setBadgeCount:0];
}

+(void) startCheck
{
    [LKNotificationCount.singleton startCheck];
}

+(void) stopCheck
{
    [LKNotificationCount.singleton stopCheck];
}

-(void) startCheck
{
    [self cancelAllRequests];
    [self cancelAllTimers];
    
    if (!LKLocalUser.singleton.isLogin) {
        
        [self setBadgeCount:0];
    }
    else{
        
        [self checkTimerStart];
    }
}

-(void) stopCheck
{
    [self cancelAllTimers];
}

-(void) checkTimerStart
{
    [self checkRequest];
    [self fireTimer:@"Check" timeInterval:60 * 2 repeat:YES];
}

-(void) checkRequest
{
    LKHttpRequestInterface * interface = [LKHttpRequestInterface interfaceType:@"notification/count"].AUTO_SESSION();
    interface.customAPIURL = LK_API2;
    
    
    @weakly(self);
    
    [self request:interface complete:^(LKHttpRequestResult *result) {
        
        @normally(self);
        
        if (result.state == LKHttpRequestStateFinished) {
            
            [self setBadgeCount:[result.json[@"data"][@"count"] integerValue]];
        }
        else if(result.state == LKHttpRequestStateFailed){
            
            
        };
    }];
}

-(void) setBadgeCount:(NSInteger)badgeCount
{
    LCUIBadgeView * badge = self.bindView.FIND(100100);
    badge.valueString = LC_NSSTRING_FROM_INT(badgeCount);
    
    LKUserDefaults.singleton[self.class.description] = LC_NSSTRING_FROM_INT(badgeCount);
}

-(void) setBindView:(UIView *)bindView
{
    _bindView = bindView;
    
    LCUIBadgeView * badge = _bindView.FIND(100100);
    
    if (badge) {
        [badge removeFromSuperview];
    }
    
    NSString * cache =  LKUserDefaults.singleton[self.class.description];
    
    badge = [[LCUIBadgeView alloc] initWithFrame:CGRectZero valueString:@"99"];
    badge.hiddenWhenEmpty = YES;
    badge.valueString = LC_NSSTRING_FROM_INGERGER(cache.integerValue);
    badge.viewFrameX = bindView.viewFrameWidth - badge.viewMidWidth - 50 + 4;
    badge.viewFrameY = - badge.viewMidHeight + 50;
    badge.tag = 100100;
    bindView.ADD(badge);
}

@end
