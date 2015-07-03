//
//  LKLocationManager.m
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/7/1.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKLocationManager.h"
#import <CoreLocation/CoreLocation.h>
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchAPI.h>
#import <AMapSearchKit/AMapSearchObj.h>

@interface LKLocationManager () <MAMapViewDelegate, AMapSearchDelegate>

LC_PROPERTY(strong) MAMapView * locationManager;
LC_PROPERTY(assign) BOOL updating;

LC_PROPERTY(strong) AMapSearchAPI * searchAPI;

@end

@implementation LKLocationManager

-(instancetype) init
{
    if (self = [super init]) {
                
        self.locationManager = [[MAMapView alloc] init];
        self.locationManager.delegate = self;
    }
    
    return self;
}


#pragma mark -


-(void) startUpdatingLocation
{
    self.locationManager.showsUserLocation = YES;
    self.updating = YES;
}

-(void) stopUpdatingLocation
{
    self.locationManager.showsUserLocation = NO;
    self.updating = NO;
}


#pragma mark -


-(void) requestCurrentLocationWithBlock:(LKLocationManagerBlock)block
{
    self.block = block;
    
    [self startUpdatingLocation];
}

-(void) requestCurrentLocationWithLocation:(MAUserLocation *)location
{
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
    
    
    AMapReGeocodeSearchRequest * regeo = [[AMapReGeocodeSearchRequest alloc] init];
    
    regeo.location = [AMapGeoPoint locationWithLatitude:location.location.coordinate.latitude longitude:location.location.coordinate.longitude];
    regeo.requireExtension = YES;
    
    [self.searchAPI AMapReGoecodeSearch:regeo];
}

#pragma mark -

- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation
{
    if (self.updating == NO) {
        return;
    }
    
    self.location = userLocation.location;
    
    [self requestCurrentLocationWithLocation:userLocation];
    
    [self stopUpdatingLocation];
}

- (void)mapView:(MAMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
    if (self.block) {
        self.block(nil, nil, error);
    }
    
    [self stopUpdatingLocation];
}


#pragma mark - 

- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response
{
    if (self.block) {
        self.block(self.location ,response.regeocode, nil);
    }
}

- (void)searchRequest:(id)request didFailWithError:(NSError *)error
{
    if (self.block) {
        self.block(nil, nil, error);
    }
}

@end
