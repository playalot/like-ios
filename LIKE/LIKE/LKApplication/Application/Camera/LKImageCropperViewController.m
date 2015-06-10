//
//  LKImageCropperViewController.m
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/4/17.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKImageCropperViewController.h"
#import "LKFilterScrollView.h"
#import "LKFilterManager.h"
#import "FastttFilter.h"
#import "LKNewPostViewController.h"
#import "LKPhotoAlbum.h"
#import "LKCameraViewController.h"

#define SCALE_FRAME_Y 100.0f
#define BOUNDCE_DURATION 0.3f

@interface LKImageCropperViewController ()

LC_PROPERTY(strong) UIImage *originalImage;
LC_PROPERTY(strong) UIImage *editedImage;

LC_PROPERTY(strong) UIImageView *showImgView;
LC_PROPERTY(strong) UIView *overlayView;
LC_PROPERTY(strong) UIView *ratioView;

LC_PROPERTY(assign) CGRect oldFrame;
LC_PROPERTY(assign) CGRect largeFrame;
LC_PROPERTY(assign) CGFloat limitRatio;

LC_PROPERTY(assign) CGRect latestFrame;

LC_PROPERTY(strong) LCUIButton * takePhotoButton;
LC_PROPERTY(strong) LCUIButton * cutButton;
LC_PROPERTY(assign) BOOL needCut;

LC_PROPERTY(assign) BOOL filterIndex;

LC_PROPERTY(strong) UIPinchGestureRecognizer * pinchGestureRecognizer;
LC_PROPERTY(strong) UIPanGestureRecognizer * panGestureRecognizer;

LC_PROPERTY(strong) LCUIButton * filterButton;
LC_PROPERTY(strong) LKFilterScrollView * filterScrollView;

LC_PROPERTY(assign) BOOL recordNavigationBarHidden;

@end

@implementation LKImageCropperViewController

- (void)dealloc {
    self.originalImage = nil;
    self.showImgView = nil;
    self.editedImage = nil;
    self.overlayView = nil;
    self.ratioView = nil;
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.squareImage = self.squareImage;
    
    self.takePhotoButton.buttonImage = [UIImage imageNamed:@"CameraCaptureClose.png" useCache:YES];
    
    [self setNavigationBarHidden:YES animated:NO];
    
    // hide status bar.
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:animated];
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:animated];
}


- (id)initWithImage:(UIImage *)originalImage cropFrame:(CGRect)cropFrame limitScaleRatio:(NSInteger)limitRatio {
    self = [super init];
    if (self) {
        
        self.cropFrame = cropFrame;
        self.limitRatio = limitRatio;
        self.originalImage = [[self fixOrientation:originalImage] scaleToWidth:1280];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initView];
    [self initControlBtn];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return NO;
}

- (void)initView {
    
    self.view.backgroundColor = [UIColor blackColor];
    
    self.showImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, LC_DEVICE_WIDTH, LC_DEVICE_HEIGHT + 20)];
    [self.showImgView setMultipleTouchEnabled:YES];
    [self.showImgView setUserInteractionEnabled:YES];
    [self.showImgView setImage:self.originalImage];
    [self.showImgView setUserInteractionEnabled:YES];
    [self.showImgView setMultipleTouchEnabled:YES];
    
    // scale to fit the screen
    CGFloat oriWidth = self.cropFrame.size.width;
    CGFloat oriHeight = self.originalImage.size.height * (oriWidth / self.originalImage.size.width);
    CGFloat oriX = self.cropFrame.origin.x + (self.cropFrame.size.width - oriWidth) / 2;
    CGFloat oriY = self.cropFrame.origin.y + (self.cropFrame.size.height - oriHeight) / 2;
    self.oldFrame = CGRectMake(oriX, oriY, oriWidth, oriHeight);
    self.latestFrame = self.oldFrame;
    self.showImgView.frame = self.oldFrame;
    
    self.largeFrame = CGRectMake(0, 0, self.limitRatio * self.oldFrame.size.width, self.limitRatio * self.oldFrame.size.height);
    
    [self addGestureRecognizers];
    [self.view addSubview:self.showImgView];
    
    self.overlayView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.overlayView.alpha = .5f;
    self.overlayView.backgroundColor = [UIColor blackColor];
    self.overlayView.userInteractionEnabled = NO;
    self.overlayView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.overlayView];
    
    self.ratioView = [[UIView alloc] initWithFrame:self.cropFrame];
    self.ratioView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.ratioView.layer.borderWidth = 1.0f;
    self.ratioView.autoresizingMask = UIViewAutoresizingNone;
    [self.view addSubview:self.ratioView];
    
    [self overlayClipping];
    
    
}

