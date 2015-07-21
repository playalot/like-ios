//
//  WMLArrayDiffUtility.h
//  Pods
//
//  Created by Sash Zats on 1/8/15.
//
//

#import <Foundation/Foundation.h>

@interface WMLArrayDiffUtility : NSObject

+ (NSArray *)diffForCurrentArray:(NSArray *)currentArray previousArray:(NSArray *)previousArray;

@property (nonatomic, copy, readonly) NSArray *previousArray;

@property (nonatomic, copy, readonly) NSArray *currentArray;

/**
 *  Returns an array of @c WMLArrayDiff objects ready to be wrapped into 
 *  @c NSIndexPath and fed to table or collection view.
 */
@property (nonatomic, copy, readonly) NSArray /* WMLArrayDiff */ *diff;

- (instancetype)initWithCurrentArray:(NSArray *)currentArray previousArray:(NSArray *)previousArray;

- (void)performDiff;

@end
// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com