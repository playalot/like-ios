//
//  FastttFocus.m
//  FastttCamera
//
//  Created by Laura Skelton on 3/2/15.
//
//

#import "FastttFocus.h"

CGFloat const kFocusSquareSize = 50.f;

@interface FastttFocus ()

@property (nonatomic, strong) UIView *view;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, assign) BOOL isFocusing;

@end

@implementation FastttFocus

+ (instancetype)fastttFocusWithView:(UIView *)view
{
    if (!view) {
        return nil;
    }
    
    FastttFocus *fastFocus = [[self alloc] init];
    
    fastFocus.view = view;
    
    fastFocus.detectsTaps = YES;
    
    return fastFocus;
}

- (void)dealloc
{
    self.delegate = nil;
    
    [self _teardownTapFocusRecognizer];
}

- (void)setDetectsTaps:(BOOL)detectsTaps
{
    if (_detectsTaps != detectsTaps) {
        _detectsTaps = detectsTaps;
        if (_detectsTaps) {
            [self _setupTapFocusRecognizer];
        } else {
            [self _teardownTapFocusRecognizer];
        }
    }
}

- (void)showFocusViewAtPoint:(CGPoint)location
{
    if (self.isFocusing) {
        return;
    }
    
    self.isFocusing = YES;
    
    UIImageView * focusView = UIImageView.view;
    focusView.image = [UIImage imageNamed:@"CameraFocus.png" useCache:YES];
    focusView.viewFrameWidth = 498 / 3;
    focusView.viewFrameHeight = 498 / 3;
    focusView.center = location;
    focusView.alpha = 0.f;
    focusView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0, 0);
    [self.view addSubview:focusView];
    
    
    LC_FAST_ANIMATIONS_F(0.3, ^{
    
        focusView.alpha = 1;
        focusView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.7, 0.7);
    
    }, ^(BOOL finished){
    
        [UIView animateWithDuration:0.25 delay:1 options:UIViewAnimationOptionCurveLinear animations:^{
            
            focusView.alpha = 0.f;

        } completion:^(BOOL finished) {
            
            [focusView removeFromSuperview];
            self.isFocusing = NO;
        }];
    });
    
//    [UIView animateWithDuration:0.3f
//                          delay:0.f
//                        options:UIViewAnimationOptionCurveEaseIn
//                     animations:^{
//                         focusView.frame = [self _centeredRectForSize:CGSizeMake(kFocusSquareSize,
//                                                                                 kFocusSquareSize)
//                                                        atCenterPoint:location];
//                         focusView.alpha = 1.f;
//                     } completion:^(BOOL finished){
//                                            }];
}

#pragma mark - Tap to Focus

- (void)_setupTapFocusRecognizer
{
    _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_handleTapFocus:)];
    [self.view addGestureRecognizer:self.tapGestureRecognizer];
}

- (void)_teardownTapFocusRecognizer
{
    if ([self.view.gestureRecognizers containsObject:self.tapGestureRecognizer]) {
        [self.view removeGestureRecognizer:self.tapGestureRecognizer];
    }
    
    self.tapGestureRecognizer = nil;
}

- (void)_handleTapFocus:(UITapGestureRecognizer *)recognizer
{
    if (self.isFocusing) {
        return;
    }
    
    CGPoint location = [recognizer locationInView:self.view];
    if ([self.delegate handleTapFocusAtPoint:location]) {
        [self showFocusViewAtPoint:location];
    }
}

- (CGRect)_centeredRectForSize:(CGSize)size atCenterPoint:(CGPoint)center
{
    return CGRectInset(CGRectMake(center.x,
                                  center.y,
                                  0.f,
                                  0.f),
                       -size.width / 2.f,
                       -size.height / 2.f);
}

@end
