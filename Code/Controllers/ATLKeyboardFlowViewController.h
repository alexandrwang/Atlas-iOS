//
//  ATLKeyboardFlowViewController.h
//  Pods
//
//  Created by Jesse Chand on 5/17/16.
//
//

#import <UIKit/UIKit.h>
#import "ATLMessagingUtilities.h"

@protocol ATLKeyboardFlowViewControllerDelegate;

@interface ATLKeyboardFlowViewController : UIPageViewController

- (void)changePageInDirection:(UIPageViewControllerNavigationDirection)direction;
- (void)changePageToIndex:(NSInteger)index;
- (BOOL)isSubmittable;
- (void)fillInAllFields;
- (void)resetMessageField;
- (NSArray*)getSelectionsArray;
- (NSInteger*)keyboardCount;

@property (nonatomic, weak) id<ATLKeyboardFlowViewControllerDelegate> flowDelegate;
@property (nonatomic, assign) NSUInteger keyboardIndex;
@property (nonatomic, assign) ATLKeyboardType keyboardType;
@property (nonatomic, copy) NSAttributedString *message;

@end

#pragma mark - ATLKeyboardFlowViewControllerDelegate

@protocol ATLKeyboardFlowViewControllerDelegate

- (void)presentLocationViewController:(UINavigationController *)controller;
- (void)popUpCustomKeyboard;
- (void)keyboardFlowViewController:(ATLKeyboardFlowViewController *)controller didChangeToPage:(NSUInteger)page withType:(ATLKeyboardType)type;
- (void)keyboardFlowViewController:(ATLKeyboardFlowViewController *)controller didUpdateSelection:(NSMutableArray *)selection;

@end