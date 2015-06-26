//
//  LKNewPostUploadCenter.m
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/6/12.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKNewPostUploadCenter.h"
#import "LKFileUploader.h"
#import "LKTag.h"
#import "QNUploadOption.h"
#import "LKPost.h"

@implementation LKPosting


@end

@implementation LKNewPostUploadCenter

-(void) dealloc
{
    [self cancelAllRequests];
}

-(instancetype) init
{
    if (self = [super init]) {
        
        self.uploadingImages = [NSMutableArray array];
        
        
        NSMutableArray * cache = [LKUserDefaults.singleton[self.class.description] mutableCopy];
        
        if (cache) {
            
            self.uploadingImages = cache;
        }
    }
    
    return self;
}

+(void) uploadImage:(UIImage *)image tags:(NSArray *)tags
{
    [LKNewPostUploadCenter.singleton uploadImage:image tags:tags];
}

-(void) uploadImage:(UIImage *)image tags:(NSArray *)tags
{
    if (!image || !tags) {
        return;
    }
    
    LKPosting * posting = [[LKPosting alloc] init];
    posting.image = image;
    posting.tags = tags;
    posting.uploading = YES;

    [self.uploadingImages addObject:posting];
    
    if (self.addedNewValue) {
        self.addedNewValue(posting, @(self.uploadingImages.count - 1));
    }
    
    [self uploadPost:posting];
}

-(void) uploadPost:(LKPosting *)posing
{
    
    QNUploadOption * option = [[QNUploadOption alloc] initWithProgessHandler:^(NSString *key, float percent) {
        
        posing.progress = percent;
        
        if (posing.updateProgress) {
            posing.updateProgress(@(percent));
        }
        
    }];
    
    
    [LKFileUploader.singleton uploadFileData:posing.image suffix:@"jpg" completeBlock:^(BOOL completed, NSString *uploadedKey, NSString *error) {
        
        if (completed) {
            
            NSMutableArray * array = [NSMutableArray array];
            
            for (LKTag * oTag in posing.tags) {
                
                [array addObject:oTag.tag];
            }
            
            [self post:uploadedKey jsonTags:array posting:posing];
        }
        else{
            
            [self failed:posing];
        }

        
    } option:option];
}

-(void) post:(NSString *)imageKey jsonTags:(NSArray *)jsonTags posting:(LKPosting *)posting
{
    LKHttpRequestInterface * interface = [LKHttpRequestInterface interfaceType:@"post"].AUTO_SESSION().POST_METHOD();
    
    [interface addParameter:imageKey key:@"content"];
    [interface addParameter:@"PHOTO"  key:@"type"];
    [interface addParameter:jsonTags key:@"tags"];
    
    
    @weakly(self);
    
    [self request:interface complete:^(LKHttpRequestResult *result) {
        
        @normally(self);
        
        if (result.state == LKHttpRequestStateFinished) {
            
            LKPost * post = [LKPost objectFromDictionary:result.json[@"data"]];

            [self finised:posting post:post];
        }
        else if(result.state == LKHttpRequestStateFailed){
            
            [self failed:posting];
        }
    }];

}

-(void) finised:(LKPosting *)posting post:(LKPost *)post
{
    NSInteger index = [self.uploadingImages indexOfObject:posting];
    
    [self.uploadingImages removeObject:posting];

    if (self.uploadFinished) {
        self.uploadFinished(post, @(index));
    }
}

-(void) reuploadPosting:(LKPosting *)posting
{
    posting.uploading = YES;
    
    if (self.stateChanged) {
        self.stateChanged(self);
    }
    
    [self uploadPost:posting];

}

-(void) cancelPosting:(LKPosting *)posting
{
    [self finised:posting post:nil];
}

-(void) failed:(LKPosting *)posting
{
    posting.uploading = NO;
    
    if (self.uploadFailed) {
        self.uploadFailed(nil);
    }
}

@end
