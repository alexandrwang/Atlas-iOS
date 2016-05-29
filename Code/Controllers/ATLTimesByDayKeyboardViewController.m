//
//  ATLTimesByDayKeyboardViewController.m
//  Pods
//
//  Created by Alexandr Wang on 5/28/16.
//
//

#import "ATLMessagingUtilities.h"
#import "ATLTimesByDayKeyboardViewController.h"
#import "ATLTimeKeyboardViewController.h"
#import "MBXPageViewController.h"
#import <objc/runtime.h>
#import <UIKit/UIKit.h>


@interface ATLTimesByDayKeyboardViewController () < MBXPageControllerDataSource, MBXPageControllerDataDelegate, ATLKeyboardDelegate>

@property (strong) UIButton * buttonNext;
@property (strong) UIButton * buttonPrev;
@property (strong) NSArray * timeKeyboardViewControllers;

@end

const CGFloat timeViewMonthLabelHeight = 32.0f;

@implementation ATLTimesByDayKeyboardViewController {
    MBXPageViewController *_pageViewController;
}

- (instancetype)init {

    if (self = [super init]) {
        _dates = [@[@"May 1", @"May 2"] mutableCopy];
        _pageViewController = [MBXPageViewController new];
        _pageViewController.MBXDataSource = self;
        _pageViewController.MBXDataDelegate = self;
        [self setupBottomRow];
        _pageViewController.pageMode = MBX_LeftRightArrows;
        [_pageViewController reloadPages];

        _pageViewController.view.clipsToBounds = YES;
        [self.view addSubview:_pageViewController.view];
        [self.view addSubview:_buttonNext];
        [self.view addSubview:_buttonPrev];
        self.view.backgroundColor = [UIColor whiteColor];
    }


    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Initiate MBXPageController

}

#pragma mark - MBXPageViewController Data Source

- (NSArray *)MBXPageButtons
{
    return @[_buttonPrev, _buttonNext];
}

- (UIView *)MBXPageContainer
{
    return self.view;
}

- (NSArray *)MBXPageControllers
{

    NSMutableArray* viewControllers = [[NSMutableArray alloc] init];
    for (NSString* date in _dates) {
        ATLTimeKeyboardViewController *tkvc = [[ATLTimeKeyboardViewController alloc] init];
        [tkvc setupDateLabel:date];
        tkvc.delegate = self;
        [viewControllers addObject:tkvc];
    }
    _timeKeyboardViewControllers = viewControllers;

    // The order matters.
    return viewControllers;
}

