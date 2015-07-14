//
//  NSNull+LCExtension.h
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/7/14.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNull (LCExtension)

LC_PROPERTY(readonly) NSInteger integerValue;
LC_PROPERTY(readonly) int intValue;
LC_PROPERTY(readonly) NSInteger length;

@end
