//
//  LCModel.h
//  LCFrameworkDemo
//
//  Created by Licheng Guo . http://nsobject.me/ on 15/4/2.
//  Copyright (c) 2015年 Licheng Guo . http://nsobject.me/. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModelLib.h"

#define LC_PROPERTY_MODEL(_class ,_nick) @property (nonatomic, strong) _class * _nick;

LC_BLOCK(id, LCModelObserver, (id observer));

@interface LCModel : JSONModel

LC_PROPERTY(readonly) NSMutableArray * observers;

LC_PROPERTY(readonly) LCModelObserver OBSERVER;

@end
