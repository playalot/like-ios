//
//  LKUploadAvatorModel.m
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/4/21.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKUploadAvatarAndCoverModel.h"
#import "LKFileUploader.h"
#import "LKCameraViewController.h"
#import "LKImageCropperViewController.h"
#import "LKUIImagePickerViewController.h"

@implementation LKUploadAvatarAndCoverModel

+(void) chooseAvatorImage:(LKUploadAvatarModelRequestFinished)uploadFinished
{
    [LKActionSheet showWithTitle:LC_LO(@"更换头像") buttonTitles:@[LC_LO(@"拍摄新图片"),LC_LO(@"从相册选择")] didSelected:^(NSInteger index) {
        
        if (index == 0) {
            
            [self camera:uploadFinished imageType:0];
        }
        else if (index == 1){
            
            [self choosePhoto:uploadFinished imageType:0];
        }
    }];
}

+(void) chooseCoverImage:(LKUploadAvatarModelRequestFinished)uploadFinished
{
    [LKActionSheet showWithTitle:LC_LO(@"更换封面") buttonTitles:@[LC_LO(@"拍摄新图片"),LC_LO(@"从相册选择")] didSelected:^(NSInteger index) {
       
        if (index == 0) {
            
            [self camera:uploadFinished imageType:1];
        }
        else if (index == 1){
            
            [self choosePhoto:uploadFinished imageType:1];
        }
        
    }];
}

#pragma mark -

+(void) camera:(LKUploadAvatarModelRequestFinished)uploadFinished imageType:(NSInteger)imageType
{
    LKCameraViewController * camera = [LKCameraViewController viewController];
    camera.squareImage = YES;
    
    camera.didFinishedPickImage = ^(UIImage * image){
        
        if (!image) {
            return;
        }
      
        [LC_KEYWINDOW showTopLoadingMessageHud:LC_LO(@"上传中...")];
        
        if (imageType == 0) {
         
            // avatar
            [LKUploadAvatarAndCoverModel uploadAvator:image requestFinished:^(NSString * error, UIImage * resultImage) {
                
                [RKDropdownAlert dismissAllAlert];
                
                if (uploadFinished) {
                    uploadFinished(error, image);
                }
                
                if (error) {
                    
                    [LC_KEYWINDOW showTopMessageErrorHud:error];
                }
            }];
        }
        else if(imageType == 1){
            
            // cover
            [LKUploadAvatarAndCoverModel uploadCover:image requestFinished:^(NSString * error, UIImage * resultImage) {
                
                [RKDropdownAlert dismissAllAlert];
                
                if (uploadFinished) {
                    uploadFinished(error, image);
                }
                
                if (error) {
                    
                    [LC_KEYWINDOW showTopMessageErrorHud:error];
                }
            }];
        }
    };
    
    [LCUIApplication presentViewController:LC_UINAVIGATION(camera) animation:NO];
}

