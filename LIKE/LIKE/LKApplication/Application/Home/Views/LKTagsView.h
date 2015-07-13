//
//  LKTagsView.h
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/4/15.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LKTag.h"

@class LKTagItem;

LC_BLOCK(void, LKTagItemDidRemoved, (__weak LKTagItem * item));
LC_BLOCK(void, LKTagItemRequest, (__weak LKTagItem * item));

@interface LKTagItem : UIView

LC_PROPERTY(strong) LCUILabel * tagLabel;
LC_PROPERTY(strong) LCUILabel * likesLabel;
//LC_PROPERTY(strong) UIView * left;
//LC_PROPERTY(strong) UIView * right;

LC_PROPERTY(strong) LKTag * tagValue;
LC_PROPERTY(strong) LKTag * associatedTagValue;

LC_PROPERTY(copy) LKTagItemRequest willRequest;
LC_PROPERTY(copy) LKTagItemRequest requestFinished;
LC_PROPERTY(copy) LKTagItemRequest customAction;

LC_PROPERTY(copy) LKTagItemDidRemoved didRemoved;

LC_PROPERTY(assign) BOOL showNumber;

@end


#pragma mark -


LC_BLOCK(void, LKTagsViewDidRemoveTag, (LKTag * tag));

@interface LKTagsView : UIScrollView

LC_PROPERTY(copy) LKTagsViewDidRemoveTag didRemoveTag;
LC_PROPERTY(strong) NSMutableArray * tags; // LKTag

LC_PROPERTY(copy) LKTagItemRequest itemRequestFinished;
LC_PROPERTY(copy) LKTagItemRequest customAction;


-(void) reloadData; // [self reloadDataAndRemoveAll:YES]
-(void) reloadDataAndRemoveAll:(BOOL)removeAll;

@end
