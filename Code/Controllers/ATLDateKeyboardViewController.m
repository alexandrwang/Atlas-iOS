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
#import "FSCalendar.h"
#import "ATLConstants.h"

@interface ATLDateKeyboardViewController () < CalendarDelegate >

@end

@implementation ATLDateKeyboardViewController {
    //    ATLCalendarView *_calendarView;
    FSCalendar *_fscalendarView;
}

- (instancetype)init {
    if (self = [super init]) {
        //        _calendarView = [[ATLCalendarView alloc] initWithFrame:self.view.bounds];
        //        _calendarView.clipsToBounds = YES;
        //        _calendarView.delegate = self;
        //        [self.view addSubview:_calendarView];
        self.view.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _fscalendarView = [[FSCalendar alloc] initWithFrame:CGRectMake(0, 0,self.view.bounds.size.width, self.view.bounds.size.height)];
    _fscalendarView.dataSource = self;
    _fscalendarView.delegate = self;
    _fscalendarView.pagingEnabled = NO;
    _fscalendarView.scrollEnabled = YES;
    _fscalendarView.allowsMultipleSelection = YES;
    _fscalendarView.showsPlaceholders = YES;
    //    _fscalendarView.scope = FSCalendarScopeWeek;
    
    _fscalendarView.appearance.weekdayTextColor = ATLBlueColor();
    _fscalendarView.appearance.headerTitleColor = ATLBlueColor();
    //    _fscalendarView.appearance.eventColor = [UIColor greenColor];
    _fscalendarView.appearance.titlePlaceholderColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1];
    _fscalendarView.appearance.titleDefaultColor = [UIColor colorWithRed:0.475 green:0.475 blue:0.475 alpha:1];
    _fscalendarView.appearance.selectionColor = ATLBlueColor();
    _fscalendarView.appearance.todayColor = [UIColor clearColor];
    _fscalendarView.appearance.titleTodayColor = ATLBlueColor();
    _fscalendarView.appearance.todaySelectionColor = ATLBlueColor();
    
    [_fscalendarView setCurrentPage:[NSDate date] animated:NO];
    
    _fscalendarView.appearance.weekdayFont = [UIFont fontWithName:@"AvenirNext-Regular" size:12.0f];
    _fscalendarView.appearance.headerTitleFont = [UIFont fontWithName:@"AvenirNext-Regular" size:12.0f];
    _fscalendarView.appearance.titleFont = [UIFont fontWithName:@"AvenirNext-Regular" size:12.0f];
    
    [self.view addSubview:_fscalendarView];
}

- (void)viewDidLayoutSubviews {
    //    _calendarView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
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

- (NSDate *)minimumDateForCalendar:(FSCalendar *)calendar {
    NSDate *today = [NSDate date];
    
    // All intervals taken from Google
    NSDate *yesterday = [today dateByAddingTimeInterval: -86400.0];
    return today;
}

- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date {
    NSLog(@"selected dates: %@", calendar.selectedDates);
    [self updatedSelection:calendar.selectedDates];
}

- (void)calendar:(FSCalendar *)calendar didDeselectDate:(NSDate *)date {
    NSLog(@"selected dates: %@", calendar.selectedDates);
    [self updatedSelection:calendar.selectedDates];
}

@end
