//
//  LKPostDetailViewController.h
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/4/20.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LCUIViewController.h"
#import "LKPost.h"
#import "LKHomepageHeader.h"


@interface LKPostDetailViewController : LCUIViewController

LC_PROPERTY(strong) LKHomepageHeader * header;
LC_PROPERTY(strong) LCUITableView * tableView;

LC_PROPERTY(strong) LKPost * post;

-(instancetype) initWithPost:(LKPost *)post;

-(void) openCommentsView:(LKTag *)tag;

@end
