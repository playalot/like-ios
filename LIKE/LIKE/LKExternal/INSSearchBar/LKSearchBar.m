//
//  LKSearchBar.m
//  Berlin Insomniac
//
//  Created by Salánki, Benjámin on 06/03/14.
//  Copyright (c) 2014 Berlin Insomniac. All rights reserved.
//

#import "LKSearchBar.h"

@interface LKSearchBar () <UITextFieldDelegate, UIGestureRecognizerDelegate>

/**
 *  The borderedframe of the search bar. Visible only when search mode is active.
 */

@property (nonatomic, strong) UIView *searchFrame;

@property (nonatomic, strong) UITextField *searchField;

/**
 *  The image view containing the search magnifying glass icon in white. Visible when search is not active.
 */

@property (nonatomic, strong) UIImageView *searchImageViewOff;

/**
 *  The image view containing the search magnifying glass icon in blue. Visible when search is active.
 */

@property (nonatomic, strong) UIImageView *searchImageViewOn;

/**
 *  The image view containing the circle part of the magnifying glass icon in blue.
 */

@property (nonatomic, strong) UIImageView *searchImageCircle;

/**
 *  The image view containing the left cross part of the magnifying glass icon in blue.
 */

@property (nonatomic, strong) UIImageView *searchImageCrossLeft;

/**
 *  The image view containing the right cross part of the magnifying glass icon in blue.
 */

@property (nonatomic, strong) UIImageView *searchImageCrossRight;

/**
 *  The frame of the search bar before a transition started. Only set if delegate is not nil.
 */

@property (nonatomic, assign) CGRect	originalFrame;

/**
 *  A gesture recognizer responsible for closing the keyboard once tapped on. 
 *
 *	Added to the window's root view controller view and set to allow touches to propagate to that view.
 */

@property (nonatomic, strong) UITapGestureRecognizer *keyboardDismissGestureRecognizer;

@property (nonatomic, assign) LKSearchBarState state;

@end

static CGFloat const kLKSearchBarInset = 15.0;
static CGFloat const kLKSearchBarImageSize = 18;
static NSTimeInterval const kLKSearchBarAnimationStepDuration = 0.25;

@implementation LKSearchBar

