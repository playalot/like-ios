//
//  LC_UIImageView.m
//  LCFramework

//  Created by Licheng Guo . ( SUGGESTIONS & BUG titm@tom.com ) on 13-9-26.
//  Copyright (c) 2014年 Licheng Guo iOS developer ( http://nsobject.me ).All rights reserved.
//  Also see the copyright page ( http://nsobject.me/copyright.rtf ).
//
//

#import "LCUIImageView.h"
#import "LCUIImageCache.h"
#import "LCUIImageLoader.h"
#import "UIImage+MostColor.h"

@interface LCUIImageView ()
{
    BOOL _inited;
}

@end

@implementation LCUIImageView

-(void) dealloc
{
    [self unobserveAllNotifications];
    [self cancelImageLoad];
}

- (id)init
{
	self = [super init];
    
	if (self){
        
		[self initSelf];
	}
    
	return self;
}

+ (instancetype) viewWithImage:(UIImage *)image
{
    return [[LCUIImageView alloc] initWithImage:image];
}

- (id)initWithImage:(UIImage *)image
{
	self = [super initWithImage:image];
    
	if (self){
        
		[self initSelf];
	}
    
	return self;
}

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
    
	if (self){
        
		[self initSelf];
	}
    
	return self;
}

- (void)initSelf
{
    if (_inited) {
        return;
    }
    
    self.contentMode = UIViewContentModeScaleToFill;
    
    self.showIndicator = NO;

    _loaded	= NO;
    _inited = YES;
    self.changeImageAnimationDuration = 0.25;
}

-(LCUIImageViewGetURL) URL
{
    LCUIImageViewGetURL block = ^ LCUIImageView * (NSString * url, UIImage * placeHolder){
      
        [self loadURL:url placeHolder:placeHolder];
        return self;
        
    };
    
    return block;
}

-(void) setUrl:(NSString *)url
{
    _url = url;
    
    [self loadURL:url placeHolder:nil];
}

-(void) loadURL:(NSString *)url placeHolder:(UIImage *)image
{
    if (LC_NSSTRING_IS_INVALID(url)){
        
        [self changeImage:nil];
        return;
    }
    
    _url = url;
    _loaded = NO;
    
    if (![url hasPrefix:@"http://"]){
        
        _url = [NSString stringWithFormat:@"http://%@", url];
    }
    
    if (image) {
        [self changeImage:image];
    }
    
    UIImage * imageCache = [LCUIImageLoader.singleton imageForURL:_url shouldLoadWithObserver:self];
    
    if(imageCache) {
        [self changeImage:imageCache];
    } else {
        
        [self.indicator setProgress:0 animated:NO];
        
        LC_FAST_ANIMATIONS(0.15, ^{
           
            self.indicator.alpha = 1;
        });
        
    }
}

- (void)changeImage:(UIImage *)image
{
    if (nil == image)
    {
        [self cancelImageLoad];
        [super setImage:nil];
        
        return;
    }
    
    if (image != self.image)
    {
        [self cancelImageLoad];
        
        if (self.blur) {
            
        }
        
        if (self.imageTintColor) {
            
        }
        
        if (self.autoMask) {
            
            UIColor * mostColor = [image mostColor];
            
//            const CGFloat * components1 = CGColorGetComponents(mostColor.CGColor);
//            const CGFloat * components2 = CGColorGetComponents([UIColor whiteColor].CGColor);
//
//            CGFloat red1, red2, green1, green2, blue1, blue2;
//            CGFloat value0 = components1[0];
//            red1 = components1[1] * 255;
//            green1 = components1[2] * 255;
//            blue1 = components1[3] * 255;
//
//            red2 = components2[1] * 255;
//            green2 = components2[2] * 255;
//            blue2 = components2[3] * 255;
            
            //向量比较
            BOOL result = [self color:mostColor isEqualToColor:[UIColor whiteColor] withTolerance:0.2];
            
            if (result) {
                
                UIImage * maskImage = [UIImage imageWithColor:[[UIColor blackColor] colorWithAlphaComponent:0.1] andSize:image.size];
                
                image = [image addMaskImage:maskImage imageSize:image.size inRect:CGRectMake(0, 0, image.size.width, image.size.height)];
            }
        }
        
       
        
        CGAffineTransform transform = self.transform;
        
        UIImageOrientation orientation = image.imageOrientation;
        
        switch (orientation)
        {
            case UIImageOrientationDown:           // EXIF = 3
            case UIImageOrientationDownMirrored:   // EXIF = 4
                transform = CGAffineTransformRotate(transform, M_PI);
                break;
                
            case UIImageOrientationLeft:           // EXIF = 6
            case UIImageOrientationLeftMirrored:   // EXIF = 5
                transform = CGAffineTransformRotate(transform, M_PI_2);
                break;
                
            case UIImageOrientationRight:          // EXIF = 8
            case UIImageOrientationRightMirrored:  // EXIF = 7
                transform = CGAffineTransformRotate(transform, -M_PI_2);
                break;
            case UIImageOrientationUp:
            case UIImageOrientationUpMirrored:
                break;
        }
            
        self.transform =  transform;
        
        [super setImage:image];
    }
}

