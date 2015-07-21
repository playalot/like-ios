//
//  WMLArrayDiff+Creation.h
//  Pods
//
//  Created by Sash Zats on 1/8/15.
//
//

#import "WMLArrayDiff.h"

@interface WMLArrayDiff (Creation)

+ (instancetype)arrayDiffForDeletionAtIndex:(NSUInteger)index;

+ (instancetype)arrayDiffForInsertionAtIndex:(NSUInteger)index;

+ (instancetype)arrayDiffForMoveFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;

@end
// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com