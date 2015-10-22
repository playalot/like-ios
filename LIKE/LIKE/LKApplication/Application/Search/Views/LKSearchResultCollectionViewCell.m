//
//  LKSearchResultCollectionViewCell.m
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/7/17.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKSearchResultCollectionViewCell.h"
#import "UIImageView+WebCache.h"

@interface LKSearchResultCollectionViewCell ()

//LC_PROPERTY(strong) LCUIImageView * contentImage;
LC_PROPERTY(strong) LCUIImageView * head;
LC_PROPERTY(strong) LCUILabel * title;
LC_PROPERTY(strong) LCUILabel * likes;

@end

@implementation LKSearchResultCollectionViewCell

LC_IMP_SIGNAL(PushUserCenter);
LC_IMP_SIGNAL(PushPostDetail);

+ (CGSize)sizeWithPost:(LKPost *)post {
    CGFloat width = (LC_DEVICE_WIDTH - 15) / 2;
    CGSize size = [LKUIKit parsingImageSizeWithURL:post.thumbnail constSize:CGSizeMake(width, width)];
    if (size.width > width) {
        size.height = width / size.width * size.height;
        size.width = width;
    }
    return CGSizeMake(width, size.height + 40);
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.head = LCUIImageView.view;
        self.head.viewFrameX = 10;
        self.head.viewFrameY = 40 / 2 - 25 / 2;
        self.head.viewFrameWidth = 25;
        self.head.viewFrameHeight = 25;
        self.head.cornerRadius = 25 / 2;
        self.head.backgroundColor = LKColor.backgroundColor;
        self.head.userInteractionEnabled = YES;
        [self.head addTapGestureRecognizer:self selector:@selector(handleHeadTap:)];
        self.ADD(self.head);
        
        self.title = LCUILabel.view;
        self.title.viewFrameX = self.head.viewRightX + 10;
        self.title.viewFrameWidth = self.viewFrameWidth - 120;
        self.title.viewFrameHeight = 40;
        self.title.font = LK_FONT(10);
        self.title.textColor = LC_RGB(51, 51, 51);
        [self.title addTapGestureRecognizer:self selector:@selector(handleHeadTap:)];
        self.ADD(self.title);
        
        self.likes = LCUILabel.view;
        self.likes.viewFrameWidth = self.viewFrameWidth - 10;
        self.likes.viewFrameHeight = 40;
        self.likes.numberOfLines = 1;
        self.likes.font = LK_FONT(10);
        self.likes.textAlignment = UITextAlignmentRight;
        self.likes.textColor = LC_RGB(51, 51, 51);
        [self.likes addTapGestureRecognizer:self selector:@selector(handleHeadTap:)];
        self.ADD(self.likes);
        
        self.contentImage = LCUIImageView.view;
        self.contentImage.viewFrameY = 40;
        self.contentImage.clipsToBounds = YES;
        self.contentImage.backgroundColor = [UIColor whiteColor];
        self.contentImage.contentMode = UIViewContentModeScaleAspectFill;
        self.contentImage.userInteractionEnabled = YES;
        [self.contentImage addTapGestureRecognizer:self selector:@selector(handleImageTapAction:)];
        
        self.ADD(self.contentImage);
        
        self.backgroundColor = [UIColor whiteColor];
        self.cornerRadius = 2;
        self.layer.masksToBounds = YES;
    }
    
    return self;
}

+ (void)roundCorners:(UIRectCorner)corners forView:(UIView *)view
{
    UIBezierPath * maskPath = [UIBezierPath bezierPathWithRoundedRect:view.bounds
                               
                                                    byRoundingCorners:corners
                               
                                                          cornerRadii:CGSizeMake(2, 2)];
    CAShapeLayer * maskLayer = [CAShapeLayer layer];
    
    maskLayer.frame = view.bounds;
    
    maskLayer.path = maskPath.CGPath;
    
    view.layer.mask = maskLayer;
}

-(void) setPost:(LKPost *)post
{
    _post = post;
    
    if (post.user.id.integerValue == LKLocalUser.singleton.user.id.integerValue) {
        
        post.user = LKLocalUser.singleton.user;
    }
    
    
    self.head.image = nil;
//    self.head.url = post.user.avatar;
    [self.head sd_setImageWithURL:[NSURL URLWithString:post.user.avatar] placeholderImage:nil options:SDWebImageRetryFailed];
    self.title.text = LC_NSSTRING_FORMAT(@"%@", post.user.name);
    self.likes.text = LC_NSSTRING_FORMAT(@"%@ likes", post.user.likes);
    
    
    CGFloat width = (LC_DEVICE_WIDTH - 15) / 2;

    
    CGSize size = [LKUIKit parsingImageSizeWithURL:post.thumbnail constSize:CGSizeMake(width, width)];
    
    if (size.width > width) {
        
        size.height = width / size.width * size.height;
        size.width = width;
    }
    
    self.contentImage.viewFrameWidth = size.width;
    self.contentImage.viewFrameHeight = size.height;
    self.contentImage.image = nil;
    [self.contentImage sd_setImageWithURL:[NSURL URLWithString:post.thumbnail] placeholderImage:nil];
    
    
    //[LKSearchResultCollectionViewCell roundCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight forView:self.contentImage];
}

-(void) handleHeadTap:(UITapGestureRecognizer *)tap
{
    self.SEND(self.PushUserCenter).object = self.post.user;
}

-(void) handleImageTapAction:(UITapGestureRecognizer *)tap
{
    self.SEND(self.PushPostDetail).object = self.post;
}

@end
