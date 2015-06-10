//
//  LC_UIImagePickerViewController.m
//  LCFramework

//  Created by Licheng Guo . ( SUGGESTIONS & BUG titm@tom.com ) on 13-10-15.
//  Copyright (c) 2014年 Licheng Guo iOS developer ( http://nsobject.me ).All rights reserved.
//  Also see the copyright page ( http://nsobject.me/copyright.rtf ).
//
//

#import "LCUIImagePickerViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface LCUIImagePickerViewController () <UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    NSInteger _cache;
}

@end

@implementation LCUIImagePickerViewController

-(void) dealloc
{
    [[UIApplication sharedApplication] setStatusBarStyle:_cache animated:YES];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:animated];
    [self setNavigationBarHidden:NO animated:animated];
}

-(id) init
{
    if (self = [super init]) {
        
        self.delegate = self;
        self.allowsEditing = YES;
        self.autoDismiss = YES;
        
        _cache = [UIApplication sharedApplication].statusBarStyle;

    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

//    if (IOS7_OR_LATER)
//    {
//        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
//            if (!granted) {
//                
//                LCUIAlertView.VIEW.MESSAGE(LC_LO(@"相机使用权限未开启，请在手机设置中开启权限（设置-隐私-相机）"))
//                                  .CANCEL(LC_LO(@"知道了"))
//                                  .SHOW();
//            }
//            
//        }];
//    }

}

-(void) setPickerType:(LCImagePickerType)pickerType
{
    switch (pickerType) {
        case LCImagePickerTypePhotoLibrary:
            
            if ([[self class] isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
                
                self.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            }
            
            break;
        case LCImagePickerTypeCamera:
#if (TARGET_IPHONE_SIMULATOR)
            
#else
            if ([[self class] isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
                
                self.sourceType = UIImagePickerControllerSourceTypeCamera;
            }
#endif
            break;
        default:
            
            self.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;

            break;
    }
    
    _pickerType = pickerType;
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    NSMutableDictionary * dict= [NSMutableDictionary dictionaryWithDictionary:editingInfo];
    [dict setObject:image forKey:@"UIImagePickerControllerEditedImage"];
    [self imagePickerController:self didFinishPickingMediaWithInfo:dict];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if (self.sourceType == UIImagePickerControllerSourceTypeCamera) {
        //UIImageWriteToSavedPhotosAlbum([info objectForKey:@"UIImagePickerControllerEditedImage"] ? [info objectForKey:@"UIImagePickerControllerEditedImage"] : [info objectForKey:@"UIImagePickerControllerOriginalImage"], nil, nil,nil);
    }
    
    INFO(@"[LCUIImagePickerViewController] Image info : %@",info);
    
    if (self.autoDismiss) {
     
        [self dismissViewControllerAnimated:YES completion:^{
            
            if (self.didFinishPicking){
                
                self.didFinishPicking(info);
            }
        }];
    }
    else{
        
        if (self.didFinishPicking){
            
            self.didFinishPicking(info);
        }
    }
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    if (![self.navigationController popViewControllerAnimated:YES]) {
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
    if (IOS7_OR_LATER) {
        
        [[UIApplication sharedApplication] setStatusBarStyle:_cache animated:YES];
    }
    
}


@end
