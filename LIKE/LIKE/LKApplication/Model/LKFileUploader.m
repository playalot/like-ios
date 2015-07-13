//
//  IFFileUploader.m
//  IFAPP
//
//  Created by Licheng Guo . http://nsobject.me/ on 15/3/2.
//  Copyright (c) 2015年 Licheng Guo . ( http://nsobject.me ). All rights reserved.
//

#import "LKFileUploader.h"
#import "LKFileUploaderConfig.h"
#import "QiniuSDK.h"
#import <CommonCrypto/CommonDigest.h>


typedef void (^LKFileUploadConfigUpdateCompleted) (BOOL completed, NSString * error);

@implementation LKFileUploader

+ (void) uploadFileData:(UIImage *)data suffix:(NSString *)suffix completeBlock:(LKFileUploadCompleted)completeBlock
{
    [LKFileUploader.singleton uploadFileData:data suffix:suffix completeBlock:completeBlock option:nil];
}

+ (void) uploadAvatarImage:(UIImage *)data suffix:(NSString *)suffix completeBlock:(LKFileUploadCompleted)completeBlock
{
    [LKFileUploader.singleton uploadAvatar:data suffix:suffix completeBlock:completeBlock];
}

+ (void) uploadCover:(UIImage *)data suffix:(NSString *)suffix completeBlock:(LKFileUploadCompleted)completeBlock
{
    [LKFileUploader.singleton uploadCover:data suffix:suffix completeBlock:completeBlock];
}

#pragma mark  -

-(void) uploadAvatar:(UIImage *)image suffix:(NSString *)suffix completeBlock:(LKFileUploadCompleted)completeBlock
{
    [self updateFileUploaderConfig:^(BOOL completed, NSString * error) {
        
        if (!completed) {
            completeBlock(NO, nil,error);
        }
        else{
            [self realUploadAvatarImage:image suffix:suffix completeBlock:completeBlock];
        }
    }];
}

-(void) uploadCover:(UIImage *)image suffix:(NSString *)suffix completeBlock:(LKFileUploadCompleted)completeBlock
{
    [self updateFileUploaderConfig:^(BOOL completed, NSString * error) {
        
        if (!completed) {
            completeBlock(NO, nil,error);
        }
        else{
            [self realUploadCoverImage:image suffix:suffix completeBlock:completeBlock];
        }
    }];
}

-(void) uploadFileData:(UIImage *)data suffix:(NSString *)suffix completeBlock:(LKFileUploadCompleted)completeBlock option:(QNUploadOption *)option
{
    // 每次都请求Token
    //   if (!LKQiniuConfig.singleton.token) {
    
    [self updateFileUploaderConfig:^(BOOL completed, NSString * error) {
        
        if (!completed) {
            completeBlock(NO, nil,error);
        }
        else{
            [self realUploadFileData:data suffix:suffix completeBlock:completeBlock option:option];
        }
    }];
    //    }
    //    else{
    //
    //        // 判断是否过期
    //        NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    //        NSTimeInterval expTime = LKQiniuConfig.singleton.expires.doubleValue;
    //
    //        // 过期了
    //        if (time > expTime) {
    //
    //            [self updateFileUploaderConfig:^(BOOL completed, NSString * error) {
    //
    //                if (!completed) {
    //                    completeBlock(NO, nil,error);
    //                }
    //                else{
    //                    [self realUploadFileData:data suffix:suffix completeBlock:completeBlock];
    //                }
    //            }];
    //        }
    //        // 没过期 直接上传
    //        else{
    //
    //            [self realUploadFileData:data suffix:suffix completeBlock:completeBlock];
    //        }
    //    }

    
}

#pragma mark -

-(void) realUploadAvatarImage:(UIImage *)image suffix:(NSString *)suffix completeBlock:(LKFileUploadCompleted)completeBlock
{
    NSString * token = LKQiniuConfig.singleton.token;

    image = [image scaleToWidth:640];
    
    NSData * imageData = UIImageJPEGRepresentation(image, 0.8);
    
    NSString * timeInterval = [NSString stringWithFormat:@"%@", @(@([[NSDate date] timeIntervalSince1970]).integerValue)];
    
    NSNumber * uid = LKLocalUser.singleton.user.id;
    
    //头像: avatar_{user_id}_{时间戳}.{jpg|png}
    NSString * key = [NSString stringWithFormat:@"avatar_%@_%@.jpg", uid, timeInterval];
    
    QNUploadManager * uploadManager = [[QNUploadManager alloc] init];
    
    [uploadManager putData:imageData key:key token:token complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
        
        // 上传成功
        if (info.statusCode == 200) {
            
            completeBlock(YES, key, nil);
        }
        else{
            
            completeBlock(NO, nil, info.error.description);
        }
        
    } option:nil];
}

