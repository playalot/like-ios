//
//  LikeHomeTableViewCell.m
//  Like_iOS
//
//  Created by Majunxiao on 15-1-8.
//  Copyright (c) 2015年 ZJ. All rights reserved.
//

#import "LKHomeTableViewCell.h"
#import "LKPost.h"
#import "LKTagsView.h"

@interface LKHomeTableViewCell()

LC_PROPERTY(strong) LCUIImageView * head;
LC_PROPERTY(strong) LCUILabel * title;
LC_PROPERTY(strong) LCUILabel * likes;
LC_PROPERTY(strong) LKTagsView * tagsView;
LC_PROPERTY(strong) LCUIButton * friendshipButton;
LC_PROPERTY(strong) LCUIActivityIndicatorView * loadingActivity;

@end

@implementation LKHomeTableViewCell

+(CGFloat) height:(LKPost *)post
{
    CGSize size = [LKUIKit parsingImageSizeWithURL:post.content constSize:CGSizeMake(LC_DEVICE_WIDTH - 10, LC_DEVICE_WIDTH - 10)];
    
    if (size.width > LC_DEVICE_WIDTH - 10) {
        
        size.height = (LC_DEVICE_WIDTH - 10) / size.width * size.height;
        size.width = (LC_DEVICE_WIDTH - 10);
    }
    
    
    static LKTagsView * __tagsView = nil;
    
    if (!__tagsView) {
        
        __tagsView = LKTagsView.view;
        __tagsView.viewFrameWidth = LC_DEVICE_WIDTH - 10;
    }
    
    __tagsView.tags = post.tags;
    
    return size.height + __tagsView.viewFrameHeight + 55;
}

-(void) buildUI
{
    self.backgroundColor = LC_RGB(245, 240, 236);
    self.contentView.backgroundColor = LC_RGB(245, 240, 236);
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
    self.contentBack = UIView.view;
    self.contentBack.clipsToBounds = YES;
    self.ADD(self.contentBack);
    
    
    
    self.contentImage = LCUIImageView.view;
    self.contentImage.viewFrameY = -30;
    self.contentImage.backgroundColor = [UIColor whiteColor];
    self.contentImage.contentMode = UIViewContentModeScaleAspectFill;
    self.contentImage.userInteractionEnabled = YES;
    self.contentImage.showIndicator = YES;
    [self.contentImage addTapGestureRecognizer:self selector:@selector(contentImageTapAction)];
    self.contentBack.ADD(self.contentImage);
    
    
    
    UIView * headerBack = UIView.view.X(5).Y(5).WIDTH(LC_DEVICE_WIDTH - 10).HEIGHT(55);
    headerBack.backgroundColor = [UIColor whiteColor];
    self.ADD(headerBack);
    
    
    [LKHomeTableViewCell roundCorners:UIRectCornerTopLeft | UIRectCornerTopRight forView:headerBack];

    
    self.head = LCUIImageView.view;
    self.head.viewFrameX = 15;
    self.head.viewFrameY = 55 / 2 - 33 / 2 + 5;
    self.head.viewFrameWidth = 33;
    self.head.viewFrameHeight = 33;
    self.head.cornerRadius = 33 / 2;
    self.head.backgroundColor = LKColor.backgroundColor;
    self.head.userInteractionEnabled = YES;
    [self.head addTapGestureRecognizer:self selector:@selector(handleHeadTap:)];
    self.ADD(self.head);
    
    
    self.title = LCUILabel.view;
    self.title.viewFrameX = self.head.viewRightX + 10;
    self.title.viewFrameY = 5;
    self.title.viewFrameWidth = LC_DEVICE_WIDTH - 55 - 10;
    self.title.viewFrameHeight = 55;
    self.title.font = LK_FONT(13);
    self.title.textColor = LC_RGB(51, 51, 51);
    [self.title addTapGestureRecognizer:self selector:@selector(handleHeadTap:)];
    self.ADD(self.title);
    
    
    self.likes = LCUILabel.view;
    self.likes.viewFrameWidth = LC_DEVICE_WIDTH / 2 - 10 - 5;
    self.likes.viewFrameY = 5;
    self.likes.viewFrameX = LC_DEVICE_WIDTH / 2 + 5 - 10;
    self.likes.viewFrameHeight = 55;
    self.likes.numberOfLines = 1;
    self.likes.font = LK_FONT(12);
    self.likes.textAlignment = UITextAlignmentRight;
    self.likes.textColor = LC_RGB(51, 51, 51);
    [self.likes addTapGestureRecognizer:self selector:@selector(handleHeadTap:)];
    self.ADD(self.likes);
    
//    self.friendshipButton = LCUIButton.view;
//    self.friendshipButton.viewFrameWidth = 55;
//    self.friendshipButton.viewFrameHeight = 55;
//    self.friendshipButton.viewFrameX = LC_DEVICE_WIDTH - self.friendshipButton.viewFrameWidth;
//    self.friendshipButton.viewFrameY = 5;
//    self.friendshipButton.showsTouchWhenHighlighted = YES;
//    [self.friendshipButton addTarget:self action:@selector(friendShipAction) forControlEvents:UIControlEventTouchUpInside];
//    self.ADD(self.friendshipButton);
//    
//    
//    self.loadingActivity = [LCUIActivityIndicatorView whiteView];
//    self.loadingActivity.center = self.friendshipButton.center;
//    self.ADD(self.loadingActivity);
//    
//    // update...
//    [self updateFriendButton];

    

    self.tagsView = LKTagsView.view;
    self.tagsView.viewFrameX = 5;
    self.tagsView.viewFrameWidth = LC_DEVICE_WIDTH - 10;
    self.tagsView.backgroundColor = [UIColor whiteColor];
    self.ADD(self.tagsView);
    
    
    
    @weakly(self);
    
    self.tagsView.itemRequestFinished = ^(LKTagItem * item){
     
        @normally(self);
        
        if (item.tagValue.isLiked) {
            
            self.post.user.likes = @(self.post.user.likes.integerValue + 1);
        }
        else{
            
            self.post.user.likes = @(self.post.user.likes.integerValue - 1);
        }
        
        
        self.likes.text = LC_NSSTRING_FORMAT(@"%@ likes", self.post.user.likes);
    };
    
}

