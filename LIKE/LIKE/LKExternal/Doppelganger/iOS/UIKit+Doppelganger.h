//
//  UIKit+Doppelganger.h
//  Pods
//
//  Created by Sash Zats on 1/13/15.
//
//

#import <UIKit/UIKit.h>

@interface UICollectionView (Doppelganger)

- (void)wml_applyBatchChanges:(NSArray *)changes inSection:(NSUInteger)section completion:(void (^)(BOOL finished))completion;

@end

@interface UITableView (Doppelganger)

- (void)wml_applyBatchChanges:(NSArray *)changes inSection:(NSUInteger)section withRowAnimation:(UITableViewRowAnimation)animation;

@end
// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com