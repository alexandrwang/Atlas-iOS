//
//  ATLKeyboardFlowViewController.m
//  Pods
//
//  Created by Jesse Chand on 5/17/16.
//
//

#import "ATLKeyboardFlowViewController.h"

#import "ATLDateKeyboardViewController.h"
#import "ATLPillKeyboardViewController.h"
#import "ATLTimeKeyboardViewController.h"
#import "ATLLocationKeyboardViewController.h"

@interface ATLKeyboardFlowViewController ()

@end

@implementation ATLKeyboardFlowViewController {
    NSArray *_keyboardArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    ATLDateKeyboardViewController *vc1 = [[ATLDateKeyboardViewController alloc] init];
    ATLPillKeyboardViewController *vc2 = [[ATLPillKeyboardViewController alloc] init];
    ATLTimeKeyboardViewController *vc3 = [[ATLTimeKeyboardViewController alloc] init];
    ATLLocationKeyboardViewController *vc4 = [[ATLLocationKeyboardViewController alloc] init];
    _keyboardArray = @[vc2, vc1, vc4, vc3];

    _keyboardIndex = 0;
    [self setViewControllers:@[_keyboardArray[_keyboardIndex]]
                   direction:UIPageViewControllerNavigationDirectionForward
                    animated:YES
                  completion:^(BOOL finished) {}];
}

#pragma mark - Switch Pages

- (void)changePageInDirection:(UIPageViewControllerNavigationDirection)direction {
    if ((direction == UIPageViewControllerNavigationDirectionForward && _keyboardIndex < (_keyboardArray.count - 1)) ||
        (direction == UIPageViewControllerNavigationDirectionReverse && _keyboardIndex > 0)) {
        _keyboardIndex = (direction == UIPageViewControllerNavigationDirectionForward ? _keyboardIndex + 1 : _keyboardIndex - 1);
        [self.flowDelegate keyboardFlowViewController:self didChangeToPage:_keyboardIndex];
        [self setViewControllers:@[_keyboardArray[_keyboardIndex]]
                       direction:direction
                        animated:YES
                      completion:^(BOOL finished) {}];
    }
}

@end
