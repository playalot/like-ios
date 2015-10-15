//
//  ExampleFilter.m
//  FastttCamera
//
//  Created by Laura Skelton on 3/4/15.
//  Copyright (c) 2015 IFTTT. All rights reserved.
//

#import "LKFilterManager.h"

@implementation LKFilterManager

-(NSMutableArray *) allFilterImage
{
    if (!_allFilterImage) {
        
        _allFilterImage = [NSMutableArray array];
        _allFilterNames = [NSMutableArray array];
        
        [self defaultSettings];
    }
    
    return _allFilterImage;
}

-(NSMutableArray *) allFilterNames
{
    if (!_allFilterNames) {
        
        _allFilterImage = [NSMutableArray array];
        _allFilterNames = [NSMutableArray array];
        
        [self defaultSettings];
    }
    
    return _allFilterNames;
}


-(void) defaultSettings
{
    [self addImageFilter:@"Vivid"];
    [self addImageFilter:@"Ansel"];
    [self addImageFilter:@"Instant"];
    [self addImageFilter:@"Midway"];
    [self addImageFilter:@"Luna"];
    [self addImageFilter:@"Vxgaga"];
//    [self addImageFilter:@"Pro"];
//    [self addImageFilter:@"Diana"];
    [self addImageFilter:@"Dawn"];
//    [self addImageFilter:@"Holga"];
    [self addImageFilter:@"Wasted"];
    [self addImageFilter:@"GtaTrevor"];
//    [self addImageFilter:@"GtaFranklin"];
}

-(void) addImageFilter:(NSString *)filterName
{
    [self.allFilterImage addObject:[UIImage imageNamed:[NSString stringWithFormat:@"%@.png", filterName]]];
    [self.allFilterNames addObject:filterName];
}


@end
