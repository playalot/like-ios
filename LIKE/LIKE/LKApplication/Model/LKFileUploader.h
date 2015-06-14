//
//  IFFileUploader.h
//  IFAPP
//
//  Created by Licheng Guo . http://nsobject.me/ on 15/3/2.
//  Copyright (c) 2015年 Licheng Guo . ( http://nsobject.me ). All rights reserved.
//

#import <Foundation/Foundation.h>

@class QNUploadOption;

LC_BLOCK(void, LKFileUploadCompleted, (BOOL completed, NSString * uploadedKey, NSString * error));

@interface LKFileUploader : NSObject

+ (void) uploadFileData:(UIImage *)data suffix:(NSString *)suffix completeBlock:(LKFileUploadCompleted)completeBlock;

+ (void) uploadAvatarImage:(UIImage *)data suffix:(NSString *)suffix completeBlock:(LKFileUploadCompleted)completeBlock;

+ (void) uploadCover:(UIImage *)data suffix:(NSString *)suffix completeBlock:(LKFileUploadCompleted)completeBlock;



-(void) uploadFileData:(UIImage *)data suffix:(NSString *)suffix completeBlock:(LKFileUploadCompleted)completeBlock option:(QNUploadOption *)option;

@end
