//
//  LKTagsView.h
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/4/15.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LKTag.h"
#import "LKTagItemView.h"

LC_BLOCK(void, LKTagsViewDidRemoveTag, (LKTag * tag));

@interface LKTagsView : UIScrollView

LC_PROPERTY(copy) LKTagsViewDidRemoveTag didRemoveTag;
LC_PROPERTY(strong) NSMutableArray *tags; // LKTag

LC_PROPERTY(copy) LKTagItemViewRequest itemRequestFinished;
LC_PROPERTY(copy) LKTagItemViewRequest customAction;
LC_PROPERTY(copy) LKTagItemViewRequest willRequest;

- (void)reloadData;
- (void)reloadDataAndRemoveAll:(BOOL)removeAll;

@end
