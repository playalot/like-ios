//
//  LKRecommendTagsView.h
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/4/20.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKTagsView.h"

@class LKRecommendTagItem;

LC_BLOCK(void, LKRecommendTagItemDidTap, (__weak LKRecommendTagItem * item));

@interface LKRecommendTagItem : UIView

LC_PROPERTY(strong) LCUILabel * tagLabel;
LC_PROPERTY(strong) NSString * tagString;
LC_PROPERTY(copy) LKRecommendTagItemDidTap didTap;

@end


LC_BLOCK(void, LKRecommendTagsViewDidTap, (LKRecommendTagItem * item));
LC_BLOCK(void, LKRecommendTagsViewDidLoad, ());

@interface LKRecommendTagsView : UIView

LC_PROPERTY(copy) NSString * title;
LC_PROPERTY(strong) NSMutableArray * tags;
LC_PROPERTY(copy) LKRecommendTagsViewDidTap itemDidTap;
LC_PROPERTY(copy) LKRecommendTagsViewDidLoad itemDidLoad;

LC_PROPERTY(assign) BOOL highlight;

-(void) loadRecommendTags;
-(void) reloadData;

@end
