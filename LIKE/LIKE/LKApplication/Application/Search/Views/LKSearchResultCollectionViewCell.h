//
//  LKSearchResultCollectionViewCell.h
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/7/17.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LKPost.h"

@interface LKSearchResultCollectionViewCell : UICollectionViewCell

LC_PROPERTY(strong) LKPost * post;
LC_PROPERTY(strong) LCUIImageView * contentImage;

+(CGSize) sizeWithPost:(LKPost *)post;

LC_ST_SIGNAL(PushUserCenter);
LC_ST_SIGNAL(PushPostDetail);

@end
