//
//  NSObject+LKTopHud.h
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/4/13.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RKDropdownAlert.h"

@interface NSObject (LKTopHud)

- (RKDropdownAlert *)showTopMessageErrorHud:(NSString *)message;
- (RKDropdownAlert *)showTopLoadingMessageHud:(NSString *)message;

@end
