//
//  LKCommentsView.h
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/5/28.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LKTag.h"

@interface LKCommentsView : UIView

LC_PROPERTY(copy) LKValueChanged reply;
LC_PROPERTY(copy) LKValueChanged showMore;

LC_PROPERTY(strong) LKTag * tagValue;

@end
