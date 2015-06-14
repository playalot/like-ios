//
//  NSObject+LKTopHud.m
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/4/13.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "NSObject+LKTopHud.h"

@implementation NSObject (LKTopHud)

- (RKDropdownAlert *)showTopMessageErrorHud:(NSString *)message
{
    return [RKDropdownAlert title:message backgroundColor:LC_RGBA(255, 66, 75, 1) textColor:[UIColor whiteColor] time:3];
}

- (RKDropdownAlert *)showTopLoadingMessageHud:(NSString *)message
{
    return [RKDropdownAlert title:message backgroundColor:[[UIColor whiteColor] colorWithAlphaComponent:0.9] textColor:LC_RGBA(255, 66, 75, 1) time:10000];
}


@end
