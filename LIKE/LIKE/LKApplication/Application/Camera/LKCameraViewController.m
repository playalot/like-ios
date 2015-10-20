//
//  LKCameraViewController.m
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/4/16.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKCameraViewController.h"
#import <ImageIO/ImageIO.h>
#import "FastttFilterCamera.h"
#import "LKFilterManager.h"
#import "LKFilterScrollView.h"
#import "FastttFilter.h"
#import "LKImageCropperViewController.h"
#import "AppDelegate.h"
#import "LKUIImagePickerViewController.h"
#import "GPUImageView.h"
#import "LKPhotoAlbum.h"

@interface LKCameraViewController () <FastttCameraDelegate>

LC_PROPERTY(strong) FastttFilterCamera *fastCamera;

LC_PROPERTY(strong) LCUIButton *takePhotoButton;
LC_PROPERTY(strong) LCUIButton *flashButton;
LC_PROPERTY(strong) LCUIButton *switchCameraButton;
LC_PROPERTY(strong) LCUIButton *photosButton;
LC_PROPERTY(strong) LCUIButton *finishedButton;
LC_PROPERTY(strong) LCUIImageView *prohibitionView;

LC_PROPERTY(strong) UIView * bottomView;

LC_PROPERTY(strong) LKFilterScrollView * filterScrollView;
LC_PROPERTY(assign) NSInteger currentFilter;
LC_PROPERTY(assign) NSInteger filterIndex;
LC_PROPERTY(assign) UIDeviceOrientation deviceOrientation;

//LC_PROPERTY(strong) UIView *gtaView1;
//LC_PROPERTY(strong) UIView *gtaView2;

LC_PROPERTY(strong) UIView *wastedView;

@end

@implementation LKCameraViewController

-(void) dealloc {
    [self unobserveAllNotifications];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:YES];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setNavigationBarHidden:YES animated:NO];
    
//    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:animated];
}

- (BOOL)prefersStatusBarHidden {
    
    return YES;
}

-(void) viewDidLoad
{
    [super viewDidLoad];
    
    self.deviceOrientation = UIDeviceOrientationPortrait;
    // 交叉溶解样式
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self observeNotification:LKCameraViewControllerDismiss];
    [self observeNotification:UIDeviceOrientationDidChangeNotification];
    
    
    NSString * mediaType = AVMediaTypeVideo;
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    
    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
        
        [self showTopMessageErrorHud:LC_LO(@"无法访问相机，可能是因为您拒绝了相机的访问权限")];
        return;
        
    }
}


