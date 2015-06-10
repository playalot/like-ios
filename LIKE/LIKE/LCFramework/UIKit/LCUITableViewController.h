//
//  LC_UITableViewController.h
//  LCFramework

//  Created by Licheng Guo . ( SUGGESTIONS & BUG titm@tom.com ) on 13-9-20.
//  Copyright (c) 2014年 Licheng Guo iOS developer ( http://nsobject.me ).All rights reserved.
//  Also see the copyright page ( http://nsobject.me/copyright.rtf ).
//
//

#import <UIKit/UIKit.h>
#import "LCUIPullLoader.h"

@interface LCUITableViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>

LC_PROPERTY(assign) UITableViewStyle initTableViewStyle;
LC_PROPERTY(strong) LCUITableView * tableView;
LC_PROPERTY(strong) LCUIPullLoader * pullLoader;

-(void) setPullLoaderStyle:(LCUIPullLoaderStyle)style beginRefresh:(LCUIPullLoaderDidBeginRefresh)beginRefresh;

-(void) reloadData;

-(LCUITableViewCell *) tableView:(LCUITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

-(CGFloat) tableView:(LCUITableView *)tableView heightForHeaderInSection:(NSInteger)section;
-(CGFloat) tableView:(LCUITableView *)tableView heightForFooterInSection:(NSInteger)section;
-(CGFloat) tableView:(LCUITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;

-(NSInteger) tableView:(LCUITableView *)tableView numberOfRowsInSection:(NSInteger)section;
-(NSInteger) numberOfSectionsInTableView:(LCUITableView *)tableView;

-(void) tableView:(LCUITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

-(void) buildUI;

@end
