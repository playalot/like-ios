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
#import "GPUImagePicture.h"
#import "GPUImageLookupFilter.h"
#import "GPUImageVignetteFilter.h"
#import "GPUImageSepiaFilter.h"

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

LC_PROPERTY(strong) LCUIButton * cutButton;
LC_PROPERTY(assign) BOOL needCut;


LC_PROPERTY(strong) UIPinchGestureRecognizer * pinchGestureRecognizer;
LC_PROPERTY(strong) UIPanGestureRecognizer * panGestureRecognizer;

LC_PROPERTY(strong) LCUIButton * filterButton;
LC_PROPERTY(strong) LKFilterScrollView * filterScrollView;

LC_PROPERTY(assign) BOOL recordNavigationBarHidden;

LC_PROPERTY(strong) UISlider * slider1;
LC_PROPERTY(strong) UISlider * slider2;


LC_PROPERTY(assign) NSInteger filterIndex;
LC_PROPERTY(assign) BOOL magic;

LC_PROPERTY(strong) UIView *gtaView1;
LC_PROPERTY(strong) UIView *gtaView2;

LC_PROPERTY(strong) UIView *wastedView;

@end

@implementation LKImageCropperViewController

- (void)dealloc
{
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
    
    [self setNavigationBarHidden:YES animated:animated];    
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (id)initWithImage:(UIImage *)originalImage
{
    self = [super init];
    
    if (self) {
        
        self.cropFrame =  CGRectMake(0, (LC_DEVICE_HEIGHT + 20 - 54) / 2 - LC_DEVICE_WIDTH / 2, LC_DEVICE_WIDTH, LC_DEVICE_WIDTH);
        self.limitRatio = 3;
        self.originalImage = [[originalImage autoOrientation] scaleToWidth:1280];
        self.filterIndex = 0;
    }

    return self;
}


- (id)initWithImage:(UIImage *)originalImage filterIndex:(NSInteger)filterIndex
{
    self = [super init];
    
    if (self) {
        
        self.cropFrame = CGRectMake(0, (LC_DEVICE_HEIGHT + 20 - 54) / 2 - LC_DEVICE_WIDTH / 2, LC_DEVICE_WIDTH, LC_DEVICE_WIDTH);
        self.limitRatio = 3;
        self.originalImage = [[originalImage autoOrientation] scaleToWidth:1280];
        self.filterIndex = filterIndex;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initView];
    [self initControlBtn];
    
    [self.filterScrollView setSelectIndex:self.filterIndex];
    [self switchFilterAtIndex:self.filterIndex];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return NO;
}

- (void)initView {
    
    self.view.backgroundColor = [UIColor blackColor];
    
    self.showImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, LC_DEVICE_WIDTH, LC_DEVICE_HEIGHT + 20)];
    self.showImgView.multipleTouchEnabled = YES;
    self.showImgView.userInteractionEnabled = YES;
    self.showImgView.image = self.originalImage;
    
    
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
    
    
    
    if (self.fromPreviewFrameString) {
        
        CGRect rect = CGRectFromString(self.fromPreviewFrameString);
        
        CGRect oldRect = self.showImgView.frame;
        
        self.showImgView.frame = rect;
        
        LC_FAST_ANIMATIONS(0.25, ^{
        
            self.showImgView.frame = oldRect;
        
        });
    }
    
    
    for (UIView * view in self.view.subviews) {
        
        if (view != self.overlayView && view != self.ratioView) {
         
            view.alpha = 0.5;
        }
    }
    
    LC_FAST_ANIMATIONS(0.25, ^{
    
        for (UIView * view in self.view.subviews) {
            
            if (view != self.overlayView && view != self.ratioView) {

                view.alpha = 1;
            }
        }
        
    });
}