#pragma mark - initialization

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:CGRectMake(CGRectGetMinX(frame), CGRectGetMinY(frame), CGRectGetWidth(frame), frame.size.height)]))
	{
        self.layer.cornerRadius = 4;
        self.layer.masksToBounds = YES;
        
        // Initialization code
		self.opaque = NO;
		self.backgroundColor = [UIColor whiteColor];
		
		self.searchFrame = [[UIView alloc] initWithFrame:self.bounds];
		self.searchFrame.backgroundColor = [UIColor clearColor];
		self.searchFrame.opaque = NO;
		self.searchFrame.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		self.searchFrame.cornerRadius = 4;
		self.searchFrame.contentMode = UIViewContentModeRedraw;
		
		[self addSubview:self.searchFrame];
		
		self.searchField = [[UITextField alloc] initWithFrame:CGRectMake(kLKSearchBarInset, 3.0, CGRectGetWidth(self.bounds) - (2 * kLKSearchBarInset) - kLKSearchBarImageSize, CGRectGetHeight(self.bounds) - 6.0)];
		self.searchField.borderStyle = UITextBorderStyleNone;
		self.searchField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		self.searchField.font = LK_FONT(13);
		self.searchField.textColor = LKColor.color;
		self.searchField.alpha = 0.0;
		self.searchField.delegate = self;
        self.searchField.returnKeyType = UIReturnKeySearch;
		
		[self.searchFrame addSubview:self.searchField];
		
		UIView *searchImageViewOnContainerView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.bounds) - kLKSearchBarInset - kLKSearchBarImageSize + 2, (CGRectGetHeight(self.bounds) - kLKSearchBarImageSize) / 2, kLKSearchBarImageSize, kLKSearchBarImageSize)];
		searchImageViewOnContainerView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
		
		[self.searchFrame addSubview:searchImageViewOnContainerView];
		
		self.searchImageViewOn = [[UIImageView alloc] initWithFrame:searchImageViewOnContainerView.bounds];
		self.searchImageViewOn.alpha = 0.0;
		self.searchImageViewOn.image = [[UIImage imageNamed:@"SearchIconClose.png"] imageWithTintColor:LC_RGB(216, 216, 216)];
        self.searchImageViewOn.contentMode = UIViewContentModeScaleAspectFit;
		[searchImageViewOnContainerView addSubview:self.searchImageViewOn];
		
		self.searchImageCircle = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 18.0, 18.0)];
		self.searchImageCircle.alpha = 0.0;
        self.searchImageCircle.image = [[UIImage imageNamed:@"SearchIconClose.png"] imageWithTintColor:LC_RGB(216, 216, 216)];
        self.searchImageCircle.contentMode = UIViewContentModeScaleAspectFit;

		[searchImageViewOnContainerView addSubview:self.searchImageCircle];
		
		self.searchImageCrossLeft = [[UIImageView alloc] initWithFrame:CGRectMake(14.0, 14.0, 8.0, 8.0)];
		self.searchImageCrossLeft.alpha = 0.0;
		self.searchImageCrossLeft.image = [[UIImage imageNamed:@"SearchIconClose.png"] imageWithTintColor:LC_RGB(216, 216, 216)];
        self.searchImageCrossLeft.contentMode = UIViewContentModeScaleAspectFit;

		[searchImageViewOnContainerView addSubview:self.searchImageCrossLeft];

		self.searchImageCrossRight = [[UIImageView alloc] initWithFrame:CGRectMake(7.0, 5.0, 8.0, 8.0)];
		self.searchImageCrossRight.alpha = 0.0;
		self.searchImageCrossRight.image = [[UIImage imageNamed:@"SearchIconClose.png"] imageWithTintColor:LC_RGB(216, 216, 216)];
        self.searchImageCrossRight.contentMode = UIViewContentModeScaleAspectFit;

		[searchImageViewOnContainerView addSubview:self.searchImageCrossRight];

		self.searchImageViewOff = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.bounds) - kLKSearchBarInset - kLKSearchBarImageSize, (CGRectGetHeight(self.bounds) - kLKSearchBarImageSize) / 2, kLKSearchBarImageSize, kLKSearchBarImageSize)];
		self.searchImageViewOff.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        self.searchImageViewOff.alpha = 1.0;
		self.searchImageViewOff.image = [UIImage imageNamed:@"SearchIconClose.png"];
        self.searchImageViewOff.contentMode = UIViewContentModeScaleAspectFit;

		[self.searchFrame addSubview:self.searchImageViewOff];

		UIView *tapableView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.bounds) - (2 * kLKSearchBarInset) - kLKSearchBarImageSize, 0.0, (2 * kLKSearchBarInset) + kLKSearchBarImageSize, CGRectGetHeight(self.bounds))];
		tapableView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
		[tapableView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeStateIfPossible:)]];
		
		[self.searchFrame addSubview:tapableView];
		
		self.keyboardDismissGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
		self.keyboardDismissGestureRecognizer.cancelsTouchesInView = NO;
		self.keyboardDismissGestureRecognizer.delegate = self;
				
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:) name:UITextFieldTextDidChangeNotification object:self.searchField];
        
        [self showSearchBar:nil];
    }
	
    return self;
}

#pragma mark - state change

- (void)changeStateIfPossible:(UITapGestureRecognizer *)gestureRecognizer
{
	switch (self.state)
	{
		case LKSearchBarStateNormal:
		{
			[self showSearchBar:gestureRecognizer];
		}
			break;
			
		case LKSearchBarStateSearchBarVisible:
		{
            [self.searchField resignFirstResponder];
		}
			break;
			
		case LKSearchBarStateSearchBarHasContent:
		{
			self.searchField.text = nil;
			[self textDidChange:nil];
		}
			break;
			
		case LKSearchBarStateTransitioning:
		{
			// Do nothing.
		}
			break;
	}
}

