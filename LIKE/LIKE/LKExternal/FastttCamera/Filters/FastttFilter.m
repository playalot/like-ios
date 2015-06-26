//
//  FastttFilter.m
//  FastttCamera
//
//  Created by Laura Skelton on 3/2/15.
//
//

#import "FastttFilter.h"
#import "GPUImageFilterGroup.h"
#import "FastttLookupFilter.h"
#import "FastttEmptyFilter.h"

@interface FastttFilter ()

@property (readwrite, nonatomic, strong) GPUImageOutput<GPUImageInput> *filter;
@property (readwrite, nonatomic, strong) GPUImageOutput<GPUImageInput> *originalFilter;

@end

@implementation FastttFilter

+ (instancetype)filterWithLookupImage:(UIImage *)lookupImage
{
    FastttFilter *fastFilter = [[self alloc] init];
    
    if (lookupImage) {
        FastttLookupFilter *lookupFilter = [[FastttLookupFilter alloc] initWithLookupImage:lookupImage];
        fastFilter.filter = lookupFilter;
        FastttEmptyFilter *emptyFilter = [[FastttEmptyFilter alloc] init];
        fastFilter.originalFilter = emptyFilter;
    } else {
        FastttEmptyFilter *emptyFilter = [[FastttEmptyFilter alloc] init];
        fastFilter.filter = emptyFilter;
        FastttEmptyFilter *emptyFilter1 = [[FastttEmptyFilter alloc] init];
        fastFilter.originalFilter = emptyFilter1;
    }
    
    return fastFilter;
}

+ (instancetype)plainFilter
{
    FastttFilter *fastFilter = [[self alloc] init];
    
    FastttEmptyFilter *emptyFilter = [[FastttEmptyFilter alloc] init];
    
    fastFilter.filter = emptyFilter;
    
    return fastFilter;
}

@end
