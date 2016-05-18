#import "ATLCalendarView.h"
#import "ATLConstants.h"
#import "ATLMessagingUtilities.h"

@interface ATLCalendarView() < UIScrollViewDelegate >

@property (nonatomic, strong) NSCalendar *gregorian;
@property (nonatomic, strong) NSDate *selectedDate;
@property (nonatomic, assign) NSInteger dayWidth;
@property (nonatomic, assign) NSCalendarUnit dayInfoUnits;
@property (nonatomic, strong) NSArray *weekDayNames;
@property (nonatomic, assign) NSInteger shakes;
@property (nonatomic, assign) NSInteger shakeDirection;
@property (nonatomic, strong) UISwipeGestureRecognizer *swipeleft;
@property (nonatomic, strong) UISwipeGestureRecognizer *swipeRight;
@property (nonatomic, copy) NSMutableArray *selectedDates;

@end

const CGFloat kMonthLabelHeight = 32.0f;

@implementation ATLCalendarView {
    UIScrollView *_dateScrollView;
    int _numberOfRows;
    CGFloat _scrollPosition;
    UIView *_hairlineView;
}

#pragma mark - Init methods

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = NO;
        _dayWidth                   = frame.size.width / 7;
        _originX                    = (frame.size.width - 7 *_dayWidth) / 2;
        _gregorian                  = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        _borderWidth                = 1.0f;
        _originY                    = 0;
        _calendarDate               = [NSDate date];
        _dayInfoUnits               = NSEraCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
        _monthAndDayTextColor       = [UIColor colorWithRed:0.475 green:0.475 blue:0.475 alpha:1];
        _dayBgColorWithoutData      = [UIColor colorWithRed:0.984 green:0.984 blue:0.984 alpha:1];
        _dayBgColorWithData         = [UIColor colorWithRed:0.984 green:0.984 blue:0.984 alpha:1];
        _dayBgColorSelected         = ATLBlueColor();
        _dayTxtColorWithoutData     = [UIColor colorWithRed:0.475 green:0.475 blue:0.475 alpha:1];;
        _dayTxtColorWithData        = [UIColor colorWithRed:0.475 green:0.475 blue:0.475 alpha:1];
        _dayTxtColorSelected        = [UIColor whiteColor];
        _borderColor                = [UIColor whiteColor];
        _allowsChangeMonthByDayTap  = NO;
        _allowsChangeMonthByButtons = YES;
        _allowsChangeMonthBySwipe   = NO;
        _hideMonthLabel             = NO;
        _keepSelDayWhenMonthChange  = YES;
        _nextMonthAnimation         = UIViewAnimationOptionTransitionNone;
        _prevMonthAnimation         = UIViewAnimationOptionTransitionNone;
        _defaultFont                = [UIFont fontWithName:@"AvenirNext-Regular" size:12.0f];
        _titleFont                  = [UIFont fontWithName:@"Helvetica-Bold" size:15.0f];

        _swipeleft = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(showNextMonth)];
        _swipeleft.direction=UISwipeGestureRecognizerDirectionLeft;
        //[self addGestureRecognizer:_swipeleft];
        _swipeRight = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(showPreviousMonth)];
        _swipeRight.direction=UISwipeGestureRecognizerDirectionRight;
        //[self addGestureRecognizer:_swipeRight];

        NSDateComponents *components = [_gregorian components:_dayInfoUnits fromDate:[NSDate date]];
        components.hour         = 0;
        components.minute       = 0;
        components.second       = 0;

        _selectedDate = [_gregorian dateFromComponents:components];
        _selectedDates = [[NSMutableArray alloc] init];
        [_selectedDates addObject:_selectedDate];

        NSArray * shortWeekdaySymbols = [[[NSDateFormatter alloc] init] shortWeekdaySymbols];
        NSMutableArray *weekdaySymbols = [[NSMutableArray alloc] init];
        for (NSString *string in shortWeekdaySymbols) {
            [weekdaySymbols addObject:[string uppercaseString]];
        }

        _weekDayNames  = @[weekdaySymbols[1], weekdaySymbols[2], weekdaySymbols[3], weekdaySymbols[4],
                           weekdaySymbols[5], weekdaySymbols[6], weekdaySymbols[0]];

        self.backgroundColor = [UIColor whiteColor];

        _hairlineView = [[UIView alloc] init];
        _hairlineView.backgroundColor = [UIColor colorWithWhite:0.8f alpha:1.0f];
        [self addSubview:_hairlineView];
    }
    return self;
}

