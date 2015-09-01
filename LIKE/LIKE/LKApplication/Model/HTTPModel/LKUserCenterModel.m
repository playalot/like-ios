//
//  LKUserCenterModel.m
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/4/15.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKUserCenterModel.h"
#import "LKPost.h"

@interface LKUserCenterModel ()

LC_PROPERTY(assign) NSInteger photoPage;
LC_PROPERTY(assign) NSInteger focusPage;
LC_PROPERTY(assign) NSInteger fansPage;

LC_PROPERTY(assign) BOOL photoCanLoadMore;
LC_PROPERTY(assign) BOOL focusCanLoadMore;
LC_PROPERTY(assign) BOOL fansCanLoadMore;

@end

@implementation LKUserCenterModel

-(void) dealloc
{
    [self cancelAllRequests];
}

-(instancetype) init
{
    if (self = [super init]) {
        
        self.photoCanLoadMore = YES;
        self.focusCanLoadMore = YES;
        self.fansCanLoadMore = YES;
    }
    
    return self;
}


-(void) getDataAtFirstPage:(BOOL)isFirstPage type:(LKUserCenterModelType)type uid:(NSNumber *)uid
{
    NSInteger page = 0;
    
    if (!isFirstPage) {
        page = [self pageWithType:type] + 1;
    }
    
    LKHttpRequestInterface * interface = nil;
    
    switch (type) {
        case LKUserCenterModelTypePhotos:
            interface = [LKHttpRequestInterface interfaceType:LC_NSSTRING_FORMAT(@"user/%@/posts/%@", uid, @(page))].AUTO_SESSION();
            break;
        case LKUserCenterModelTypeFocus:
            interface = [LKHttpRequestInterface interfaceType:LC_NSSTRING_FORMAT(@"user/%@/follows/%@", uid, @(page))].AUTO_SESSION();
            break;
        case LKUserCenterModelTypeFans:
            interface = [LKHttpRequestInterface interfaceType:LC_NSSTRING_FORMAT(@"user/%@/fans/%@", uid, @(page))].AUTO_SESSION();
            break;
        case LKUserCenterModelTypeFavor:
            interface = [LKHttpRequestInterface interfaceType:LC_NSSTRING_FORMAT(@"user/%@/posts/%@", uid, @(page))].AUTO_SESSION();
            break;
        default:
            break;
    }
    
    
    @weakly(self);
    
    [self request:interface complete:^(LKHttpRequestResult *result) {
        
        @normally(self);
        
        if (result.state == LKHttpRequestStateFinished) {
            
            [self handleResultWithType:type isFirstPage:isFirstPage result:result];
        
            [self setPageWithType:type page:page];
            
            if (self.requestFinished) {
                self.requestFinished(type, result, nil);
            }
        }
        else if (result.state == LKHttpRequestStateFailed){
            
            if (self.requestFinished) {
                self.requestFinished(type, result, result.error);
            }
        }
    }];

}

-(BOOL) canLoadMoreWithType:(LKUserCenterModelType)type
{
    switch (type) {
            
        case LKUserCenterModelTypePhotos:
            
            return self.photoCanLoadMore;
            break;
            
        case LKUserCenterModelTypeFocus:
            
            return self.focusCanLoadMore;
            break;
            
        case LKUserCenterModelTypeFans:
            
            return self.fansCanLoadMore;
            break;
            
        case LKUserCenterModelTypeFavor:
            
            return self.photoCanLoadMore;
            break;
            
        default:
            
            return YES;
            break;
    }
}

-(void) handleResultWithType:(LKUserCenterModelType)type isFirstPage:(BOOL)isFirstPage result:(LKHttpRequestResult *)result
{
    switch (type) {
            
        case LKUserCenterModelTypePhotos:
        {
            NSArray * datasource = result.json[@"data"][@"posts"];
            
            NSMutableArray * resultData = [NSMutableArray array];
            
            for (NSDictionary * tmp in datasource) {
                
                [resultData addObject:[LKPost objectFromDictionary:tmp]];
            }
            
            if (isFirstPage) {
                
                self.photoArray = resultData;
            }
            else{
                
                [self.photoArray addObjectsFromArray:resultData];
            }
            
            if (datasource.count < 21) {
                
                self.photoCanLoadMore = NO;
            }
            
        }
            break;
            
        case LKUserCenterModelTypeFocus:
        {
            NSArray * datasource = result.json[@"data"][@"follows"];
            
            NSMutableArray * resultData = [NSMutableArray array];
            
            for (NSDictionary * tmp in datasource) {
                
                [resultData addObject:[LKUser objectFromDictionary:tmp]];
            }
            
            if (isFirstPage) {
                
                self.focusArray = resultData;
            }
            else{
                
                [self.focusArray addObjectsFromArray:resultData];
            }
            
            if (datasource.count < 20) {
                
                self.focusCanLoadMore = NO;
            }
        }
            break;
            
        case LKUserCenterModelTypeFans:
        {
            NSArray * datasource = result.json[@"data"][@"fans"];
            
            NSMutableArray * resultData = [NSMutableArray array];
            
            for (NSDictionary * tmp in datasource) {
                
                [resultData addObject:[LKUser objectFromDictionary:tmp]];
            }
            
            if (isFirstPage) {
                
                self.fansArray = resultData;
            }
            else{
                
                [self.fansArray addObjectsFromArray:resultData];
            }
            
            if (datasource.count < 20) {
                
                self.fansCanLoadMore = NO;
            }
        }
            break;
            
        case LKUserCenterModelTypeFavor:
        {
            NSArray * datasource = result.json[@"data"][@"posts"];
            
            NSMutableArray * resultData = [NSMutableArray array];
            
            for (NSDictionary * tmp in datasource) {
                
                [resultData addObject:[LKPost objectFromDictionary:tmp]];
            }
            
            if (isFirstPage) {
                
                self.photoArray = resultData;
            }
            else{
                
                [self.photoArray addObjectsFromArray:resultData];
            }
            
            if (datasource.count < 21) {
                
                self.photoCanLoadMore = NO;
            }
            
        }
            break;
            
        default:
            break;
    }
}

-(NSMutableArray *) dataWithType:(LKUserCenterModelType)type
{
    switch (type) {
            
        case LKUserCenterModelTypePhotos:
            return self.photoArray;
            break;
            
        case LKUserCenterModelTypeFocus:
            return self.focusArray;
            break;
            
        case LKUserCenterModelTypeFans:
            return self.fansArray;
            break;
            
        case LKUserCenterModelTypeFavor:
            return self.photoArray;
            break;
            
        default:
            break;
    }
}

-(NSInteger) pageWithType:(LKUserCenterModelType)type
{
    switch (type) {
            
        case LKUserCenterModelTypePhotos:
            return self.photoPage;
            break;
            
        case LKUserCenterModelTypeFocus:
            return self.focusPage;
            break;
            
        case LKUserCenterModelTypeFans:
            return self.fansPage;
            break;
            
        case LKUserCenterModelTypeFavor:
            return self.photoPage;
            break;
            
        default:
            break;
    }
}

-(void) setPageWithType:(LKUserCenterModelType)type page:(NSInteger)page
{
    switch (type) {
            
        case LKUserCenterModelTypePhotos:
            self.photoPage = page;
            break;
            
        case LKUserCenterModelTypeFocus:
            self.focusPage = page;
            break;
            
        case LKUserCenterModelTypeFans:
            self.fansPage = page;
            break;
            
        case LKUserCenterModelTypeFavor:
            self.photoPage = page;
            break;
            
        default:
            break;
    }
}

@end
