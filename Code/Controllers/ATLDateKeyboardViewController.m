//
//  ATLDateKeyboardViewController.m
//  Pods
//
//  Created by Jesse Chand on 5/8/16.
//
//

#import "ATLDateKeyboardViewController.h"
#import "ATLCalendarView.h"
#import "ATLMessagingUtilities.h"

@interface ATLDateKeyboardViewController () < CalendarDelegate >

@end

@implementation ATLDateKeyboardViewController {
    ATLCalendarView *_calendarView;
}

- (instancetype)init {
    if (self = [super init]) {
        _calendarView = [[ATLCalendarView alloc] initWithFrame:self.view.bounds];
        _calendarView.clipsToBounds = YES;
        _calendarView.delegate = self;
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

@end
