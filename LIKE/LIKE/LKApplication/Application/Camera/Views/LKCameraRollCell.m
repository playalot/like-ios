//
//  LKCameraRollCell.m
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/6/19.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKCameraRollCell.h"

@interface LKCameraRollCell ()

LC_PROPERTY(strong) AVCaptureSession * captureSession;
LC_PROPERTY(strong) AVCaptureVideoPreviewLayer * prevLayer;

@end

@implementation LKCameraRollCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
            
            AVCaptureDeviceInput * captureInput = [AVCaptureDeviceInput deviceInputWithDevice:[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo] error:nil];
            
            self.captureSession = [[AVCaptureSession alloc] init];
            
            if(captureInput && [self.captureSession canAddInput:captureInput]){
                
                [self.captureSession addInput:captureInput];
            }
            
            [self.captureSession startRunning];
            
            self.prevLayer = [AVCaptureVideoPreviewLayer layerWithSession: self.captureSession];
            self.prevLayer.frame = LC_RECT(2.5, 2.5, frame.size.width - 5, frame.size.height - 5);
            self.prevLayer.backgroundColor = [UIColor lightGrayColor].CGColor;
            self.prevLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
            [self.layer addSublayer:self.prevLayer];
            
            self.alpha = 0;
            
            
            [UIView animateWithDuration:0.5 delay:1 options:UIViewAnimationOptionCurveEaseIn animations:^{
                
                self.alpha = 1;
                
            } completion:^(BOOL finished) {
               
                ;
                
            }];
            
        }else{
            
            self.prevLayer = [AVCaptureVideoPreviewLayer layerWithSession: self.captureSession];
            self.prevLayer.frame = LC_RECT(2.5, 2.5, frame.size.width - 5, frame.size.height - 5);
            self.prevLayer.backgroundColor = [UIColor lightGrayColor].CGColor;
            self.prevLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
            [self.layer addSublayer:self.prevLayer];
            
        }
        
        UIImageView * imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CameraRollIcon.png" useCache:YES]];
        imageView.viewCenterX = self.viewMidWidth;
        imageView.viewCenterY = self.viewMidHeight;
        self.ADD(imageView);
    }
    return self;
}

@end
