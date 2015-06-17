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

@interface LKCameraViewController () <FastttCameraDelegate>

LC_PROPERTY(strong) FastttFilterCamera * fastCamera;

LC_PROPERTY(strong) LCUIButton * takePhotoButton;
LC_PROPERTY(strong) LCUIButton * flashButton;
LC_PROPERTY(strong) LCUIButton * switchCameraButton;
LC_PROPERTY(strong) LCUIButton * photosButton;
LC_PROPERTY(strong) LCUIButton * finishedButton;

LC_PROPERTY(strong) LCUIButton * filterButton;
LC_PROPERTY(strong) LKFilterScrollView * filterScrollView;

LC_PROPERTY(assign) NSInteger currentFilter;

@end

@implementation LKCameraViewController

-(void) dealloc
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:YES];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setNavigationBarHidden:YES animated:NO];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:animated];
    
    self.takePhotoButton.buttonImage = [UIImage imageNamed:@"CameraCapture.png" useCache:YES];
}

-(void) viewDidLoad
{
    [super viewDidLoad];
    
    [self observeNotification:LKCameraViewControllerDismiss];
}

-(void) handleNotification:(NSNotification *)notification
{
    if ([notification is:LKCameraViewControllerDismiss]) {
        
        [self.navigationController popToRootViewControllerAnimated:NO];
        [self dismissViewControllerAnimated:YES completion:nil];
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
    
    [self fastttAddChildViewController:self.fastCamera];
    
    
    // settings...
    [self.fastCamera setCameraDevice:FastttCameraDeviceRear];
    [self.fastCamera setCameraTorchMode:FastttCameraTorchModeOff];
    [self.fastCamera setCameraFlashMode:FastttCameraFlashModeOff];

    
    self.takePhotoButton = LCUIButton.view;
    self.takePhotoButton.viewFrameWidth = 263 / 3;
    self.takePhotoButton.viewFrameHeight = 155 / 3;
    self.takePhotoButton.viewFrameX = LC_DEVICE_WIDTH / 2 - self.takePhotoButton.viewMidWidth;
    self.takePhotoButton.viewFrameY = self.view.viewFrameHeight - 25 - self.takePhotoButton.viewFrameHeight;
    self.takePhotoButton.buttonImage = [UIImage imageNamed:@"CameraCapture.png" useCache:YES];
    self.takePhotoButton.showsTouchWhenHighlighted = YES;
    [self.takePhotoButton addTarget:self action:@selector(capture) forControlEvents:UIControlEventTouchUpInside];
    self.view.ADD(self.takePhotoButton);
    

    self.flashButton = LCUIButton.view;
    self.flashButton.viewFrameX = 0;
    self.flashButton.viewFrameY = 0;
    self.flashButton.viewFrameWidth = 45 / 3 + 50;
    self.flashButton.viewFrameHeight = 75 / 3 + 50;
    [self.flashButton setImage:[UIImage imageNamed:@"CameraFlash.png" useCache:YES] forState:UIControlStateNormal];
    [self.flashButton setImage:[[UIImage imageNamed:@"CameraFlash.png" useCache:YES] imageWithTintColor:LKColor.color] forState:UIControlStateSelected];
    self.flashButton.selected = NO;
    self.flashButton.showsTouchWhenHighlighted = YES;
    [self.flashButton addTarget:self action:@selector(flash) forControlEvents:UIControlEventTouchUpInside];
    self.view.ADD(self.flashButton);
    

    self.switchCameraButton = LCUIButton.view;
    self.switchCameraButton.viewFrameWidth = 30 + 50;
    self.switchCameraButton.viewFrameHeight = 68 / 3 + 50;
    self.switchCameraButton.viewFrameX = LC_DEVICE_WIDTH - self.switchCameraButton.viewFrameWidth;
    self.switchCameraButton.viewFrameY = 0;
    self.switchCameraButton.buttonImage = [UIImage imageNamed:@"CameraChange.png" useCache:YES];
    self.switchCameraButton.showsTouchWhenHighlighted = YES;
    [self.switchCameraButton addTarget:self action:@selector(switchCamera) forControlEvents:UIControlEventTouchUpInside];
    self.view.ADD(self.switchCameraButton);

    
    self.photosButton = LCUIButton.view;
    self.photosButton.viewFrameWidth = 70 / 3 + 50;
    self.photosButton.viewFrameHeight = 60 / 3 + 50;
    self.photosButton.viewFrameX = 0;
    self.photosButton.viewCenterY = self.takePhotoButton.viewCenterY;
    self.photosButton.buttonImage = [UIImage imageNamed:@"CameraPhotos.png" useCache:YES];
    self.photosButton.showsTouchWhenHighlighted = YES;
    [self.photosButton addTarget:self action:@selector(photos) forControlEvents:UIControlEventTouchUpInside];
    self.view.ADD(self.photosButton);
    
    
    self.finishedButton = LCUIButton.view;
    self.finishedButton.viewFrameWidth = 64 / 3 + 50;
    self.finishedButton.viewFrameHeight = 64 / 3 + 50;
    self.finishedButton.viewFrameX = LC_DEVICE_WIDTH - self.finishedButton.viewFrameWidth;
    self.finishedButton.viewCenterY = self.takePhotoButton.viewCenterY;
    self.finishedButton.buttonImage = [UIImage imageNamed:@"CameraClose.png" useCache:YES];
    self.finishedButton.showsTouchWhenHighlighted = YES;
    [self.finishedButton addTarget:self action:@selector(finished) forControlEvents:UIControlEventTouchUpInside];
    self.view.ADD(self.finishedButton);
    
    
    {
        {
            NSArray * filterNames = LKFilterManager.singleton.allFilterNames;
            
            // filters...
            LKFilterScrollView * filterScrollView = LKFilterScrollView.view;
            filterScrollView.viewFrameWidth = self.view.viewFrameWidth;
            
            [filterScrollView addFilterName:LC_LO(@"默认") filterImage:[UIImage imageNamed:@"FilterPreview.jpg" useCache:YES]];

            for (NSInteger i = 1; i< filterNames.count ; i++) {
                
                FastttFilter * fastFilter = [FastttFilter filterWithLookupImage:LKFilterManager.singleton.allFilterImage[i - 1]];
                
                UIImage * image = [fastFilter.filter imageByFilteringImage:[UIImage imageNamed:@"FilterPreview.jpg" useCache:YES]];
                
                [filterScrollView addFilterName:filterNames[i - 1] filterImage:image];
            }
            
            filterScrollView.viewFrameHeight = filterScrollView.contentSize.height;
            filterScrollView.viewFrameY = self.takePhotoButton.viewFrameY - 25 - filterScrollView.viewFrameHeight;
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
            self.filterButton.pop_spring.center = LC_POINT(self.filterButton.viewCenterX, self.filterScrollView.viewCenterY + 40);
            self.view.ADD(self.filterButton);
            

            self.filterScrollView.viewFrameX = self.view.viewFrameWidth;
            
            
            [self performSelector:@selector(switchFilter) withObject:nil afterDelay:1];
        }
    }
}

-(void) capture
{
    self.takePhotoButton.buttonImage = [UIImage imageNamed:@"CameraCaptureClose.png" useCache:YES];

    self.takePhotoButton.userInteractionEnabled = NO;
    
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

-(void) switchCamera
{
    FastttCameraDevice cameraDevice;
    
    switch (self.fastCamera.cameraDevice)
    {
        case FastttCameraDeviceFront:
            cameraDevice = FastttCameraDeviceRear;
            break;
        case FastttCameraDeviceRear:
        default:
            cameraDevice = FastttCameraDeviceFront;
            break;
    }
    
    if ([FastttFilterCamera isCameraDeviceAvailable:cameraDevice]){
        
        [self.fastCamera setCameraDevice:cameraDevice];
        
        if (![self.fastCamera isFlashAvailableForCurrentDevice]) {
            ;
        }
    }
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
    
    picker.finalizationBlock = ^(id picker, NSDictionary * imageInfo){
      
        LKImageCropperViewController * cropper = [[LKImageCropperViewController alloc] initWithImage:imageInfo[@"UIImagePickerControllerOriginalImage"]
                                                                                           cropFrame:CGRectMake(0, (LC_DEVICE_HEIGHT + 20) / 2 - LC_DEVICE_WIDTH / 2, LC_DEVICE_WIDTH, LC_DEVICE_WIDTH)
                                                                                     limitScaleRatio:3];
        
        cropper.buttonFrame = self.takePhotoButton.frame;
        cropper.filterFrame = self.filterButton.frame;
        cropper.filterScrollFrame = self.filterScrollView.frame;
        cropper.squareImage = self.squareImage;
        [cropper showBackButton];
        
        [picker pushViewController:cropper animated:YES];

    };
    
    picker.cancellationBlock = ^(UIImagePickerController * picker){
      
        [picker dismissViewControllerAnimated:YES completion:nil];
        
    };

//   @weakly(picker);
//    
//    picker.didFinishPicking = ^(NSDictionary * imageInfo){
//      
//        @normally(picker);
//        
//        NSLog(@"imageinfo = %@",imageInfo);
//        
//    };
}


-(void) finished
{
    [self dismissViewControllerAnimated:NO completion:nil];
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
    if (index == 0) {
        self.fastCamera.filterImage = nil;
        return;
    }
    
    self.fastCamera.filterImage = LKFilterManager.singleton.allFilterImage[index - 1];
}

#pragma mark -

- (void)cameraController:(id<FastttCameraInterface>)cameraController didFinishCapturingImage:(FastttCapturedImage *)capturedImage
{
    LKImageCropperViewController * cropper = [[LKImageCropperViewController alloc] initWithImage:capturedImage.fullImage cropFrame:CGRectMake(0, (LC_DEVICE_HEIGHT + 20) / 2 - LC_DEVICE_WIDTH / 2, LC_DEVICE_WIDTH, LC_DEVICE_WIDTH) limitScaleRatio:3];
    cropper.buttonFrame = self.takePhotoButton.frame;
    cropper.filterFrame = self.filterButton.frame;
    cropper.filterScrollFrame = self.filterScrollView.frame;
    cropper.squareImage = self.squareImage;
    
    [self.navigationController pushViewController:cropper animated:NO];
    
    
    cropper.didFinishedPickImage = self.didFinishedPickImage;
    
    self.takePhotoButton.userInteractionEnabled = YES;
}

@end