- (void)initControlBtn
{
    UIView * bottomView = UIView.view.COLOR(LC_RGB(34, 34, 34));
    bottomView.viewFrameWidth = LC_DEVICE_WIDTH;
    bottomView.viewFrameHeight = 54;
    bottomView.viewFrameY = self.view.viewFrameHeight - bottomView.viewFrameHeight;
    self.view.ADD(bottomView);
    
    
    
    NSArray * bottomToolsIcon = @[@"CameraMagic.png", @"CameraCut.png"];
    
    
    UIView * bottonTools = UIView.view.WIDTH(bottomToolsIcon.count * 57 + ((bottomToolsIcon.count - 1) * 20)).HEIGHT(57);
    bottonTools.viewCenterX = bottomView.viewMidWidth;
    bottomView.ADD(bottonTools);
    
    for (NSInteger i = 0; i<bottomToolsIcon.count; i++) {
        
        LCUIButton * button = LCUIButton.view;
        button.viewFrameWidth = 54;
        button.viewFrameHeight = 54;
        button.viewFrameX = 20 * i + 54 * i;
        button.buttonImage = [UIImage imageNamed:bottomToolsIcon[i] useCache:YES];
        [button setImage:[button.buttonImage imageWithTintColor:LKColor.color] forState:UIControlStateSelected];
        button.tag = i;
        [button addTarget:self action:@selector(buttonToolsAction:) forControlEvents:UIControlEventTouchUpInside];
        bottonTools.ADD(button);
    }
    
    
    // 查询上一个viewcontroller是不是拍照，如果是拍照就显示重拍，否则就是取消
    
    BOOL fromCamera = NO;
    
    UIViewController * lastViewController = nil;
    
    for (UIViewController * vc in self.navigationController.viewControllers) {
        
        if (!lastViewController) {
            
            lastViewController = vc;
            continue;
        }
        
        if (vc == self) {
            
            if ([lastViewController isKindOfClass:[LKCameraViewController class]]) {
                
                fromCamera = YES;
            }
        }
        
        lastViewController = vc;
    }
    
    
    
    LCUIButton * retakeButton = LCUIButton.view;
    retakeButton.viewFrameWidth = 80;
    retakeButton.viewFrameHeight = 54;
    retakeButton.showsTouchWhenHighlighted = YES;
    retakeButton.titleFont = LK_FONT(15);
    retakeButton.titleColor = [UIColor whiteColor];
    [retakeButton addTarget:self action:@selector(popAction) forControlEvents:UIControlEventTouchUpInside];
    
    if (fromCamera) {
        
        retakeButton.title = LC_LO(@"重拍");
    }
    else{
        
        retakeButton.title = LC_LO(@"取消");
    }

    bottomView.ADD(retakeButton);
    
    
    LCUIButton * finishedButton = LCUIButton.view;
    finishedButton.viewFrameWidth = 80;
    finishedButton.viewFrameHeight = 54;
    finishedButton.viewFrameX = LC_DEVICE_WIDTH - finishedButton.viewFrameWidth;
    finishedButton.showsTouchWhenHighlighted = YES;
    finishedButton.title = LC_LO(@"保存");
    finishedButton.titleColor = LKColor.color;
    finishedButton.titleFont = LK_FONT(15);
    [finishedButton addTarget:self action:@selector(confirm) forControlEvents:UIControlEventTouchUpInside];
    bottomView.ADD(finishedButton);
    
    
    NSArray * filterNames = LKFilterManager.singleton.allFilterNames;
    
    
    // filters...
    LKFilterScrollView * filterScrollView = LKFilterScrollView.view;
    
    UIImage * preview = [self.originalImage scaleToWidth:100];//[UIImage imageNamed:@"FilterPreview.jpg" useCache:YES];
    
    [filterScrollView addFilterName:LC_LO(@"默认") filterImage:preview];
    
    for (NSInteger i = 1; i< filterNames.count + 1; i++) {
        
        UIImage * image = [self lookkupImageFilterWithImage:LKFilterManager.singleton.allFilterImage[i - 1] originImage:preview];
        
        // Wasted滤镜
        if (i == filterNames.count - 2) {
            
            CGFloat width = image.size.width;
            CGFloat height = width / 414 * 72;
            
            image = [image addMaskImage:[UIImage imageNamed:@"Wasted2" useCache:YES] imageSize:image.size inRect:CGRectMake(0, (image.size.height - height) * 0.5, width, height)];
        }
        
        // GTA滤镜
        if (i == filterNames.count - 1) {
            
            CGFloat width = (245. / 1020.) * image.size.width * 1.5;
            CGFloat height = width / 245 * 172.;
            CGFloat padding = (30. / 1020.) * image.size.width;
            
            image = [image addMaskImage:[UIImage imageNamed:@"Gta-driving.png" useCache:YES] imageSize:image.size inRect:CGRectMake(padding, image.size.height - height - padding, width, height)];
        }

        if (i == filterNames.count) {
            
            CGFloat width = (245. / 1020.) * image.size.width * 1.5;
            CGFloat height = width / 245 * 172.;
            CGFloat padding = (30. / 1020.) * image.size.width;
            
            image = [image addMaskImage:[UIImage imageNamed:@"Gta-walking.png" useCache:YES] imageSize:image.size inRect:CGRectMake(padding, image.size.height - height - padding, width, height)];
        }
        
        
        [filterScrollView addFilterName:filterNames[i - 1] filterImage:image];
    }
    

    filterScrollView.viewFrameWidth = self.view.viewFrameWidth;
    filterScrollView.viewFrameHeight = filterScrollView.contentSize.height;
    filterScrollView.viewFrameY = bottomView.viewFrameY;
    
    self.filterScrollView = filterScrollView;
    [self.view insertSubview:filterScrollView belowSubview:bottomView];
    
    
    @weakly(self);
    
    filterScrollView.didSelectedItem = ^(NSInteger index){
        
        @normally(self);
        
        [self switchFilterAtIndex:index];
    };
    
    
    self.filterButton = LCUIButton.view;
    self.filterButton.viewFrameWidth = 80;
    self.filterButton.viewFrameHeight = 40;
    self.filterButton.viewFrameX = self.view.viewFrameWidth - self.filterButton.viewFrameWidth;
    self.filterButton.viewFrameY = bottomView.viewFrameY - self.filterButton.viewFrameHeight;
    self.filterButton.buttonImage = [UIImage imageNamed:@"CameraFilter.png" useCache:YES];
    self.filterButton.title = LC_LO(@"  滤镜");
    self.filterButton.titleFont = LK_FONT(13);
    self.filterButton.titleColor = [UIColor whiteColor];
    [self.filterButton addTarget:self action:@selector(switchFilter) forControlEvents:UIControlEventTouchUpInside];
    self.filterButton.showsTouchWhenHighlighted = YES;
    self.view.ADD(self.filterButton);
    
    
    self.overlayView.alpha = 0;
    self.ratioView.alpha = 0;
    
    self.panGestureRecognizer.enabled = NO;
    self.pinchGestureRecognizer.enabled = NO;
    
    
//    self.slider1 = [[UISlider alloc] initWithFrame:CGRectMake(0, 0, 150, 20)];
//    self.slider1.viewCenterX = LC_DEVICE_WIDTH / 2;
//    self.slider1.minimumValue = 0;
//    self.slider1.maximumValue = 1;
//    [self.slider1 addTarget:self action:@selector(valueChange:) forControlEvents:UIControlEventValueChanged];
//    bottomView.ADD(self.slider1);
//
//
//    self.slider2 = [[UISlider alloc] initWithFrame:CGRectMake(0, 30, 150, 20)];
//    self.slider2.viewCenterX = LC_DEVICE_WIDTH / 2;
//    self.slider2.minimumValue = 0;
//    self.slider2.maximumValue = 1;
//    [self.slider2 addTarget:self action:@selector(valueChange:) forControlEvents:UIControlEventValueChanged];
//    bottomView.ADD(self.slider2);
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
//    LCUIButton * backButton = LCUIButton.view;
//    backButton.viewFrameWidth = 80;
//    backButton.viewFrameHeight = 64;
//    backButton.buttonImage = [UIImage imageNamed:@"NavigationBarBack.png" useCache:YES];
//    backButton.showsTouchWhenHighlighted = YES;
//    [backButton addTarget:self action:@selector(popAction) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:backButton];

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

-(void) switchFilter
{
    LC_FAST_ANIMATIONS(0.25, ^{
       
        if (self.filterScrollView.viewFrameY >= self.view.viewFrameHeight - 54.) {
            
            self.filterScrollView.viewFrameY = self.view.viewFrameHeight - 54 - self.filterScrollView.viewFrameHeight;
            self.filterButton.viewFrameY = self.filterScrollView.viewFrameY - self.filterButton.viewFrameHeight;
        }
        else{
            
            self.filterScrollView.viewFrameY = self.view.viewFrameHeight - 54;
            self.filterButton.viewFrameY = self.filterScrollView.viewFrameY - self.filterButton.viewFrameHeight;
        }
        
    });
}

- (void)switchFilterAtIndex:(NSInteger)index
{
    self.filterIndex = index;

    [self update];
}

-(void) update
{
    @autoreleasepool {
        
        UIImage * image = self.originalImage;
        
        if (self.filterIndex != 0) {
            
            image = [self lookkupImageFilterWithImage:LKFilterManager.singleton.allFilterImage[self.filterIndex - 1] originImage:self.originalImage];
            
            if (self.wastedView) {
                [self.wastedView removeFromSuperview];
                self.wastedView = nil;
            }
            
            if (self.gtaView1) {
                [self.gtaView1 removeFromSuperview];
                self.gtaView1 = nil;
            }
            
            if (self.gtaView2) {
                [self.gtaView2 removeFromSuperview];
                self.gtaView2 = nil;
            }
            
            NSInteger filterImageCount = LKFilterManager.singleton.allFilterImage.count;
            
            // Wasted滤镜
            if (self.filterIndex == filterImageCount - 2) {
                
//                CGFloat width = image.size.width;
//                CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
//                CGFloat scale = [UIScreen mainScreen].scale;
//                CGFloat height = width / 1242 * 216;
                CGFloat width = image.size.width;
                CGFloat height = width * 216 / 1242;
                
                image = [image addMaskImage:[UIImage imageNamed:@"Wasted2" useCache:YES] imageSize:image.size inRect:CGRectMake(0, (image.size.height - height) * 0.5, width, height)];
            }
            
            // GTA滤镜
            if (self.filterIndex == filterImageCount - 1) {
                
                CGFloat width = (245. / 1020.) * image.size.width;
                CGFloat height = width / 245 * 172.;
                CGFloat padding = (30. / 1020.) * image.size.width;
                
                image = [image addMaskImage:[UIImage imageNamed:@"Gta-driving.png" useCache:YES] imageSize:image.size inRect:CGRectMake(padding, image.size.height - height - padding, width, height)];
            }
            
            if (self.filterIndex == filterImageCount) {
                
                CGFloat width = (245. / 1020.) * image.size.width;
                CGFloat height = width / 245 * 172.;
                CGFloat padding = (30. / 1020.) * image.size.width;
                
                image = [image addMaskImage:[UIImage imageNamed:@"Gta-walking.png" useCache:YES] imageSize:image.size inRect:CGRectMake(padding, image.size.height - height - padding, width, height)];
            }

        }
        
        if (self.magic) {
            
            image = [image magic];
        }
        
        self.showImgView.image = image;
    }
}

-(UIImage *) currentFilter:(UIImage *)image
{
    @autoreleasepool {
        
        if (self.filterIndex != 0) {
            
            image = [self lookkupImageFilterWithImage:LKFilterManager.singleton.allFilterImage[self.filterIndex - 1] originImage:image];
        }
        
        if (self.magic) {
            
            image = [image magic];
        }
        
        return image;
    }
}

-(void) valueChange:(UISlider *)slider
{
    GPUImagePicture * stillImageSource = [[GPUImagePicture alloc] initWithImage:self.originalImage];
    GPUImagePicture * lookupImageSource = [[GPUImagePicture alloc] initWithImage:[UIImage imageNamed:@"Vivid.png" useCache:YES]];
    GPUImageLookupFilter * lookupFilter = [[GPUImageLookupFilter alloc] init];
    
    [stillImageSource addTarget:lookupFilter];
    [lookupImageSource addTarget:lookupFilter];
    [lookupFilter useNextFrameForImageCapture];
    
    GPUImageVignetteFilter * vignettefilter = [[GPUImageVignetteFilter alloc] init];
    vignettefilter.vignetteStart = self.slider1.value; // 0.256 // 0.356 // 0.569 // 0.550
    vignettefilter.vignetteEnd = self.slider2.value;   // 0.806 // 0.803 // 0.899 // 1
    
    [lookupFilter addTarget:vignettefilter];
    [stillImageSource processImage];
    [lookupImageSource processImage];
    [vignettefilter useNextFrameForImageCapture];
    UIImage * filteredimage = [vignettefilter imageFromCurrentFramebuffer];
    
    self.showImgView.image = filteredimage;
}

-(void) buttonToolsAction:(UIButton *)button
{
    button.selected = !button.selected;

    if (button.tag == 0) {
        
        self.magic = button.selected;
        
        [self update];
    }
    else if (button.tag == 1){
    
        [self cutAction];
        
    }
}

-(UIImage *)lookkupImageFilterWithImage:(UIImage *)filterImage originImage:(UIImage *)originImage
{
    GPUImagePicture * stillImageSource = [[GPUImagePicture alloc] initWithImage:originImage];
    GPUImagePicture * lookupImageSource = [[GPUImagePicture alloc] initWithImage:filterImage];
    GPUImageLookupFilter * lookupFilter = [[GPUImageLookupFilter alloc] init];
    
//    GPUImageVignetteFilter * vignettefilter = [[GPUImageVignetteFilter alloc] init];
//    vignettefilter.vignetteStart = 0.569;
//    vignettefilter.vignetteEnd =  0.899;
    
//    [lookupFilter addTarget:vignettefilter];
    [stillImageSource addTarget:lookupFilter];
    [lookupImageSource addTarget:lookupFilter];
    
    [stillImageSource processImage];
    [lookupImageSource processImage];
    
    [stillImageSource useNextFrameForImageCapture];
    [lookupFilter useNextFrameForImageCapture];
    
    UIImage * filteredimage = [lookupFilter imageFromCurrentFramebuffer];
    
    filteredimage = [UIImage imageWithCGImage:filteredimage.CGImage scale:filteredimage.scale orientation:originImage.imageOrientation];
    
    return filteredimage;
}

// 需要裁剪
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
        [self postNotification:LKCameraViewControllerDismiss];
    } else {
        // push 发布控制器
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
    UIView * view = self.showImgView;
    
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan || panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        
        CGPoint point = [panGestureRecognizer translationInView:self.view];

        view.center = CGPointMake(view.center.x + point.x, view.center.y + point.y);
        [panGestureRecognizer setTranslation:CGPointMake(0, 0) inView:view.superview];
        
//        // calculate accelerator
//        CGFloat absCenterX = self.cropFrame.origin.x + self.cropFrame.size.width / 2;
//        CGFloat absCenterY = self.cropFrame.origin.y + self.cropFrame.size.height / 2;
//        CGFloat scaleRatio = self.showImgView.frame.size.width / self.cropFrame.size.width;
//        CGFloat acceleratorX = 1 - ABS(absCenterX - view.center.x) / (scaleRatio * absCenterX);
//        CGFloat acceleratorY = 1 - ABS(absCenterY - view.center.y) / (scaleRatio * absCenterY);
//        CGPoint translation = [panGestureRecognizer translationInView:view.superview];
//        
//        [view setCenter:(CGPoint){view.center.x + translation.x * acceleratorX, view.center.y + translation.y * acceleratorY}];
//        [panGestureRecognizer setTranslation:CGPointZero inView:view.superview];
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

/**
 *  获取当前图片
 */
-(UIImage *) currentImage
{
    if (self.needCut) {
        return [self currentFilter:[self getSubImage]];
    }
    else{
        return self.showImgView.image;
    }
}

/**
 *  裁剪图片
 */
-(UIImage *)getSubImage{
    
    UIImageView * showImgView = [[UIImageView alloc] initWithImage:self.originalImage];
    showImgView.frame = self.showImgView.frame;
    
    
    CGRect squareFrame = self.cropFrame;
    CGFloat scaleRatio = self.latestFrame.size.width / showImgView.image.size.width;
    CGFloat x = (squareFrame.origin.x - self.latestFrame.origin.x) / scaleRatio;
    CGFloat y = (squareFrame.origin.y - self.latestFrame.origin.y) / scaleRatio;
    CGFloat w = squareFrame.size.width / scaleRatio;
    CGFloat h = squareFrame.size.height / scaleRatio;
    if (self.latestFrame.size.width < self.cropFrame.size.width) {
        CGFloat newW = showImgView.image.size.width;
        CGFloat newH = newW * (self.cropFrame.size.height / self.cropFrame.size.width);
        x = 0; y = y + (h - newH) / 2;
        w = newH; h = newH;
    }
    if (self.latestFrame.size.height < self.cropFrame.size.height) {
        CGFloat newH = showImgView.image.size.height;
        CGFloat newW = newH * (self.cropFrame.size.width / self.cropFrame.size.height);
        x = x + (w - newW) / 2; y = 0;
        w = newH; h = newH;
    }
    CGRect myImageRect = CGRectMake(x, y, w, h);
    CGImageRef imageRef = showImgView.image.CGImage;
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
