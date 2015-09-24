//
//  LKPostView.h
//  LIKE
//
//  Created by huangweifeng on 9/24/15.
//  Copyright © 2015 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LCUIView.h"

@interface LKPostView : LCUIView

LC_PROPERTY(copy) NSString *imageURLString;
LC_PROPERTY(strong) NSMutableArray *tagList;

@end
