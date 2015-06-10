//
//  LCUIImageCache.m
//  LCFrameworkDemo
//
//  Created by 王振君 on 15-4-7.
//  Copyright (c) 2015年 Licheng Guo . http://nsobject.me/. All rights reserved.
//

#import "LCUIImageCache.h"

@implementation LCUIImageCache


-(instancetype) singletonInit
{
    self.memoryCache = [[LCMemoryCache alloc] init];
    self.memoryCache.clearWhenMemoryLow = YES;
    
    self.fileCache = [[LCFileCache alloc] init];
    self.fileCache.cachePath = LC_NSSTRING_FORMAT(@"%@/LCImageCache/",[LCSanbox libCachePath]);
    
    return self;
}

- (BOOL)hasCachedWithKey:(NSString *)key
{
    NSString * cacheKey = [key MD5];
    
    BOOL flag = [self.memoryCache hasObjectForKey:cacheKey];
    
    if (NO == flag){
        
        flag = [self.fileCache hasObjectForKey:cacheKey];
    }
    
    return flag;
}

- (UIImage *)imageWithKey:(NSString *)string
{
    NSString * cacheKey = [string MD5];
    
    UIImage * image = nil;
    
    NSObject * object = [self.memoryCache objectForKey:cacheKey];
    
    if (object && [object isKindOfClass:[UIImage class]]){
        
        image = (UIImage *)object;
    }
    
    if (nil == image){
        
        NSString * fullPath = [self.fileCache fileNameForKey:cacheKey];
        
        if (fullPath){
            
            image = [UIImage imageWithContentsOfFile:fullPath];
            
            UIImage * cachedImage = (UIImage *)[self.memoryCache objectForKey:cacheKey];
            
            if (nil == cachedImage && image != cachedImage){
                
                [self.memoryCache setObject:image forKey:cacheKey];
            }
        }
    }
    
    return image;
}

- (void)saveImageToMemoryCache:(UIImage *)image key:(NSString *)key
{
    NSString * cacheKey = [key MD5];
    
    UIImage * cachedImage = [self.memoryCache objectForKey:cacheKey];
    
    if (nil == cachedImage && image != cachedImage){
        
        [self.memoryCache setObject:image forKey:cacheKey];
    }
}

-(void) saveImageDataToFileCache:(NSData *)imageData key:(NSString *)key
{
    NSString * cacheKey = [key MD5];
    
    [self.fileCache setObject:imageData forKey:cacheKey];
}

- (void)removeImageWithKey:(NSString *)key
{
    NSString * cacheKey = [key MD5];
    
    [_memoryCache removeObjectForKey:cacheKey];
    [_fileCache removeObjectForKey:cacheKey];
}

- (void)deleteAllImages
{
    [_memoryCache removeAllObjects];
    [_fileCache removeAllObjects];
}



@end
