//
//  LKUserCenterModel.m
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/4/15.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKUserCenterModel.h"
#import "LKPost.h"
#import "LKUserPostsInterface.h"
#import "LKUserFollowsInterface.h"
#import "LKUserFansInterface.h"
#import "LKUserFavouritesInterface.h"

@interface LKUserCenterModel ()

LC_PROPERTY(assign) NSInteger photoPage;
LC_PROPERTY(assign) NSInteger focusPage;
LC_PROPERTY(assign) NSInteger fansPage;
LC_PROPERTY(assign) NSInteger favorPage;

LC_PROPERTY(assign) BOOL photoCanLoadMore;
LC_PROPERTY(assign) BOOL focusCanLoadMore;
LC_PROPERTY(assign) BOOL fansCanLoadMore;
LC_PROPERTY(assign) BOOL favorCanLoadMore;

LC_PROPERTY(strong) NSNumber *favorTimestamp;
LC_PROPERTY(strong) NSNumber *photoTimestamp;

LC_PROPERTY(assign) NSInteger index;

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
        self.favorCanLoadMore = YES;
    }
    
    return self;
}

- (void)getDataAtFirstPage:(BOOL)isFirstPage
                      type:(LKUserCenterModelType)type
                       uid:(NSNumber *)uid {
    NSInteger page = 0;
    
    if (!isFirstPage) {
        page = [self pageWithType:type] + 1;
    } else {
        self.photoTimestamp = nil;
        self.favorTimestamp = nil;
    }
    
    LKBaseInterface *interface = nil;
    
    switch (type) {
        case LKUserCenterModelTypePhotos: {
//            interface = [[LKUserPostsInterface alloc] initWithUid:uid page:page];
            interface = [[LKUserPostsInterface alloc] initWithTimeStamp:self.photoTimestamp uid:uid];
            break;
        }
        case LKUserCenterModelTypeFocus:
            interface = [[LKUserFollowsInterface alloc] initWithUid:uid page:page];
            break;
            
        case LKUserCenterModelTypeFans:
            interface = [[LKUserFansInterface alloc] initWithUid:uid page:page];
            break;
            
        case LKUserCenterModelTypeFavor:
            interface = [[LKUserFavouritesInterface alloc] initWithTimeStamp:self.favorTimestamp];
            break;
            
        default:
            break;
    }
    
    @weakly(interface);
    
    [interface startWithCompletionBlockWithSuccess:^(LCBaseRequest *request) {
        
        @normally(interface);
        
        switch (type) {
                
            case LKUserCenterModelTypePhotos: {
                
                LKUserPostsInterface *userPostsInterface = (LKUserPostsInterface *)interface;
                NSArray *datasource = userPostsInterface.posts;
                NSNumber *photoTimestamp = userPostsInterface.next;
                self.photoTimestamp = photoTimestamp;
                
                if (isFirstPage) {
                    self.photoArray = [NSMutableArray arrayWithArray:datasource];
                } else {
                    NSMutableArray *newPosts = self.photoArray;
                    [newPosts addObjectsFromArray:datasource];
                    self.photoArray = newPosts;
                }
                
                self.photoCanLoadMore = datasource.count != 0;
                
                break;
            }
                
            case LKUserCenterModelTypeFocus: {
                
                LKUserFollowsInterface *userFollowsInterface = (LKUserFollowsInterface *)interface;
                NSArray * datasource = userFollowsInterface.follows;
                if (isFirstPage) {
                    self.focusArray = [NSMutableArray arrayWithArray:datasource];
                } else {
                    NSMutableArray *newUsers = [NSMutableArray arrayWithArray:self.focusArray];
                    [newUsers addObjectsFromArray:datasource];
                    [self.focusArray addObjectsFromArray:newUsers];
                }

                self.focusCanLoadMore = datasource.count != 0;
                
                break;
            }
                
            case LKUserCenterModelTypeFans: {
                LKUserFansInterface *userFansInterface = (LKUserFansInterface *)interface;
                
                NSArray *datasource = userFansInterface.fans;
                
                if (isFirstPage) {
                    self.fansArray = [NSMutableArray arrayWithArray:datasource];;
                } else {
                    NSMutableArray *newFans = [NSMutableArray arrayWithArray:self.fansArray];
                    [newFans addObjectsFromArray:datasource];
                    self.fansArray = newFans;
                }
                
                self.fansCanLoadMore = datasource.count != 0;
                
                break;
            }
                
            case LKUserCenterModelTypeFavor: {
                
                LKUserFavouritesInterface *favorInterface = (LKUserFavouritesInterface *)interface;
                NSArray *datasource = favorInterface.posts;
                NSNumber *favorTimestamp = favorInterface.next;
                self.favorTimestamp = favorTimestamp;
                
                if (isFirstPage) {
                    self.favorArray = [NSMutableArray arrayWithArray:datasource];
                } else {
                    NSMutableArray *newFavors = [NSMutableArray arrayWithArray:self.favorArray];
                    [newFavors addObjectsFromArray:datasource];
                    self.favorArray = newFavors;
                }
                
                self.favorCanLoadMore = datasource.count != 0;
                
                break;
            }
                
            default:
                break;
        }
        
        if (self.requestFinished) {
            self.requestFinished(type, nil);
        }
        
    } failure:^(LCBaseRequest *request) {
        
        if (self.requestFinished) {
            self.requestFinished(type, @"404");
        }
        
    }];
}

