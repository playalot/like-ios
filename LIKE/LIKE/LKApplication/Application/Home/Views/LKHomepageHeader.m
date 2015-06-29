//
//  LKHomepageHeader.m
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/4/13.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKHomepageHeader.h"

@interface LKHomepageHeader ()

LC_PROPERTY(strong) UIView * line;
LC_PROPERTY(assign) CGPoint point;

@end

@implementation LKHomepageHeader

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame]){
        
        [self configureBar];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame maxHeight:(CGFloat)maxHeight minHeight:(CGFloat)minHeight
{
    if(self = [super initWithFrame:frame]){
        
        self.preMaxHeight = maxHeight;
        self.preMinHeight = minHeight;
        
        [self configureBar];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame maxHeight:(CGFloat)maxHeight
{
    if(self = [super initWithFrame:frame])
    {
        self.preMaxHeight = maxHeight;
        [self configureBar];
    }
    
    return self;
}

-(void) updateWithUser:(LKUser *)user
{
    if (user) {
        
        self.nameLabel.text = [NSString stringWithFormat:@"%@\n %@ likes", user.name, @(user.likes.integerValue)];
        self.headImageView.url = user.avatar;
        self.nameLabelOnShowing.text = user.name;
        
        if (!LC_NSSTRING_IS_INVALID(user.cover)) {
            
            CATransition * animation = [CATransition animation];
            [animation setDuration:0.15];
            [animation setType:kCATransitionFade];
            [self.backgroundView.layer addAnimation:animation forKey:@"transition"];
            
            self.backgroundView.url = user.cover;
        }
        else{
            
            self.backgroundView.url = @"http://cdn.likeorz.com/default_cover.jpg?imageView2/1/w/750/h/750/q/85";
        }
    }
    else{
        
        self.nameLabel.text = LC_LO(@"游客");
        self.headImageView.url = @"http://cdn.likeorz.com/default_avatar.jpg?imageView2/1/w/120/h/120/q/100";
        self.backgroundView.url = @"http://cdn.likeorz.com/default_cover.jpg?imageView2/1/w/750/h/750/q/85";
    }
}

- (void)configureBar
{
    // Configure bar appearence
    
    if (self.preMaxHeight) {
        self.maximumBarHeight = self.preMaxHeight;
    }
    else{
        self.maximumBarHeight = 200.0;
    }
    
    
    if (self.preMinHeight) {
        self.minimumBarHeight = self.preMinHeight;
    }
    else{
        
        self.minimumBarHeight = 64.0;
    }
    
    
    self.backgroundView = [[LCUIImageView alloc] initWithFrame:self.bounds];
    self.backgroundView.viewFrameWidth = self.viewFrameWidth;
    self.backgroundView.viewFrameHeight = self.maximumBarHeight;
    self.backgroundView.viewFrameY = 0;
    self.backgroundView.contentMode = UIViewContentModeScaleAspectFill;
    self.backgroundView.userInteractionEnabled = YES;
    self.backgroundView.clipsToBounds = YES;
    [self addSubview:self.backgroundView];
    [self sendSubviewToBack:self.backgroundView];
    
    
    self.maskView = UIView.view;
    self.maskView.frame = self.backgroundView.bounds;
    self.maskView.backgroundColor = LKColor.color;
    
    
    BLKFlexibleHeightBarSubviewLayoutAttributes * initialMaskViewLayoutAttributes = [[BLKFlexibleHeightBarSubviewLayoutAttributes alloc] init];
    initialMaskViewLayoutAttributes.size = self.backgroundView.bounds.size;
    initialMaskViewLayoutAttributes.center = CGPointMake(self.frame.size.width*0.5, self.maximumBarHeight * 0.5);
    initialMaskViewLayoutAttributes.alpha = 0;
    [self.maskView addLayoutAttributes:initialMaskViewLayoutAttributes forProgress:0.0];
    
    BLKFlexibleHeightBarSubviewLayoutAttributes *midwayMaskViewLayoutAttributes = [[BLKFlexibleHeightBarSubviewLayoutAttributes alloc] initWithExistingLayoutAttributes:initialMaskViewLayoutAttributes];
    initialMaskViewLayoutAttributes.center = CGPointMake(self.frame.size.width*0.5, self.maximumBarHeight * 0.5);
    midwayMaskViewLayoutAttributes.alpha = 0.6;
    [self.maskView addLayoutAttributes:midwayMaskViewLayoutAttributes forProgress:0.6];
    
    BLKFlexibleHeightBarSubviewLayoutAttributes *finalMaskViewLayoutAttributes = [[BLKFlexibleHeightBarSubviewLayoutAttributes alloc] initWithExistingLayoutAttributes:midwayMaskViewLayoutAttributes];
    initialMaskViewLayoutAttributes.center = CGPointMake(self.frame.size.width*0.5, self.maximumBarHeight * 0.5);
    finalMaskViewLayoutAttributes.alpha = 01;
    [self.maskView addLayoutAttributes:finalMaskViewLayoutAttributes forProgress:1.0];
    
    [self addSubview:self.maskView];

    
    // Add and configure name label
    self.nameLabel = LCUILabel.view;
    self.nameLabel.font = LK_FONT(16);
    self.nameLabel.textColor = [UIColor whiteColor];
    self.nameLabel.numberOfLines = 0;
    self.nameLabel.textAlignment = UITextAlignmentCenter;
    self.nameLabel.text = [NSString stringWithFormat:@"%@\n %@ likes",LKLocalUser.singleton.user.name, @(LKLocalUser.singleton.user.likes.integerValue)];
    [self.nameLabel addTapGestureRecognizer:self selector:@selector(labelTapAction)];

    
    BLKFlexibleHeightBarSubviewLayoutAttributes *initialNameLabelLayoutAttributes = [[BLKFlexibleHeightBarSubviewLayoutAttributes alloc] init];
    initialNameLabelLayoutAttributes.size = CGSizeMake(LC_DEVICE_WIDTH - 200, 50);
    initialNameLabelLayoutAttributes.center = CGPointMake(self.frame.size.width*0.5, self.maximumBarHeight-50.0);
    initialNameLabelLayoutAttributes.alpha = 1;
    [self.nameLabel addLayoutAttributes:initialNameLabelLayoutAttributes forProgress:0.0];
    
    BLKFlexibleHeightBarSubviewLayoutAttributes *midwayNameLabelLayoutAttributes = [[BLKFlexibleHeightBarSubviewLayoutAttributes alloc] initWithExistingLayoutAttributes:initialNameLabelLayoutAttributes];
    midwayNameLabelLayoutAttributes.center = CGPointMake(self.frame.size.width*0.5, (self.maximumBarHeight-self.minimumBarHeight)*0.4+self.minimumBarHeight-50.0);
    midwayNameLabelLayoutAttributes.alpha = 0.6;
    [self.nameLabel addLayoutAttributes:midwayNameLabelLayoutAttributes forProgress:0.6];
    
    BLKFlexibleHeightBarSubviewLayoutAttributes *finalNameLabelLayoutAttributes = [[BLKFlexibleHeightBarSubviewLayoutAttributes alloc] initWithExistingLayoutAttributes:midwayNameLabelLayoutAttributes];
    finalNameLabelLayoutAttributes.center = CGPointMake(self.frame.size.width*0.5, self.minimumBarHeight-25.0);
    finalNameLabelLayoutAttributes.alpha = 0;
    [self.nameLabel addLayoutAttributes:finalNameLabelLayoutAttributes forProgress:1.0];
    
    [self addSubview:self.nameLabel];
    
    
    
    
    self.icon = LCUIImageView.view;
    self.icon.image = [UIImage imageNamed:@"HomeLikeIcon.png" useCache:YES];
    self.icon.viewFrameWidth = 94 / 3;
    self.icon.viewFrameHeight = 88 / 3;
    self.icon.center = CGPointMake(self.viewMidWidth, self.maximumBarHeight - 50);
    self.icon.alpha = 1;
    
    
    BLKFlexibleHeightBarSubviewLayoutAttributes * initialIconLayoutAttributes = [[BLKFlexibleHeightBarSubviewLayoutAttributes alloc] init];
    initialIconLayoutAttributes.size = CGSizeMake(94 / 3, 88 / 3);
    initialIconLayoutAttributes.center = CGPointMake(self.frame.size.width*0.5, self.maximumBarHeight-50.0);
    initialIconLayoutAttributes.alpha = 0;

    [self.icon addLayoutAttributes:initialIconLayoutAttributes forProgress:0.0];
    
    BLKFlexibleHeightBarSubviewLayoutAttributes *midwayIconLayoutAttributes = [[BLKFlexibleHeightBarSubviewLayoutAttributes alloc] initWithExistingLayoutAttributes:initialIconLayoutAttributes];
    midwayIconLayoutAttributes.center = CGPointMake(self.frame.size.width*0.5, (self.maximumBarHeight-self.minimumBarHeight)*0.4+self.minimumBarHeight-50.0);
    midwayIconLayoutAttributes.alpha = 0.6;
    [self.icon addLayoutAttributes:midwayIconLayoutAttributes forProgress:0.6];

    BLKFlexibleHeightBarSubviewLayoutAttributes *finalIconLayoutAttributes = [[BLKFlexibleHeightBarSubviewLayoutAttributes alloc] initWithExistingLayoutAttributes:midwayIconLayoutAttributes];
    finalIconLayoutAttributes.center = CGPointMake(self.frame.size.width*0.5, self.minimumBarHeight-25.0);
    finalIconLayoutAttributes.alpha = 1;
    [self.icon addLayoutAttributes:finalIconLayoutAttributes forProgress:1.0];
    
    [self addSubview:self.icon];
    
    
    
    
    // Add and configure name label
    self.nameLabelOnShowing = LCUILabel.view;
    self.nameLabelOnShowing.viewFrameX = self.icon.viewMidWidth - LC_DEVICE_WIDTH / 2;
    self.nameLabelOnShowing.viewFrameHeight = self.icon.viewFrameHeight;
    self.nameLabelOnShowing.viewFrameWidth = LC_DEVICE_WIDTH;
    self.nameLabelOnShowing.font = LK_FONT_B(16);
    self.nameLabelOnShowing.textColor = [UIColor whiteColor];
    self.nameLabelOnShowing.textAlignment = UITextAlignmentCenter;
    self.nameLabelOnShowing.text = [NSString stringWithFormat:@"%@",LKLocalUser.singleton.user.name];
    self.nameLabelOnShowing.hidden = YES;
    [self.icon addSubview:self.nameLabelOnShowing];
    
    
    
    
    

    
    // Add and configure profile image
    self.headImageView = LCUIImageView.view;
    self.headImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.headImageView.cornerRadius = 65 / 2;
    self.headImageView.borderWidth = 2;
    self.headImageView.borderColor = [UIColor whiteColor];
    self.headImageView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.75];
    self.headImageView.userInteractionEnabled = YES;
    [self.headImageView addTapGestureRecognizer:self selector:@selector(userHeadTapAction)];
    
    BLKFlexibleHeightBarSubviewLayoutAttributes *initialProfileImageViewLayoutAttributes = [[BLKFlexibleHeightBarSubviewLayoutAttributes alloc] init];
    initialProfileImageViewLayoutAttributes.size = CGSizeMake(65, 65);
    initialProfileImageViewLayoutAttributes.center = CGPointMake(self.frame.size.width*0.5, self.maximumBarHeight-110.0);
    [self.headImageView addLayoutAttributes:initialProfileImageViewLayoutAttributes forProgress:0.0];
    
    BLKFlexibleHeightBarSubviewLayoutAttributes *midwayProfileImageViewLayoutAttributes = [[BLKFlexibleHeightBarSubviewLayoutAttributes alloc] initWithExistingLayoutAttributes:initialProfileImageViewLayoutAttributes];
    midwayProfileImageViewLayoutAttributes.center = CGPointMake(self.frame.size.width*0.5, (self.maximumBarHeight-self.minimumBarHeight)*0.8+self.minimumBarHeight-110.0);
    [self.headImageView addLayoutAttributes:midwayProfileImageViewLayoutAttributes forProgress:0.2];
    
    BLKFlexibleHeightBarSubviewLayoutAttributes *finalProfileImageViewLayoutAttributes = [[BLKFlexibleHeightBarSubviewLayoutAttributes alloc] initWithExistingLayoutAttributes:midwayProfileImageViewLayoutAttributes];
    finalProfileImageViewLayoutAttributes.center = CGPointMake(self.frame.size.width*0.5, (self.maximumBarHeight-self.minimumBarHeight)*0.64+self.minimumBarHeight-110.0);
    finalProfileImageViewLayoutAttributes.transform = CGAffineTransformMakeScale(0.5, 0.5);
    finalProfileImageViewLayoutAttributes.alpha = 0.0;
    [self.headImageView addLayoutAttributes:finalProfileImageViewLayoutAttributes forProgress:0.5];
    
    [self addSubview:self.headImageView];
    
    
    [self addTapGestureRecognizer:self selector:@selector(backgroundTapAction:)];
    
    
//    self.line = UIView.view.Y(self.backgroundView.viewFrameHeight - 0.3).WIDTH(LC_DEVICE_WIDTH).HEIGHT(0.3).COLOR([[UIColor blackColor] colorWithAlphaComponent:0.3]);
//    self.ADD(self.line);
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    

}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    // 1. 得到当前手指的位置
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    // 2. 得到上一次手指的位置
    CGPoint preLocation = [touch previousLocationInView:self];
    // 3. 计算两个位置之间的偏移
    CGPoint offset = CGPointMake(location.x - preLocation.x, location.y - preLocation.y);
    
    // 4. 使用计算出来的偏移量，调整视图的位置
//    [self setCenter:CGPointMake(self.center.x + offset.x, self.center.y + offset.y)];
    
    CGFloat y = self.scrollView.contentOffset.y - offset.y * (3./4.);
    y = y < -(self.maximumBarHeight * 2) ? -(self.maximumBarHeight * 2) : y;
    
    [self.scrollView setContentOffset:CGPointMake(0, y) animated:NO];
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGFloat y = self.scrollView.contentOffset.y < -self.maximumBarHeight ? -self.maximumBarHeight : self.scrollView.contentOffset.y;
    
    [self.scrollView setContentOffset:CGPointMake(0, y) animated:YES];

    if (self.scrollView.viewFrameHeight - self.scrollView.contentInset.top >= self.scrollView.contentSize.height) {
        
        [self.scrollView setContentOffset:CGPointMake(0, -self.maximumBarHeight) animated:YES];
    }
}


-(void) userHeadTapAction
{
    if (self.headAction) {
        self.headAction(self.headImageView);
    }
}

-(void) backgroundTapAction:(UITapGestureRecognizer *)tap
{
    CGPoint point = [tap locationInView:self];
    
    /*
     moreButton.viewFrameWidth = 50 / 3 + 40;
     moreButton.viewFrameHeight = 11 / 3 + 40;
     moreButton.viewFrameX = LC_DEVICE_WIDTH - moreButton.viewFrameWidth;
     moreButton.viewFrameY = 10;
     */
    
    if (CGRectContainsPoint(CGRectMake(LC_DEVICE_WIDTH - (50 / 3 + 40), 10, 50 / 3 + 40, 11 / 3 + 40), point)) {
        return;
    }
    
    if (self.maskView.alpha >= 1 && self.maskView.superview) {
        
        [self.scrollView setContentOffset:LC_POINT(0, -self.maximumBarHeight) animated:YES];
        return;
    }
    
    if (self.backgroundAction) {
        self.backgroundAction(nil);
    }
}

-(void) labelTapAction
{
    if (self.labelAction) {
        self.labelAction(nil);
    }
}

-(void) handleScrollDidScroll:(UIScrollView *)scrollView
{
    self.clipsToBounds = YES;
    
    CGFloat addHeight = -(scrollView.contentOffset.y + self.maximumBarHeight);
    
    CGFloat newHeight = self.maximumBarHeight + addHeight;
    
    newHeight = newHeight < self.maximumBarHeight ? self.maximumBarHeight : newHeight;
    
    self.viewFrameHeight = newHeight;
    self.backgroundView.viewFrameHeight = newHeight;

    
    if(scrollView.contentOffset.y < -self.maximumBarHeight){
        
        self.clipsToBounds = NO;
    }
    
    if (scrollView.contentOffset.y < -self.minimumBarHeight) {
        
        CGFloat y = -((scrollView.contentOffset.y + (CGFloat)self.maximumBarHeight) * 0.5f);
        y = y > 0 ? 0 : y;
        
        self.backgroundView.viewFrameY = y;
    }
    
//    CGFloat lineY = -scrollView.contentOffset.y;
//    
//    lineY = lineY < 64. ? 64. : lineY;
//    
//    self.line.viewFrameY = lineY - 0.3;
//    
//    NSLog(@"%f", lineY);
}

@end
