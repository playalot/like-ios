//
//  LKPhotoAlbum.m
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/4/24.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKPhotoAlbum.h"
#import <AssetsLibrary/AssetsLibrary.h>

typedef void(^LKSaveImageCompletion)(NSError * error);

@interface ALAssetsLibrary (LKImageSave)

@end

@implementation ALAssetsLibrary (LKImageSave)

-(void) saveImage:(UIImage *)image toAlbum:(NSString *)albumName withCompletionBlock:(LKSaveImageCompletion)completionBlock
{
    //write the image data to the assets library (camera roll)
    [self writeImageToSavedPhotosAlbum:image.CGImage orientation:(ALAssetOrientation)image.imageOrientation
                       completionBlock:^(NSURL* assetURL, NSError* error) {
                           
                           //error handling
                           if (error!=nil) {
                               completionBlock(error);
                               return;
                           }
                           
                           //add the asset to the custom photo album
                           [self addAssetURL: assetURL
                                     toAlbum:albumName
                         withCompletionBlock:completionBlock];
                           
                       }];
}

-(void)addAssetURL:(NSURL*)assetURL toAlbum:(NSString*)albumName withCompletionBlock:(LKSaveImageCompletion)completionBlock
{
    __block BOOL albumWasFound = NO;
    
    //search all photo albums in the library
    [self enumerateGroupsWithTypes:ALAssetsGroupAlbum
                        usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                            
                            //compare the names of the albums
                            if ([albumName compare: [group valueForProperty:ALAssetsGroupPropertyName]]==NSOrderedSame) {
                                
                                //target album is found
                                albumWasFound = YES;
                                
                                //get a hold of the photo's asset instance
                                [self assetForURL: assetURL
                                      resultBlock:^(ALAsset *asset) {
                                          
                                          //add photo to the target album
                                          [group addAsset: asset];
                                          
                                          //run the completion block
                                          completionBlock(nil);
                                          
                                      } failureBlock: completionBlock];
                                
                                //album was found, bail out of the method
                                return;
                            }
                            
                            if (group==nil && albumWasFound==NO) {
                                //photo albums are over, target album does not exist, thus create it
                                
                                __weak ALAssetsLibrary* weakSelf = self;
                                
                                //create new assets album
                                [self addAssetsGroupAlbumWithName:albumName
                                                      resultBlock:^(ALAssetsGroup *group) {
                                                          
                                                          //get the photo's instance
                                                          [weakSelf assetForURL: assetURL
                                                                    resultBlock:^(ALAsset *asset) {
                                                                        
                                                                        //add photo to the newly created album
                                                                        [group addAsset: asset];
                                                                        
                                                                        //call the completion block
                                                                        completionBlock(nil);
                                                                        
                                                                    } failureBlock: completionBlock];
                                                          
                                                      } failureBlock: completionBlock];
                                
                                //should be the last iteration anyway, but just in case
                                return;
                            }
                            
                        } failureBlock: completionBlock];
    
}

@end

@implementation LKPhotoAlbum

+(void) saveImage:(UIImage *)image showTip:(BOOL)showTip
{
    if (!image) {
        return;
    }
    
    ALAssetsLibrary * lib = ALAssetsLibrary.new;
    
    [lib saveImage:image toAlbum:@"Like" withCompletionBlock:^(NSError * error) {
        
        if (showTip) {
            
            if (!error) {
                
                RKDropdownAlert * alertView = [LC_KEYWINDOW showTopLoadingMessageHud:@"图片保存成功"];
                [alertView performSelector:@selector(viewWasTapped:) withObject:alertView afterDelay:3];
            }
            else{
                
                [LCUIAlertView showWithTitle:nil message:@"图片保存失败，可能是因为您拒绝了相册的访问权限" cancelTitle:@"知道了" otherTitle:nil didTouchedBlock:^(NSInteger integerValue) {
                    
                }];
            }
        }

    }];
}

@end