- (void)initControlBtn {
    
    self.takePhotoButton = LCUIButton.view;
    
    
    if (self.buttonFrame.size.width) {
        
        self.takePhotoButton.frame = self.buttonFrame;
    }
    else{
        
        self.takePhotoButton.viewFrameWidth = 234 / 3;
        self.takePhotoButton.viewFrameHeight = 83 / 3;
        self.takePhotoButton.viewFrameX = LC_DEVICE_WIDTH / 2 - self.takePhotoButton.viewMidWidth;
        self.takePhotoButton.viewFrameY = self.view.viewFrameHeight - 25 - self.takePhotoButton.viewFrameHeight - 10;
    }
    
    
    self.takePhotoButton.buttonImage = [UIImage imageNamed:@"CameraCaptureClose.png" useCache:YES];
    self.takePhotoButton.showsTouchWhenHighlighted = YES;
    [self.takePhotoButton addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    self.view.ADD(self.takePhotoButton);
    
    
    self.cutButton = LCUIButton.view;
    self.cutButton.viewFrameWidth = 70 / 3 + 50;
    self.cutButton.viewFrameHeight = 69 / 3 + 50;
    self.cutButton.viewFrameX = 0;
    self.cutButton.viewCenterY = self.takePhotoButton.viewCenterY - 4;
    self.cutButton.buttonImage = [UIImage imageNamed:@"CameraCut.png" useCache:YES];
    self.cutButton.showsTouchWhenHighlighted = YES;
    [self.cutButton addTarget:self action:@selector(cutAction) forControlEvents:UIControlEventTouchUpInside];
    self.view.ADD(self.cutButton);
    
    
    LCUIButton * finishedButton = LCUIButton.view;
    finishedButton.viewFrameWidth = 71 / 3 + 50;
    finishedButton.viewFrameHeight = 71 / 3 + 50;
    finishedButton.viewFrameX = LC_DEVICE_WIDTH - finishedButton.viewFrameWidth;
    finishedButton.viewCenterY = self.takePhotoButton.viewCenterY;
    finishedButton.buttonImage = [UIImage imageNamed:@"CameraFinished.png" useCache:YES];
    finishedButton.showsTouchWhenHighlighted = YES;
    [finishedButton addTarget:self action:@selector(confirm) forControlEvents:UIControlEventTouchUpInside];
    self.view.ADD(finishedButton);
    
    
    {
        {
            NSArray * filterNames = LKFilterManager.singleton.allFilterNames;
            
            
            // filters...
            LKFilterScrollView * filterScrollView = LKFilterScrollView.view;
            
            [filterScrollView addFilterName:@"默认" filterImage:[UIImage imageNamed:@"FilterPreview.jpg" useCache:YES]];
            
            for (NSInteger i = 1; i< filterNames.count ; i++) {
                
                FastttFilter * fastFilter = [FastttFilter filterWithLookupImage:LKFilterManager.singleton.allFilterImage[i - 1]];
                
                UIImage * image = [fastFilter.filter imageByFilteringImage:[UIImage imageNamed:@"FilterPreview.jpg" useCache:YES]];
                
                [filterScrollView addFilterName:filterNames[i - 1] filterImage:image];
            }
            
            if (self.filterScrollFrame.size.width) {
                filterScrollView.frame = self.filterScrollFrame;
            }
            else{
                filterScrollView.viewFrameWidth = self.view.viewFrameWidth;
                filterScrollView.viewFrameHeight = filterScrollView.contentSize.height;
                filterScrollView.viewFrameY = self.takePhotoButton.viewFrameY - 25 - filterScrollView.viewFrameHeight;
            }
            
            self.filterScrollView = filterScrollView;
            self.view.ADD(self.filterScrollView);
            
            
            @weakly(self);
            
            filterScrollView.didSelectedItem = ^(NSInteger index){
                
                @normally(self);
                
                [self switchFilterAtIndex:index];
            };
            
            
            self.filterButton = LCUIButton.view;
            self.filterButton.viewFrameX = self.view.viewFrameWidth - 76;
            self.filterButton.viewFrameWidth = 31 + 50;
            self.filterButton.viewFrameHeight = 31 + 50;
            self.filterButton.viewCenterY = self.filterScrollView.viewCenterY;
            self.filterButton.buttonImage = [UIImage imageNamed:@"CameraFilter.png" useCache:YES];
            [self.filterButton addTarget:self action:@selector(switchFilter) forControlEvents:UIControlEventTouchUpInside];
            self.filterButton.showsTouchWhenHighlighted = YES;
            
            if (self.filterFrame.size.width) {
                self.filterButton.frame = self.filterFrame;
            }
            else{
                self.filterButton.pop_spring.center = LC_POINT(self.filterButton.viewCenterX, self.filterScrollView.viewCenterY + 40);
            }

            self.view.ADD(self.filterButton);
            
            [self hideFilter];
            self.filterScrollView.viewFrameX = self.view.viewFrameWidth;
            
            
//            self.filterButton.pop_spring.center = LC_POINT(self.filterButton.viewCenterX, self.filterScrollView.viewCenterY - 70);
//            self.filterScrollView.pop_spring.frame = CGRectMake(0, self.filterScrollView.viewFrameY, self.filterScrollView.viewFrameWidth, self.filterScrollView.viewFrameHeight);

        }
    }

    
    
    self.overlayView.alpha = 0;
    self.ratioView.alpha = 0;
    
    self.panGestureRecognizer.enabled = NO;
    self.pinchGestureRecognizer.enabled = NO;
}

-(void) showDismissButton
{
    LCUIButton * dismissButton = LCUIButton.view;
    dismissButton.viewFrameWidth = 70 / 3 + 50;
    dismissButton.viewFrameHeight = 71 / 3 + 50;
    dismissButton.viewFrameY = 20;
    dismissButton.buttonImage = [UIImage imageNamed:@"CameraClose.png" useCache:YES];
    dismissButton.showsTouchWhenHighlighted = YES;
    [dismissButton addTarget:self action:@selector(dismissAction) forControlEvents:UIControlEventTouchUpInside];
    self.view.ADD(dismissButton);
}

-(void) showBackButton
{
    LCUIButton * backButton = LCUIButton.view;
    backButton.viewFrameWidth = 50;
    backButton.viewFrameHeight = 54 / 3 + 40;
    backButton.viewFrameY = 10;
    backButton.buttonImage = [UIImage imageNamed:@"NavigationBarBackShadow.png" useCache:YES];
    backButton.showsTouchWhenHighlighted = YES;
    [backButton addTarget:self action:@selector(popAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];

}

-(void) popAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) dismissAction
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) setSquareImage:(BOOL)squareImage
{
    _squareImage = squareImage;
    
    if (_squareImage) {
        self.needCut = YES;
    }
}

