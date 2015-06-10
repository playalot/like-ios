//
//  LC_UITapMaskView.m
//  WuxianchangPro
//
//  Created by Licheng Guo . ( SUGGESTIONS & BUG titm@tom.com ) on 13-11-1.
//  Copyright (c) 2013年 Wuxiantai Developer ( http://www.wuxiantai.com ). All rights reserved.
//

#import "LCUIMaskView.h"

@implementation LCUIMaskView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.alpha = 0;
        self.backgroundColor = LC_RGBA(0, 0, 0, 0.3);
        [self addTapGestureRecognizer:self selector:@selector(tapAction)];
    }
    return self;
}

-(id) init
{
    if (self = [super init]) {
        
        self.alpha = 0;
        self.backgroundColor = LC_RGBA(0, 0, 0, 0.3);
        [self addTapGestureRecognizer:self selector:@selector(tapAction)];
    }
    
    return self;
}

-(void) show
{
    LC_FAST_ANIMATIONS(0.25, ^{
    
        self.alpha = 1;
    
    });
}

-(void) hide
{
    LC_FAST_ANIMATIONS(0.25, ^{
        
        self.alpha = 0;
        
    });
}

-(void) hide:(BOOL)animated
{
    if (animated) {
        LC_FAST_ANIMATIONS(0.25, ^{
            
            self.alpha = 0;
            
        });
        
        return;
    }
    
    self.alpha = 0;
}

-(void) tapAction
{
    if (self.willHide) {
        self.willHide(self);
    }
    
    [self hide];
}

@end
