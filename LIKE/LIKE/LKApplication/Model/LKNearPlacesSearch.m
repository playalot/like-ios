//
//  LKNearPlacesSearch.m
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/7/2.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKNearPlacesSearch.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchAPI.h>
#import <AMapSearchKit/AMapSearchObj.h>

@interface LKNearPlacesSearch () <MAMapViewDelegate, AMapSearchDelegate>

LC_PROPERTY(strong) AMapSearchAPI * searchAPI;

@end

@implementation LKNearPlacesSearch

-(instancetype) init
{
    if (self = [super init]) {
        
    }
    
    return self;
}

#pragma mark -

-(void) requestNearPlacesWithLocation:(CLLocation *)location page:(NSInteger)page block:(LKNearPlacesSearchBlock)block;
{
    self.block = block;
    
    self.searchAPI = [[AMapSearchAPI alloc] initWithSearchKey:[MAMapServices sharedServices].apiKey Delegate:self];
    
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    
    NSArray * allLanguages = [defaults objectForKey:@"AppleLanguages"];
    
    NSString * preferredLang = [allLanguages objectAtIndex:0];
    
    if (![preferredLang isEqualToString:@"zh-Hans"]) {
        
        self.searchAPI.language = AMapSearchLanguage_en;
    }
    else{
        
        self.searchAPI.language = AMapSearchLanguage_zh_CN;
    }
    
    
    AMapPlaceSearchRequest * request = [[AMapPlaceSearchRequest alloc] init];
    request.searchType = AMapSearchType_PlaceAround;
    request.location = [AMapGeoPoint locationWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude];
    request.sortrule = 1;
    request.requireExtension = YES;
    request.offset = 100;
    request.page = page;
    
    [self.searchAPI AMapPlaceSearch:request];
}

-(void) requestNearPlacesWithLocation:(CLLocation *)location name:(NSString *)name block:(LKNearPlacesSearchBlock)block
{
    self.block = block;
    
    self.searchAPI = [[AMapSearchAPI alloc] initWithSearchKey:[MAMapServices sharedServices].apiKey Delegate:self];
    
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    
    NSArray * allLanguages = [defaults objectForKey:@"AppleLanguages"];
    
    NSString * preferredLang = [allLanguages objectAtIndex:0];
    
    if (![preferredLang isEqualToString:@"zh-Hans"]) {
        
        self.searchAPI.language = AMapSearchLanguage_en;
    }
    else{
        
        self.searchAPI.language = AMapSearchLanguage_zh_CN;
    }
    
    
    AMapPlaceSearchRequest * request = [[AMapPlaceSearchRequest alloc] init];
    request.searchType = AMapSearchType_PlaceAround;
    request.location = [AMapGeoPoint locationWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude];
    request.sortrule = 1;
    request.requireExtension = YES;
    request.offset = 100;
    request.keywords = name;
    
    [self.searchAPI AMapPlaceSearch:request];
}

#pragma mark - 

- (void)onPlaceSearchDone:(AMapPlaceSearchRequest *)request response:(AMapPlaceSearchResponse *)response
{
    if (self.block) {
        self.block(response.pois, nil);
    }    
}

- (void)searchRequest:(id)request didFailWithError:(NSError *)error
{
    if (self.block) {
        self.block(nil, error);
    }
}


@end