- (BOOL)color:(UIColor *)color1 isEqualToColor:(UIColor *)color2 withTolerance:(CGFloat)tolerance {
    
    CGFloat r1, g1, b1, a1, r2, g2, b2, a2;
    [color1 getRed:&r1 green:&g1 blue:&b1 alpha:&a1];
    [color2 getRed:&r2 green:&g2 blue:&b2 alpha:&a2];
    return
    fabs(r1 - r2) <= tolerance &&
    fabs(g1 - g2) <= tolerance &&
    fabs(b1 - b2) <= tolerance &&
    fabs(a1 - a2) <= tolerance;
}

-(void) cancelImageLoad
{
    [LCUIImageLoader.singleton cancelLoadForURL:self.url];
    [LCUIImageLoader.singleton removeObserver:self forURL:self.url];
    
    self.indicator.alpha = 0;

    _loaded = NO;
}

- (void)setFrame:(CGRect)frame
{
    BOOL same = CGRectEqualToRect(self.frame, frame);
    
    [super setFrame:frame];
    
    if (_indicator && same == NO){
        
        CGRect indicatorFrame;
        indicatorFrame.size.width = 180 / 3;
        indicatorFrame.size.height = 180 / 3;
        indicatorFrame.origin.x = (frame.size.width - indicatorFrame.size.width) / 2.0f;
        indicatorFrame.origin.y = (frame.size.height - indicatorFrame.size.height) / 2.0f;
        
        _indicator.frame = indicatorFrame;
    }
}

#pragma mark -

- (M13ProgressViewRing *)indicator
{
    if (_indicator == nil && self.showIndicator)
    {
   
        CGRect indicatorFrame;
        indicatorFrame.size.width = 180 / 3;
        indicatorFrame.size.height = 180 / 3;
        indicatorFrame.origin.x = (self.frame.size.width - indicatorFrame.size.width) / 2.0f;
        indicatorFrame.origin.y = (self.frame.size.height - indicatorFrame.size.height) / 2.0f;
        
        _indicator = [[M13ProgressViewRing alloc] initWithFrame:indicatorFrame];
        [_indicator setPrimaryColor:LKColor.color];
        [_indicator setSecondaryColor:LKColor.backgroundColor];
        _indicator.progressRingWidth = 2;
        _indicator.showPercentage = NO;
        _indicator.alpha = 0;
        
        self.ADD(_indicator);
    }
    
    [_indicator setProgress:0 animated:YES];
    
    return _indicator;
}

//- (UIActivityIndicatorViewStyle)indicatorStyle
//{
//    return self.indicator.activityIndicatorViewStyle;
//}
//
//- (void)setIndicatorStyle:(UIActivityIndicatorViewStyle)value
//{
//    self.indicator.activityIndicatorViewStyle = value;
//}

#pragma mark - 

//- (void)setProgress:(float)newProgress
//{
//
//}


-(void) handleNotification:(NSNotification *)notification
{
    NSString * url = [[notification userInfo] objectForKey:@"imageURL"];

    if ([notification is:LCImageLoaderNotificationLoaded(self.url)]) {
        
        if(![url isEqualToString:self.url]) return;
        
        LC_FAST_ANIMATIONS(0.15, ^{
            
            self.indicator.alpha = 0;
        });
        
        
        CATransition * animation = [CATransition animation];
        [animation setDuration:self.changeImageAnimationDuration];
        
        if (self.flipAnimation) {
            
            [animation setType:@"oglFlip"];
        }
        else{
            
            [animation setType:kCATransitionFade];
        }
        
        [animation setSubtype:kCATransitionFromRight];
        [self.layer addAnimation:animation forKey:@"transition"];
        
        UIImage * anImage = [[notification userInfo] objectForKey:@"image"];
        
        [self changeImage:anImage];
        
        if (self.loadImageFinishedBlock) {
            self.loadImageFinishedBlock(self);
        }
        
    }
    else if ([notification is:LCImageLoaderNotificationLoadFailed(self.url)]){
        
        if(![url isEqualToString:self.url]) return;
        
        LC_FAST_ANIMATIONS(0.15, ^{
            
            self.indicator.alpha = 0;
        });
        
    }
    else if ([notification is:LCImageLoaderNotificationLoadRecived(self.url)]){
        
        if(![url isEqualToString:self.url]) return;
        
        id object = notification.userInfo[@"progress"];
        
        if (self.downloadProgressUpdateBlock) {
            self.downloadProgressUpdateBlock([object floatValue]);
        }

    
        if (self.showIndicator) {
                        
            [self.indicator setProgress:[object doubleValue] animated:YES];
        }
    }
    
}

@end
