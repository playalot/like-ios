//
//  LKActionSheet.h
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/5/5.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "TRActionSheet.h"

@interface LKActionSheet : TRActionSheet

LC_PROPERTY(copy) LCUIActionSheetDidSelected didSelected;

+ (instancetype) showWithTitle:(NSString *)title
                  buttonTitles:(NSArray *)titles
                   didSelected:(LCUIActionSheetDidSelected)didSelected;

+ (instancetype) showWithTitle:(NSString *)title
                  buttonTitles:(NSArray *)titles
                   shareTitles:(NSArray *)shareTitles
                    shareImage:(UIImage *)shareImage
                   didSelected:(LCUIActionSheetDidSelected)didSelected;

@end
