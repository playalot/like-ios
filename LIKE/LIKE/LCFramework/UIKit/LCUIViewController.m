//
//  LC_UIViewController.m
//  LCFramework

//  Created by Licheng Guo . ( SUGGESTIONS & BUG titm@tom.com ) on 13-9-21.
//  Copyright (c) 2014年 Licheng Guo iOS developer ( http://nsobject.me ).All rights reserved.
//  Also see the copyright page ( http://nsobject.me/copyright.rtf ).
//
//

#import "LCUIViewController.h"

@interface LCUIViewController ()


@end

@implementation LCUIViewController

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.isCurrentDisplayController = YES;
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.isCurrentDisplayController = NO;
}


-(void) dealloc
{
    [self cancelAllRequests];
    [self cancelAllTimers];
    [self unobserveAllNotifications];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
    
    [self buildUI];
    
    
}

/**
 *  iOS6以后不再使用
 */
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    
    return NO;
}

-(void) buildUI
{
    
}

@end
