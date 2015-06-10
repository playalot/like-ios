//
//  LKShareTools.h
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/5/20.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import <UIKit/UIKit.h>

LC_BLOCK(UIImage *, LKShareToolsShareImage, (NSInteger index));

@interface LKShareTools : UIView

LC_PROPERTY(copy) LKValueChanged willShow;
LC_PROPERTY(copy) LKValueChanged willHide;
LC_PROPERTY(copy) LKShareToolsShareImage willShareImage;

@end
