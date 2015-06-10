//
//  LKTagsView.m
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/4/15.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKTagsView.h"
#import "LKTagLikeModel.h"
#import "LKLoginViewController.h"

@interface LKTagItem ()

LC_PROPERTY(assign) BOOL custom;

@end

@implementation LKTagItem

-(instancetype) init
{
    if (self = [super init]) {
        
        self.cornerRadius = 4;
        self.layer.masksToBounds = NO;
        

        self.tagLabel = LCUILabel.view;
        self.tagLabel.font = LK_FONT(11);
        self.tagLabel.textColor = [UIColor whiteColor];//LC_RGB(74, 74, 74);
        self.ADD(self.tagLabel);
        

        self.likesLabel = LCUILabel.view;
        self.likesLabel.font = LK_FONT(11);
        self.likesLabel.textColor = [UIColor whiteColor];
        self.likesLabel.borderWidth = 1;
        self.likesLabel.borderColor = [[UIColor whiteColor] colorWithAlphaComponent:0.4];
        self.likesLabel.textAlignment = UITextAlignmentCenter;
        self.likesLabel.layer.shouldRasterize = YES;
        self.ADD(self.likesLabel);
        
        
        [self addTapGestureRecognizer:self selector:@selector(like)];
    }
    
    return self;
}

-(void) like
{
    if (self.custom) {
        
        if (self.customAction) {
            self.customAction(self);
        }
        
        return;
    }
    
    if([LKLoginViewController needLoginOnViewController:[LCUIApplication sharedInstance].window.rootViewController]){
        
        return;
    };
 
    @weakly(self);
    
    if (self.willRequest) {
        self.willRequest(self);
    }
    
    
    if (self.tagValue.isLiked) {
        
        self.tagValue.likes = @(self.tagValue.likes.integerValue - 1);
    }
    else{
        
        self.tagValue.likes = @(self.tagValue.likes.integerValue + 1);
    }
    
    self.tagValue.isLiked = !self.tagValue.isLiked;
    
    // 新数据重新赋值
    self.tagValue = self.tagValue;
    
    
    self.userInteractionEnabled = NO;
    
    LC_FAST_ANIMATIONS_F(0.15, ^{
        
        self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.2, 1.2);
        
    }, ^(BOOL finished){
        
        LC_FAST_ANIMATIONS_F(0.15, ^{
            
            self.transform = self.tagValue.likes.integerValue <= 0 ? CGAffineTransformScale(CGAffineTransformIdentity, 0, 0) : CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
            
        }, ^(BOOL finished){
            
            self.userInteractionEnabled = YES;
            
            if (self.requestFinished) {
                self.requestFinished(self);
            }

            if (self.tagValue.likes.integerValue <= 0) {

                if (self.didRemoved) {
                    self.didRemoved(self);
                }
            }
        });
    });
    
    [LKTagLikeModel likeOrUnLike:self.tagValue requestFinished:^(LKHttpRequestResult *result, NSString *error) {
       
        @normally(self);
        
        if (error) {
            
            [self showTopMessageErrorHud:error];
        }
        else{
            
//            self.userInteractionEnabled = NO;
//
//
//            // 动画
//            [@[self] pop_sequenceWithInterval:0 animations:^(id object, NSInteger index) {
//                
//                self.pop_springBounciness = 0;
//                self.pop_springSpeed = 120;
//                self.pop_duration = 0.1;
//                self.pop_spring.pop_scaleXY = CGPointMake(1.2, 1.2);
//                
//            } completion:^(BOOL finished) {
//                
//                [@[self] pop_sequenceWithInterval:0 animations:^(id object, NSInteger index) {
//                    
//                    self.pop_springBounciness = 0;
//                    self.pop_springSpeed = 150;
//                    self.pop_duration = 0.1;
//                    self.pop_spring.pop_scaleXY = self.tagValue.likes.integerValue <= 0 ? CGPointMake(0, 0) : CGPointMake(1.0, 1.0);
//                    
//                } completion:^(BOOL finished) {
//                    
//                    self.userInteractionEnabled = YES;
//
//                    if (self.requestFinished) {
//                        self.requestFinished(self);
//                    }
//                    
//                    if (self.tagValue.likes.integerValue <= 0) {
//                        
//                        if (self.didRemoved) {
//                            self.didRemoved(self);
//                        }
//                    }
//                }];
//            }];
            
        }
    }];

    
}


