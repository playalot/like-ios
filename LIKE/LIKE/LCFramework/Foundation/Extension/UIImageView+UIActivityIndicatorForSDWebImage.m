//
//  UIImageView+UIActivityIndicatorForSDWebImage.m
//  UIActivityIndicator for SDWebImage
//
//  Created by Giacomo Saccardo.
//  Copyright (c) 2014 Giacomo Saccardo. All rights reserved.
//

#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import <objc/runtime.h>
#import "M13ProgressViewRing.h"

static char TAG_ACTIVITY_INDICATOR;

#define TAG_RING 1001

@interface UIImageView (Private)

-(void)addActivityIndicatorWithStyle:(UIActivityIndicatorViewStyle) activityStyle;

-(void)addActivityProcessRing;

@end

@implementation UIImageView (UIActivityIndicatorForSDWebImage)

@dynamic activityIndicator;

- (void)addActivityProcessingRing {
    M13ProgressViewRing *activityProcessingRing = (M13ProgressViewRing *)[self viewWithTag:TAG_RING];
    if (!activityProcessingRing) {
        activityProcessingRing = [[M13ProgressViewRing alloc] init];
        activityProcessingRing.showPercentage = NO;
        activityProcessingRing.primaryColor = LKColor.color;
        activityProcessingRing.secondaryColor = LKColor.color;
        activityProcessingRing.viewFrameWidth = 50;
        activityProcessingRing.viewFrameHeight = 50;
        activityProcessingRing.viewFrameX = (self.viewFrameWidth - activityProcessingRing.viewFrameWidth) * 0.5;
        activityProcessingRing.viewFrameY = (self.viewFrameHeight - activityProcessingRing.viewFrameHeight) * 0.5;
        activityProcessingRing.tag = TAG_RING;
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [self addSubview:activityProcessingRing];
        });
    }
}

- (void)removeActivityProcessingRing {
    M13ProgressViewRing *activityProcessingRing = (M13ProgressViewRing *)[self viewWithTag:TAG_RING];
    if (activityProcessingRing) {
        [activityProcessingRing removeFromSuperview];
    }
}

- (UIActivityIndicatorView *)activityIndicator {
    return (UIActivityIndicatorView *)objc_getAssociatedObject(self, &TAG_ACTIVITY_INDICATOR);
}

- (void)setActivityIndicator:(UIActivityIndicatorView *)activityIndicator {
    objc_setAssociatedObject(self, &TAG_ACTIVITY_INDICATOR, activityIndicator, OBJC_ASSOCIATION_RETAIN);
}

- (void)addActivityIndicatorWithStyle:(UIActivityIndicatorViewStyle)activityStyle {
    if (!self.activityIndicator) {
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:activityStyle];
        
        self.activityIndicator.autoresizingMask = UIViewAutoresizingNone;
        [self updateActivityIndicatorFrame];
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [self addSubview:self.activityIndicator];
        });
    }
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self.activityIndicator startAnimating];
    });
}

-(void)updateActivityIndicatorFrame {
    if (self.activityIndicator) {
        CGRect activityIndicatorBounds = self.activityIndicator.bounds;
        float x = (self.frame.size.width - activityIndicatorBounds.size.width) / 2.0;
        float y = (self.frame.size.height - activityIndicatorBounds.size.height) / 2.0;
        self.activityIndicator.frame = CGRectMake(x, y, activityIndicatorBounds.size.width, activityIndicatorBounds.size.height);
    }
}

- (void)removeActivityIndicator {
    if (self.activityIndicator) {
        [self.activityIndicator removeFromSuperview];
        self.activityIndicator = nil;
    }
}

-(void)layoutSubviews {
    [super layoutSubviews];

    [self updateActivityIndicatorFrame];
}

#pragma mark - Methods

- (void)setImageWithURL:(NSURL *)url usingActivityIndicatorStyle:(UIActivityIndicatorViewStyle)activityStyle {
    [self setImageWithURL:url placeholderImage:nil options:0 progress:nil completed:nil usingActivityIndicatorStyle:activityStyle];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder usingActivityIndicatorStyle:(UIActivityIndicatorViewStyle)activityStye {
    [self setImageWithURL:url placeholderImage:placeholder options:0 progress:nil completed:nil usingActivityIndicatorStyle:activityStye];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options usingActivityIndicatorStyle:(UIActivityIndicatorViewStyle)activityStyle{
    [self setImageWithURL:url placeholderImage:placeholder options:options progress:nil completed:nil usingActivityIndicatorStyle:activityStyle];
}

- (void)setImageWithURL:(NSURL *)url completed:(SDWebImageCompletionBlock)completedBlock usingActivityIndicatorStyle:(UIActivityIndicatorViewStyle)activityStyle {
    [self setImageWithURL:url placeholderImage:nil options:0 progress:nil completed:completedBlock usingActivityIndicatorStyle:activityStyle];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder completed:(SDWebImageCompletionBlock)completedBlock usingActivityIndicatorStyle:(UIActivityIndicatorViewStyle)activityStyle {
    [self setImageWithURL:url placeholderImage:placeholder options:0 progress:nil completed:completedBlock usingActivityIndicatorStyle:activityStyle];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options completed:(SDWebImageCompletionBlock)completedBlock usingActivityIndicatorStyle:(UIActivityIndicatorViewStyle)activityStyle {
    [self setImageWithURL:url placeholderImage:placeholder options:options progress:nil completed:completedBlock usingActivityIndicatorStyle:activityStyle];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options progress:(SDWebImageDownloaderProgressBlock)progressBlock completed:(SDWebImageCompletionBlock)completedBlock usingActivityIndicatorStyle:(UIActivityIndicatorViewStyle)activityStyle {
    
    [self addActivityProcessingRing];
    __weak typeof(self) weakSelf = self;
    [self sd_setImageWithURL:url
         placeholderImage:placeholder
                  options:options
                 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                 
                     M13ProgressViewRing *activityProcessingRing = (M13ProgressViewRing *)[self viewWithTag:TAG_RING];
                     if (activityProcessingRing) {
                         if (progressBlock && receivedSize!= expectedSize) {
                             [activityProcessingRing setProgress:receivedSize * 1.0 / expectedSize animated:YES];
                         }
                     }
                 }
                completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageUrl) {
                    if (completedBlock) {
                        completedBlock(image, error, cacheType, imageUrl);
                    }
                    [weakSelf removeActivityProcessingRing];
                }
     ];
}

@end
