//
//  ATLKeyboardFlowViewController.h
//  Pods
//
//  Created by Jesse Chand on 5/17/16.
//
//

#import <UIKit/UIKit.h>

@protocol ATLKeyboardFlowViewControllerDelegate;

@interface ATLKeyboardFlowViewController : UIPageViewController

- (void)changePageInDirection:(UIPageViewControllerNavigationDirection)direction;

@property (nonatomic, weak) id<ATLKeyboardFlowViewControllerDelegate> flowDelegate;
@property (nonatomic, assign) NSUInteger keyboardIndex;

@end

#pragma mark - ATLKeyboardFlowViewControllerDelegate

@protocol ATLKeyboardFlowViewControllerDelegate

- (void)keyboardFlowViewController:(ATLKeyboardFlowViewController *)controller didChangeToPage:(NSUInteger)page;

@end