//
//  UIViewController+ZDBackButtonHandler.m
//  UINavigationControllerStudy
//
//  Created by Zero on 15/10/30.
//  Copyright © 2015年 Zero.D.Saber. All rights reserved.
//

#import "UIViewController+ZDBack.h"

@implementation UIViewController (ZDBack)

@end

@implementation UINavigationController (ShouldPopOnBackButton)

- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item
{
	if ([self.viewControllers count] < [navigationBar.items count]) {
		return YES;
	}

	BOOL shouldPop = YES;
	UIViewController *vc = [self topViewController];

	if ([vc respondsToSelector:@selector(navigationControllerShouldPop:)]) {
		shouldPop = [vc navigationControllerShouldPop:self];
	}

	if (shouldPop) {
		dispatch_async(dispatch_get_main_queue(), ^{
			[self popViewControllerAnimated:YES];
		});
	}
	else {
		// Workaround for iOS7.1. Thanks to @boliva - http://stackoverflow.com/posts/comments/34452906
		for (UIView *subview in [navigationBar subviews]) {
			if (subview.alpha < 1.) {
				[UIView animateWithDuration:.25 animations:^{
					subview.alpha = 1.;
				}];
			}
		}
	}

	return NO;
}

- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPushItem:(UINavigationItem *)item
{
	UIViewController *viewController = self.viewControllers.count > 1 ?	\
		[self.viewControllers objectAtIndex:self.viewControllers.count - 2] : nil;

	if (!viewController) {
		return YES;
	}

	NSString *backButtonTitle = nil;

	if ([viewController respondsToSelector:@selector(navigationItemBackBarButtonTitle)]) {
		backButtonTitle = [viewController navigationItemBackBarButtonTitle];
	}

	if (!backButtonTitle) {
		backButtonTitle = viewController.title;
	}

	UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithTitle:backButtonTitle
		style:UIBarButtonItemStylePlain
		target:nil action:nil];
	viewController.navigationItem.backBarButtonItem = backButtonItem;

	return YES;
}

@end
