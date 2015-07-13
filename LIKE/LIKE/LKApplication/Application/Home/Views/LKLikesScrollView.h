//
//  LKLikesScrollView.h
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/7/6.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import <UIKit/UIKit.h>

LC_BLOCK(void, LKLikesScrollViewDidSelectUser, (LKUser * user));

@interface LKLikesScrollView : UIView

LC_PROPERTY(copy) LKLikesScrollViewDidSelectUser didSelectUser;

-(void) setLikers:(NSArray *)likers allLikersNumber:(NSNumber *)allLikersNumber;

@end
