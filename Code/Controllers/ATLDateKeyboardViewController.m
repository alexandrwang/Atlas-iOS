//
//  ATLDateKeyboardViewController.m
//  Pods
//
//  Created by Jesse Chand on 5/8/16.
//
//

#import "ATLDateKeyboardViewController.h"
#import "ATLCalendarView.h"

@interface ATLDateKeyboardViewController ()

@end

@implementation ATLDateKeyboardViewController {
    ATLCalendarView *_calendarView;
}

- (instancetype)init {
    if (self = [super init]) {
        _calendarView = [[ATLCalendarView alloc] initWithFrame:self.view.bounds];
        _calendarView.clipsToBounds = YES;
        [self.view addSubview:_calendarView];
        self.view.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)viewDidLayoutSubviews {
    _calendarView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
}

@end