-(void) cutAction
{
    if (self.squareImage) {
        self.needCut = YES;
        return;
    }
    
    self.needCut = !self.needCut;
}

-(void) hideFilter
{
    if (self.filterScrollView.viewFrameX <= 0) {

        self.filterScrollView.pop_spring.center = LC_POINT(self.view.viewFrameWidth + self.view.viewMidWidth, self.filterScrollView.viewCenterY);
        self.filterButton.pop_spring.center = LC_POINT(self.filterButton.viewCenterX, self.filterScrollView.viewCenterY + 40);
    }
}

-(void) switchFilter
{
    if (self.filterScrollView.viewFrameX <= 0) {
        
        // hide...
        self.filterScrollView.pop_spring.center = LC_POINT(self.view.viewFrameWidth + self.view.viewMidWidth, self.filterScrollView.viewCenterY);
        self.filterButton.pop_spring.center = LC_POINT(self.filterButton.viewCenterX, self.filterScrollView.viewCenterY + 40);
    }
    else{
        
        // show...
        self.filterScrollView.pop_spring.center = LC_POINT(self.view.viewMidWidth, self.filterScrollView.viewCenterY);
        self.filterButton.pop_spring.center = LC_POINT(self.filterButton.viewCenterX, self.filterScrollView.viewCenterY - 70);
        
    }
}

