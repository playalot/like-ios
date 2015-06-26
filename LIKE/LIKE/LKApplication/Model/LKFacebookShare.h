//
//  LKFacebookShare.h
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/6/17.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LCUITableViewCell.h"

LC_BLOCK(void, LKFacebookLoginComplete, (NSString * uid, NSString * accessToken, NSString * nickName, NSString * error));

@interface LKFacebookShare : LCUITableViewCell

-(void)login:(LKFacebookLoginComplete)complete;

@end
