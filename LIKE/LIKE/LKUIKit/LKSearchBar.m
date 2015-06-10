//
//  LKSearchBar.m
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/5/26.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKSearchBar.h"

@implementation LKSearchBar

-(void) setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    self.layer.cornerRadius = frame.size.height / 2;
    self.layer.masksToBounds = YES;
    
//    self.layer.borderColor = LKColor.color.CGColor;
//    self.layer.borderWidth = 1;
}


@end
