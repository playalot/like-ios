//
//  LKNotificationCount.m
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/4/24.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKNotificationCount.h"
#import "M13BadgeView.h"

@interface LKNotificationCount ()

LC_PROPERTY(strong) UIView * bindView;

@end

@implementation LKNotificationCount

+(void) bindView:(UIView *)bindView
{
    [LKNotificationCount.singleton setBindView:bindView];
}

+ (void)bindView:(UIView *)bindView withBadgeCount:(NSInteger)badgeCount {

    M13BadgeView *badge = bindView.FIND(100100);
    NSString *cache =  LKUserDefaults.singleton[self.class.description];
    badge.text = LC_NSSTRING_FROM_INGERGER(cache.integerValue + badgeCount);
    LKUserDefaults.singleton[self.class.description] = LC_NSSTRING_FROM_INT(cache.integerValue + badgeCount);
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:badgeCount];
    
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
    
    @weakly(self);
    
    [self request:interface complete:^(LKHttpRequestResult *result) {
        
        @normally(self);
        
        if (result.state == LKHttpRequestStateFinished) {
            
            NSInteger count = [result.json[@"data"][@"count"] integerValue];
            
            [self setBadgeCount:count];
        }
        else if(result.state == LKHttpRequestStateFailed){
            
            
        };
    }];
}

-(void) setBadgeCount:(NSInteger)badgeCount
{
    M13BadgeView * badge = self.bindView.FIND(100100);
    badge.text = LC_NSSTRING_FROM_INT(badgeCount);
    //badge.viewFrameX = self.bindView.viewFrameWidth - badge.viewFrameWidth - self.bindView.viewMidWidth;
    
    LKUserDefaults.singleton[self.class.description] = LC_NSSTRING_FROM_INT(badgeCount);
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:badgeCount];
}

-(void) handleTimer:(NSTimer *)timer
{
//    M13BadgeView * badge = self.bindView.FIND(100100);
//    
//    NSInteger count = LC_RANDOM(0, 999);
//    
//    badge.text = LC_NSSTRING_FROM_INT(count);
}

-(void) setBindView:(UIView *)bindView
{
    _bindView = bindView;
    
    M13BadgeView * badge = _bindView.FIND(100100);
    
    if (badge) {
        [badge removeFromSuperview];
    }

    NSString * cache =  LKUserDefaults.singleton[self.class.description];

    badge = [[M13BadgeView alloc] init];
    badge.animateChanges = NO;
    badge.text = LC_NSSTRING_FROM_INGERGER(cache.integerValue);
    badge.textColor = LKColor.color;
    badge.badgeBackgroundColor = [UIColor whiteColor];
    badge.font = LK_FONT(10);
    badge.hidesWhenZero = YES;
    badge.tag = 100100;
    badge.verticalAlignment = M13BadgeViewVerticalAlignmentNone;
    badge.horizontalAlignment = M13BadgeViewHorizontalAlignmentLeft;
    badge.viewFrameY = 0;
    bindView.ADD(badge);
}

@end
