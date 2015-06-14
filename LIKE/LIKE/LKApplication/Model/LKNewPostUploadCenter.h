//
//  LKNewPostUploadCenter.h
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/6/12.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LKPosting : NSObject

LC_PROPERTY(assign) BOOL uploading;
LC_PROPERTY(assign) CGFloat progress;
LC_PROPERTY(strong) UIImage * image;
LC_PROPERTY(strong) NSArray * tags;
LC_PROPERTY(copy) LKValueChanged updateProgress;

@end

@interface LKNewPostUploadCenter : NSObject

LC_PROPERTY(strong) NSMutableArray * uploadingImages;

LC_PROPERTY(copy) LKValueChangedM addedNewValue;
LC_PROPERTY(copy) LKValueChangedM uploadFinished;
LC_PROPERTY(copy) LKValueChanged uploadFailed;
LC_PROPERTY(copy) LKValueChanged stateChanged;

+(void) uploadImage:(UIImage *)image tags:(NSArray *)tags;

-(void) reuploadPosting:(LKPosting *)posting;
-(void) cancelPosting:(LKPosting *)posting;

@end
