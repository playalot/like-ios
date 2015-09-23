//
//  LKAttentionView.m
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/7/21.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKAttentionView.h"
#import "LKHomeViewController.h"

@interface LKAttentionView ()

@end

@implementation LKAttentionView

-(instancetype) init {
    if (self = [super initWithFrame:CGRectMake(0, 0, LC_DEVICE_WIDTH, LC_DEVICE_HEIGHT + 20 - 64)]) {
        
        self.backgroundImageView.backgroundColor = LKColor.backgroundColor;
        
        self.tableView = [[LCUITableView alloc] initWithFrame:CGRectZero];
        self.tableView.frame = self.bounds;
        self.tableView.backgroundView = nil;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableView.scrollsToTop = YES;
        self.tableView.backgroundColor = [UIColor clearColor];
        self.ADD(self.tableView);
        

        self.pullLoader = [LCUIPullLoader pullLoaderWithScrollView:self.tableView pullStyle:LCUIPullLoaderStyleFooter];
        self.pullLoader.indicatorViewStyle = UIActivityIndicatorViewStyleWhite;
        
        @weakly(self);
        
        self.pullLoader.beginRefresh = ^(LCUIPullLoaderDiretion diretion){
            
            @normally(self);
            
            [(LKHomeViewController *)self.delegate loadData:diretion];
        };
        
    }
    
    return self;
}

-(void) setDelegate:(id)delegate
{
    _delegate = delegate;
    
    self.tableView.delegate = delegate;
    self.tableView.dataSource = delegate;
}

@end
