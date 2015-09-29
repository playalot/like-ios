//
//  LKUIImagePickerViewController.m
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/6/9.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKUIImagePickerViewController.h"
#import <objc/runtime.h>
#import "LKCameraViewController.h"
#import "LKImageCropperViewController.h"
#import "LKNewPostViewController.h"

static char finalizationBlockKey;
static char cancelationBlockKey;

@implementation UIImagePickerController (LKImagePicker)

- (UIImagePickerControllerFinalizationBlock)finalizationBlock
{
    return objc_getAssociatedObject(self, &finalizationBlockKey);
}

- (UIImagePickerControllerCancellationBlock)cancellationBlock
{
    return objc_getAssociatedObject(self, &cancelationBlockKey);
}

- (void)setFinalizationBlock:(UIImagePickerControllerFinalizationBlock)block
{
    if (!block) {
        return;
    }
    
    self.delegate = self;
    objc_setAssociatedObject(self, &finalizationBlockKey, block, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setCancellationBlock:(UIImagePickerControllerCancellationBlock)block
{
    if (!block) {
        return;
    }
    
    self.delegate = self;
    objc_setAssociatedObject(self, &cancelationBlockKey, block, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSLog(@"info: %@", info);
    
    if (self.finalizationBlock) {
        self.finalizationBlock(self, info);
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    if (self.cancellationBlock) {
        self.cancellationBlock(self);
    }
}

@end

@interface LKUIImagePickerViewController ()

LC_PROPERTY(assign) UIStatusBarStyle barStyleCache;

@end

@implementation LKUIImagePickerViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:animated];
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:animated];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden {
    
    return NO;
}

- (instancetype)init {
    if (self = [super init]) {
        self.barStyleCache = [UIApplication sharedApplication].statusBarStyle;
    }
    return self;
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ([viewController isKindOfClass:[LKCameraViewController class]] ||
        [viewController isKindOfClass:[LKImageCropperViewController class]] ||
         [viewController isKindOfClass:[LKNewPostViewController class]]) {
    } else {
//        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
//        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
        
        [self setNeedsStatusBarAppearanceUpdate];
    }
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
}

@end