-(void) handleNotification:(NSNotification *)notification
{
    if ([notification is:LKCameraViewControllerDismiss]) {
        [self.navigationController popToRootViewControllerAnimated:NO];
        [self dismissViewControllerAnimated:NO completion:nil];
    }
    else if ([notification is:UIDeviceOrientationDidChangeNotification]){
        
        self.deviceOrientation = [UIDevice currentDevice].orientation;
        
        [UIView animateWithDuration:0.25 animations:^{
            
            switch (self.deviceOrientation){
                    
                case UIDeviceOrientationPortrait:
                {
                    self.fastCamera.view.viewFrameHeight = self.view.viewFrameWidth;
                    self.fastCamera.previewView.frame = self.fastCamera.view.bounds;
                    self.filterScrollView.viewFrameY = self.bottomView.viewFrameY - self.filterScrollView.viewFrameHeight;
                    
                    NSMutableArray * array = [@[self.flashButton, self.switchCameraButton, self.photosButton] mutableCopy];

                    if (self.wastedView) {
                        [array addObject:self.wastedView];
                        
                        LC_FAST_ANIMATIONS(0.25, ^{
                            
                            self.wastedView.viewFrameX = 0;
                            self.wastedView.viewFrameY = (self.fastCamera.view.viewFrameHeight - self.wastedView.viewFrameHeight) * 0.5;
                            
                        });
                    }
                    
//                    if (self.gtaView1) {
//                        [array addObject:self.gtaView1];
//                        
//                        LC_FAST_ANIMATIONS(0.25, ^{
//                            
//                            self.gtaView1.viewFrameX = 20;
//                            self.gtaView1.viewFrameY = self.fastCamera.view.viewFrameHeight - self.gtaView1.viewFrameHeight;
//                            
//                        });
//                    }
                    
//                    if (self.gtaView2) {
//                        [array addObject:self.gtaView2];
//                        
//                        LC_FAST_ANIMATIONS(0.25, ^{
//                            
//                            self.gtaView2.viewFrameX = 20;
//                            self.gtaView2.viewFrameY = self.fastCamera.view.viewFrameHeight - self.gtaView2.viewFrameHeight;
//                            
//                        });
//                    }
                    
                    [self viewTransformMakeRotation:array rotation:0];
                    break;
                }
                case UIDeviceOrientationLandscapeLeft:
                case UIDeviceOrientationLandscapeRight:
                {
                    self.fastCamera.view.viewFrameHeight = self.view.viewFrameWidth / 3 * 4;
                    self.fastCamera.previewView.frame = self.fastCamera.view.bounds;
                    self.filterScrollView.viewFrameY = self.bottomView.viewFrameY;
                    
                    CGFloat rotation = self.deviceOrientation == UIDeviceOrientationLandscapeLeft ? 90.f : -90.f;
                    
                    NSMutableArray * array = [@[self.flashButton, self.switchCameraButton, self.photosButton] mutableCopy];
                    
                    if (self.wastedView) {
                        
                        [array addObject:self.wastedView];
                        
                        LC_FAST_ANIMATIONS(0.25, ^{
                            
                            self.wastedView.viewFrameX = 0;
                            self.wastedView.viewFrameY = (self.fastCamera.view.viewFrameHeight - self.wastedView.viewFrameHeight) * 0.5;
                        });
                    }
                    
//                    if (self.gtaView1) {
//                        
//                        [array addObject:self.gtaView1];
//                        
//                        LC_FAST_ANIMATIONS(0.25, ^{
//                            
//                            if (self.deviceOrientation == UIDeviceOrientationLandscapeLeft) {
//
//                                self.gtaView1.viewFrameX = 0;
//                                self.gtaView1.viewFrameY = 20;
//                            
//                            }
//                            else{
//                                
//                                self.gtaView1.viewFrameX = self.fastCamera.view.viewFrameWidth - self.gtaView1.viewFrameWidth;
//                                self.gtaView1.viewFrameY = self.fastCamera.view.viewFrameHeight - self.gtaView1.viewFrameHeight- 20;
//                            }
//                        });
//                    }
//                    
//                    if (self.gtaView2) {
//                        
//                        [array addObject:self.gtaView2];
//                        
//                        LC_FAST_ANIMATIONS(0.25, ^{
//                            
//                            if (self.deviceOrientation == UIDeviceOrientationLandscapeLeft) {
//                                
//                                self.gtaView2.viewFrameX = 0;
//                                self.gtaView2.viewFrameY = 20;
//                                
//                            }
//                            else{
//                                
//                                self.gtaView2.viewFrameX = self.fastCamera.view.viewFrameWidth - self.gtaView2.viewFrameWidth;
//                                self.gtaView2.viewFrameY = self.fastCamera.view.viewFrameHeight - self.gtaView2.viewFrameHeight- 20;
//                            }
//                        });
//                    }

                    
                    [self viewTransformMakeRotation:array rotation:(rotation * M_PI) / 180.0f];
                    
                    break;
                }
                default:
                    
                    break;
            }
            
        } completion:^(BOOL finished) {
            
            
        }];
    }
}

-(void) viewTransformMakeRotation:(NSArray *)views rotation:(CGFloat)rotation
{
    for (UIView * view in views) {
        
        if (rotation == 0) {
            
            view.transform = CGAffineTransformIdentity;
        }
        else{
            
            view.transform = CGAffineTransformRotate(CGAffineTransformIdentity, rotation);
        }
    }
}

