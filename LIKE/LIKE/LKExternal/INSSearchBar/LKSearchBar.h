//
//  LKSearchBar.h
//  Berlin Insomniac
//
//  Created by Salánki, Benjámin on 06/03/14.
//  Copyright (c) 2014 Berlin Insomniac. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  The different states for an LKSearchBarState.
 */

typedef NS_ENUM(NSUInteger, LKSearchBarState)
{
	/**
	 *  The default or normal state. The search field is hidden.
	 */
	
	LKSearchBarStateNormal = 0,
	
	/**
	 *  The state where the search field is visible.
	 */
	
	LKSearchBarStateSearchBarVisible,

	/**
	 *  The state where the search field is visible and there is text entered.
	 */
	
	LKSearchBarStateSearchBarHasContent,

	/**
	 *  The search bar is transitioning between states.
	 */
	
	LKSearchBarStateTransitioning
};

@class LKSearchBar;

/**
 *  The delegate is responsible for providing values to the search bar that it can use to determine its size.
 */

@protocol LKSearchBarDelegate <NSObject>

@optional
/**
 *  The delegate is asked to provide the destination frame for the search bar when the search bar is transitioning to the visible state.
 *
 *  @param searchBar The search bar that will begin transitioning.
 *
 *  @return The frame in the coordinate system of the search bar's superview.
 */

- (CGRect)destinationFrameForSearchBar:(LKSearchBar *)searchBar;

/**
 *  The delegate is informed about the imminent state transitioning of the status bar.
 *
 *  @param searchBar        The search bar that will begin transitioning.
 *  @param destinationState The state that the bar will be in once transitioning completes. The current state of the search bar can be queried and will return the state before transitioning.
 */

- (void)searchBar:(LKSearchBar *)searchBar willStartTransitioningToState:(LKSearchBarState)destinationState;

/**
 *  The delegate is informed about the state transitioning of the status bar that has just occured.
 *
 *  @param searchBar        The search bar that went through state transitioning.
 *  @param destinationState The state that the bar was in before transitioning started. The current state of the search bar can be queried and will return the state after transitioning.
 */

- (void)searchBar:(LKSearchBar *)searchBar didEndTransitioningFromState:(LKSearchBarState)previousState;

/**
 *  The delegate is informed that the search bar's return key was pressed. This should be used to start querries.
 *
 *  Important: If the searchField property is explicitly supplied with a delegate property this method will not be called.
 *
 *  @param searchBar        The search bar whose return key was pressed.
 */

- (void)searchBarDidTapReturn:(LKSearchBar *)searchBar;

/**
 *  The delegate is informed that the search bar's text has changed.
 *
 *  Important: If the searchField property is explicitly supplied with a delegate property this method will not be called.
 *
 *  @param searchBar        The search bar whose text did change.
 */

- (void)searchBarTextDidChange:(LKSearchBar *)searchBar;

- (void)searchBarDidBeginEditing:(LKSearchBar *)searchBar editing:(BOOL)editing;

@end

/**
 *  An animating search bar.
 */

@interface LKSearchBar : UIView

/**
 *  The current state of the search bar.
 */

@property (nonatomic, readonly) LKSearchBarState state;

/**
 *  The text field used for entering search queries. Visible only when search is active.
 */

@property (nonatomic, readonly) UITextField *searchField;

/**
 *  The (optional) delegate is responsible for providing values necessary for state change animations of the search bar. @see LKSearchBarDelegate.
 */

@property (nonatomic, weak) id<LKSearchBarDelegate>	delegate;

@end
