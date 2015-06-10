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

-(void) dealloc
{
    [self cancelAllRequests];
    [self cancelAllTimers];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
    
    [self buildUI];
}

-(void) buildUI
{
    
}

@end
