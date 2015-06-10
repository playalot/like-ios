//
//  LCUIImageCache.h
//  LCFrameworkDemo
//
//  Created by 王振君 on 15-4-7.
//  Copyright (c) 2015年 Licheng Guo . http://nsobject.me/. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LCUIImageCache : NSObject

LC_PROPERTY(strong) LCMemoryCache * memoryCache;
LC_PROPERTY(strong) LCFileCache * fileCache;

-(BOOL) hasCachedWithKey:(NSString *)key;
-(UIImage *) imageWithKey:(NSString *)key;

-(void) saveImageToMemoryCache:(UIImage *)image key:(NSString *)key;
-(void) saveImageDataToFileCache:(NSData *)imageData key:(NSString *)key;

-(void) removeImageWithKey:(NSString *)key;

- (void)deleteAllImages;

@end
