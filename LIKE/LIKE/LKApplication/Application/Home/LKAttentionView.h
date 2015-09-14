//
//  LKAttentionView.h
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/7/21.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LKAttentionView : UIView

LC_PROPERTY(strong) LCUIPullLoader * pullLoader;

LC_PROPERTY(strong) LCUITableView * tableView;

LC_PROPERTY(weak) id delegate;

@end