-(void) buildUI
{
    self.view.backgroundColor = [UIColor blackColor];
    self.navigationController.view.backgroundColor = [UIColor blackColor];
    
    
    self.fastCamera = [FastttFilterCamera cameraWithFilterImage:nil];
    self.fastCamera.delegate = self;
    self.fastCamera.maxScaledDimension = 600.f;
    self.fastCamera.view.backgroundColor = [UIColor blackColor];
    self.fastCamera.view.viewFrameY = 64;
    self.fastCamera.view.viewFrameHeight = LC_DEVICE_WIDTH;
    
    [self fastttAddChildViewController:self.fastCamera];
    
    
    // settings...
    [self.fastCamera setCameraDevice:FastttCameraDeviceRear];
    [self.fastCamera setCameraTorchMode:FastttCameraTorchModeOff];
    [self.fastCamera setCameraFlashMode:FastttCameraFlashModeOff];


    self.flashButton = LCUIButton.view;
    self.flashButton.viewFrameY = 0;
    self.flashButton.viewFrameWidth = 51;
    self.flashButton.viewFrameHeight = 64;
    [self.flashButton setImage:[UIImage imageNamed:@"CameraFlash.png" useCache:YES] forState:UIControlStateNormal];
    [self.flashButton setImage:[UIImage imageNamed:@"CameraFlash_selected.png" useCache:YES] forState:UIControlStateSelected];
    self.flashButton.selected = NO;
    self.flashButton.showsTouchWhenHighlighted = YES;
    [self.flashButton addTarget:self action:@selector(flash) forControlEvents:UIControlEventTouchUpInside];
    self.view.ADD(self.flashButton);
    

    self.switchCameraButton = LCUIButton.view;
    self.switchCameraButton.viewFrameWidth = 51;
    self.switchCameraButton.viewFrameHeight = 64;
    self.switchCameraButton.viewFrameX = LC_DEVICE_WIDTH - self.switchCameraButton.viewFrameWidth;
    self.switchCameraButton.viewFrameY = 0;
    [self.switchCameraButton setImage:[UIImage imageNamed:@"CameraChange.png" useCache:YES] forState:UIControlStateNormal];
    [self.switchCameraButton setImage:[UIImage imageNamed:@"CameraChange_selected.png" useCache:YES] forState:UIControlStateSelected];
    self.switchCameraButton.showsTouchWhenHighlighted = YES;
    [self.switchCameraButton addTarget:self action:@selector(switchCamera) forControlEvents:UIControlEventTouchUpInside];
    self.view.ADD(self.switchCameraButton);
    
    
    self.prohibitionView = LCUIImageView.view;
    self.prohibitionView.hidden = YES;
    self.prohibitionView.viewFrameWidth = 200;
    self.prohibitionView.viewFrameHeight = 200;
    self.prohibitionView.viewCenterX = self.fastCamera.view.viewCenterX;
    self.prohibitionView.viewCenterY = self.fastCamera.view.viewMidHeight;
    self.prohibitionView.image = [UIImage imageNamed:@"ProhibitionOfSelf.png" useCache:YES];
    if (self.fastCamera.view) {
        self.fastCamera.view.ADD(self.prohibitionView);
    }


    self.bottomView = UIView.view.COLOR([UIColor whiteColor]);
    self.bottomView.viewFrameWidth = LC_DEVICE_WIDTH;
    self.bottomView.viewFrameHeight = 83;
    self.bottomView.viewFrameY = self.view.viewFrameHeight - self.bottomView.viewFrameHeight;
    self.view.ADD(self.bottomView);
    
    
    CGFloat equalWidth = LC_DEVICE_WIDTH / 3;
    
    self.takePhotoButton = LCUIButton.view;
    self.takePhotoButton.viewFrameWidth = 63;
    self.takePhotoButton.viewFrameHeight = 63;
    self.takePhotoButton.viewCenterX = self.bottomView.viewMidWidth;
    self.takePhotoButton.viewCenterY = self.bottomView.viewMidHeight;
    self.takePhotoButton.buttonImage = [UIImage imageNamed:@"CameraCapture.png" useCache:YES];
    self.takePhotoButton.showsTouchWhenHighlighted = YES;
    [self.takePhotoButton addTarget:self action:@selector(capture) forControlEvents:UIControlEventTouchUpInside];
    self.bottomView.ADD(self.takePhotoButton);
    
    
    self.photosButton = LCUIButton.view;
    self.photosButton.viewFrameWidth = 32;
    self.photosButton.viewFrameHeight = 32;
    self.photosButton.viewCenterY = self.bottomView.viewMidHeight;
    self.photosButton.viewFrameX = (equalWidth - self.photosButton.viewFrameWidth) * 0.5;
    self.photosButton.buttonImage = [UIImage imageNamed:@"CameraPhotos.png" useCache:YES];
    self.photosButton.showsTouchWhenHighlighted = YES;
    [self.photosButton addTarget:self action:@selector(photos) forControlEvents:UIControlEventTouchUpInside];
    self.bottomView.ADD(self.photosButton);
    
    
    self.finishedButton = LCUIButton.view;
    self.finishedButton.viewFrameWidth = 32;
    self.finishedButton.viewFrameHeight = 32;
    self.finishedButton.viewCenterY = self.bottomView.viewMidHeight;
    self.finishedButton.viewFrameX = LC_DEVICE_WIDTH - (equalWidth
                                                     - self.finishedButton.viewFrameWidth) * 0.5
                                                     - self.finishedButton.viewFrameWidth;
    self.finishedButton.buttonImage = [UIImage imageNamed:@"CameraClose.png" useCache:YES];
    self.finishedButton.showsTouchWhenHighlighted = YES;
    [self.finishedButton addTarget:self action:@selector(finished) forControlEvents:UIControlEventTouchUpInside];
    self.bottomView.ADD(self.finishedButton);
    
    
    
    NSArray *filterImages = LKFilterManager.singleton.allFilterImage;
    NSArray * filterNames = LKFilterManager.singleton.allFilterNames;
    
    // filters...
    LKFilterScrollView * filterScrollView = LKFilterScrollView.view;
    filterScrollView.viewFrameWidth = self.view.viewFrameWidth;
    
    [filterScrollView addFilterName:LC_LO(@"默认") filterImage:[UIImage imageNamed:@"FilterPreview.jpg" useCache:YES]];

    for (NSInteger i = 1; i<= filterImages.count ; i++) {
        
        FastttFilter * fastFilter = [FastttFilter filterWithLookupImage:LKFilterManager.singleton.allFilterImage[i - 1]];
        
        UIImage * image = [fastFilter.filter imageByFilteringImage:[UIImage imageNamed:@"FilterPreview.jpg" useCache:YES]];
        
        [filterScrollView addFilterName:filterNames[i - 1] filterImage:image];
    }
    
    filterScrollView.viewFrameHeight = filterScrollView.contentSize.height;
    filterScrollView.viewFrameY = self.bottomView.viewFrameY - filterScrollView.viewFrameHeight;
    self.filterScrollView = filterScrollView;
    [self.view insertSubview:self.filterScrollView belowSubview:self.bottomView];

    
    @weakly(self);
    
    filterScrollView.didSelectedItem = ^(NSInteger index){
        
        @normally(self);
        
        [self switchFilterAtIndex:index];
    };
}

