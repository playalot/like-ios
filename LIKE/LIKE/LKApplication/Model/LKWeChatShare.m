//
//  LKWeChatShare.m
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/5/19.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKWeChatShare.h"

@interface LKWeChatShare ()

LC_PROPERTY(copy) LKWeChatLoginComplete complete;

@end

@implementation LKWeChatShare

+(BOOL) shareImage:(UIImage *)image timeLine:(BOOL)timeLine
{
    if (![WXApi isWXAppInstalled]) {
        
        [LCUIAlertView showWithTitle:LC_LO(@"提醒") message:LC_LO(@"您未安装微信客户端，无法分享") cancelTitle:LC_LO(@"好的") otherTitle:nil didTouchedBlock:^(NSInteger integerValue) {
            
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


-(void)login:(LKWeChatLoginComplete)complete
{
    if (![WXApi isWXAppInstalled]) {
        
        [LCUIAlertView showWithTitle:LC_LO(@"提醒") message:LC_LO(@"您未安装微信客户端，无法分享") cancelTitle:LC_LO(@"好的") otherTitle:nil didTouchedBlock:^(NSInteger integerValue) {
            
            ;
            
        }];
        return;
    }
    
    self.complete = complete;
    
    SendAuthReq * req = [[SendAuthReq alloc ] init];
    req.scope = @"snsapi_userinfo,snsapi_base";
    req.state = @"0744" ;
    [WXApi sendReq:req];
}

/*! @brief 收到一个来自微信的请求，第三方应用程序处理完后调用sendResp向微信发送结果
 *
 * 收到一个来自微信的请求，异步处理完成后必须调用sendResp发送处理结果给微信。
 * 可能收到的请求有GetMessageFromWXReq、ShowMessageFromWXReq等。
 * @param req 具体请求内容，是自动释放的
 */
-(void) onReq:(BaseReq*)req
{
    
}



/*! @brief 发送一个sendReq后，收到微信的回应
 *
 * 收到一个来自微信的处理结果。调用一次sendReq后会收到onResp。
 * 可能收到的处理结果有SendMessageToWXResp、SendAuthResp等。
 * @param resp具体的回应内容，是自动释放的
 */
-(void) onResp:(BaseResp*)resp
{
    SendAuthResp * aresp = (SendAuthResp *)resp;
    
    if (aresp.errCode == 0) {
        
        NSString * code = aresp.code;

        NSString * url = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code", @"wxa3f301de2a84df8b", @"d96c9dcc1e6a04890b794a4e5398b293", code];
        
        [LCGCD dispatchAsync:LCGCDPriorityDefault block:^{
           
            NSString * result = [NSString stringWithContentsOfURL:[NSURL URLWithString:url] encoding:NSUTF8StringEncoding error:nil];
            
            NSData * data = [result dataUsingEncoding:NSUTF8StringEncoding];
            
            NSDictionary * resultDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            
            [LCGCD dispatchAsyncInMainQueue:^{
               
                
                if (resultDic) {
                    
                    NSString * accessToken = resultDic[@"access_token"];
                    NSString * openID = resultDic[@"openid"];
                    
                    if (self.complete) {
                        self.complete(openID, accessToken, nil);
                    }
                }
                else{
                    
                    if (self.complete) {
                        self.complete(nil, nil, LC_LO(@"发生错误"));
                    }
                }
            }];
        }];
    }
    else{
        
        self.complete(nil, nil, LC_LO(@"发生错误"));
    }
}

@end
