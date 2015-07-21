//
//  WMLArrayDiff.h
//  Pods
//
//  Created by Sash Zats on 1/8/15.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, WMLArrayDiffType) {
    WMLArrayDiffTypeMove,
    WMLArrayDiffTypeInsert,
    WMLArrayDiffTypeDelete
};

@interface WMLArrayDiff : NSObject

@property (nonatomic, readonly) WMLArrayDiffType type;

@property (nonatomic, readonly) NSUInteger previousIndex;

@property (nonatomic, readonly) NSUInteger currentIndex;

@end
// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com