- (id)init {
    self = [self initWithFrame:CGRectMake(0, 0, 320, 400)];
    if (self) {
    }
    return self;
}

#pragma mark - Custom setters

- (void)setAllowsChangeMonthByButtons:(BOOL)allows
{
    _allowsChangeMonthByButtons = allows;
    [self setNeedsDisplay];
}

- (void)setAllowsChangeMonthBySwipe:(BOOL)allows
{
    _allowsChangeMonthBySwipe   = allows;
    _swipeleft.enabled          = allows;
    _swipeRight.enabled         = allows;
}

- (void)setHideMonthLabel:(BOOL)hideMonthLabel
{
    _hideMonthLabel = hideMonthLabel;
    [self setNeedsDisplay];
}

-(void)setSelectedDate:(NSDate *)selectedDate
{
    _selectedDate = selectedDate;
    [self setNeedsDisplay];
}

- (void)setCalendarDate:(NSDate *)calendarDate
{
    _calendarDate = calendarDate;
    [self setNeedsDisplay];
}


#pragma mark - Public methods

- (void)showNextMonth
{
    NSDateComponents *components = [_gregorian components:_dayInfoUnits fromDate:_calendarDate];
    components.day = 1;
    components.month ++;
    NSDate * nextMonthDate =[_gregorian dateFromComponents:components];

    if ([self canSwipeToDate:nextMonthDate])
    {
        _scrollPosition = 0;
        [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        _calendarDate = nextMonthDate;
        components = [_gregorian components:_dayInfoUnits fromDate:_calendarDate];

        if (!_keepSelDayWhenMonthChange)
        {
            _selectedDate = [_gregorian dateFromComponents:components];
        }
        [self performViewAnimation:_nextMonthAnimation];
    }
    else
    {
        [self performViewNoSwipeAnimation];
    }
}


- (void)showPreviousMonth
{
    NSDateComponents *components = [_gregorian components:_dayInfoUnits fromDate:_calendarDate];
    components.day = 1;
    components.month --;
    NSDate * prevMonthDate = [_gregorian dateFromComponents:components];

    if ([self canSwipeToDate:prevMonthDate])
    {
        _scrollPosition = 0;
        [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        _calendarDate = prevMonthDate;
        components = [_gregorian components:_dayInfoUnits fromDate:_calendarDate];

        if (!_keepSelDayWhenMonthChange)
        {
            _selectedDate = [_gregorian dateFromComponents:components];
        }
        [self performViewAnimation:_prevMonthAnimation];
    }
    else
    {
        [self performViewNoSwipeAnimation];
    }
}

#pragma mark - Various methods

- (NSInteger)buttonTagForDate:(NSDate *)date
{
    NSDateComponents * componentsDate       = [_gregorian components:_dayInfoUnits fromDate:date];
    NSDateComponents * componentsDateCal    = [_gregorian components:_dayInfoUnits fromDate:_calendarDate];

    if (componentsDate.month == componentsDateCal.month && componentsDate.year == componentsDateCal.year)
    {
        // Both dates are within the same month : buttonTag = day
        return componentsDate.day;
    }
    else
    {
        //  buttonTag = deltaMonth * 40 + day
        NSInteger offsetMonth =  (componentsDate.year - componentsDateCal.year)*12 + (componentsDate.month - componentsDateCal.month);
        return componentsDate.day + offsetMonth*40;
    }
}

- (BOOL)canSwipeToDate:(NSDate *)date
{
    if (_datasource == nil)
        return YES;
    return [_datasource canSwipeToDate:date];
}

- (void)performViewAnimation:(UIViewAnimationOptions)animation
{
    NSDateComponents * components = [_gregorian components:_dayInfoUnits fromDate:_selectedDate];

    NSDate *clickedDate = [_gregorian dateFromComponents:components];
    [_delegate dayChangedToDate:clickedDate];

    [UIView transitionWithView:self
                      duration:0.5f
                       options:animation
                    animations:^ { [self setNeedsDisplay]; }
                    completion:nil];
}

- (void)performViewNoSwipeAnimation
{
    _shakeDirection = 1;
    _shakes = 0;
    [self shakeView:self];
}

- (void)shakeView:(UIView *)theOneYouWannaShake
{
    [UIView animateWithDuration:0.05 animations:^
     {
         theOneYouWannaShake.transform = CGAffineTransformMakeTranslation(5*_shakeDirection, 0);

     } completion:^(BOOL finished)
     {
         if(_shakes >= 4)
         {
             theOneYouWannaShake.transform = CGAffineTransformIdentity;
             return;
         }
         _shakes++;
         _shakeDirection = _shakeDirection * -1;
         [self shakeView:theOneYouWannaShake];
     }];
}

#pragma mark - Button creation and configuration

- (UIButton *)dayButtonWithFrame:(CGRect)frame
{
    UIButton *button                = [UIButton buttonWithType:UIButtonTypeCustom];
    button.titleLabel.font          = _defaultFont;
    button.frame                    = frame;
    button.layer.borderColor        = _borderColor.CGColor;
    [button     addTarget:self action:@selector(tappedDate:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)configureDayButton:(UIButton *)button withDate:(NSDate*)date
{
    NSDateComponents *components = [_gregorian components:_dayInfoUnits fromDate:date];
    [button setTitle:[NSString stringWithFormat:@"%ld",(long)components.day] forState:UIControlStateNormal];
    button.tag = [self buttonTagForDate:date];

    BOOL isSelected = NO;
    for (NSDate *current in _selectedDates) {
        if ([current compare:date] == NSOrderedSame) {
            button.layer.borderWidth = 0;
            [button setTitleColor:_dayTxtColorSelected forState:UIControlStateNormal];
            [button setBackgroundColor:_dayBgColorSelected];
            isSelected = YES;
            break;
        }
    }

    if (!isSelected) {
        // Unselected button
        button.layer.borderWidth = _borderWidth/2.f;
        [button setTitleColor:_dayTxtColorWithoutData forState:UIControlStateNormal];
        [button setBackgroundColor:_dayBgColorWithoutData];

        if (_datasource != nil && [_datasource isDataForDate:date])
        {
            [button setTitleColor:_dayTxtColorWithData forState:UIControlStateNormal];
            [button setBackgroundColor:_dayBgColorWithData];
        }
    }

    NSDateComponents *componentsDateCal = [_gregorian components:_dayInfoUnits fromDate:_calendarDate];
    if (components.month != componentsDateCal.month)
        button.titleLabel.alpha = 0.33f;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (_dateScrollView.contentOffset.y != 0) {
        _scrollPosition = _dateScrollView.contentOffset.y;
    }
}

#pragma mark - Action methods

- (IBAction)tappedDate:(UIButton *)sender
{
    NSDateComponents *components = [_gregorian components:_dayInfoUnits fromDate:_calendarDate];

    if (sender.tag < 0 || sender.tag >= 40)
    {
        // The day tapped is in another month than the one currently displayed

        if (!_allowsChangeMonthByDayTap)
            return;

        NSInteger offsetMonth   = (sender.tag < 0)?-1:1;
        NSInteger offsetTag     = (sender.tag < 0)?40:-40;

        // otherMonthDate set to beginning of the next/previous month
        components.day = 1;
        components.month += offsetMonth;
        NSDate * otherMonthDate =[_gregorian dateFromComponents:components];

        if ([self canSwipeToDate:otherMonthDate])
        {
            [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            _calendarDate = otherMonthDate;

            // New selected date set to the day tapped
            components.day = sender.tag + offsetTag;
            _selectedDate = [_gregorian dateFromComponents:components];

            UIViewAnimationOptions animation = (offsetMonth >0) ? _nextMonthAnimation:_prevMonthAnimation;

            // Animate the transition
            [self performViewAnimation:animation];
        }
        else
        {
            [self performViewNoSwipeAnimation];
        }
        return;
    }

    // Day taped within the the displayed month
    NSDateComponents * componentsDateSel = [_gregorian components:_dayInfoUnits fromDate:_selectedDate];

    // We redifine the selected day
    componentsDateSel.day       = sender.tag;
    componentsDateSel.month     = components.month;
    componentsDateSel.year      = components.year;
    _selectedDate               = [_gregorian dateFromComponents:componentsDateSel];

    if ([_selectedDates containsObject:_selectedDate]) {
        [_selectedDates removeObject:_selectedDate];
    } else {
        [_selectedDates addObject:_selectedDate];
    }
    [self setNeedsDisplay];

    // Configure  the new selected day button
    [self configureDayButton:sender withDate:_selectedDate];

    // Finally, notify the delegate
    [_delegate dayChangedToDate:_selectedDate];

}

- (void)layoutSubviews {
    CGFloat dayHeight = (self.bounds.size.height - kMonthLabelHeight) / 5.0f;
    _dateScrollView.frame = CGRectMake(0, dayHeight, _dayWidth * 7, dayHeight * 4);
    _dateScrollView.contentSize = CGSizeMake(_dayWidth * 7, dayHeight * _numberOfRows);
    _dateScrollView.contentOffset = CGPointMake(0, _scrollPosition);

    _hairlineView.frame = CGRectMake(0, 0, self.bounds.size.width, 1.0f / [[UIScreen mainScreen] nativeScale]);
}

#pragma mark - Drawing methods

- (void)drawRect:(CGRect)rect
{
    CGFloat dayHeight = (self.bounds.size.height - kMonthLabelHeight) / 5.0f;
    [_dateScrollView removeFromSuperview];
    _dateScrollView = [[UIScrollView alloc] init];
    _dateScrollView.delegate = self;
    _dateScrollView.translatesAutoresizingMaskIntoConstraints = YES;
    [self addSubview:_dateScrollView];
    _dateScrollView.frame = CGRectMake(0, dayHeight, _dayWidth * 7, dayHeight * 4);
    _dateScrollView.contentSize = CGSizeMake(_dayWidth * 7, dayHeight * 6);
    [_dateScrollView setAlwaysBounceHorizontal:NO];
    [_dateScrollView setAlwaysBounceVertical:YES];

    NSDateComponents *components = [_gregorian components:_dayInfoUnits fromDate:_calendarDate];
    components.day = 1;
    NSDate *firstDayOfMonth         = [_gregorian dateFromComponents:components];
    NSDateComponents *comps         = [_gregorian components:NSWeekdayCalendarUnit fromDate:firstDayOfMonth];

    NSInteger weekdayBeginning      = [comps weekday];  // Starts at 1 on Sunday
    weekdayBeginning -=2;
    if(weekdayBeginning < 0)
        weekdayBeginning += 7;                          // Starts now at 0 on Monday

    NSRange days = [_gregorian rangeOfUnit:NSDayCalendarUnit
                                    inUnit:NSMonthCalendarUnit
                                   forDate:_calendarDate];

    NSInteger monthLength = days.length;
    NSInteger remainingDays = (monthLength + weekdayBeginning) % 7;


    // Frame drawing
    NSInteger minY = _originY + _dayWidth;
    NSInteger maxY = _originY + _dayWidth * (NSInteger)(1+(monthLength+weekdayBeginning)/7) + ((remainingDays !=0)? _dayWidth:0);

    if (_delegate != nil && [_delegate respondsToSelector:@selector(setHeightNeeded:)])
        [_delegate setHeightNeeded:maxY];

    CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSetFillColorWithColor(context, _borderColor.CGColor);
    CGContextAddRect(context, CGRectMake(_originX - _borderWidth/2.f, minY - _borderWidth/2.f, 7*_dayWidth + _borderWidth, _borderWidth));
    CGContextAddRect(context, CGRectMake(_originX - _borderWidth/2.f, maxY - _borderWidth/2.f, 7*_dayWidth + _borderWidth, _borderWidth));
    CGContextAddRect(context, CGRectMake(_originX - _borderWidth/2.f, minY - _borderWidth/2.f, _borderWidth, maxY - minY));
    CGContextAddRect(context, CGRectMake(_originX + 7*_dayWidth - _borderWidth/2.f, minY - _borderWidth/2.f, _borderWidth, maxY - minY));
    CGContextFillPath(context);
    CGColorSpaceRelease(baseSpace), baseSpace = NULL;

    // Day labels
    __block CGRect frameWeekLabel = CGRectMake(0, _originY, _dayWidth, dayHeight);
    [_weekDayNames  enumerateObjectsUsingBlock:^(NSString * dayOfWeekString, NSUInteger idx, BOOL *stop)
     {
         frameWeekLabel.origin.x         = _originX+(_dayWidth*idx);
         UILabel *weekNameLabel          = [[UILabel alloc] initWithFrame:frameWeekLabel];
         weekNameLabel.text              = dayOfWeekString;
         weekNameLabel.textColor         = _monthAndDayTextColor;
         weekNameLabel.font              = [UIFont fontWithName:@"AvenirNext-UltraLight" size:12.0f];
         weekNameLabel.backgroundColor   = [UIColor clearColor];
         weekNameLabel.textAlignment     = NSTextAlignmentCenter;
         [self addSubview:weekNameLabel];
     }];

    // Current month
    for (NSInteger i= 0; i<monthLength; i++)
    {
        components.day      = i+1;
        NSInteger offsetX   = (_dayWidth*((i+weekdayBeginning)%7));
        NSInteger offsetY   = (dayHeight *((i+weekdayBeginning)/7));
        _numberOfRows = 1 + (i+weekdayBeginning)/7;
        UIButton *button    = [self dayButtonWithFrame:CGRectMake(_originX+offsetX, _originY+offsetY, _dayWidth, dayHeight)];

        [self configureDayButton:button withDate:[_gregorian dateFromComponents:components]];
        [_dateScrollView addSubview:button];
    }

    // Previous month
    NSDateComponents *previousMonthComponents = [_gregorian components:_dayInfoUnits fromDate:_calendarDate];
    previousMonthComponents.month --;
    NSDate *previousMonthDate = [_gregorian dateFromComponents:previousMonthComponents];
    NSRange previousMonthDays = [_gregorian rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:previousMonthDate];
    NSInteger maxDate = previousMonthDays.length - weekdayBeginning;
    for (int i=0; i<weekdayBeginning; i++)
    {
        previousMonthComponents.day     = maxDate+i+1;
        NSInteger offsetX               = (_dayWidth*(i%7));
        NSInteger offsetY               = (dayHeight *(i/7));
        UIButton *button                = [self dayButtonWithFrame:CGRectMake(_originX+offsetX, _originY+offsetY, _dayWidth, dayHeight)];

        [self configureDayButton:button withDate:[_gregorian dateFromComponents:previousMonthComponents]];
        [_dateScrollView addSubview:button];
    }

    // Next month
    if (remainingDays != 0) {
        NSDateComponents *nextMonthComponents = [_gregorian components:_dayInfoUnits fromDate:_calendarDate];
        nextMonthComponents.month ++;

        for (NSInteger i=remainingDays; i<7; i++)
        {
            nextMonthComponents.day         = (i+1)-remainingDays;
            NSInteger offsetX               = (_dayWidth*((i) %7));
            NSInteger offsetY               = (dayHeight *((monthLength+weekdayBeginning)/7));
            UIButton *button                = [self dayButtonWithFrame:CGRectMake(_originX+offsetX, _originY+offsetY, _dayWidth, dayHeight)];

            [self configureDayButton:button withDate:[_gregorian dateFromComponents:nextMonthComponents]];
            [_dateScrollView addSubview:button];
        }
    }

    // Month label
    NSDateFormatter *format1 = [[NSDateFormatter alloc] init];
    [format1 setDateFormat:@"MMMM"];
    NSString *dateString1 = [[format1 stringFromDate:_calendarDate] uppercaseString];
    NSMutableAttributedString *attrString1 = [[NSMutableAttributedString alloc] initWithString:dateString1 attributes:@{NSFontAttributeName:[UIFont fontWithName:@"AvenirNext-Bold" size:16.0f]}];
    NSDateFormatter *format2 = [[NSDateFormatter alloc] init];
    [format2 setDateFormat:@" yyyy"];
    NSString *dateString2 = [[format2 stringFromDate:_calendarDate] uppercaseString];
    NSMutableAttributedString *attrString2 = [[NSMutableAttributedString alloc] initWithString:dateString2 attributes:@{NSFontAttributeName:[UIFont fontWithName:@"AvenirNext-UltraLight" size:16.0f]}];
    [[attrString1 mutableString] appendString:[attrString2 mutableString]];

    UILabel *titleText = [[UILabel alloc] initWithFrame:CGRectMake(0, self.bounds.size.height - kMonthLabelHeight, self.bounds.size.width, kMonthLabelHeight)];
    titleText.textAlignment = NSTextAlignmentCenter;
    titleText.attributedText = attrString1;
    titleText.textColor = [UIColor colorWithRed:0.506 green:0.506 blue:0.506 alpha:1];
    [self addSubview:titleText];

    //if (_delegate != nil && [_delegate respondsToSelector:@selector(setMonthLabel:)])
    //    [_delegate setMonthLabel:[NSString stringWithFormat:@"%@%@", dateString1, dateString2]];

    // Previous and next button
    CGFloat buttonOffset = 42.0f;

    NSBundle *resourcesBundle = ATLResourcesBundle();
    UIButton * buttonPrev          = [[UIButton alloc] initWithFrame:CGRectMake(buttonOffset, self.bounds.size.height - kMonthLabelHeight, kMonthLabelHeight, kMonthLabelHeight)];
    [buttonPrev setImage:[UIImage imageNamed:@"arrow" inBundle:resourcesBundle compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [buttonPrev setTitleColor:_monthAndDayTextColor forState:UIControlStateNormal];
    [buttonPrev addTarget:self action:@selector(showPreviousMonth) forControlEvents:UIControlEventTouchUpInside];
    buttonPrev.titleLabel.font          = _defaultFont;
    buttonPrev.imageView.transform = CGAffineTransformMakeScale(-1, 1);
    [self addSubview:buttonPrev];

    UIButton * buttonNext          = [[UIButton alloc] initWithFrame:CGRectMake(self.bounds.size.width - kMonthLabelHeight - buttonOffset, self.bounds.size.height - kMonthLabelHeight, kMonthLabelHeight, kMonthLabelHeight)];
    [buttonNext setImage:[UIImage imageNamed:@"arrow" inBundle:resourcesBundle compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [buttonNext setTitleColor:_monthAndDayTextColor forState:UIControlStateNormal];
    [buttonNext addTarget:self action:@selector(showNextMonth) forControlEvents:UIControlEventTouchUpInside];
    buttonNext.titleLabel.font          = _defaultFont;
    [self addSubview:buttonNext];

    BOOL enableNext = YES;
    BOOL enablePrev = YES;

    NSDateComponents *componentsTmp = [_gregorian components:_dayInfoUnits fromDate:_calendarDate];
    componentsTmp.day = 1;
    componentsTmp.month --;
    NSDate * prevMonthDate =[_gregorian dateFromComponents:componentsTmp];
    if (![self canSwipeToDate:prevMonthDate])
    {
        buttonPrev.alpha    = 0.4f;
        buttonPrev.enabled  = NO;
        enablePrev          = NO;
    }
    componentsTmp.month +=2;
    NSDate * nextMonthDate =[_gregorian dateFromComponents:componentsTmp];
    if (![self canSwipeToDate:nextMonthDate])
    {
        buttonNext.alpha    = 0.4f;
        buttonNext.enabled  = NO;
        enableNext          = NO;
    }
    if (!_allowsChangeMonthByButtons)
    {
        buttonNext.hidden = YES;
        buttonPrev.hidden = YES;
    }
    if (_delegate != nil && [_delegate respondsToSelector:@selector(setEnabledForPrevMonthButton:nextMonthButton:)])
        [_delegate setEnabledForPrevMonthButton:enablePrev nextMonthButton:enableNext];
}

@end