-(void) capture
{
    [self.fastCamera takePicture];
}

-(void) flash
{
    FastttCameraFlashMode flashMode;
    
    switch (self.fastCamera.cameraFlashMode)
    {
        case FastttCameraFlashModeOn:
            flashMode = FastttCameraFlashModeOff;
            break;
        case FastttCameraFlashModeOff:
        default:
            flashMode = FastttCameraFlashModeOn;
            break;
    }
    
    if ([self.fastCamera isFlashAvailableForCurrentDevice]){
        [self.fastCamera setCameraFlashMode:flashMode];
        
        self.flashButton.selected = flashMode == FastttCameraFlashModeOn ? YES : NO;
    }
}

- (void)switchCamera {
    
    self.prohibitionView.hidden = !self.prohibitionView.isHidden;
    
    if (!self.prohibitionView.isHidden) {
        
        CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation"];
        
        anim.values = @[@(M_PI_4 * 0.03), @(-M_PI_4 * 0.03), @(M_PI_4 * 0.03)];
        
        anim.duration = 0.15;
        anim.repeatCount = 3;
        
        [self.prohibitionView.layer addAnimation:anim forKey:nil];
        
        self.flashButton.userInteractionEnabled = NO;
        self.filterScrollView.userInteractionEnabled = NO;
        self.photosButton.userInteractionEnabled = NO;
        self.takePhotoButton.userInteractionEnabled = NO;
        self.finishedButton.userInteractionEnabled = NO;
    } else {
        self.flashButton.userInteractionEnabled = YES;
        self.filterScrollView.userInteractionEnabled = YES;
        self.photosButton.userInteractionEnabled = YES;
        self.takePhotoButton.userInteractionEnabled = YES;
        self.finishedButton.userInteractionEnabled = YES;
    }
//    FastttCameraDevice cameraDevice;
//    
//    switch (self.fastCamera.cameraDevice)
//    {
//        case FastttCameraDeviceFront:
//            cameraDevice = FastttCameraDeviceRear;
//            break;
//        case FastttCameraDeviceRear:
//        default:
//            cameraDevice = FastttCameraDeviceFront;
//            break;
//    }
//    
//    if ([FastttFilterCamera isCameraDeviceAvailable:cameraDevice]){
//        
//        [self.fastCamera setCameraDevice:cameraDevice];
//        
//        if (![self.fastCamera isFlashAvailableForCurrentDevice]) {
//            ;
//        }
//    }
}

