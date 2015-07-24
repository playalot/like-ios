//
//  LKRecommendTagsView.h
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/4/20.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKTagsView.h"

@class LKRecommendTagItem;


@interface __LKTagS : LKTag

LC_PROPERTY(assign) NSInteger type;

@end


LC_BLOCK(void, LKRecommendTagItemDidTap, (__weak LKRecommendTagItem * item));

@interface LKRecommendTagItem : UIView

LC_PROPERTY(strong) LCUILabel * tagLabel;
LC_PROPERTY(strong) __LKTagS * tagValue;
LC_PROPERTY(copy) LKRecommendTagItemDidTap didTap;

@end


LC_BLOCK(void, LKRecommendTagsViewDidTap, (LKRecommendTagItem * item, NSInteger type));
LC_BLOCK(void, LKRecommendTagsViewDidLoad, ());

@interface LKRecommendTagsView : UIView

LC_PROPERTY(copy) NSString * title;
LC_PROPERTY(strong) NSMutableArray * tags;
LC_PROPERTY(copy) LKRecommendTagsViewDidTap itemDidTap;
LC_PROPERTY(copy) LKRecommendTagsViewDidLoad itemDidLoad;

LC_PROPERTY(assign) BOOL highlight;
LC_PROPERTY(assign) BOOL tapRemove;

-(void) loadRecommendTags;
-(void) reloadData:(BOOL)animation;

@end