- (void)showSearchBar:(id)sender
{
	if (self.state == LKSearchBarStateNormal)
	{
		if ([self.delegate respondsToSelector:@selector(searchBar:willStartTransitioningToState:)])
		{
			[self.delegate searchBar:self willStartTransitioningToState:LKSearchBarStateSearchBarVisible];
		}
		
		self.state = LKSearchBarStateSearchBarVisible;
		
		self.searchField.text = nil;
		
		[UIView animateWithDuration:kLKSearchBarAnimationStepDuration animations:^{
			
			self.searchFrame.layer.borderColor = [UIColor whiteColor].CGColor;
			
			if ([self.delegate respondsToSelector:@selector(destinationFrameForSearchBar:)])
			{
				self.originalFrame = self.frame;
				
				self.frame = [self.delegate destinationFrameForSearchBar:self];
			}
			
		} completion:^(BOOL finished) {
			
			//[self.searchField becomeFirstResponder];

			[UIView animateWithDuration:kLKSearchBarAnimationStepDuration * 2 animations:^{
				
				self.searchFrame.layer.backgroundColor = [UIColor whiteColor].CGColor;
				self.searchImageViewOff.alpha = 0.0;
				self.searchImageViewOn.alpha = 1.0;
				self.searchField.alpha = 1.0;
				
			} completion:^(BOOL finished) {
								
				self.state = LKSearchBarStateSearchBarVisible;
				
				if ([self.delegate respondsToSelector:@selector(searchBar:didEndTransitioningFromState:)])
				{
					[self.delegate searchBar:self didEndTransitioningFromState:LKSearchBarStateNormal];
				}
			}];
		}];
	}
}

//- (void)hideSearchBar:(id)sender
//{
//	if (self.state == LKSearchBarStateSearchBarVisible || self.state == LKSearchBarStateSearchBarHasContent)
//	{
//		[self.window endEditing:YES];
//		
//		if ([self.delegate respondsToSelector:@selector(searchBar:willStartTransitioningToState:)])
//		{
//			[self.delegate searchBar:self willStartTransitioningToState:LKSearchBarStateNormal];
//		}
//
//		self.searchField.text = nil;
//		
//		self.state = LKSearchBarStateTransitioning;
//		
//		[UIView animateWithDuration:kLKSearchBarAnimationStepDuration animations:^{
//			
//			if ([self.delegate respondsToSelector:@selector(destinationFrameForSearchBar:)])
//			{
//				self.frame = self.originalFrame;
//			}
//			
//			self.searchFrame.layer.backgroundColor = [UIColor clearColor].CGColor;
//			self.searchImageViewOff.alpha = 1.0;
//			self.searchImageViewOn.alpha = 0.0;
//			self.searchField.alpha = 0.0;
//			
//		} completion:^(BOOL finished) {
//			
//			[UIView animateWithDuration:kLKSearchBarAnimationStepDuration animations:^{
//				
//				self.searchFrame.layer.borderColor = [UIColor clearColor].CGColor;
//				
//			} completion:^(BOOL finished) {
//				
//				self.searchImageCircle.frame = CGRectMake(0.0, 0.0, 18.0, 18.0);
//				self.searchImageCrossLeft.frame = CGRectMake(14.0, 14.0, 8.0, 8.0);
//				self.searchImageCircle.alpha = 0.0;
//				self.searchImageCrossLeft.alpha = 0.0;
//				self.searchImageCrossRight.alpha = 0.0;
//				
//				self.state = LKSearchBarStateNormal;
//				
//				if ([self.delegate respondsToSelector:@selector(searchBar:didEndTransitioningFromState:)])
//				{
//					[self.delegate searchBar:self didEndTransitioningFromState:LKSearchBarStateSearchBarVisible];
//				}
//			}];
//		}];
//	}
//}

#pragma mark - keyboard handling

