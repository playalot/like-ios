//
//  LKPresentAnimation.m
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/7/20.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKPresentAnimation.h"
#import "LKPostDetailViewController.h"

@interface LKPresentAnimation ()

LC_PROPERTY(assign) BOOL isDismissed;

@end

@implementation LKPresentAnimation

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.25;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController * fromViewController = (UIViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    LKPostDetailViewController * toViewController = (LKPostDetailViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];

    if (self.isDismissed) {
     
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
    else{
     
        [[transitionContext containerView] addSubview:toViewController.view];
        toViewController.view.alpha = 0;
        toViewController.view.transform = CGAffineTransformMakeScale(0.9, 0.9);
        [UIView animateWithDuration:[self transitionDuration:transitionContext]  animations:^{
            fromViewController.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
            toViewController.view.alpha = 1;
            toViewController.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
        } completion:^(BOOL finished) {
            fromViewController.view.transform = CGAffineTransformIdentity;
            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
            
        }];

    }
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    self.isDismissed = NO;
    return self;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    self.isDismissed = YES;
    return self;
}

@end
