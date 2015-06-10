//
//  LKSegmentHeader.h
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/4/15.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LKSegmentHeaderItem : LCUIView

LC_PROPERTY(strong) LCUILabel * title;
LC_PROPERTY(strong) LCUILabel * subTitle;
LC_PROPERTY(strong) UIView * line;

@end

LC_BLOCK(void, LKSegmentHeaderDidSelected, (NSInteger index));

@interface LKSegmentHeader : LCUIView

LC_PROPERTY(strong) NSMutableArray * items;
LC_PROPERTY(copy) LKSegmentHeaderDidSelected didSelected;

-(void) addTitle:(NSString *)title subTitle:(NSString *)subTitle;
-(void) setTitle:(NSString *)title subTitle:(NSString *)subTitle atIndex:(NSInteger)atIndex;

@end
