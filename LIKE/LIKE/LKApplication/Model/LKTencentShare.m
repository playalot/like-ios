//
//  LKTencentShare.m
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/5/19.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKTencentShare.h"
#import <TencentOpenAPI/QQApiInterface.h>
#import "MobClick.h"

@implementation LKTencentShare

+(BOOL) shareImage:(UIImage *)image
{
    if (![QQApiInterface isQQInstalled]) {
        
        [LCUIAlertView showWithTitle:LC_LO(@"提醒") message:LC_LO(@"您未安装QQ客户端，无法分享") cancelTitle:LC_LO(@"好的") otherTitle:nil didTouchedBlock:^(NSInteger integerValue) {
            
            ;
            
        }];
        return NO;
    }
    
    if (!image) {
        return NO;
    }
    
    
//    QQApiImageObject * object = [[QQApiImageObject alloc] init];
//    object.title = @"like";
//    object.previewImageData = UIImageJPEGRepresentation([image scaleToWidth:300], 0.5);
//    object.data = UIImageJPEGRepresentation(image, 1);
//
//    QQApiMessage * apiMessage = [[QQApiMessage alloc] initWithObject:object andType:QQApiMessageTypeSendMessageToQQRequest];
//    
//    return [QQApi sendMessage:apiMessage];
    
    //
    QQApiImageObject *imgObj = [QQApiImageObject objectWithData:UIImageJPEGRepresentation(image, 1)
                                               previewImageData:UIImageJPEGRepresentation([image scaleToWidth:300], 0.5)
                                                          title:@"like"
                                                    description:@""];
    
    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:imgObj];
    
    //将内容分享到qq
    [QQApiInterface sendReq:req];
    
    [MobClick event:@"4"];

    return YES;
}

@end
