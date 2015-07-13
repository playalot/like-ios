//
//  LKUploadingCell.m
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/6/12.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKUploadingCell.h"

@interface LKUploadingCell ()

LC_PROPERTY(strong) LCUIImageView * postImageView;
LC_PROPERTY(strong) UIProgressView * progressView;
LC_PROPERTY(strong) LCUILabel * tipLabel;
LC_PROPERTY(strong) LCUIButton * cancelButton;

@end

@implementation LKUploadingCell

LC_IMP_SIGNAL(LKUploadingCellCancel);
LC_IMP_SIGNAL(LKUploadingCellReupload);


-(void) buildUI
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
    self.postImageView = LCUIImageView.new;
    self.postImageView.viewFrameX = 5;
    self.postImageView.viewFrameY = 5;
    self.postImageView.viewFrameWidth = 33;
    self.postImageView.viewFrameHeight = 33;
    self.ADD(self.postImageView);
    
    
    self.progressView = UIProgressView.new;
    self.progressView.viewFrameX = self.postImageView.viewRightX + 10;
    self.progressView.viewFrameWidth = LC_DEVICE_WIDTH - self.postImageView.viewRightX - 20;
    self.progressView.viewFrameHeight = 4;
    self.progressView.viewCenterY = 38. / 2. - 2. + 5.;
    self.progressView.progressTintColor = LKColor.color;
    self.progressView.trackTintColor = LC_RGB(216, 216, 216);
    self.ADD(self.progressView);
    
    
    self.tipLabel = LCUILabel.new;
    self.tipLabel.viewFrameWidth = LC_DEVICE_WIDTH;
    self.tipLabel.viewFrameHeight = 33;
    self.tipLabel.viewFrameY = 5;
    self.tipLabel.font = LK_FONT(13);
    self.tipLabel.textColor = LC_RGB(180, 180, 180);
    self.tipLabel.textAlignment = UITextAlignmentCenter;
    self.tipLabel.text = LC_LO(@"点击此处重新上传");
    [self.tipLabel addTapGestureRecognizer:self selector:@selector(reupload)];
    self.ADD(self.tipLabel);
    
    
    self.cancelButton = LCUIButton.view;
    self.cancelButton.viewFrameWidth = 50;
    self.cancelButton.viewFrameHeight = 33;
    self.cancelButton.viewFrameY = 5;
    self.cancelButton.viewFrameX = LC_DEVICE_WIDTH - 45;
    self.cancelButton.buttonImage = [[[UIImage imageNamed:@"NavigationBarDismiss.png" useCache:YES] scaleToWidth:13] imageWithTintColor:LC_RGB(180, 180, 180)];
    self.cancelButton.showsTouchWhenHighlighted = YES;
    [self.cancelButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    self.ADD(self.cancelButton);
}

-(void) cancel
{
    self.SEND(self.LKUploadingCellCancel).object = self.posting;
}

-(void) reupload
{
    self.SEND(self.LKUploadingCellReupload).object = self.posting;
}

-(void) setPosting:(LKPosting *)posting
{
    _posting = posting;
    
    self.postImageView.image = posting.image;
    
    if (posting.uploading) {
        
        self.progressView.hidden = NO;
        self.tipLabel.hidden = YES;
        self.cancelButton.hidden = YES;
        
        self.progressView.progress = posting.progress;
        
        @weakly(self);
        
        posting.updateProgress = ^(NSNumber * number){
          
            @normally(self);
            
            [self.progressView setProgress:number.floatValue animated:YES];
            
        };
    }
    else{
        
        self.cancelButton.hidden = NO;
        self.progressView.hidden = YES;
        self.tipLabel.hidden = NO;
    }
}

@end
