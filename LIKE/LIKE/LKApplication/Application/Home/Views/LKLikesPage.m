//
//  LKLikesPage.m
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/5/8.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKLikesPage.h"
#import "UIImageView+WebCache.h"

@interface LKLikesPage () <UIScrollViewDelegate>

LC_PROPERTY(strong) LKUser * user;
LC_PROPERTY(strong) NSMutableArray * users;
LC_PROPERTY(strong) NSNumber * tagID;

LC_PROPERTY(strong) UIImageView * contentView;
LC_PROPERTY(strong) UIScrollView * scrollView;
LC_PROPERTY(strong) UIPageControl * pageControl;
LC_PROPERTY(strong) LCUILabel * tipLabel;
LC_PROPERTY(strong) UIView * line;

@end

@implementation LKLikesPage

-(void) dealloc
{
    [self cancelAllRequests];
}

+ (instancetype) pageWithTagID:(NSNumber *)tagID user:(LKUser *)user
{
    LKLikesPage * page = [[LKLikesPage alloc] initWithTagID:tagID];
    page.user = user;

    return page;
}

-(instancetype) initWithTagID:(NSNumber *)tagID
{
    if (self = [super initWithFrame:LC_RECT(0, 0, LC_DEVICE_WIDTH, LC_DEVICE_HEIGHT + 20)]) {
        
        self.tagID = tagID;
        
        [self initUI];
    }
    
    return self;
}

-(void) showAtPoint:(CGPoint)point inView:(UIView *)containerView
{
    self.contentView.viewCenterX = point.x;
    self.contentView.viewFrameY = point.y - self.contentView.viewFrameHeight;
    
    if (self.contentView.viewFrameY < 0) {
        
        if (self.resetPointWhenOutOfSide) {
            self.resetPointWhenOutOfSide(nil);
            return;
        }
    }
    
    self.alpha = 0;
    self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.8, 0.8);
    self.contentView.viewFrameY -= 30;
    
    [containerView addSubview:self];

    
    [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:3 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        self.transform = CGAffineTransformIdentity;
        self.alpha = 1;
        self.contentView.viewFrameY += 30;
        
    } completion:^(BOOL finished) {
        
    }];
    
}

-(void) initUI
{
    [self addTapGestureRecognizer:self selector:@selector(dismissAction:)];
    [self addPanGestureRecognizer:self selector:@selector(dismissAction:)];

    
    self.contentView = UIImageView.view;
    self.contentView.viewFrameWidth = 694 / 3;
    self.contentView.viewFrameHeight = 366 / 3;
    self.contentView.image = [UIImage imageNamed:@"LikesPage.png" useCache:YES];
    self.contentView.userInteractionEnabled = YES;
    self.ADD(self.contentView);
    
    NSInteger lineCount = 2;
    
    CGFloat headWidth = 80 / 3;
    CGFloat padding = 10;
    CGFloat scrollViewHeight = padding * lineCount + headWidth * lineCount + padding;
    
    self.scrollView = UIScrollView.view;
    self.scrollView.viewFrameX = 1;
    self.scrollView.viewFrameY = 1;
    self.scrollView.viewFrameWidth = self.contentView.viewFrameWidth - 2;
    self.scrollView.viewFrameHeight = scrollViewHeight - 1;
    self.scrollView.delegate = self;
    self.scrollView.pagingEnabled = YES;
    self.contentView.ADD(self.scrollView);
    
    
    self.pageControl = UIPageControl.view;
    self.pageControl.hidesForSinglePage = YES;
    self.pageControl.viewFrameWidth = self.contentView.viewFrameWidth;
    self.pageControl.viewFrameHeight = 20 + 11;
    self.pageControl.viewFrameY = self.scrollView.viewBottomY;
    self.pageControl.pageIndicatorTintColor = LKColor.backgroundColor;
    self.pageControl.currentPageIndicatorTintColor = LKColor.color;
    self.pageControl.alpha = 0;
    self.contentView.ADD(self.pageControl);
    
    
    self.tipLabel = LCUILabel.view;
    self.tipLabel.frame = self.pageControl.frame;
    self.tipLabel.font = LK_FONT(9);
    self.tipLabel.textColor = LC_RGB(150, 150, 150);
    self.tipLabel.textAlignment = UITextAlignmentCenter;
    self.tipLabel.alpha = 0;
    self.contentView.ADD(self.tipLabel);
    
    
    self.line = UIView.view.X(10).Y(self.scrollView.viewBottomY + 2).WIDTH(self.scrollView.viewFrameWidth - 20).HEIGHT(0.5).COLOR([LC_RGB(150, 150, 150) colorWithAlphaComponent:0.3]);
    self.line.alpha = 0;
    self.contentView.ADD(self.line);
    
    [self loadData];
}


-(void) loadData
{
    LCUIActivityIndicatorView * indicatorView = [LCUIActivityIndicatorView grayView];
    indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [indicatorView startAnimating];
    indicatorView.viewCenterX = self.contentView.viewMidWidth;
    indicatorView.viewCenterY = self.contentView.viewMidHeight - 10;
    self.contentView.ADD(indicatorView);
    
    
    LKHttpRequestInterface * interface = [LKHttpRequestInterface interfaceType:[NSString stringWithFormat:@"mark/%@/likes", self.tagID]].AUTO_SESSION();
    
    @weakly(self);
    
    [self request:interface complete:^(LKHttpRequestResult *result) {
        
        @normally(self);
        
        if (result.state == LKHttpRequestStateFinished) {
            
            NSArray * array = result.json[@"data"][@"likes"];
            
            NSMutableArray * users = [NSMutableArray array];
            
            for (NSDictionary * dic in array) {
                
                [users addObject:[LKUser objectFromDictionary:dic[@"user"]]];
            }
            
            self.users = users;
            
            LC_FAST_ANIMATIONS_F(0.25, ^{
            
                indicatorView.alpha = 0;
                
            }, ^(BOOL finished){
               
                [indicatorView removeFromSuperview];
                [self reloadData];
                
            });
            
        }
        else if (result.state == LKHttpRequestStateFailed){
            
            [self showTopMessageErrorHud:result.error];
            [self dismiss];
        }
        
    }];

}

