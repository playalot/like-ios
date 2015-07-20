//
//  LKHotTagsSegmentView.h
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/7/15.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

@interface LKHotTagsSegmentView : UIView

-(void) loadHotTags;

LC_PROPERTY(assign) NSInteger selectIndex;
LC_PROPERTY(copy) LKValueChanged itemDidTap;
LC_PROPERTY(copy) LKValueChanged itemDidLoad;

-(void) setSelectIndex:(NSInteger)index;

@end
