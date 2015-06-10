//
//  UITabBarItem+LCExtension.m
//  LCFrameworkDemo
//
//  Created by Leer on 15/4/10.
//  Copyright (c) 2015年 Licheng Guo . http://nsobject.me/. All rights reserved.
//

#import "UITabBarItem+LCExtension.h"

#define KEY_TAGDATA	"UITabBarItem.Image.Key"

@implementation UITabBarItem (LCExtension)

- (NSArray *)imageArray
{
    return [LCAssociate getAssociatedObject:self key:KEY_TAGDATA];
}

- (void)setImageArray:(NSArray *)imageArray
{
    return [LCAssociate setAssociatedObject:self value:imageArray key:KEY_TAGDATA];
}

@end
