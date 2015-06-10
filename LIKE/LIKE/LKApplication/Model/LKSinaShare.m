//
//  LKSinaShare.m
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/5/19.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKSinaShare.h"
#import "WeiboSDK.h"

@implementation LKSinaShare

+(BOOL) shareImage:(UIImage *)image
{
    if (![WeiboSDK isWeiboAppInstalled]) {
        
        [LCUIAlertView showWithTitle:@"提示" message:@"您未安装微博客户端，无法分享" cancelTitle:@"知道了" otherTitle:nil didTouchedBlock:^(NSInteger integerValue) {
            
            ;
            
        }];
        return NO;
    }
    
    if (!image) {
        return NO;
    }
    
    
    WBImageObject * imageObject = [WBImageObject object];
    imageObject.imageData = UIImageJPEGRepresentation(image, 1);
    
    WBMessageObject * object = [[WBMessageObject alloc] init];
    object.imageObject = imageObject;
    object.text = @"分享自 #like-你的新玩具# http://www.likeorz.com";
    
    WBSendMessageToWeiboRequest * request = [WBSendMessageToWeiboRequest requestWithMessage:object];
    
    return [WeiboSDK sendRequest:request];    
}

@end
