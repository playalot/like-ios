//
//  __LKFilterConsoleViewController.m
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/7/14.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "__LKFilterConsole.h"

@interface __LKFilterConsole ()

LC_PROPERTY(strong) UIScrollView * scrollView;

LC_PROPERTY(strong) UIImage * image;
LC_PROPERTY(strong) UIImage * filterImage;

LC_PROPERTY(strong) UISlider * red;
LC_PROPERTY(strong) UISlider * green;
LC_PROPERTY(strong) UISlider * blue;

LC_PROPERTY(strong) UISlider * brightness;
LC_PROPERTY(strong) UISlider * contrast;
LC_PROPERTY(strong) UISlider * whiteBalance;
LC_PROPERTY(strong) UISlider * saturation;
LC_PROPERTY(strong) UISlider * sharpen;

LC_PROPERTY(strong) UISlider * vignetteStart;
LC_PROPERTY(strong) UISlider * vignetteEnd;

LC_PROPERTY(strong) UIImageView * preview;

@end

@implementation __LKFilterConsole

-(instancetype) initWithImage:(UIImage *)image filterImage:(UIImage *)filterImage
{
    if (self = [super init]) {
        
        self.image = image;
        self.filterImage = image;
    }
    
    return self;
}

-(void) buildUI
{
    self.scrollView = UIScrollView.view;
    self.scrollView.viewFrameWidth = LC_DEVICE_WIDTH;
    self.scrollView.viewFrameHeight = self.view.viewFrameHeight - 64;
    self.view.ADD(self.scrollView);
    
    self.preview = [[UIImageView alloc] initWithImage:self.image];
    self.preview.viewFrameWidth = LC_DEVICE_WIDTH;
    self.preview.viewFrameHeight = LC_DEVICE_WIDTH;
    self.preview.contentMode = UIViewContentModeScaleAspectFit;
    self.preview.backgroundColor = [UIColor whiteColor];
    self.scrollView.ADD(self.preview);
    
    
    [self addSliderWithTitle:@"Red" range:NSMakeRange(0, 2) value:1 beginY:0 p:self.red];
    
}

-(void) addSliderWithTitle:(NSString *)title
                     range:(NSRange)range
                     value:(CGFloat)value
                    beginY:(CGFloat)beginY
                         p:(id)p
{
    LCUILabel * label = LCUILabel.view;
    label.viewFrameWidth = LC_DEVICE_WIDTH;
    label.viewFrameHeight = 44;
    label.textColor = [UIColor blackColor];
    label.text = [NSString stringWithFormat:@"  %@",title];
    self.scrollView.ADD(label);
}


@end