-(void) setTagValue:(LKTag *)tagValue
{
    [self setTagValue:tagValue customTag:nil customCount:nil customLiked:nil];
}

-(void) setTagValue:(LKTag *)tagValue customTag:(NSString *)customTag customCount:(NSString *)customCount customLiked:(NSNumber *)customLiked
{
    if (!tagValue) {
        return;
    }
    
    _tagValue = tagValue;
    
    
    self.tagLabel.text = customTag ? customTag : tagValue.tag;
    self.tagLabel.FIT();
    
    
    CGFloat topPadding = 2.;
    CGFloat leftPadding = 9.;
    

    self.tagLabel.viewFrameX = leftPadding;
    self.tagLabel.viewFrameY = topPadding + 1.5;
    
    self.likesLabel.text = LC_NSSTRING_FORMAT(@"%@", customCount ? customCount : tagValue.likes);
    self.likesLabel.FIT();
    
    self.likesLabel.viewFrameX = self.tagLabel.viewRightX + leftPadding - 2;
    self.likesLabel.viewFrameY = topPadding / 2. + 1;
    self.likesLabel.viewFrameHeight = (self.tagLabel.viewFrameHeight + topPadding * 2.) - topPadding;
    self.likesLabel.viewFrameWidth = self.likesLabel.viewFrameWidth < self.likesLabel.viewFrameHeight ? self.likesLabel.viewFrameHeight : self.likesLabel.viewFrameWidth;
    self.likesLabel.cornerRadius = self.likesLabel.viewMidHeight;


    self.viewFrameWidth = self.likesLabel.viewRightX + topPadding;
    self.viewFrameHeight = self.likesLabel.viewBottomY + topPadding;
    
    self.cornerRadius = self.viewMidHeight;
    self.layer.masksToBounds = NO;
    
    self.custom = customLiked ? YES : NO;
    
    
    //
    if (customLiked ? customLiked.boolValue : tagValue.isLiked) {
        
        self.backgroundColor = [LKColor.color colorWithAlphaComponent:1];
        self.likesLabel.textColor = [UIColor whiteColor];
        self.likesLabel.borderColor = [[UIColor whiteColor] colorWithAlphaComponent:0.4];
        self.tagLabel.textColor = [UIColor whiteColor];
    }
    else{
        
        self.backgroundColor = LC_RGB(245, 240, 236);
        self.likesLabel.textColor = [LC_RGB(74, 74, 74) colorWithAlphaComponent:0.9];
        self.tagLabel.textColor = [LC_RGB(74, 74, 74) colorWithAlphaComponent:0.9];
        self.likesLabel.borderColor = LC_RGB(220, 215, 209);
    }
}

@end

@interface LKTagsView ()

LC_PROPERTY(strong) UIView * tipLine;

@end

@implementation LKTagsView

-(instancetype) init
{
    if (self = [super init]) {
        
        self.pagingEnabled = YES;
        self.scrollsToTop = NO;
    }
    
    return self;
}


-(void) setTags:(NSMutableArray *)tags
{
    _tags = tags;
    
    [self reloadData];
}

-(void) reloadData
{
    [self reloadDataAndRemoveAll:YES];
}

