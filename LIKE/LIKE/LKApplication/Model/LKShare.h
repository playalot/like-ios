//
//  LKShare.h
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/5/19.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, LKShareType)
{
    LKShareTypeWeChatFriend = 0,
    LKShareTypeWeChatTimeLine,
    LKShareTypeQQ,
    LKShareTypeSina,
};

@interface LKShare : NSObject

+(BOOL) shareImageWithType:(LKShareType)type image:(UIImage *)image;

@end
