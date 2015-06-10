//
//  LKLikesPage.h
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/5/8.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import <UIKit/UIKit.h>

LC_BLOCK(void, LKLikesPageDidTapHead, (LKUser * user));

@interface LKLikesPage : UIView

LC_PROPERTY(copy) LKLikesPageDidTapHead didTapHead;
LC_PROPERTY(copy) LKValueChanged resetPointWhenOutOfSide;

+ (instancetype) pageWithTagID:(NSNumber *)tagID user:(LKUser *)user;

-(void) showAtPoint:(CGPoint)point inView:(UIView *)containerView;
-(void) dismiss;

@end
