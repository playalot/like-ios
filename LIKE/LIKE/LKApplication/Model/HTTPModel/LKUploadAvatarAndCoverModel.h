//
//  LKUploadAvatorModel.h
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/4/21.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LCHTTPRequestModel.h"

LC_BLOCK(void, LKUploadAvatarModelRequestFinished, (NSString * error, UIImage * resultImage));

@interface LKUploadAvatarAndCoverModel : LCHTTPRequestModel

+(void) chooseAvatorImage:(LKUploadAvatarModelRequestFinished)uploadFinished;
+(void) chooseCoverImage:(LKUploadAvatarModelRequestFinished)uploadFinished;

@end