-(void) setUsers:(NSMutableArray *)users
{
    self.tipLabel.text = [NSString stringWithFormat:@"%@ likes", @(users.count)];

    _users = users;
    
    NSInteger onePageItemCount = 2 * 6;
    
    NSInteger yu = users.count % onePageItemCount;
    
    if (yu > 0) {
        
        NSInteger addCount = onePageItemCount - yu;
        
        for (NSInteger i = 0; i<addCount; i++) {
            
            LKUser * user = [[LKUser alloc] init];
            user.id = @(-1);
            
            [_users addObject:user];
        }
    }
    
    self.pageControl.numberOfPages = _users.count / onePageItemCount < 1 ? 1 : _users.count / onePageItemCount;
    
    LC_FAST_ANIMATIONS(0.25, ^{

        self.line.alpha = 1;

        if (self.pageControl.numberOfPages <= 1) {
            
            self.pageControl.alpha = 0;
            self.tipLabel.alpha = 1;
        }
        else{
            
            self.pageControl.alpha = 1;
            self.tipLabel.alpha = 0;
        }
    });

}

-(void) reloadData
{
    [self.scrollView removeAllSubviews];

    CGFloat topPadding = 10;
    CGFloat leftPadding = 10;
    CGFloat headWidth = 80 / 3;

    
    LCUIImageView * lastItem = nil;
    
    
    NSInteger page = 0;
    NSInteger line = 0;
    CGFloat maxHeight = 0;
    
    for (NSInteger i = 0 ; i< self.users.count ; i++) {
        
        LKUser * user = self.users[i];
        
        LCUIImageView * item = LCUIImageView.view;
        item.viewFrameWidth = headWidth;
        item.viewFrameHeight = headWidth;
        item.cornerRadius = item.viewMidHeight;
        item.backgroundColor = LKColor.backgroundColor;
        item.userInteractionEnabled = YES;
        item.tag = i;
        
        if (user.avatar) {
//            item.url = user.avatar;
            [item sd_setImageWithURL:[NSURL URLWithString:user.avatar] placeholderImage:nil];
            [item addTapGestureRecognizer:self selector:@selector(didTapHeadAction:)];
        }
        
        self.scrollView.ADD(item);
        
        

        if (user.id.integerValue == -1) {
            
            item.alpha = 0;
        }
        else{
            
            item.alpha = 0;
            item.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0, 0);
        }
        
        
        
        [UIView animateWithDuration:0.35 delay:user.id.integerValue == -1 ? 0 : 0.1 * i usingSpringWithDamping:0.7 initialSpringVelocity:3 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            
            item.transform = CGAffineTransformIdentity;
            item.alpha = 1;
            
        } completion:^(BOOL finished) {
            
        }];
        
        if (!lastItem){
            
            item.frame = CGRectMake(leftPadding, topPadding, item.viewFrameWidth, item.viewFrameHeight);
            
        }else{
            
            CGFloat test = lastItem.viewRightX + leftPadding + item.viewFrameWidth - (page * self.scrollView.viewFrameWidth);
            
            if (test > self.scrollView.viewFrameWidth) {
                
                if (line == 1) {
                    
                    page += 1;
                    line = 0;
                    
                }else{
                    
                    line += 1;
                }
                
                item.frame = CGRectMake(leftPadding + (page * self.scrollView.viewFrameWidth), (line + 1) * topPadding + line * item.viewFrameHeight, item.viewFrameWidth, item.viewFrameHeight);
                
                
            }else{
                
                item.frame = CGRectMake(lastItem.viewFrameX + lastItem.viewFrameWidth + leftPadding, (line + 1) * topPadding + line * item.viewFrameHeight, item.viewFrameWidth, item.viewFrameHeight);
            }
            
        }
        
        lastItem = item;
        
        
        CGFloat height = lastItem.viewBottomY + topPadding;
        maxHeight = height > maxHeight ? height : maxHeight;
        
    }
    
    CGSize size = CGSizeMake((page + 1) * self.scrollView.viewFrameWidth, self.scrollView.viewFrameHeight);
    
    self.scrollView.contentSize = size;
    
}

-(void) dismissAction:(UITapGestureRecognizer *)tap
{
    CGPoint point = [tap locationInView:self];
    
    BOOL contains = CGRectContainsPoint(self.contentView.frame, point);
    
    if (!contains) {
        [self dismiss];
    }
}

-(void) dismiss
{
    if (self.superview) {
        
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseInOut animations:^{
            
            self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.8, 0.8);
            self.alpha = 0;
            self.contentView.viewFrameY -= 30;

            
        } completion:^(BOOL finished) {
            
            if (finished) {
                
                [self removeFromSuperview];
            }
        }];
    }
}

-(void) didTapHeadAction:(UITapGestureRecognizer *)tap
{
    [self dismiss];
    
    if (self.didTapHead) {
        self.didTapHead(self.users[tap.view.tag]);
    }
}

#pragma mark -

-(void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.pageControl.currentPage = scrollView.contentOffset.x / scrollView.viewFrameWidth;
}

@end
