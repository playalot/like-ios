//
//  LKShare.m
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/5/19.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKShare.h"
#import "LKWeChatShare.h"
#import "LKSinaShare.h"
#import "LKTencentShare.h"
#import "MobClick.h"

@implementation LKShare

+(BOOL) shareImageWithType:(LKShareType)type image:(UIImage *)image
{
    switch (type) {
        case LKShareTypeWeChatFriend: {
            
            return [LKWeChatShare shareImage:image timeLine:NO];
        }
            
        case LKShareTypeWeChatTimeLine: {
            
            return [LKWeChatShare shareImage:image timeLine:YES];
        }
            
        case LKShareTypeSina: {
            
            return [LKSinaShare shareImage:image];
            
            break;
        }
            
        case LKShareTypeQQ: {
            
            return [LKTencentShare shareImage:image];
            
            break;
            
        }
        default:
            
            return NO;
            break;
    }
    
    return NO;
}

@end
