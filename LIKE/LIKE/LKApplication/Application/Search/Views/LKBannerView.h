//
//  LKBannerView.h
//  LIKE
//
//  Created by Elkins.Zhao on 15/10/23.
//  Copyright © 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LKTag.h"

LC_BLOCK(void, LKBannerViewTapAction, (LKTag *tag));

@interface LKBannerView : UICollectionReusableView

//- (instancetype)initWithBannerImage:(UIImage *)bannerImage andParticipantsCount:(NSNumber *)participantsCount;
LC_PROPERTY(strong) LKTag *tagValue;
LC_PROPERTY(strong) LKBannerViewTapAction bannerViewDidTap;

@end
