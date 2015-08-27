//
//  LKLikesScrollView.m
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/7/6.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKLikesScrollView.h"
#import "UIImageView+WebCache.h"

@interface LKLikesScrollView ()

LC_PROPERTY(strong) UIScrollView * scrollView;
LC_PROPERTY(strong) NSArray * likers;
LC_PROPERTY(strong) NSMutableArray * cache;

@end

@implementation LKLikesScrollView

-(instancetype) init
{
    if (self = [super init]) {
        
        self.scrollView = UIScrollView.view;
        self.scrollView.showsVerticalScrollIndicator = NO;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.ADD(self.scrollView);
        
        self.cache = [NSMutableArray array];
    }
    
    return self;
}

-(void) setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    self.scrollView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
}

-(void) setLikers:(NSArray *)likers allLikersNumber:(NSNumber *)allLikersNumber
{
    self.likers = likers;
    
    CGFloat padding = 5;
    CGFloat width = 26;
    
    
    for (UIView * view in self.scrollView.subviews) {
        
        view.hidden = YES;
    }
    
    
    self.hidden = likers.count == 0 ? YES : NO;
    
    CGFloat viewRightX = 0;
    
    for (NSInteger i = 0; i< likers.count; i++) {
        
        LKUser * user = likers[i];
        
        LCUIImageView * item = nil;
        
        if (i < self.cache.count) {
            
            item = self.cache[i];
        }
        else{
            
            item = LCUIImageView.view;
            item.viewFrameWidth = width;
            item.viewFrameHeight = width;
            item.cornerRadius = width / 2;
            item.userInteractionEnabled = YES;
            [item addTapGestureRecognizer:self selector:@selector(itemDiTap:)];
            self.scrollView.ADD(item);

            [self.cache addObject:item];
        }
        
        item.hidden = NO;
        item.viewFrameX = i * width + i * padding + 8;
        item.backgroundColor = LKColor.backgroundColor;
//        item.url = user.avatar;
        [item sd_setImageWithURL:[NSURL URLWithString:user.avatar] placeholderImage:nil];
        item.tag = i;
        
        viewRightX = item.viewRightX;
    }
    
    CGFloat contentWith = viewRightX + padding;
    
    self.scrollView.contentSize = CGSizeMake(contentWith < self.viewFrameWidth ? self.viewFrameWidth : contentWith, self.viewFrameHeight);
}

-(void) itemDiTap:(UITapGestureRecognizer *)tap
{
    if (self.didSelectUser) {
        self.didSelectUser(self.likers[tap.view.tag]);
    }
}

-(NSString *)abbreviateNumber:(NSInteger)num {
    
    NSString *abbrevNum;
    
    CGFloat number = (CGFloat)num;
    
    //Prevent numbers smaller than 1000 to return NULL
    if (num >= 1000) {
        
        NSArray * abbrev = @[@"K", @"M", @"B"];
        
        for (NSInteger i = abbrev.count - 1; i >= 0; i--) {
            
            // Convert array index to "1000", "1000000", etc
            int size = pow(10,(i+1)*3);
            
            if(size <= number) {
                // Removed the round and dec to make sure small numbers are included like: 1.1K instead of 1K
                number = number/size;
                NSString *numberString = [self floatToString:number];
                
                // Add the letter for the abbreviation
                abbrevNum = [NSString stringWithFormat:@"%@%@", numberString, [abbrev objectAtIndex:i]];
            }
            
        }
    } else {
        
        // Numbers like: 999 returns 999 instead of NULL
        abbrevNum = [NSString stringWithFormat:@"%@", @(number)];
    }
    
    return abbrevNum;
}

- (NSString *) floatToString:(CGFloat) val {
    NSString *ret = [NSString stringWithFormat:@"%.1f", val];
    unichar c = [ret characterAtIndex:[ret length] - 1];
    
    while (c == 48) { // 0
        ret = [ret substringToIndex:[ret length] - 1];
        c = [ret characterAtIndex:[ret length] - 1];
        
        //After finding the "." we know that everything left is the decimal number, so get a substring excluding the "."
        if(c == 46) { // .
            ret = [ret substringToIndex:[ret length] - 1];
        }
    }
    
    return ret;
}

@end