- (void)switchFilterAtIndex:(NSInteger)index
{
    self.filterIndex = index;

    if (index == 0) {
        
        self.showImgView.image = self.originalImage;
        return;
    }
    
    @autoreleasepool {
        
        FastttFilter * fastFilter = [FastttFilter filterWithLookupImage:LKFilterManager.singleton.allFilterImage[index - 1]];
        
        UIImage * image = [fastFilter.filter imageByFilteringImage:self.originalImage];
        
        self.showImgView.image = image;
    }
   
}

-(void) setNeedCut:(BOOL)needCut
{
    _needCut = needCut;
    
    LC_FAST_ANIMATIONS(0.15, ^{
        
        if (_needCut) {
            self.overlayView.alpha = 0.5;
            self.ratioView.alpha = 0.5;
            
            self.panGestureRecognizer.enabled = YES;
            self.pinchGestureRecognizer.enabled = YES;
        }
        else{
            self.overlayView.alpha = 0;
            self.ratioView.alpha = 0;
            
            self.panGestureRecognizer.enabled = NO;
            self.pinchGestureRecognizer.enabled = NO;
            
            
            // scale to fit the screen
            CGFloat oriWidth = self.cropFrame.size.width;
            CGFloat oriHeight = self.originalImage.size.height * (oriWidth / self.originalImage.size.width);
            CGFloat oriX = self.cropFrame.origin.x + (self.cropFrame.size.width - oriWidth) / 2;
            CGFloat oriY = self.cropFrame.origin.y + (self.cropFrame.size.height - oriHeight) / 2;
            self.oldFrame = CGRectMake(oriX, oriY, oriWidth, oriHeight);
            self.latestFrame = self.oldFrame;
            self.showImgView.frame = self.oldFrame;
            
            self.largeFrame = CGRectMake(0, 0, self.limitRatio * self.oldFrame.size.width, self.limitRatio * self.oldFrame.size.height);
        }
    });
    
    
    self.cutButton.layer.pop_spring.pop_rotation = _needCut ?  M_PI_4 * 3 : - M_PI_4 * (3/4);
}

- (void)cancel:(id)sender
{
    for (UIViewController * viewController in self.navigationController.viewControllers) {
        
        if ([viewController isKindOfClass:[LKCameraViewController class]]) {
            
            self.takePhotoButton.buttonImage = [UIImage imageNamed:@"CameraCapture.png" useCache:YES];

            [self performSelector:@selector(delayPop:) withObject:viewController afterDelay:0.01];
        }
    }
}

-(void) delayPop:(UIViewController *)viewController
{
    [self.navigationController popToViewController:viewController animated:NO];
}

