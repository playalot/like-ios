//
//  LCHTTPRequestModel.h
//  LCFrameworkDemo
//
//  Created by Licheng Guo . http://nsobject.me/ on 15/4/2.
//  Copyright (c) 2015年 Licheng Guo . http://nsobject.me/. All rights reserved.
//

#import "LCModel.h"

LC_BLOCK(BOOL, LCHTTPRequestModelSaveResponseData, (id<NSCopying> responseData, NSString * key));
LC_BLOCK(id, LCHTTPRequestModelGetResponseCache, (NSString * key));

@interface LCHTTPRequestModel : LCModel

LC_PROPERTY(readonly) LCHTTPRequestModelSaveResponseData SAVE_CACHE;
LC_PROPERTY(readonly) LCHTTPRequestModelSaveResponseData GET_CACHE;

@end