-(void) addTagAction
{
    if (self.addTag) {
        self.addTag(self.post);
    }
}

-(void) handleHeadTap:(UITapGestureRecognizer *)tap
{
    LCSignal * signal = self.SEND(self.PushUserCenter);
    signal.object = self.post.user;
}

-(void) contentImageTapAction
{
    self.contentImage.SEND(self.PushPostDetail).object = self.post;
}

-(void) setPost:(LKPost *)post
{
    _post = post;
    
    
    if (post.user.id.integerValue == LKLocalUser.singleton.user.id.integerValue) {
        
        post.user = LKLocalUser.singleton.user;
    }
    
    
    self.head.image = nil;
    self.head.url = post.user.avatar;
    self.title.text = LC_NSSTRING_FORMAT(@"%@", post.user.name);
    self.likes.text = LC_NSSTRING_FORMAT(@"%@ likes", post.user.likes);
    
    
    CGSize size = [LKUIKit parsingImageSizeWithURL:post.content constSize:CGSizeMake(LC_DEVICE_WIDTH - 10, LC_DEVICE_WIDTH - 10)];
    
    if (size.width > LC_DEVICE_WIDTH - 10) {
        
        size.height = (LC_DEVICE_WIDTH - 10) / size.width * size.height;
        size.width = (LC_DEVICE_WIDTH - 10);
    }
    
    
    self.contentBack.viewFrameX = 5 + (LC_DEVICE_WIDTH - 10) / 2 - size.width / 2;
    self.contentBack.viewFrameY = 55;
    self.contentBack.viewFrameWidth = size.width;
    self.contentBack.viewFrameHeight = size.height;
    
    self.contentImage.clipsToBounds = YES;
    self.contentImage.frame = self.contentBack.bounds;
    self.contentImage.image = nil;
    self.contentImage.url = post.content;
    
    
    
    self.tagsView.tags = post.tags;
    self.tagsView.viewFrameY = self.contentBack.viewBottomY;
    
    [LKHomeTableViewCell roundCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight forView:self.tagsView];

    
    @weakly(self);
    
    self.tagsView.didRemoveTag = ^(LKTag * tag){
        
        @normally(self);
        
        if (self.removedTag) {
            self.removedTag(self.post);
        }
    };
    
    self.tagsView.customAction = ^(id value){
      
        @normally(self);

        if (self.addTag) {
            self.addTag(self.post);
        }
        
    };
}

-(void) reloadTags
{
//    LC_FAST_ANIMATIONS(1, ^{
//        
//        [self.tagsView reloadDataAndRemoveAll:NO];
//    });
}


- (void)cellOnTableView:(UITableView *)tableView didScrollOnView:(UIView *)view
{
//    CGRect rectInSuperview = [tableView convertRect:self.frame toView:view];
//    
//    CGFloat distanceFromCenter = CGRectGetHeight(view.frame)/2 - CGRectGetMinY(rectInSuperview);
//    CGFloat difference = CGRectGetHeight(self.contentImage.frame) - CGRectGetHeight(self.frame);
//    CGFloat move = (distanceFromCenter / CGRectGetHeight(view.frame)) * difference;
//    
//    CGRect imageRect = self.contentImage.frame;
//    imageRect.origin.y = -(difference/2)+move;
//    self.contentImage.frame = imageRect;
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


@end
