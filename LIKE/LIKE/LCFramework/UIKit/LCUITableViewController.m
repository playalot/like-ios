//
//  LC_UITableViewController.m
//  LCFramework

//  Created by Licheng Guo . ( SUGGESTIONS & BUG titm@tom.com ) on 13-9-20.
//  Copyright (c) 2014年 Licheng Guo iOS developer ( http://nsobject.me ).All rights reserved.
//  Also see the copyright page ( http://nsobject.me/copyright.rtf ).
//
//

#import "LCUITableViewController.h"

@interface LCUITableViewController ()

@end

@implementation LCUITableViewController

-(void) dealloc
{
    [self cancelAllRequests];
    [self cancelAllTimers];
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView = [[LCUITableView alloc] initWithFrame:self.view.bounds style:self.initTableViewStyle];
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.view = self.tableView;
    
    [self buildUI];
}

-(void) buildUI
{
    
}

-(void) setPullLoaderStyle:(LCUIPullLoaderStyle)style beginRefresh:(LCUIPullLoaderDidBeginRefresh)beginRefresh
{
    self.pullLoader = [LCUIPullLoader pullLoaderWithScrollView:self.tableView pullStyle:style];
    
    self.pullLoader.beginRefresh = beginRefresh;
}

- (void) reloadData
{
    LC_GCD_SYNCHRONOUS(^{
    
        [self.tableView reloadData];
    
    });
}

-(LCUITableViewCell *) tableView:(LCUITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    LCUITableViewCell * cell = [tableView autoCreateDequeueReusableCellWithIdentifier:@"cell" andClass:[LCUITableViewCell class]];
    
    cell.textLabel.text = LC_NSSTRING_FORMAT(@"%@",@(indexPath.row));
    
    return cell;
}

-(CGFloat) tableView:(LCUITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

-(CGFloat) tableView:(LCUITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}

-(CGFloat) tableView:(LCUITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

-(NSInteger) tableView:(LCUITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

-(NSInteger) numberOfSectionsInTableView:(LCUITableView *)tableView
{
    return 1;
}

-(void) tableView:(LCUITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ;
}

- (NSIndexPath *)tableView:(LCUITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [LCUITableView roundCornersForSelectedBackgroundViewForGroupTableView:tableView
                                                                          cell:[tableView cellForRowAtIndexPath:indexPath]
                                                                     indexPath:indexPath];
    return indexPath;
}

- (NSString *)tableView:(LCUITableView *)tableView titleForHeaderInSection:(NSInteger)section
{

    return @"";
    
}

- (NSString *)tableView:(LCUITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return @"";
}


@end
