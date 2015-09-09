//
//  LKSinaShare.m
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/5/19.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKSinaShare.h"
#import "MobClick.h"

@interface LKSinaShare ()

LC_PROPERTY(copy) LKSinaLoginComplete complete;

@end

@implementation LKSinaShare

+(BOOL) shareImage:(UIImage *)image
{
    if (![WeiboSDK isWeiboAppInstalled]) {
        
        [LCUIAlertView showWithTitle:LC_LO(@"提醒") message:LC_LO(@"您未安装微博客户端，无法分享") cancelTitle:LC_LO(@"好的") otherTitle:nil didTouchedBlock:^(NSInteger integerValue) {
            
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
    
    /*
     
     #将兴趣玩到极致# 我在like发布了一张照片，一起来玩吧 (۶•̀ᴗ•́)۶ @like-你的新玩具
     */
    
    object.text = @"#将兴趣玩到极致# 我在like发布了一张照片，一起来玩吧 (۶•̀ᴗ•́)۶ @like-你的新玩具";
    
    WBSendMessageToWeiboRequest * request = [WBSendMessageToWeiboRequest requestWithMessage:object];
    
    [MobClick event:@"1"];

    return [WeiboSDK sendRequest:request];
}

-(void)login:(LKSinaLoginComplete)complete
{
    if (![WeiboSDK isWeiboAppInstalled]) {
        
        [LCUIAlertView showWithTitle:LC_LO(@"提醒") message:LC_LO(@"您未安装微博客户端，无法分享") cancelTitle:LC_LO(@"好的") otherTitle:nil didTouchedBlock:^(NSInteger integerValue) {
            
            ;
            
        }];
        return;
    }
    
    self.complete = complete;
    
    WBAuthorizeRequest * request = [WBAuthorizeRequest request];

    request.redirectURI = @"http://www.likeorz.com";

    request.scope = @"all";

    [WeiboSDK sendRequest:request];
}

-(void)didReceiveWeiboResponse:(WBBaseResponse *)response
{
    if ([response isKindOfClass:WBAuthorizeResponse.class])
    {
        if (response.statusCode == 0) {

            if (self.complete) {
                self.complete([(WBAuthorizeResponse *)response userID], [(WBAuthorizeResponse *)response accessToken], nil);
            }
        }
        else{
            
            if (self.complete) {
                self.complete(nil, nil, LC_LO(@"发生错误"));
            }
        }
    }
}

-(void) didReceiveWeiboRequest:(WBBaseRequest *)request
{

}

@end
