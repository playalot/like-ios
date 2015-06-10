//
//  LC_UITableView.h
//  LCFramework

//  Created by Licheng Guo . ( SUGGESTIONS & BUG titm@tom.com ) on 13-9-20.
//  Copyright (c) 2014年 Licheng Guo iOS developer ( http://nsobject.me ).All rights reserved.
//  Also see the copyright page ( http://nsobject.me/copyright.rtf ).
//
//

#import <UIKit/UIKit.h>

LC_BLOCK(void, LCUITableViewDidTap, ());
LC_BLOCK(void, LCUITableViewWillReload, ());

@class LCUITableViewCell;

@interface LCUITableView : UITableView

LC_PROPERTY(copy) LCUITableViewDidTap didTap;
LC_PROPERTY(copy) LCUITableViewWillReload willReload;

LC_PROPERTY(strong) UIColor * backgroundViewColor;

- (void)setBackgroundViewColor:(UIColor *)color;
- (void)scrollToBottomAnimated:(BOOL)animated;

-(id) autoCreateDequeueReusableCellWithIdentifier:(NSString *)identifier andClass:(Class)cellClass;
-(id) autoCreateDequeueReusableCellWithIdentifier:(NSString *)identifier
                                         andClass:(Class)cellClass
                                configurationCell:(void (^)(id configurationCell))configurationCell;





//
+ (void)roundCornersForSelectedBackgroundViewForGroupTableView:(UITableView *)tableView cell:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath;

@end