- (void)keyboardWillShow:(NSNotification *)notification {
	if ([self.searchField isFirstResponder]) {
        if ([self.delegate respondsToSelector:@selector(searchBar:willStartTransitioningToState:)]) {
            [self.delegate searchBar:self willStartTransitioningToState:LKSearchBarStateSearchBarVisible];
        }
        if ([self.delegate respondsToSelector:@selector(searchBarDidBeginEditing:editing:)]) {
            [self.delegate searchBarDidBeginEditing:self editing:YES];
        }
		[self.window addGestureRecognizer:self.keyboardDismissGestureRecognizer];
	}
}

- (void)keyboardWillHide:(NSNotification *)notification {
	if ([self.searchField isFirstResponder]) {
        if ([self.delegate respondsToSelector:@selector(searchBar:willStartTransitioningToState:)]) {
            [self.delegate searchBar:self willStartTransitioningToState:LKSearchBarStateNormal];
        }
        if ([self.delegate respondsToSelector:@selector(searchBarDidBeginEditing:editing:)]) {
            [self.delegate searchBarDidBeginEditing:self editing:NO];
        }
		[self.window removeGestureRecognizer:self.keyboardDismissGestureRecognizer];
	}
}

- (void)dismissKeyboard:(UITapGestureRecognizer *)gestureRecognizer
{
	if ([self.searchField isFirstResponder])
	{
		[self.window endEditing:YES];
		
		if (self.state == LKSearchBarStateSearchBarVisible && self.searchField.text.length == 0)
		{
            [self.searchField resignFirstResponder];
        }
	}
}

#pragma mark - clear button handling

- (void)textDidChange:(NSNotification *)notification
{
	BOOL hasText = self.searchField.text.length != 0;
	
	if (hasText)
	{
		if (self.state == LKSearchBarStateSearchBarVisible)
		{
			self.state = LKSearchBarStateTransitioning;
			
            LC_FAST_ANIMATIONS(0.25, ^{
                
                self.searchImageViewOn.alpha = 0.0;
                self.searchImageCircle.alpha = 1.0;
                self.searchImageCrossLeft.alpha = 1.0;
                self.searchImageCircle.frame = CGRectMake(2.0, 0, 18.0, 18.0);
                self.searchImageCrossLeft.frame = CGRectMake(7.0, 5.0, 8.0, 8.0);
                self.searchImageCrossRight.alpha = 1.0;

            });
            
			
            self.state = LKSearchBarStateSearchBarHasContent;

			[UIView animateWithDuration:kLKSearchBarAnimationStepDuration animations:^{
				
				
				
			} completion:^(BOOL finished) {
				
				[UIView animateWithDuration:kLKSearchBarAnimationStepDuration animations:^{
					
					
				} completion:^(BOOL finished) {
					
				
				}];
			}];
		}
	}
	else
	{
		if (self.state == LKSearchBarStateSearchBarHasContent)
		{
			self.state = LKSearchBarStateTransitioning;
			
            LC_FAST_ANIMATIONS(0.25, ^{

            self.searchImageCrossRight.alpha = 0.0;
            self.searchImageCircle.frame = CGRectMake(0.0, -2, 18.0, 18.0);
            self.searchImageCrossLeft.frame = CGRectMake(14.0, 12.0, 8.0, 8.0);
            self.searchImageViewOn.alpha = 1.0;
            self.searchImageCircle.alpha = 0.0;
            self.searchImageCrossLeft.alpha = 0.0;
            
            });
                
            self.state = LKSearchBarStateSearchBarVisible;

		}
	}
	
	if ([self.delegate respondsToSelector:@selector(searchBarTextDidChange:)])
	{
		[self.delegate searchBarTextDidChange:self];
	}
}

#pragma mark - text field delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	BOOL retVal = YES;
	
	if ([self.delegate respondsToSelector:@selector(searchBarDidTapReturn:)])
	{
		[self.delegate searchBarDidTapReturn:self];
	}
	
	return retVal;
}

#pragma mark - gesture recognizer delegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
	BOOL retVal = YES;

	if (CGRectContainsPoint(self.bounds, [touch locationInView:self]))
	{
		retVal = NO;
	}
	
	return retVal;
}

#pragma mark - cleanup

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:self.searchField];
}

@end
