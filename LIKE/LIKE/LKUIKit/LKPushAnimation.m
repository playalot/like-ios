//
//  LKPushAnimation.m
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/5/6.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKPushAnimation.h"
#import "LKPostDetailViewController.h"
#import "LKHomeViewController.h"

@implementation LKPushAnimation

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    LKHomeViewController * fromViewController = (LKHomeViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    LKPostDetailViewController * toViewController = (LKPostDetailViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    [[transitionContext containerView] addSubview:toViewController.view];
    
    toViewController.view.alpha = 0;
    toViewController.view.transform = CGAffineTransformMakeScale(0.9, 0.9);
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext]  animations:^{
        
        fromViewController.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
        toViewController.view.alpha = 1;
        toViewController.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
        
    } completion:^(BOOL finished) {
        
        fromViewController.header.alpha = 1;
        
        fromViewController.view.transform = CGAffineTransformIdentity;
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        
    }];
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.25;
}

@end