-(void) reloadDataAndRemoveAll:(BOOL)removeAll
{
    if (removeAll) {
        [self removeAllSubviews];
    }
    
    
    CGFloat topPadding = 12;
    CGFloat leftPadding = 12;
    CGFloat maxHeight = 0;

    
    LKTagItem * lastItem = nil;
    

    LKTagItem * newItem = self.FIND(-3);
    
    if (!newItem) {
        
        newItem = LKTagItem.view;
    }

    newItem.tag = -3;
    [newItem setTagValue:[[LKTag alloc] init] customTag:@"New" customCount:@"+" customLiked:@(YES)];
    newItem.frame = CGRectMake(leftPadding, topPadding, newItem.viewFrameWidth, newItem.viewFrameHeight);
    
    
    @weakly(self);

    newItem.customAction = ^(LKTagItem * item){
      
        @normally(self);

        if (self.customAction) {
            self.customAction(nil);
        }
    };

    lastItem = newItem;
    maxHeight = lastItem.viewBottomY + topPadding;

    self.ADD(newItem);
    
    
    NSInteger page = 0;
    NSInteger line = 0;
    
    for (NSInteger i = 0 ; i< self.tags.count ; i++) {
        
        LKTag * tag = self.tags[i];

        if(tag.likes.integerValue == 0){
            continue;
        }
        
        LKTagItem * item = self.FIND(tag.id.integerValue);
        
        if (!item) {
            
            item = LKTagItem.view;
        }
        
        item.tag = tag.id.integerValue;
        item.tagValue = tag;
        
        @weakly(self);
        
        item.didRemoved = ^(LKTagItem * cache){
            
            @normally(self);
            
            // 重新构建
            [self.tags removeObject:cache.tagValue];
            [cache removeFromSuperview];
            
            if (self.didRemoveTag) {
                self.didRemoveTag(cache.tagValue);
            }
            
            LC_FAST_ANIMATIONS(1, ^{
                
                [self reloadDataAndRemoveAll:NO];
            });
        };
        
        item.willRequest = ^(LKTagItem * cache){
            
            //@normally(self);
            
            //self.userInteractionEnabled = NO;
        };
        
        item.requestFinished = ^(LKTagItem * cache){
            
            @normally(self);
            
            if (self.itemRequestFinished) {
                self.itemRequestFinished(cache);
            }
            
            //self.userInteractionEnabled = YES;
        };
        
        
        self.ADD(item);

        
        if (!lastItem){
            
            item.frame = CGRectMake(leftPadding, topPadding, item.viewFrameWidth, item.viewFrameHeight);
            
        }else{
            
            CGFloat test = lastItem.viewRightX + leftPadding * 2 + item.viewFrameWidth - (page * self.viewFrameWidth);
            
            if (test > self.viewFrameWidth) {
                
                if (line == 999) {
                    
                    page += 1;
                    line = 0;
                    
                }else{
                    
                    line += 1;
                }
                
                item.frame = CGRectMake(leftPadding + (page * self.viewFrameWidth), (line + 1) * topPadding + line * item.viewFrameHeight, item.viewFrameWidth, item.viewFrameHeight);
                
                
            }else{
                
                item.frame = CGRectMake(lastItem.viewFrameX + lastItem.viewFrameWidth + leftPadding, (line + 1) * topPadding + line * item.viewFrameHeight, item.viewFrameWidth, item.viewFrameHeight);
            }
            
        }
        
        lastItem = item;
        
        
        CGFloat height = lastItem.viewBottomY + topPadding;
        maxHeight = height > maxHeight ? height : maxHeight;
        
    }
    
    CGSize size = CGSizeMake((page + 1) * self.viewFrameWidth, maxHeight);
    
    self.contentSize = size;
    self.viewFrameHeight = size.height;
    
    
    if (page + 1 > 1) {
        
        LC_REMOVE_FROM_SUPERVIEW(self.tipLine, YES);
        
        self.tipLine = UIView.view;
        self.tipLine.viewFrameX = self.viewFrameWidth - 4;
        self.tipLine.viewFrameWidth = 4;
        self.tipLine.viewFrameHeight = self.viewFrameHeight;
        self.tipLine.backgroundColor = [LKColor.color colorWithAlphaComponent:0.8];
        self.tipLine.alpha = 0;
        self.ADD(self.tipLine);
        
        [self cancelAllTimers];
        NSTimer * timer = [self fireTimer:@"TipLine" timeInterval:1 repeat:YES];
        
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    }
}

-(void) removeFromSuperview
{
    [super removeFromSuperview];
    
    [self cancelAllTimers];
}

-(void) handleTimer:(NSTimer *)timer
{
    LC_FAST_ANIMATIONS(0.5, ^{
       
        if (self.tipLine.alpha == 0) {
         
            self.tipLine.alpha = 0.2;
        }
        else if (self.tipLine.alpha == 0.2) {
            
            self.tipLine.alpha = 1;
        }
        else{
            self.tipLine.alpha = 0.2;
        }
        
    });

}

@end
