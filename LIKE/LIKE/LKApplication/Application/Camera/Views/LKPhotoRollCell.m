//
//  LKPhotoRollCell.m
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/6/19.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKPhotoRollCell.h"

@interface LKPhotoRollCell ()

LC_PROPERTY(strong) LCUIImageView * imageView;

@end

@implementation LKPhotoRollCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        self.imageView = [[LCUIImageView alloc] initWithFrame:LC_RECT(2.5, 2.5, frame.size.width - 5, frame.size.height - 5)];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.imageView.alpha = 0;
        self.ADD(self.imageView);
    }
    
    return self;
}

-(void) setImage:(UIImage *)image
{
    _image = image;
    
    self.imageView.image = image;
    
    if (self.imageView.image) {
        
        LC_FAST_ANIMATIONS(0.5, ^{
            
            self.imageView.alpha = 1;
        });
    }
}

@end
