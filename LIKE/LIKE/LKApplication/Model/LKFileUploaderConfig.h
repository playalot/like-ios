//
//  IFConfig.h
//  IFAPP
//
//  Created by Licheng Guo . http://nsobject.me/ on 15/3/2.
//  Copyright (c) 2015年 Licheng Guo . ( http://nsobject.me ). All rights reserved.
//

#pragma mark -

/**
 调用init后,会根据当前类名在doc目录下创建db。
 The path of source code : [[LC_Sanbox docPath] stringByAppendingString:LC_NSSTRING_FORMAT(@"/%@.db",[self class])]
 */
@interface LKConfig : LCUserDefaults

@end

#pragma mark -

@interface LKQiniuConfig : LKConfig

LC_PROPERTY(copy) NSString * token;
LC_PROPERTY(copy) NSString * space;
LC_PROPERTY(strong) NSNumber * expires;

@end

#pragma mark -