- (void)confirm
{
    UIImage * image = [self currentImage];

    if (!self.dontSaveToAblum) {
        
        if ((self.filterIndex != 0 || self.needCut)) {
            
            [LKPhotoAlbum saveImage:image showTip:NO];
        }
    }
    
    if (self.didFinishedPickImage) {
        self.didFinishedPickImage(image);
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else{
        
        [self.navigationController pushViewController:[[LKNewPostViewController alloc] initWithImage:image] animated:YES];
    }
}

- (void)overlayClipping
{
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    CGMutablePathRef path = CGPathCreateMutable();
    // Left side of the ratio view
    CGPathAddRect(path, nil, CGRectMake(0, 0,
                                        self.ratioView.frame.origin.x,
                                        self.overlayView.frame.size.height));
    // Right side of the ratio view
    CGPathAddRect(path, nil, CGRectMake(
                                        self.ratioView.frame.origin.x + self.ratioView.frame.size.width,
                                        0,
                                        self.overlayView.frame.size.width - self.ratioView.frame.origin.x - self.ratioView.frame.size.width,
                                        self.overlayView.frame.size.height));
    // Top side of the ratio view
    CGPathAddRect(path, nil, CGRectMake(0, 0,
                                        self.overlayView.frame.size.width,
                                        self.ratioView.frame.origin.y));
    // Bottom side of the ratio view
    CGPathAddRect(path, nil, CGRectMake(0,
                                        self.ratioView.frame.origin.y + self.ratioView.frame.size.height,
                                        self.overlayView.frame.size.width,
                                        self.overlayView.frame.size.height - self.ratioView.frame.origin.y + self.ratioView.frame.size.height));
    maskLayer.path = path;
    self.overlayView.layer.mask = maskLayer;
    CGPathRelease(path);
}

// register all gestures
- (void) addGestureRecognizers
{
    // add pinch gesture
    self.pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchView:)];
    [self.view addGestureRecognizer:self.pinchGestureRecognizer];
    
    // add pan gesture
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panView:)];
    [self.view addGestureRecognizer:self.panGestureRecognizer];
}

// pinch gesture handler
- (void) pinchView:(UIPinchGestureRecognizer *)pinchGestureRecognizer
{
    UIView *view = self.showImgView;
    if (pinchGestureRecognizer.state == UIGestureRecognizerStateBegan || pinchGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        view.transform = CGAffineTransformScale(view.transform, pinchGestureRecognizer.scale, pinchGestureRecognizer.scale);
        pinchGestureRecognizer.scale = 1;
    }
    else if (pinchGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        CGRect newFrame = self.showImgView.frame;
        newFrame = [self handleScaleOverflow:newFrame];
        newFrame = [self handleBorderOverflow:newFrame];
        [UIView animateWithDuration:BOUNDCE_DURATION animations:^{
            self.showImgView.frame = newFrame;
            self.latestFrame = newFrame;
        }];
    }
}

// pan gesture handler
- (void) panView:(UIPanGestureRecognizer *)panGestureRecognizer
{
    UIView *view = self.showImgView;
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan || panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        // calculate accelerator
        CGFloat absCenterX = self.cropFrame.origin.x + self.cropFrame.size.width / 2;
        CGFloat absCenterY = self.cropFrame.origin.y + self.cropFrame.size.height / 2;
        CGFloat scaleRatio = self.showImgView.frame.size.width / self.cropFrame.size.width;
        CGFloat acceleratorX = 1 - ABS(absCenterX - view.center.x) / (scaleRatio * absCenterX);
        CGFloat acceleratorY = 1 - ABS(absCenterY - view.center.y) / (scaleRatio * absCenterY);
        CGPoint translation = [panGestureRecognizer translationInView:view.superview];
        [view setCenter:(CGPoint){view.center.x + translation.x * acceleratorX, view.center.y + translation.y * acceleratorY}];
        [panGestureRecognizer setTranslation:CGPointZero inView:view.superview];
    }
    else if (panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        // bounce to original frame
        CGRect newFrame = self.showImgView.frame;
        newFrame = [self handleBorderOverflow:newFrame];
        [UIView animateWithDuration:BOUNDCE_DURATION animations:^{
            self.showImgView.frame = newFrame;
            self.latestFrame = newFrame;
        }];
    }
}

- (CGRect)handleScaleOverflow:(CGRect)newFrame {
    // bounce to original frame
    CGPoint oriCenter = CGPointMake(newFrame.origin.x + newFrame.size.width/2, newFrame.origin.y + newFrame.size.height/2);
    if (newFrame.size.width < self.oldFrame.size.width) {
        newFrame = self.oldFrame;
    }
    if (newFrame.size.width > self.largeFrame.size.width) {
        newFrame = self.largeFrame;
    }
    newFrame.origin.x = oriCenter.x - newFrame.size.width/2;
    newFrame.origin.y = oriCenter.y - newFrame.size.height/2;
    return newFrame;
}