+(void) choosePhoto:(LKUploadAvatarModelRequestFinished)uploadFinished imageType:(NSInteger)imageType
{
    LKUIImagePickerViewController * picker = [[LKUIImagePickerViewController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.allowsEditing = NO;
    picker.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    picker.navigationBar.tintColor = [UIColor whiteColor];
    
    [picker.navigationBar setBackgroundImage:[UIImage imageWithColor:[LKColor.color colorWithAlphaComponent:1] andSize:LC_SIZE(LC_DEVICE_WIDTH, 64)] forBarMetrics:UIBarMetricsDefault];
    
    NSMutableDictionary * dictText = [NSMutableDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,LK_FONT_B(18),NSFontAttributeName,nil];
    
    [picker.navigationBar setTitleTextAttributes:dictText];
    
    [LCUIApplication presentViewController:picker animation:YES];
    
    
    picker.finalizationBlock = ^(id picker, NSDictionary * imageInfo){
        
        UIImage *image = imageInfo[@"UIImagePickerControllerOriginalImage"];
        
        if (!image) {
            return;
        }
        
        LKImageCropperViewController * cropper = [[LKImageCropperViewController alloc] initWithImage:image];
        cropper.squareImage = YES;
        cropper.dontSaveToAblum = YES;
        
        [picker pushViewController:cropper animated:YES];
        [cropper showBackButton];
        
        cropper.didFinishedPickImage = ^(UIImage * image){
            
            if (!image) {
                return;
            }
            
            [LC_KEYWINDOW showTopLoadingMessageHud:LC_LO(@"上传中...")];

            if (imageType == 0) {
                
                // avatar
                [LKUploadAvatarAndCoverModel uploadAvator:image requestFinished:^(NSString * error, UIImage * resultImage) {
                    
                    [RKDropdownAlert dismissAllAlert];
                    
                    if (uploadFinished) {
                        uploadFinished(error, image);
                    }
                    
                    if (error) {
                        
                        [LC_KEYWINDOW showTopMessageErrorHud:error];
                    }
                }];
            }
            else if(imageType == 1){
                
                // cover
                [LKUploadAvatarAndCoverModel uploadCover:image requestFinished:^(NSString * error, UIImage * resultImage) {
                    
                    [RKDropdownAlert dismissAllAlert];
                    
                    if (uploadFinished) {
                        uploadFinished(error, image);
                    }
                    
                    if (error) {
                        
                        [LC_KEYWINDOW showTopMessageErrorHud:error];
                    }
                }];
            }
            
            [picker dismissViewControllerAnimated:YES completion:nil];
        };
    };
    
    picker.cancellationBlock = ^(UIImagePickerController * picker){
        
        [picker dismissViewControllerAnimated:YES completion:nil];
        
    };

}

#pragma mark -

+(void) uploadAvator:(UIImage *)avator requestFinished:(LKUploadAvatarModelRequestFinished)requestFinished {
    if (!avator) return;
    
    [LKFileUploader uploadAvatarImage:avator suffix:@"jpg" completeBlock:^(BOOL completed, NSString *uploadedKey, NSString *error) {
        if (error) {
            requestFinished(error, avator);
        } else {
            [LKUploadAvatarAndCoverModel putRequestUserAvatar:uploadedKey image:avator requestFinished:requestFinished];
        }
    }];
}

+(void) uploadCover:(UIImage *)cover requestFinished:(LKUploadAvatarModelRequestFinished)requestFinished
{
    if (!cover) return;
    
    [LKFileUploader uploadCover:cover suffix:@"jpg" completeBlock:^(BOOL completed, NSString *uploadedKey, NSString *error) {
        
        if (error) {
            requestFinished(error, cover);
        }
        else{
            
            [LKUploadAvatarAndCoverModel putRequestUserCover:uploadedKey image:cover requestFinished:requestFinished];
        }
    }];
}

#pragma mark -

+(void) putRequestUserAvatar:(NSString *)imageKey image:(UIImage *)image requestFinished:(LKUploadAvatarModelRequestFinished)requestFinished
{
    LKHttpRequestInterface * interface = [LKHttpRequestInterface interfaceType:@"user/avatar"].AUTO_SESSION().PUT_METHOD();
    
    [interface addParameter:imageKey key:@"avatar"];
    
    [self request:interface complete:^(LKHttpRequestResult *result) {
     
        if (result.state == LKHttpRequestStateFinished) {
            
            requestFinished(nil, image);
        }
        else if (result.state == LKHttpRequestStateFailed){
            
            requestFinished(result.error, image);
        }
    }];
}

+(void) putRequestUserCover:(NSString *)imageKey image:(UIImage *)image requestFinished:(LKUploadAvatarModelRequestFinished)requestFinished
{
    LKHttpRequestInterface * interface = [LKHttpRequestInterface interfaceType:@"user/cover"].AUTO_SESSION().PUT_METHOD();
    
    [interface addParameter:imageKey key:@"cover"];
    
    [self request:interface complete:^(LKHttpRequestResult *result) {
        
        if (result.state == LKHttpRequestStateFinished) {
            
            requestFinished(nil, image);
        }
        else if (result.state == LKHttpRequestStateFailed){
            
            requestFinished(result.error, image);
        }
        
    }];
}

@end
