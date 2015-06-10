//
//  LKWeChatShare.m
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/5/19.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKWeChatShare.h"
#import "WXApi.h"

@implementation LKWeChatShare

+(BOOL) shareImage:(UIImage *)image timeLine:(BOOL)timeLine
{
    if (![WXApi isWXAppInstalled]) {
        
        [LCUIAlertView showWithTitle:@"提示" message:@"您未安装微信客户端，无法分享" cancelTitle:@"知道了" otherTitle:nil didTouchedBlock:^(NSInteger integerValue) {
           
            ;
            
        }];
        return NO;
    }
    
    if (!image) {
        return NO;
    }
    
    WXMediaMessage * message = [WXMediaMessage message];
    
    CGFloat compressionQuality = 0.5;
    NSData * thumbData = UIImageJPEGRepresentation([image scaleToWidth:300], compressionQuality);
    
    while (thumbData.length > 32 * 1024) {
        
        compressionQuality -= 0.1;
        thumbData = UIImageJPEGRepresentation([image scaleToWidth:300], compressionQuality);
    }
    
    message.thumbData = thumbData;
    message.title = @"like";

    WXImageObject * ext = [WXImageObject object];
    
    ext.imageData = UIImageJPEGRepresentation(image, 1);
    
    message.mediaObject = ext;
    
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = timeLine ? WXSceneTimeline : WXSceneSession;
    
    return [WXApi sendReq:req];
}

@end
