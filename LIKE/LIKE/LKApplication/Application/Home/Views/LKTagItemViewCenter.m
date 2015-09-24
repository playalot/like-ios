//
//  LKTagItemViewCenter.m
//  LIKE
//
//  Created by huangweifeng on 9/24/15.
//  Copyright © 2015 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKTagItemViewCenter.h"

#define TAG_ITEM_VIEW_CENTER_DEFAULT_SIZE 20000

@interface LKTagItemViewCenter ()

LC_PROPERTY(strong) LKQueue *imageViewQueue;

@end

@implementation LKTagItemViewCenter

+ (instancetype)sharedInstance {
    static LKTagItemViewCenter *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[LKTagItemViewCenter alloc] init];
    });
    return _instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.imageViewQueue = [[LKQueue alloc] init];
        for (NSInteger i = 0; i < TAG_ITEM_VIEW_CENTER_DEFAULT_SIZE; i ++) {
            [self.imageViewQueue enqueue:LKTagItemView.view];
        }
    }
    return self;
}

- (LKTagItemView *)getImageView {
    if (self.imageViewQueue.size == 0) {
        return LKTagItemView.view;
    }
    return (LKTagItemView *)[self.imageViewQueue dequeue];
}

- (void)addImageViews:(NSArray *)imageViews {
    for (NSInteger i = 0; i < imageViews.count && i < TAG_ITEM_VIEW_CENTER_DEFAULT_SIZE; ++i) {
        [self addImageView:imageViews[i]];
    }
}

- (void)addImageView:(LKTagItemView *)imageView {
    if (![imageView isKindOfClass:[LKTagItemView class]])
        return;
    [self.imageViewQueue enqueue:imageView];
}

- (NSArray *)getImageViewsByCount:(NSInteger)count {
    NSMutableArray *resultArray = [NSMutableArray array];
    for (NSInteger i = 0; i < count; ++i) {
        if (self.imageViewQueue.size == 0) {
            [resultArray addObject:LKTagItemView.view];
        } else {
            [resultArray addObject:self.imageViewQueue.dequeue];
        }
    }
    return resultArray;
}

@end
