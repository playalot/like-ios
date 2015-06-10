//
//  LKPopAnimation.m
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/5/6.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKPopAnimation.h"

@implementation LKPopAnimation

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    

    fromViewController.view.alpha = 1;
    toViewController.view.alpha = 1;
    toViewController.view.transform = CGAffineTransformMakeScale(1.1, 1.1);

    
    [[transitionContext containerView] insertSubview:toViewController.view belowSubview:fromViewController.view];

    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        
        toViewController.view.transform = CGAffineTransformMakeScale(1.0, 1.0);
        toViewController.view.alpha = 1.0f;
        
        fromViewController.view.transform = CGAffineTransformMakeScale(0.9, 0.9);
        fromViewController.view.alpha = 0.0f;
        
    } completion:^(BOOL finished) {
        
        fromViewController.view.transform = CGAffineTransformIdentity;
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        
    }];
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.25;
}

@end
