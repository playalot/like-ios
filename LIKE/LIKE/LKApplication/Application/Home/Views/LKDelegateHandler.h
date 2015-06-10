//
//  LKHomepageHeaderHandler.h
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/4/24.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LKDelegateHandler : NSObject

/**
 The first delegate.
 */
@property (nonatomic, weak) id<NSObject> firstDelegate;

/**
 The second delegate.
 */
@property (nonatomic, weak) id<NSObject> secondDelegate;

/**
 A convenience initializer that sets the first and second delegate.
 @param The existing layout attributes.
 @return A delegate splitter instance, or nil of initialization fails.
 */
- (instancetype)initWithFirstDelegate:(id<NSObject>)firstDelegate secondDelegate:(id<NSObject>)secondDelegate;

@end
