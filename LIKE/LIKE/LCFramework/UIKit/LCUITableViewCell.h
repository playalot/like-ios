//
//  LC_UITableViewCell.h
//  LCFramework

//  Created by Licheng Guo . ( SUGGESTIONS & BUG titm@tom.com ) on 13-9-20.
//  Copyright (c) 2014年 Licheng Guo iOS developer ( http://nsobject.me ).All rights reserved.
//  Also see the copyright page ( http://nsobject.me/copyright.rtf ).
//
//

#import <UIKit/UIKit.h>

@interface LCUITableViewCell : UITableViewCell

LC_PROPERTY(strong) NSIndexPath * cellIndexPath;
LC_PROPERTY(strong) UIColor * selectedViewColor;

LC_PROPERTY(assign) LCUITableView * tableView;

-(void) buildUI;

@end
