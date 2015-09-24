//
//  LKTagItemViewCenter.h
//  LIKE
//
//  Created by huangweifeng on 9/24/15.
//  Copyright © 2015 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LKTagItemView.h"
#import "LKQueue.h"

@interface LKTagItemViewCenter : NSObject

+ (instancetype)sharedInstance;

- (LKTagItemView *)getImageView;

- (void)addImageViews:(NSArray *)imageViews;

- (void)addImageView:(LKTagItemView *)imageView;

- (NSArray *)getImageViewsByCount:(NSInteger)count;

@end
