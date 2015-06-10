//
//  LKHotTagsView.h
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/5/26.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import <UIKit/UIKit.h>


@class LKHotTagItem;

LC_BLOCK(void, LKHotTagItemDidTap, (LKHotTagItem * item));

@interface LKHotTagItem : UIView

LC_PROPERTY(strong) LCUILabel * tagLabel;
LC_PROPERTY(strong) NSString * tagString;
LC_PROPERTY(copy) LKHotTagItemDidTap didTap;

@end


#pragma mark -


LC_BLOCK(void, LKRecommendTagsViewDidTap, (LKHotTagItem * item));
LC_BLOCK(void, LKRecommendTagsViewDidLoad, ());


@interface LKHotTagsView : UIView


LC_PROPERTY(copy) NSString * title;
LC_PROPERTY(strong) NSMutableArray * tags;
LC_PROPERTY(copy) LKRecommendTagsViewDidTap itemDidTap;
LC_PROPERTY(copy) LKRecommendTagsViewDidLoad itemDidLoad;

LC_PROPERTY(assign) BOOL highlight;

-(void) loadHotTags;
-(void) reloadData;


@end