- (void)setupBottomRow {
    UIColor * _monthAndDayTextColor       = [UIColor colorWithRed:0.475 green:0.475 blue:0.475 alpha:1];
    UIFont * _defaultFont = [UIFont fontWithName:@"AvenirNext-Regular" size:12.0f];

    NSBundle *resourcesBundle = ATLResourcesBundle();

    //    UILabel *titleText1=[[UILabel alloc] init];
    //    titleText1.textAlignment = NSTextAlignmentCenter;
    //    titleText1.attributedText = @"June";
    //    [titleText1 setTextColor:[UIColor colorWithRed:0.506 green:0.506 blue:0.506 alpha:1]];
    //    [titleText1 sizeToFit];
    //    [self.view addSubview:titleText1];
    //
    //    UILabel *titleText2=[[UILabel alloc] init];
    //    titleText2.textAlignment = NSTextAlignmentCenter;
    //    titleText2.attributedText = @"2";
    //    [titleText2 setTextColor:[UIColor colorWithRed:0.506 green:0.506 blue:0.506 alpha:1]];
    //    [titleText2 sizeToFit];
    //    [self.view addSubview:titleText2];
    //
    //    CGFloat combinedWidth = titleText1.frame.size.width + titleText2.frame.size.width;
    //    titleText1.frame = CGRectMake((self.view.bounds.size.width - combinedWidth) / 2, self.view.bounds.size.height - timeViewMonthLabelHeight, titleText1.frame.size.width, timeViewMonthLabelHeight);
    //    titleText2.frame = CGRectMake(CGRectGetMaxX(titleText1.frame), self.view.bounds.size.height - timeViewMonthLabelHeight, titleText2.frame.size.width, timeViewMonthLabelHeight);

    // Previous and next button
    CGFloat buttonOffset = 42.0f;

    _buttonPrev = [[UIButton alloc] initWithFrame:CGRectMake(buttonOffset, self.view.bounds.size.height - timeViewMonthLabelHeight, timeViewMonthLabelHeight, timeViewMonthLabelHeight)];
    [_buttonPrev setImage:[UIImage imageNamed:@"previous" inBundle:resourcesBundle compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [_buttonPrev setTitleColor:_monthAndDayTextColor forState:UIControlStateNormal];
    //    [_buttonPrev addTarget:self action:@selector(showPreviousMonth) forControlEvents:UIControlEventTouchUpInside];
    _buttonPrev.titleLabel.font          = _defaultFont;
    [self.view addSubview:_buttonPrev];

    _buttonNext          = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - timeViewMonthLabelHeight - buttonOffset, self.view.bounds.size.height - timeViewMonthLabelHeight, timeViewMonthLabelHeight, timeViewMonthLabelHeight)];
    [_buttonNext setImage:[UIImage imageNamed:@"next" inBundle:resourcesBundle compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [_buttonNext setTitleColor:_monthAndDayTextColor forState:UIControlStateNormal];
    //    [_buttonNext addTarget:self action:@selector(showNextMonth) forControlEvents:UIControlEventTouchUpInside];
    _buttonNext.titleLabel.font          = _defaultFont;
    [self.view addSubview:_buttonNext];

    BOOL enableNext = YES;
    BOOL enablePrev = YES;

    if (![self canSwipeForward])
    {
        _buttonPrev.alpha    = 0.4f;
        _buttonPrev.enabled  = NO;
        enablePrev          = NO;
    }
    if (![self canSwipeBackward])
    {
        _buttonNext.alpha    = 0.4f;
        _buttonNext.enabled  = NO;
        enableNext          = NO;
    }
    //    if (!_allowsChangeMonthByButtons)
    //    {
    //        _buttonNext.hidden = YES;
    //        _buttonPrev.hidden = YES;
    //    }
    //    if (_delegate != nil && [_delegate respondsToSelector:@selector(setEnabledForPrevMonthButton:nextMonthButton:)])
    //        [_delegate setEnabledForPrevMonthButton:enablePrev nextMonthButton:enableNext];
}

- (BOOL) canSwipeForward {
    return YES;
}

- (BOOL) canSwipeBackward {
    return YES;
}

#pragma mark - MBXPageViewController Delegate

- (void)MBXPageChangedToIndex:(NSInteger)index
{
    NSLog(@"%@ %ld", [self class], (long)index);
    if (index == 0) {
        _buttonPrev.hidden = YES;
    } else if (index == [_dates count] - 1) {
        _buttonNext.hidden = YES;
    }

    if (index > 0) {
        _buttonPrev.hidden = NO;
    }
    if (index < [_dates count] - 1) {
        _buttonNext.hidden = NO;
    }
}

- (void)viewDidLayoutSubviews {
    CGFloat buttonOffset = 22.0f;
    _pageViewController.view.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height + 100);
    _buttonPrev.frame = CGRectMake(buttonOffset, self.view.bounds.size.height - timeViewMonthLabelHeight, 152/2, 48/2);
    _buttonNext.frame = CGRectMake(self.view.bounds.size.width - (152/2) - buttonOffset, self.view.bounds.size.height - timeViewMonthLabelHeight, 152/2, 48/2);
}

- (void)updatedSelection:(NSMutableArray *)selection {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMMM d"];

    for (NSDate *date in selection) {
        [result addObject:[formatter stringFromDate:date]];
    }
    self.selection = result;
    [self.delegate keyboard:self withType:ATLKeyboardTypeDate didUpdateSelection:self.selection];
}

#pragma mark - ATLKeyboardDelegate


- (void)keyboard:(ATLKeyboardViewController *)keyboard withType:(ATLKeyboardType)type didUpdateSelection:(NSMutableArray *)selection {

    if (type == ATLKeyboardTypeTime && [keyboard isKindOfClass:ATLTimeKeyboardViewController.class]) {
        NSMutableArray *allTimes = [[NSMutableArray alloc] init];
        BOOL isOneEmpty = NO;
        for (ATLTimeKeyboardViewController* timeKeyboardViewController in _timeKeyboardViewControllers) {
            NSMutableString *string = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"%@ at ", timeKeyboardViewController.date]];
            for (int i = 0; i < timeKeyboardViewController.selection.count; i++) {
                NSString *item = timeKeyboardViewController.selection[i];
                [string appendString:item];
                if (i != selection.count - 1) {
                    [string appendString:@", "];
                }
            }
            if (timeKeyboardViewController.selection.count == 0) {
                isOneEmpty = YES;
            }
            [allTimes addObject:string];
        }

        self.selection = [allTimes copy];

        if (!isOneEmpty) {
            [self.delegate keyboard:self withType:ATLKeyboardTypeTimesByDay didUpdateSelection:self.selection];
        } else {
            [self.delegate keyboard:self withType:ATLKeyboardTypeTimesByDay didUpdateSelection:@[]];
        }
    }
}

#pragma mark - Public methods

- (void)setDates:(NSMutableArray *)dates {
    // basically reconstruct the whole view
    _dates = dates;
    [_pageViewController.view removeFromSuperview];
    //    [_buttonPrev removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    //    [_buttonNext removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    //    [_buttonNext removeFromSuperview];
    //    [_buttonPrev removeFromSuperview];

    _pageViewController = [MBXPageViewController new];
    _pageViewController.MBXDataSource = self;
    _pageViewController.MBXDataDelegate = self;
    _pageViewController.pageMode = MBX_LeftRightArrows;
    [_pageViewController reloadPages];
    _pageViewController.view.clipsToBounds = YES;

    [self.view addSubview:_pageViewController.view];
    [self.view addSubview:_buttonNext];
    [self.view addSubview:_buttonPrev];
    
    // Hide buttons if they can't do anything
    _buttonPrev.hidden = YES;
    if ([_dates count] <= 1) {
        _buttonNext.hidden = YES;
    } else {
        _buttonNext.hidden = NO;
    }
    
    _buttonNext.layer.zPosition = 1;
    _buttonPrev.layer.zPosition = 1;
    
    //    [self viewDidLayoutSubviews];
}

@end