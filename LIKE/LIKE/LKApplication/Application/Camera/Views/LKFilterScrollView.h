//
//  LKFilterScrollView.h
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/4/17.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import <UIKit/UIKit.h>

LC_BLOCK(void, LKFilterScrollViewDidSelectedItem, (NSInteger index));

@interface LKFilterScrollView : UIScrollView

LC_PROPERTY(copy) LKFilterScrollViewDidSelectedItem didSelectedItem;

-(void) addFilterName:(NSString *)filterName filterImage:(UIImage *)filterImage;

@end
