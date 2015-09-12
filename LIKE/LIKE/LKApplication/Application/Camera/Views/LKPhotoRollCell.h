//
//  LKPhotoRollCell.h
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/6/19.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@interface LKPhotoRollCell : UICollectionViewCell

LC_PROPERTY(strong) UIImage * image;
LC_PROPERTY(assign) PHImageRequestID requestID;

@end