-(void) realUploadCoverImage:(UIImage *)image suffix:(NSString *)suffix completeBlock:(LKFileUploadCompleted)completeBlock
{
    NSString * token = LKQiniuConfig.singleton.token;
    
    image = [image scaleToWidth:1280];
    
    NSData * imageData = UIImageJPEGRepresentation(image, 0.8);
    
    NSString * timeInterval = [NSString stringWithFormat:@"%@", @(@([[NSDate date] timeIntervalSince1970]).integerValue)];
    
    NSNumber * uid = LKLocalUser.singleton.user.id;
    
    //头像: avatar_{user_id}_{时间戳}.{jpg|png}
    NSString * key = [NSString stringWithFormat:@"cover_%@_%@.jpg", uid, timeInterval];
    
    QNUploadManager * uploadManager = [[QNUploadManager alloc] init];
    
    [uploadManager putData:imageData key:key token:token complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
        
        // 上传成功
        if (info.statusCode == 200) {
            
            completeBlock(YES, key, nil);
        }
        else{
            
            completeBlock(NO, nil, info.error.description);
        }
        
    } option:nil];
}

-(void) realUploadFileData:(UIImage *)image suffix:(NSString *)suffix completeBlock:(LKFileUploadCompleted)completeBlock option:(QNUploadOption *)option
{
    NSString * token = LKQiniuConfig.singleton.token;
    
    if (image.size.width > 1280) {
        image = [image scaleToWidth:1280];
    }
    
    NSData * imageData = UIImageJPEGRepresentation(image, 0.8);
    
    CGFloat imageHeight = image.size.height;
    CGFloat imageWidth = image.size.width;
    
    NSString * uuid = [[NSString UUID].lowercaseString stringByReplacingOccurrencesOfString:@"-" withString:@""];
    NSString * timeInterval = [NSString stringWithFormat:@"%@", @(@([[NSDate date] timeIntervalSince1970]).integerValue)];
    NSString * userid = LC_NSSTRING_FORMAT(@"%@", LKLocalUser.singleton.user.id);
    
    //d0f8d1a659409da4_1422544870_w_1920_h_1080_1.jpg
    //图片命名 {md5原图 截取第8个字符开始后16个字符}_{时间戳}_w_{原图宽度}_h_{原图高度}_{user_id}.{jpg|png}
    NSString * key = [NSString stringWithFormat:@"%@_%@_w_%0.f_h_%0.f_%@.%@", uuid, timeInterval, imageWidth, imageHeight, userid, suffix];
    
    QNUploadManager * uploadManager = [[QNUploadManager alloc] init];
    
    [uploadManager putData:imageData key:key token:token complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
        
        // 上传成功
        if (info.statusCode == 200) {
            
            completeBlock(YES, key, nil);
        }
        else{
            
            completeBlock(NO, nil, info.error.description);
        }
        
    } option:option];
}

#pragma mark -

/**
 更新文件上传配置
 */
-(void) updateFileUploaderConfig:(LKFileUploadConfigUpdateCompleted)completed
{
    LKHttpRequestInterface * interface = [LKHttpRequestInterface interfaceType:@"post/uploadToken"].AUTO_SESSION();
    
    [self request:interface complete:^(LKHttpRequestResult *result) {
        
        if (result.state == LKHttpRequestStateFinished) {
            
            NSDictionary * config = result.json[@"data"];
            
            LKQiniuConfig.singleton.token = config[@"upload_token"];
            //LKQiniuConfig.singleton.expires = config[@"expires"];
            //LKQiniuConfig.singleton.space = config[@"space"];
            
            completed(YES, nil);
        }
        else if(result.state == LKHttpRequestStateFailed){
            
            completed(NO, result.error);
        }
    }];
    
}


//-(NSString *) createKey:(NSString *)ext
//{
//    NSDate * now = [NSDate date];
//    NSCalendar * calendar = [NSCalendar currentCalendar];
//    
//    NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
//    
//    NSDateComponents * dateComponent = [calendar components:unitFlags fromDate:now];
//
//    NSString * year = [self converString:dateComponent.year];
//    NSString * month = [self converString:dateComponent.month];
//    NSString * day = [self converString:dateComponent.day];
//    NSString * hour = [self converString:dateComponent.hour];
//    NSString * minute = [self converString:dateComponent.minute];
//    NSString * second = [self converString:dateComponent.second];
//
//    
//    NSMutableString * key = [[NSMutableString alloc] init];
//    
//    [key appendFormat:@"%@/",IFFileUploderConfig.LCI.space];
//    [key appendFormat:@"%@/",year];
//    [key appendFormat:@"%@%@/",month,day];
//    [key appendFormat:@"%@%@%@_%@.%@",hour,minute,second,@(LC_RANDOM(10000, 99999)),ext];
//
//    return key;
//}
//
//-(NSString *) converString:(NSInteger)value
//{
//    return value < 10 ? LC_NSSTRING_FORMAT(@"0%@", @(value)) : LC_NSSTRING_FROM_INT(value);
//}

- (NSString *)cf_md5_16byte:(NSData *)data
{
    unsigned char result[16];
    CC_MD5( data.bytes, (CC_LONG)data.length, result ); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x",
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11]
            ];
}

@end
