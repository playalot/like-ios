//
//  LKUIImagePickerViewController.h
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/6/9.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "CTAssetsPickerController.h"

typedef void (^UIImagePickerControllerFinalizationBlock)(UIImagePickerController *picker, NSDictionary *info);
typedef void (^UIImagePickerControllerCancellationBlock)(UIImagePickerController *picker);

@interface UIImagePickerController (LKImagePicker) <UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property (nonatomic, strong) UIImagePickerControllerFinalizationBlock finalizationBlock;
@property (nonatomic, strong) UIImagePickerControllerCancellationBlock cancellationBlock;

@end

@interface LKUIImagePickerViewController : UIImagePickerController

@end
