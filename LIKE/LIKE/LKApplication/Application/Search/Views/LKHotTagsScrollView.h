//
//  LKHotTagsScrollView.h
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/7/15.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LKHotTagsScrollView : UIScrollView

LC_PROPERTY(strong) NSArray * tags;

LC_PROPERTY(copy) LKValueChanged itemDidTap;

@end