- (CGRect)handleBorderOverflow:(CGRect)newFrame {
    // horizontally
    if (newFrame.origin.x > self.cropFrame.origin.x) newFrame.origin.x = self.cropFrame.origin.x;
    if (CGRectGetMaxX(newFrame) < self.cropFrame.size.width) newFrame.origin.x = self.cropFrame.size.width - newFrame.size.width;
    // vertically
    if (newFrame.origin.y > self.cropFrame.origin.y) newFrame.origin.y = self.cropFrame.origin.y;
    if (CGRectGetMaxY(newFrame) < self.cropFrame.origin.y + self.cropFrame.size.height) {
        newFrame.origin.y = self.cropFrame.origin.y + self.cropFrame.size.height - newFrame.size.height;
    }
    // adapt horizontally rectangle
    if (self.showImgView.frame.size.width > self.showImgView.frame.size.height && newFrame.size.height <= self.cropFrame.size.height) {
        newFrame.origin.y = self.cropFrame.origin.y + (self.cropFrame.size.height - newFrame.size.height) / 2;
    }
    return newFrame;
}

-(UIImage *) currentImage
{
    if (self.needCut) {
        return [self getSubImage];
    }
    else{
        return self.showImgView.image;
    }
}

-(UIImage *)getSubImage{
    CGRect squareFrame = self.cropFrame;
    CGFloat scaleRatio = self.latestFrame.size.width / self.showImgView.image.size.width;
    CGFloat x = (squareFrame.origin.x - self.latestFrame.origin.x) / scaleRatio;
    CGFloat y = (squareFrame.origin.y - self.latestFrame.origin.y) / scaleRatio;
    CGFloat w = squareFrame.size.width / scaleRatio;
    CGFloat h = squareFrame.size.height / scaleRatio;
    if (self.latestFrame.size.width < self.cropFrame.size.width) {
        CGFloat newW = self.showImgView.image.size.width;
        CGFloat newH = newW * (self.cropFrame.size.height / self.cropFrame.size.width);
        x = 0; y = y + (h - newH) / 2;
        w = newH; h = newH;
    }
    if (self.latestFrame.size.height < self.cropFrame.size.height) {
        CGFloat newH = self.showImgView.image.size.height;
        CGFloat newW = newH * (self.cropFrame.size.width / self.cropFrame.size.height);
        x = x + (w - newW) / 2; y = 0;
        w = newH; h = newH;
    }
    CGRect myImageRect = CGRectMake(x, y, w, h);
    CGImageRef imageRef = self.showImgView.image.CGImage;
    CGImageRef subImageRef = CGImageCreateWithImageInRect(imageRef, myImageRect);
    CGSize size;
    size.width = myImageRect.size.width;
    size.height = myImageRect.size.height;
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, myImageRect, subImageRef);
    UIImage* smallImage = [UIImage imageWithCGImage:subImageRef];
    CGImageRelease(subImageRef);
    UIGraphicsEndImageContext();
    return smallImage;
}

- (UIImage *)fixOrientation:(UIImage *)srcImg {
    if (srcImg.imageOrientation == UIImageOrientationUp) return srcImg;
    CGAffineTransform transform = CGAffineTransformIdentity;
    switch (srcImg.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, srcImg.size.width, srcImg.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, srcImg.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, srcImg.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (srcImg.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, srcImg.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, srcImg.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    CGContextRef ctx = CGBitmapContextCreate(NULL, srcImg.size.width, srcImg.size.height,
                                             CGImageGetBitsPerComponent(srcImg.CGImage), 0,
                                             CGImageGetColorSpace(srcImg.CGImage),
                                             CGImageGetBitmapInfo(srcImg.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (srcImg.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            CGContextDrawImage(ctx, CGRectMake(0,0,srcImg.size.height,srcImg.size.width), srcImg.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,srcImg.size.width,srcImg.size.height), srcImg.CGImage);
            break;
    }
    
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}


@end
