//
//  LCUIView.m
//  LCFrameworkDemo
//
//  Created by Licheng Guo . http://nsobject.me/ on 15/4/2.
//  Copyright (c) 2015年 Licheng Guo . http://nsobject.me/. All rights reserved.
//

#import "LCUIView.h"

@interface LCUIView ()
{
    BOOL _inited;
}

@end

@implementation LCUIView


-(id) init
{
    if (self = [super init]) {
        
        if (_inited == NO) {
            
            [self buildUI];
        }
        
        _inited = YES;
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        
        if (_inited == NO) {
            
            [self buildUI];
        }
        
        _inited = YES;
    }
    
    return self;
}

-(void) buildUI
{
    
}

@end