- (BOOL)canLoadMoreWithType:(LKUserCenterModelType)type {
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
            return self.favorCanLoadMore;
            break;
            
        default:
            return YES;
            break;
    }
}


- (void)handleResultWithType:(LKUserCenterModelType)type isFirstPage:(BOOL)isFirstPage result:(LKHttpRequestResult *)result {
    
    switch (type) {
        case LKUserCenterModelTypePhotos: {
            NSArray *datasource = result.json[@"data"][@"posts"];
            NSNumber *photoTimestamp = result.json[@"data"][@"next"];

            NSMutableArray * resultData = [NSMutableArray array];
            
            for (NSDictionary * tmp in datasource) {
                [resultData addObject:[LKPost objectFromDictionary:tmp]];
            }
            
//            if (isFirstPage) {
//                self.photoArray = resultData;
//            } else {
//                [self.photoArray addObjectsFromArray:resultData];
//            }
            
            if (isFirstPage) {
                self.photoArray = resultData;
                self.index++;
                if (self.index >= 2) {
                    self.photoTimestamp = photoTimestamp;
                }
                
            } else {
                
                if (self.photoTimestamp.integerValue != photoTimestamp.integerValue) {
                    [self.photoArray addObjectsFromArray:resultData];
                    self.photoTimestamp = photoTimestamp;
                }
            }
            
            if (datasource.count == 0) {
                self.photoCanLoadMore = NO;
            }
        }
            break;
            
        case LKUserCenterModelTypeFocus: {
            
            NSArray * datasource = result.json[@"data"][@"follows"];
            NSMutableArray * resultData = [NSMutableArray array];
            for (NSDictionary * tmp in datasource) {
                [resultData addObject:[LKUser objectFromDictionary:tmp]];
            }
            
            if (isFirstPage) {
                self.focusArray = resultData;
            } else {
                [self.focusArray addObjectsFromArray:resultData];
            }
            
            if (datasource.count == 0) {
                self.focusCanLoadMore = NO;
            }
        }
            break;
            
        case LKUserCenterModelTypeFans: {
            
            NSArray * datasource = result.json[@"data"][@"fans"];
            NSMutableArray * resultData = [NSMutableArray array];
            for (NSDictionary * tmp in datasource) {
                [resultData addObject:[LKUser objectFromDictionary:tmp]];
            }
            
            if (isFirstPage) {
                self.fansArray = resultData;
            }  else {
                [self.fansArray addObjectsFromArray:resultData];
            }
            
            if (datasource.count == 0) {
                self.fansCanLoadMore = NO;
            }
        }
            break;
            
        case LKUserCenterModelTypeFavor: {
            
            NSArray *datasource = result.json[@"data"][@"posts"];
            NSNumber *favorTimestamp = result.json[@"data"][@"next"];
            
            NSMutableArray *resultData = [NSMutableArray array];
            
            for (NSDictionary *tmp in datasource) {
                [resultData addObject:[LKPost objectFromDictionary:tmp]];
            }
            
            if (isFirstPage) {
                self.favorArray = resultData;
                self.index++;
                if (self.index >= 2) {
                    self.favorTimestamp = favorTimestamp;
                }
                
            } else {
                
                if (self.favorTimestamp.integerValue != favorTimestamp.integerValue) {
                    [self.favorArray addObjectsFromArray:resultData];
                    self.favorTimestamp = favorTimestamp;
                }
            }
            
            if (datasource.count == 0) {
                self.favorCanLoadMore = NO;
            }
            
        }
            break;
            
        default:
            break;
    }
}

- (NSMutableArray *)dataWithType:(LKUserCenterModelType)type {
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
            return self.favorArray;
            break;
            
        default:
            break;
    }
}

- (NSInteger)pageWithType:(LKUserCenterModelType)type {
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
            return self.favorPage;
            break;
            
        default:
            break;
    }
}

- (void)setPageWithType:(LKUserCenterModelType)type page:(NSInteger)page {
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
            self.favorPage = page;
            break;
            
        default:
            break;
    }
}

@end
