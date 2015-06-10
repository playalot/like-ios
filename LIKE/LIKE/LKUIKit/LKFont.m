//
//  IFFont.m
//  IFAPP
//
//  Created by Leer on 15/1/13.
//  Copyright (c) 2015年 Licheng Guo . ( http://nsobject.me ). All rights reserved.
//

#import "LKFont.h"

@implementation LKFont

+(UIFont *) fontWithSize:(CGFloat)size bold:(BOOL)bold
{
    if (bold) {
        
        return [UIFont fontWithName:@"AvenirNext-Medium" size:size];
    }
    
    return [UIFont fontWithName:@"AvenirNext-Regular" size:size];
}

@end
