//
//  LKUploadingCell.h
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/6/12.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LCUITableViewCell.h"
#import "LKNewPostUploadCenter.h"

@interface LKUploadingCell : LCUITableViewCell

LC_PROPERTY(strong) LKPosting * posting;


LC_ST_SIGNAL(LKUploadingCellCancel);
LC_ST_SIGNAL(LKUploadingCellReupload);


@end