//
//  LKAssistiveTouchButton.m
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/4/22.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKAssistiveTouchButton.h"

@interface LKAssistiveTouchButton ()

LC_PROPERTY(strong) UIPanGestureRecognizer *panGestureRecognizer;
LC_PROPERTY(strong) UITapGestureRecognizer *tapGestureRecognizer;
LC_PROPERTY(assign) UIView * inView;
LC_PROPERTY(assign) CGRect frameRect;

LC_PROPERTY(assign) NSTimeInterval interval;
LC_PROPERTY(assign) BOOL moved;
LC_PROPERTY(assign) CGPoint beginPoint;

@end

@implementation LKAssistiveTouchButton

-(id)initWithFrame:(CGRect)frame inView:(UIView *)inView
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.frameRect = frame;
        self.inView = inView;
        
        self.view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HomepageIcon.png" useCache:YES]];
        self.view.userInteractionEnabled = YES;
        self.view.center = LC_POINT(frame.size.width / 2, frame.size.height / 2);
        
//        LCUIBlurView * blur = LCUIBlurView.view;
//        blur.frame = CGRectMake(0, 0, self.view.viewFrameWidth - 2, self.view.viewFrameHeight - 2);
//        blur.cornerRadius = blur.viewMidHeight;
//        blur.center = LC_POINT(frame.size.width / 2, frame.size.height / 2);
//        self.ADD(blur);
        
        self.ADD(self.view);
    }
    return self;
}

-(void) didTapAction
{
    if (self.didSelected) {
        self.didSelected();
    }
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.touchDown) {
        self.touchDown();
    }
    
    self.moved = NO;
    
    UITouch * touch = [touches anyObject];
    
    self.beginPoint = [touch locationInView:self.superview];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    // 1. 得到当前手指的位置
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    // 2. 得到上一次手指的位置
    CGPoint preLocation = [touch previousLocationInView:self];
    // 3. 计算两个位置之间的偏移
    CGPoint offset = CGPointMake(location.x - preLocation.x, location.y - preLocation.y);
    
    // 4. 使用计算出来的偏移量，调整视图的位置
    [self setCenter:CGPointMake(self.center.x + offset.x, self.center.y + offset.y)];
    // self.center = location;
    
    //[LCGCD dispatchAsync:LCGCDPriorityDefault block:^{
    
        
    //}];
    
    CGPoint moveLocation = [touch locationInView:self.superview];

    CGPoint moveOffset = CGPointMake(moveLocation.x - self.beginPoint.x, moveLocation.y - self.beginPoint.y);
    
    if (moveOffset.x < 5 && moveOffset.x > -5 && moveOffset.y < 5 && moveOffset.y > -5) {
        
        self.moved = NO;
    }
    else{
        
        self.moved = YES;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.touchEnd) {
        self.touchEnd();
    }
    
    //[self cancelAllTimers];
 
    if (!self.moved) {
        
        if (self.didSelected) {
            self.didSelected();
        }
    }
    
    [self sliding];
    
    
    [self performSelector:@selector(delayUpdateLocalFrame) withObject:nil afterDelay:0.5];
}

-(void) delayUpdateLocalFrame
{
    NSString * frameString = NSStringFromCGRect(self.frame);

    [LKUserDefaults.singleton setObject:frameString forKey:@"LKAssistiveTouchButton"];
}

-(void) handleTimer:(NSTimer *)timer
{
    self.interval += 0.01;
}

/**
 *  允许移动,计算各边界值
 */
-(void) sliding
{
    /**
     *  view距离左边的距离
     */
    
    float left = self.center.x - (self.bounds.size.width)/2;
    
    /**
     *  view距离右边的距离
     */
    
    float right = self.inView.bounds.size.width -   self.center.x - (self.bounds.size.width)/2;
    
    
    /**
     *  view距离上边的距离
     */
    
    float top = self.center.y - (self.bounds.size.height)/2;
    
    /**
     *  view距离下边的距离
     */
    
    float bottom = self.inView.bounds.size.height - self.center.y - (self.bounds.size.height)/2;
    
    float end =   [self minimumEachBoundaryWhitLeft:left WhitRight:right WhitTop:top WhitBottom:bottom];
    
    [self move:end WhitLeft:left WhitRight:right WhitTop:top WhitBottom:bottom];
    
}
/**
 *  将各个边界的值排序
 *
 *  @param left   左边
 *  @param right  右边
 *  @param top    上边
 *  @param bottom 下边
 *
 *  @return 返回最小值
 */
-(float) minimumEachBoundaryWhitLeft:(float)left WhitRight:(float)right WhitTop:(float)top WhitBottom:(float)bottom
{
    
    float array[4]={
        left,right,top,bottom
    };
    
    float temp;
    for (int i=0; i<4; i++) {
        for (int j=i+1; j<4; j++) {
            
            if (array[i]>array[j]) {
                temp=array[i];
                array[i]=array[j];
                array[j]=temp;
            }
        }
    }
    
    float end = array[0];
    return end;
    
}
/**
 *  开始移动
 *
 *  @param end    最小值
 *  @param left   左边
 *  @param right  右边
 *  @param top    上边
 *  @param bottom 下边
 */
-(void) move:(float)end WhitLeft:(float)left WhitRight:(float)right WhitTop:(float)top WhitBottom:(float)bottom{
    
    [UIView animateWithDuration:0.25 animations:^{
        if (end == left) {
            
            self.center = CGPointMake(self.bounds.size.width/2, self.center.y);
        }else if (end == right)
        {
            self.center = CGPointMake(self.inView.bounds.size.width - (self.bounds.size.width)/2, self.center.y);
        }else if (end == top)
        {
            self.center = CGPointMake(self.center.x, self.bounds.size.height/2);
        }else
        {
            self.center = CGPointMake(self.center.x, self.inView.bounds.size.height - (self.bounds.size.height)/2);
        }
    }];
    
    
    /**
     *  调整边界
     */
    
    if (self.frame.origin.x<0) {
        self.frame = CGRectMake(0, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
    }
    
    if (self.frame.origin.x+self.bounds.size.width>self.inView.bounds.size.width) {
        self.frame = CGRectMake(self.inView.bounds.size.width-self.bounds.size.width,self.frame.origin.y , self.frame.size.width, self.frame.size.height);
    }
    
    if (self.frame.origin.y<0) {
        self.frame = CGRectMake(self.frame.origin.x,0 , self.frame.size.width, self.frame.size.height);
    }
    
    if (self.frame.origin.y+self.bounds.size.height>self.inView.bounds.size.height) {
        self.frame = CGRectMake(self.frame.origin.x,self.inView.bounds.size.height-self.bounds.size.height , self.frame.size.width, self.frame.size.height);
    }
    
}


@end
