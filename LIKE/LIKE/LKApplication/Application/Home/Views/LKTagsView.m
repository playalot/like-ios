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
        self.showNumber = YES;

        self.tagLabel = LCUILabel.view;
        self.tagLabel.font = LK_FONT(14);
        self.tagLabel.textColor = [UIColor whiteColor];//LC_RGB(74, 74, 74);
        self.ADD(self.tagLabel);
        
    
        self.lineView = LCUIImageView.view;
        self.ADD(self.lineView);
        

        self.likesLabel = LCUILabel.view;
        self.likesLabel.font = LK_FONT_B(14);
        self.likesLabel.textColor = [UIColor whiteColor];
//        self.likesLabel.borderWidth = 1;
//        self.likesLabel.borderColor = [[UIColor whiteColor] colorWithAlphaComponent:0.4];
        self.likesLabel.textAlignment = UITextAlignmentCenter;
        self.likesLabel.layer.shouldRasterize = YES;
        self.ADD(self.likesLabel);
        
        
        [self addTapGestureRecognizer:self selector:@selector(like)];
    }
    
    return self;
}

- (instancetype)initWithFont:(UIFont *)font {
    
    if (self == [super init]) {
        
        self.cornerRadius = 4;
        self.layer.masksToBounds = NO;
        self.showNumber = YES;
        
        self.tagLabel = LCUILabel.view;
        self.tagLabel.font = font;
        self.tagLabel.textColor = [UIColor whiteColor];//LC_RGB(74, 74, 74);
        self.ADD(self.tagLabel);
        
        
        self.likesLabel = LCUILabel.view;
        self.likesLabel.font = font;
        self.likesLabel.textColor = [UIColor whiteColor];
//        self.likesLabel.borderWidth = 1;
//        self.likesLabel.borderColor = [[UIColor whiteColor] colorWithAlphaComponent:0.4];
        self.likesLabel.textAlignment = UITextAlignmentCenter;
        self.likesLabel.layer.shouldRasterize = YES;
        self.ADD(self.likesLabel);
        
        UIView *maskView = UIView.view.COLOR([[UIColor blackColor] colorWithAlphaComponent:0.2]);
        self.backgroundImageView.ADD(maskView);
        self.maskView = maskView;
        
        
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
    
    if (self.tagValue.isLiked && self.tagValue.likes.integerValue == 1) {
        
        [LCUIAlertView showWithTitle:LC_LO(@"提醒") message:LC_LO(@"确定要删除这个标签吗？") cancelTitle:LC_LO(@"确定") otherTitle:LC_LO(@"取消") didTouchedBlock:^(NSInteger integerValue) {
            
            if (integerValue == 0) {
                
                [self likeAction];
            }
        }];
        
        return;
    }
    else{
        
        [self likeAction];
    }
}


-(void) likeAction
{
    @weakly(self);
    
    if (self.willRequest) {
        self.willRequest(self);
    }
    
    if (self.chooseTag) {
        
        if (self.chooseTag.isLiked) {
            
            self.chooseTag.likes = @(self.chooseTag.likes.integerValue - 1);
        }
        else{
            
            self.chooseTag.likes = @(self.chooseTag.likes.integerValue + 1);
        }
        
        self.chooseTag.isLiked = !self.chooseTag.isLiked;
        
        // 新数据重新赋值
        self.chooseTag = self.chooseTag;
    } else {
        
        if (self.tagValue.isLiked) {
            
            self.tagValue.likes = @(self.tagValue.likes.integerValue - 1);
        }
        else{
            
            self.tagValue.likes = @(self.tagValue.likes.integerValue + 1);
        }

        self.tagValue.isLiked = !self.tagValue.isLiked;

        // 新数据重新赋值
        self.tagValue = self.tagValue;
    }
    
//    static int i = 1;
//    
//    i++;
//    
//    if (i % 2) {
//        
//        
//        if (self.tagValue.isLiked) {
//            
//            self.backgroundColor = [UIColor whiteColor];
//
//            [self mdInflateAnimatedFromPoint:self.likesLabel.center backgroundColor:LKColor.color duration:0.5 completion:nil];
//            
//        }
//        else{
//            
//            self.backgroundColor = LKColor.color;
//
//            [self mdDeflateAnimatedToPoint:self.likesLabel.center backgroundColor:LC_RGB(245, 240, 236) duration:0.5 completion:nil];
//            
//        }
//    }
//    else{
    
        if (self.tagValue.isLiked) {

            /*
            CGRect rect = [self convertRect:self.bounds toView:LC_KEYWINDOW];
            
            THLabel * label = [[THLabel alloc] init];
            label.shadowColor = LKColor.color;
            label.shadowOffset = CGSizeMake(0, 2);
            label.shadowBlur = 5;
            label.text = @"+1";
            label.font = LK_FONT(18);
            label.textColor = [UIColor whiteColor];
            label.FIT();
            label.viewCenterX = rect.origin.x + rect.size.width / 2;
            label.viewCenterY = rect.origin.y + rect.size.height / 2;;
            label.alpha = 0;
            LC_KEYWINDOW.ADD(label);
            
            [UIView animateWithDuration:0.25 animations:^{
                
                label.alpha = 1;
                label.viewCenterY -= 20;
                
            } completion:^(BOOL finished) {
                
                [UIView animateWithDuration:1 animations:^{
                    
                    label.alpha = 0;
                    
                } completion:^(BOOL finished) {
                    
                    [label removeFromSuperview];
                    
                }];
                
            }];
            */
        }
//    }

    
    self.userInteractionEnabled = NO;
    
    LC_FAST_ANIMATIONS_F(0.15, ^{
        
        self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.2, 1.2);
        
    }, ^(BOOL finished){
        
        LC_FAST_ANIMATIONS_F(0.15, ^{
            
            if (self.chooseTag) {
                
                self.transform = self.chooseTag.likes.integerValue <= 0 ? CGAffineTransformScale(CGAffineTransformIdentity, 0, 0) : CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
            } else {
                
                self.transform = self.tagValue.likes.integerValue <= 0 ? CGAffineTransformScale(CGAffineTransformIdentity, 0, 0) : CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
            }
            
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
    
    if (self.maskView) {
        
        return;
    }
    
    [LKTagLikeModel likeOrUnLike:self.chooseTag ? self.chooseTag : self.tagValue requestFinished:^(LKHttpRequestResult *result, NSString *error) {
        
        @normally(self);
        
        if (error) {
            
            [self showTopMessageErrorHud:error];
        }
        else{
            
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
    
//    CATransition * animation = [CATransition animation];
//    [animation setDuration:0.25];
//    [animation setType:kCATransitionFade];
//    [animation setSubtype:kCATransitionFromRight];
//    [self.layer addAnimation:animation forKey:@"transition"];
    
    _tagValue = tagValue;
    
    
    self.tagLabel.text = customTag ? customTag : tagValue.tag.description;
    self.tagLabel.FIT();
    
    
    CGFloat tagHeight = self.tagLabel.font.lineHeight;
    CGFloat topPadding = (26 - tagHeight) * 0.5;
    CGFloat leftPadding = 8;
    
    self.tagLabel.viewFrameX = leftPadding;
//    self.tagLabel.viewFrameY = topPadding + 1.5;
    self.tagLabel.viewFrameY = topPadding;
    
    if (self.showNumber) {
        
        self.lineView.viewFrameHeight = 16;
        self.lineView.viewFrameWidth = 1;
        self.lineView.viewFrameX = self.tagLabel.viewRightX + 6;
        self.lineView.viewFrameY = 5;
        self.lineView.image = [UIImage imageNamed:@"SeparateLine.png" useCache:YES];
        
//        UIGraphicsBeginImageContext(CGSizeMake(50, 50));
//        CGContextRef context = UIGraphicsGetCurrentContext();
//        CGContextSetLineWidth(context, 0.5);
//        CGContextSetRGBStrokeColor(context, 0.314, 0.486, 0.859, 1.0);
//        CGContextBeginPath(context);
//        CGContextMoveToPoint(context, self.tagLabel.viewRightX + 8, 5);
//        CGContextAddLineToPoint(context, self.tagLabel.viewRightX + 8, 27);
//        CGContextStrokePath(context);
//        UIImage *line = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();
//        self.lineView.image = line;
        
        
        self.likesLabel.text = LC_NSSTRING_FORMAT(@"%@", customCount ? customCount : tagValue.likes);
        self.likesLabel.FIT();
        
//        self.likesLabel.viewFrameX = self.tagLabel.viewRightX + leftPadding - 2;
        self.likesLabel.viewFrameX = self.lineView.viewRightX + 6;
//        self.likesLabel.viewFrameY = topPadding / 2. + 1;
        self.likesLabel.viewCenterY = self.tagLabel.viewCenterY;
//        self.likesLabel.viewFrameHeight = (self.tagLabel.viewFrameHeight + topPadding * 2.) - topPadding;
        self.likesLabel.viewFrameHeight = self.likesLabel.font.lineHeight;
//        self.likesLabel.viewFrameWidth = self.likesLabel.viewFrameWidth < self.likesLabel.viewFrameHeight ? self.likesLabel.viewFrameHeight + 4 : self.likesLabel.viewFrameWidth + 4;
        CGSize likesLabelSize = [[tagValue.likes stringValue] sizeWithFont:self.likesLabel.font byHeight:self.likesLabel.viewFrameHeight];
        self.likesLabel.viewFrameWidth = likesLabelSize.width;
//        self.likesLabel.cornerRadius = self.likesLabel.viewMidHeight;
        
        
//        self.viewFrameWidth = self.likesLabel.viewRightX + topPadding;
        self.viewFrameWidth = self.likesLabel.viewRightX + 8;
//        self.viewFrameHeight = self.likesLabel.viewBottomY + topPadding;
        self.viewFrameHeight = 26;
    }
    else{
        
        self.viewFrameWidth = self.tagLabel.viewRightX + leftPadding;
        self.viewFrameHeight = self.tagLabel.viewBottomY + topPadding;
    }
    
    
//    self.cornerRadius = self.viewMidHeight;
    self.cornerRadius = 4;
    self.layer.masksToBounds = NO;
    
    self.custom = customLiked ? YES : NO;
    
    
    //
    if (customLiked ? customLiked.boolValue : tagValue.isLiked) {
        
        self.backgroundColor = [LKColor.color colorWithAlphaComponent:1];
        self.likesLabel.textColor = [UIColor whiteColor];
//        self.likesLabel.borderColor = [[UIColor whiteColor] colorWithAlphaComponent:0.4];
        self.lineView.image = [UIImage imageNamed:@"SeparateLine_selected.png" useCache:YES];
        self.tagLabel.textColor = [UIColor whiteColor];
        
        if (self.maskView) {
            
            self.backgroundImageView.hidden = YES;
        }
    }
    else{
        
        self.backgroundColor = LC_RGB(229, 229, 229);
        self.likesLabel.textColor = LC_RGB(75, 75, 75);
        self.tagLabel.textColor = LC_RGB(75, 75, 75);
//        self.likesLabel.borderColor = LC_RGB(220, 215, 209);
        
        if (self.maskView) {
            
            self.tagLabel.textColor = [UIColor whiteColor];
            self.likesLabel.textColor = [UIColor whiteColor];
            self.backgroundImageView.hidden = NO;
        }
    }
    
    self.maskView.frame = self.bounds;
    self.backgroundImageView.layer.cornerRadius = 15;
    self.backgroundImageView.layer.masksToBounds = YES;
}

- (void)setChooseTag:(LKTag *)chooseTag {
    
    if (!chooseTag) {
        return;
    }
    
    _chooseTag = chooseTag;
    
    self.tagLabel.text = chooseTag.tag.description;
    self.tagLabel.FIT();
    
    
    CGFloat topPadding = 5;
    CGFloat leftPadding = 15;
    
    self.tagLabel.viewFrameX = leftPadding;
    self.tagLabel.viewFrameY = topPadding + 1.5;
    
    if (self.showNumber) {
        
        self.likesLabel.text = LC_NSSTRING_FORMAT(@"%@", chooseTag.likes);
        self.likesLabel.FIT();
        
        self.likesLabel.viewFrameX = self.tagLabel.viewRightX + leftPadding - 2;
        self.likesLabel.viewFrameY = topPadding / 2. + 1;
        self.likesLabel.viewFrameHeight = (self.tagLabel.viewFrameHeight + topPadding * 2.) - topPadding;
        self.likesLabel.viewFrameWidth = self.likesLabel.viewFrameWidth < self.likesLabel.viewFrameHeight ? self.likesLabel.viewFrameHeight + 4 : self.likesLabel.viewFrameWidth + 4;
        self.likesLabel.cornerRadius = self.likesLabel.viewMidHeight;
        
        
        self.viewFrameWidth = self.likesLabel.viewRightX + topPadding;
        self.viewFrameHeight = self.likesLabel.viewBottomY + topPadding;
    }
    else{
        
        self.viewFrameWidth = self.tagLabel.viewRightX + leftPadding;
        self.viewFrameHeight = self.tagLabel.viewBottomY + topPadding;
    }
    
    
//    self.cornerRadius = self.viewMidHeight;
    self.cornerRadius = 4;
    self.layer.masksToBounds = NO;
    self.custom = NO;
    
    //
    if (!chooseTag.isLiked) {
        
        self.backgroundColor = [LKColor.color colorWithAlphaComponent:1];
        self.likesLabel.textColor = [UIColor whiteColor];
        self.likesLabel.borderColor = [[UIColor whiteColor] colorWithAlphaComponent:0.4];
        self.tagLabel.textColor = [UIColor whiteColor];
        
        if (self.maskView) {
            
            self.backgroundImageView.hidden = YES;
        }
    }
    else{
        
        self.backgroundColor = LC_RGB(245, 240, 236);
        self.likesLabel.textColor = [LC_RGB(74, 74, 74) colorWithAlphaComponent:0.9];
        self.tagLabel.textColor = [LC_RGB(74, 74, 74) colorWithAlphaComponent:0.9];
        self.likesLabel.borderColor = LC_RGB(220, 215, 209);
        
        if (self.maskView) {
            
            self.tagLabel.textColor = [UIColor whiteColor];
            self.likesLabel.textColor = [UIColor whiteColor];
            self.backgroundImageView.hidden = NO;
        }
        
    }
    
    self.maskView.frame = self.bounds;
    self.backgroundImageView.layer.cornerRadius = 15;
    self.backgroundImageView.layer.masksToBounds = YES;

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
    
    self.viewFrameHeight = 0;
    
    CGFloat leftMargin = 14;
    CGFloat topMargin = 14;
    CGFloat topPadding = 10;
    CGFloat leftPadding = 10;
    CGFloat maxHeight = 0;

    
    LKTagItem * lastItem = nil;
    
    
    NSInteger page = 0;
    NSInteger line = 0;
    
    for (NSInteger i = 0; i < self.tags.count; i++) {
        
        LKTag *tag = self.tags[i];

        if(tag.likes.integerValue == 0){
            
            continue;
        }
        
        LKTagItem *item = self.FIND(tag.id.integerValue);
        
        if (!item) {
            
            item = LKTagItem.view;
        }
        
        item.tag = tag.id.integerValue;
        item.tagValue = tag;
        
        @weakly(self);
        
        item.didRemoved = ^(LKTagItem *cache){
            
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
        
        item.willRequest = ^(LKTagItem *cache){
            
            @normally(self);
            
            if (self.willRequest) {
                self.willRequest(cache);
            }
            
            //self.userInteractionEnabled = NO;
        };
        
        item.requestFinished = ^(LKTagItem *cache){
            
            @normally(self);
            
            if (self.itemRequestFinished) {
                self.itemRequestFinished(cache);
            }
            
            //self.userInteractionEnabled = YES;
        };
        
        
        self.ADD(item);

        
        if (!lastItem){
            
            item.frame = CGRectMake(leftMargin, topMargin, item.viewFrameWidth, item.viewFrameHeight);
            
        }else{
            
            CGFloat test = lastItem.viewRightX + leftPadding + leftMargin + item.viewFrameWidth - (page * self.viewFrameWidth);
            
            if (test > self.viewFrameWidth) {
                
                if (line == 999) {
                    
                    page += 1;
                    line = 0;
                    
                }else{
                    
                    line += 1;
                }
                
                item.frame = CGRectMake(leftMargin + (page * self.viewFrameWidth), line * topPadding + topMargin + line * item.viewFrameHeight, item.viewFrameWidth, item.viewFrameHeight);
                
                
            }else{
                
                item.frame = CGRectMake(lastItem.viewFrameX + lastItem.viewFrameWidth + leftPadding, line * topPadding + topMargin + line * item.viewFrameHeight, item.viewFrameWidth, item.viewFrameHeight);
            }
            
        }
        
        lastItem = item;
        
        
        CGFloat height = lastItem.viewBottomY + topMargin;
        maxHeight = height > maxHeight ? height : maxHeight;
        
    }

    
    UIView *newItem = self.FIND(-3);
    
    if (!newItem) {
        
        newItem = [self buildNewActionTag];
    }
    
    newItem.tag = -3;
    //[newItem setTagValue:[[LKTag alloc] init] customTag:@"New" customCount:@"+" customLiked:@(YES)];
    //newItem.frame = CGRectMake(leftPadding, topPadding, newItem.viewFrameWidth, newItem.viewFrameHeight);
    
    if (!lastItem){
        
        newItem.frame = CGRectMake(leftMargin, topMargin, newItem.viewFrameWidth, newItem.viewFrameHeight);
        
    }else{
        
//        CGFloat test = lastItem.viewRightX + leftPadding * 2 + newItem.viewFrameWidth - (page * self.viewFrameWidth);
        CGFloat test = lastItem.viewRightX + newItem.viewFrameWidth + 16 + 20;
        
        if (test > self.viewFrameWidth) {
            
            if (line == 999) {
                
                page += 1;
                line = 0;
                
            }else{
                
                line += 1;
            }
            
            newItem.frame = CGRectMake(leftMargin + (page * self.viewFrameWidth), line * topPadding + topMargin + line * lastItem.viewFrameHeight, newItem.viewFrameWidth, newItem.viewFrameHeight);
            
            
        }else{
            
            newItem.frame = CGRectMake(lastItem.viewFrameX + lastItem.viewFrameWidth + leftPadding, line * topPadding + topMargin + line * lastItem.viewFrameHeight, newItem.viewFrameWidth, newItem.viewFrameHeight);
        }
        
    }
    
    newItem.viewFrameX = self.viewFrameWidth - newItem.viewFrameWidth - 10;
    [newItem addTapGestureRecognizer:self selector:@selector(newTagAction)];
    
    //    newItem.customAction = ^(LKTagItem * item){
    //
    //        @normally(self);
    //
    //        if (self.customAction) {
    //            self.customAction(nil);
    //        }
    //    };
    
    lastItem = (LKTagItem *)newItem;

    CGFloat height = lastItem.viewBottomY + topMargin;
    maxHeight = height > maxHeight ? height : maxHeight;
    
    self.ADD(newItem);
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

-(void) addNewItem:(LKTagItem *)item {
}

-(void) removeFromSuperview {
    [super removeFromSuperview];
//    [self cancelAllTimers];
}

- (void)handleTimer:(NSTimer *)timer {

    LC_FAST_ANIMATIONS(0.5, ^{
        if (self.tipLine.alpha == 0) {
            self.tipLine.alpha = 0.2;
        } else if (self.tipLine.alpha == 0.2) {
            self.tipLine.alpha = 1;
        } else {
            self.tipLine.alpha = 0.2;
        }
    });
}

- (UIView *)buildNewActionTag {
    
    UIView *newTagView = UIView.view;
    
    UIImage *icon = [[UIImage imageNamed:@"AddNewTag.png" useCache:YES] imageWithTintColor:LKColor.color];
    
    LCUIImageView *imageView = [LCUIImageView viewWithImage:icon];
    imageView.viewFrameHeight = 26;
    imageView.viewFrameWidth = 26;
    newTagView.ADD(imageView);
    
    
//    NSString * addNewTagString = LC_LO(@"添加标签");
//    
//    LCUILabel * tip = LCUILabel.view;
//    tip.font = LK_FONT(11);
//    tip.text = addNewTagString;
//    tip.textColor = LKColor.color;
//    tip.FIT();
//    tip.viewFrameX = imageView.viewRightX + 5;
//    tip.viewFrameY = imageView.viewMidHeight - tip.viewMidHeight + 0.5;
//    newTagView.ADD(tip);
    
    
//    newTagView.viewFrameWidth = imageView.viewFrameWidth + 5 + tip.viewFrameWidth + 10;
//    newTagView.viewFrameHeight = imageView.viewFrameHeight;
//    newTagView.cornerRadius = newTagView.viewMidHeight;
//    newTagView.borderColor = LKColor.color;
//    newTagView.borderWidth = 1;
    newTagView.viewFrameWidth = imageView.viewFrameWidth;
    newTagView.viewFrameHeight = imageView.viewFrameHeight;
    
    return newTagView;
}

-(void) newTagAction
{
    if (self.customAction) {
        self.customAction(nil);
    }
}

@end
