//
//  LKPostTagsDetailModel.m
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/4/20.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKPostTagsDetailModel.h"
#import "LKTag.h"

@interface LKPostTagsDetailModel ()

LC_PROPERTY(strong) NSMutableDictionary * associatedTagsDic;

@end

@implementation LKPostTagsDetailModel

-(void) dealloc
{
    [self cancelAllRequests];
}

-(void) setAssociatedTags:(NSMutableArray *)associatedTags
{
    _associatedTags = associatedTags;
    
    self.associatedTagsDic = [NSMutableDictionary dictionary];
    
    for (LKTag * tag in _associatedTags) {
        
        [self.associatedTagsDic setObject:tag forKey:tag.id.description];
    }
}

-(void) loadDataWithPostID:(NSNumber *)postID getMore:(BOOL)getMore
{
    NSInteger page = 0;
    
    if (getMore) {
        page = _page + 1;
    }
    
    LKHttpRequestInterface * interface = [LKHttpRequestInterface interfaceType:[NSString stringWithFormat:@"post/%@/marks/%@", @(postID.integerValue), @(page)]].AUTO_SESSION();
    
    // post/1/ma
    
    @weakly(self);
    
    [self request:interface complete:^(LKHttpRequestResult *result) {
       
        @normally(self);
        
        if (result.state == LKHttpRequestStateFinished) {
            
            NSArray * tmp = result.json[@"data"][@"marks"];
            
            NSMutableArray * array = [NSMutableArray array];
            
            for (NSDictionary * obj in tmp) {
                
                LKTag * newTag = [LKTag objectFromDictionary:obj];
                LKTag * oldTag = self.associatedTagsDic[newTag.id.description];
                
                if (oldTag) {
                    
                    oldTag.user = newTag.user;
                    oldTag.likes = newTag.likes;
                    oldTag.isLiked = newTag.isLiked;
                    oldTag.createTime = newTag.createTime;
                    oldTag.comments = newTag.comments;
                    oldTag.totalComments = newTag.totalComments;
                    oldTag.likers = newTag.likers;
                    
                    [array addObject:oldTag];

                }
                else{
                    
                    [array addObject:newTag];
                }
            }
            
            if (getMore) {
                [self.tags addObjectsFromArray:array];
            }
            else{
                self.tags = array;
            }
            
            self.page = page;
            
            if (self.requestFinished) {
                self.requestFinished(result, nil);
            }
        }
        else if (result.state == LKHttpRequestStateFailed){
            
            if (self.requestFinished) {
                self.requestFinished(result, result.error);
            }
        }
        else if(result.state == LKHttpRequestStateCanceled){
            
            if (self.requestFinished) {
                self.requestFinished(result, nil);
            }
        }
        
    }];
}

@end