-(void) photos
{
    LKUIImagePickerViewController * picker = [[LKUIImagePickerViewController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.allowsEditing = NO;
    picker.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    picker.navigationBar.tintColor = [UIColor whiteColor];

    [picker.navigationBar setBackgroundImage:[UIImage imageWithColor:[LKColor.color colorWithAlphaComponent:1] andSize:LC_SIZE(LC_DEVICE_WIDTH, 64)] forBarMetrics:UIBarMetricsDefault];
   
    NSMutableDictionary * dictText = [NSMutableDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,LK_FONT_B(18),NSFontAttributeName,nil];
    [picker.navigationBar setTitleTextAttributes:dictText];
    
    [self presentViewController:picker animated:YES completion:nil];
    
    @weakly(self);

    picker.finalizationBlock = ^(id picker, NSDictionary * imageInfo){
      
        @normally(self);
        
        UIImage *image = imageInfo[@"UIImagePickerControllerOriginalImage"];
        
        if (!image) {
            return;
        }
        
        LKImageCropperViewController * cropper = [[LKImageCropperViewController alloc] initWithImage:image];
        cropper.squareImage = self.squareImage;
        cropper.didFinishedPickImage = self.didFinishedPickImage;
        
        [cropper showBackButton];
        
        [picker pushViewController:cropper animated:YES];

    };
    
    picker.cancellationBlock = ^(UIImagePickerController * picker){
      
        [picker dismissViewControllerAnimated:YES completion:nil];
        
    };
}


-(void) finished
{
    [self dismissViewControllerAnimated:YES completion:nil];
//    [self.navigationController popViewControllerAnimated:YES];
}

- (void)switchFilterAtIndex:(NSInteger)index
{
    self.filterIndex = index;
    
    if (self.wastedView) {
        [self.wastedView removeFromSuperview];
        self.wastedView = nil;
    }
    
//    if (self.gtaView1) {
//        [self.gtaView1 removeFromSuperview];
//        self.gtaView1 = nil;
//    }
//    
//    if (self.gtaView2) {
//        [self.gtaView2 removeFromSuperview];
//        self.gtaView2 = nil;
//    }

    
    if (index == 0) {
        self.fastCamera.filterImage = nil;
        return;
    }
    
    NSArray *filterNames = LKFilterManager.singleton.allFilterNames;
    
    if (self.filterIndex == filterNames.count - 1) {
        
        self.wastedView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Wasted2" useCache:YES]];
        self.wastedView.viewFrameX = 0;
        self.wastedView.viewFrameWidth = self.fastCamera.view.viewFrameWidth;
        self.wastedView.viewFrameY = (self.fastCamera.view.viewFrameHeight - self.wastedView.viewFrameHeight) * 0.5;
        self.fastCamera.view.ADD(self.wastedView);
    }
    
//    if (self.filterIndex == filterNames.count - 1) {
//        
//        self.gtaView1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Gta-driving.png" useCache:YES]];
//        self.gtaView1.viewFrameX = 10;
//        self.gtaView1.viewFrameY = self.fastCamera.view.viewFrameHeight - self.gtaView1.viewFrameHeight - 10;
//        self.fastCamera.view.ADD(self.gtaView1);
//    }
//    
//    if (self.filterIndex == filterNames.count) {
//        
//        self.gtaView2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Gta-walking.png" useCache:YES]];
//        self.gtaView2.viewFrameX = 10;
//        self.gtaView2.viewFrameY = self.fastCamera.view.viewFrameHeight - self.gtaView2.viewFrameHeight - 10;
//        self.fastCamera.view.ADD(self.gtaView2);
//    }
    
    self.fastCamera.filterImage = LKFilterManager.singleton.allFilterImage[index - 1];
}

#pragma mark -

- (void)cameraController:(id<FastttCameraInterface>)cameraController didFinishCapturingImage:(FastttCapturedImage *)capturedImage
{
    UIImage * image = capturedImage.fullImage;
    
    if (!image) {
        return;
    }
    
    if (self.deviceOrientation == UIDeviceOrientationLandscapeLeft || self.deviceOrientation == UIDeviceOrientationLandscapeRight) {
        
        image = [UIImage imageWithCGImage:image.CGImage scale:image.scale orientation:self.deviceOrientation == UIDeviceOrientationLandscapeLeft ? UIImageOrientationLeft : UIImageOrientationRight];
    }
    
    [LKPhotoAlbum saveImage:image showTip:NO];

    
    UIView *flashView = [UIView new];
    flashView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
    flashView.alpha = 0.f;
    [self.view addSubview:flashView];
    
    flashView.frame = self.fastCamera.view.frame;
    
    LKImageCropperViewController * cropper = [[LKImageCropperViewController alloc] initWithImage:image filterIndex:self.filterIndex];
    
    cropper.squareImage = self.squareImage;
    cropper.fromPreviewFrameString = NSStringFromCGRect(self.fastCamera.view.frame);
    
    [self.navigationController pushViewController:cropper animated:NO];
    
    cropper.didFinishedPickImage = self.didFinishedPickImage;
}

@end
