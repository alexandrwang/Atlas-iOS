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
#import "ATLTimesByDayKeyboardViewController.h"
#import "ATLLocationKeyboardViewController.h"
#import "ATLMessagingUtilities.h"
#import "CMAddressSearchViewController.h"

@interface ATLKeyboardFlowViewController () < ATLKeyboardDelegate, CMAddressSearchDelegate>

@property (nonatomic, strong) NSArray *dates;

@end

@implementation ATLKeyboardFlowViewController {
    NSArray *_keyboardArray;
    NSArray *_keyboardMessages;
    NSMutableArray *_selections;
}

// This is sample JSON data used to construct the keyboard flow and placeholder text.
// Eventually you want to replace this with server data.

- (NSDictionary *)templateDataSource {
    return @{ @"message" : @[ @{ @"text" : @"I need a ",
                                 @"type" : @"plaintext"},
                              @{ @"text" : @"[pick a specialist]",
                                 @"type" : @"pill"},
                              
                              @{ @"text" : @" near ",
                                 @"type" : @"plaintext"},
                              @{ @"text" : @"[pick location, press next]",
                                 @"type" : @"location"},
                              
                              @{ @"text" : @" at any open time on my calendar, but I prefer these times: ",
                                 @"type" : @"plaintext"},
                              
                              @{ @"text" : @"[pick times, press send]",
                                 @"type" : @"time"},
                            ]};
}

- (void)_parseJSONData:(NSDictionary *)data {
    NSMutableArray *array = [[NSMutableArray alloc] init];

    for (NSDictionary *dict in data[@"message"]) {
        if ([dict[@"type"] isEqualToString:@"pill"]) {
            [array addObject:[[ATLPillKeyboardViewController alloc] init]];
        } else if ([dict[@"type"] isEqualToString:@"date"]) {
            [array addObject:[[ATLDateKeyboardViewController alloc] init]];
        } else if ([dict[@"type"] isEqualToString:@"location"]) {
            [array addObject:[[ATLLocationKeyboardViewController alloc] init]];
        } else if ([dict[@"type"] isEqualToString:@"timesByDay"]) {
            [array addObject:[[ATLTimesByDayKeyboardViewController alloc] init]];
        } else if ([dict[@"type"] isEqualToString:@"time"]) {
            ATLTimeKeyboardViewController *tkvc = [[ATLTimeKeyboardViewController alloc] init];
            [tkvc setupDateLabel:@"Preferred Times"];
            [array addObject:tkvc];
        }
    }

    _keyboardArray = array;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self _parseJSONData:[self templateDataSource]];
    _selections = [[NSMutableArray alloc] init];
    _keyboardIndex = 0;

    for (ATLKeyboardViewController *keyboardViewController in _keyboardArray) {
        keyboardViewController.delegate = self;
    }

    [self setViewControllers:@[_keyboardArray[_keyboardIndex]]
                   direction:UIPageViewControllerNavigationDirectionForward
                    animated:YES
                  completion:^(BOOL finished) {}];
    [self _updateKeyboardType];
    [self _updateMessages:NO];
    [self.flowDelegate keyboardFlowViewController:self didChangeToPage:_keyboardIndex withType:_keyboardType];

    ATLKeyboardViewController *viewController = _keyboardArray[_keyboardIndex];
    [self.flowDelegate keyboardFlowViewController:self didUpdateSelection:viewController.selection];
}

#pragma mark - Switch Pages

- (void)changePageInDirection:(UIPageViewControllerNavigationDirection)direction {
    if ((direction == UIPageViewControllerNavigationDirectionForward && _keyboardIndex < (_keyboardArray.count - 1)) ||
        (direction == UIPageViewControllerNavigationDirectionReverse && _keyboardIndex > 0)) {
        _keyboardIndex = (direction == UIPageViewControllerNavigationDirectionForward ? _keyboardIndex + 1 : _keyboardIndex - 1);
        
        // update the days if we're going to a TimesByDay keyboard
        if ([_keyboardArray[_keyboardIndex] isKindOfClass:ATLTimesByDayKeyboardViewController.class]) {
            [_keyboardArray[_keyboardIndex] setDates:_dates];
        }
        [self setViewControllers:@[_keyboardArray[_keyboardIndex]]
                       direction:direction
                        animated:YES
                      completion:^(BOOL finished) {}];
        [self _updateKeyboardType];
        [self _updateMessages:NO];
        [self.flowDelegate keyboardFlowViewController:self didChangeToPage:_keyboardIndex withType:_keyboardType];
        ATLKeyboardViewController *viewController = _keyboardArray[_keyboardIndex];
        [self.flowDelegate keyboardFlowViewController:self didUpdateSelection:viewController.selection];

    }
}

- (void)changePageToIndex:(NSInteger)index {
    if (index >= 0 && index < _keyboardArray.count) {
        _keyboardIndex = index;
        [self setViewControllers:@[_keyboardArray[_keyboardIndex]]
                       direction:UIPageViewControllerNavigationDirectionReverse
                        animated:YES
                      completion:^(BOOL finished) {}];
        [self _updateKeyboardType];
        [self _updateMessages:NO];
        [self.flowDelegate keyboardFlowViewController:self didChangeToPage:_keyboardIndex withType:_keyboardType];
        ATLKeyboardViewController *viewController = _keyboardArray[_keyboardIndex];
        [self.flowDelegate keyboardFlowViewController:self didUpdateSelection:viewController.selection];
    }
}

#pragma mark - Public Functions

- (BOOL)isSubmittable {
    return (_keyboardIndex == (_keyboardArray.count - 1));
}

- (void)fillInAllFields {
    [self _updateMessages:YES];
    [self.flowDelegate keyboardFlowViewController:self didChangeToPage:_keyboardIndex withType:_keyboardType];
}

- (void)resetMessageField {
    [self _parseJSONData:[self templateDataSource]];
    _selections = [[NSMutableArray alloc] init];
    _keyboardIndex = 0;

    for (ATLKeyboardViewController *keyboardViewController in _keyboardArray) {
        keyboardViewController.delegate = self;
    }

    [self setViewControllers:@[_keyboardArray[_keyboardIndex]]
                   direction:UIPageViewControllerNavigationDirectionForward
                    animated:YES
                  completion:^(BOOL finished) {}];
    [self _updateKeyboardType];
    [self _updateMessages:NO];
    [self.flowDelegate keyboardFlowViewController:self didChangeToPage:_keyboardIndex withType:_keyboardType];

    ATLKeyboardViewController *viewController = _keyboardArray[_keyboardIndex];
    [self.flowDelegate keyboardFlowViewController:self didUpdateSelection:viewController.selection];
}

- (NSArray*)getSelectionsArray {
    return _selections;
}

- (void)_updateKeyboardType {
    UIViewController *keyboard = _keyboardArray[_keyboardIndex];
    ATLKeyboardType type = ATLKeyboardTypeDefault;
    if ([keyboard isKindOfClass:[ATLPillKeyboardViewController class]]) {
        type = ATLKeyboardTypePill;
    } else if ([keyboard isKindOfClass:[ATLTimeKeyboardViewController class]]) {
        type = ATLKeyboardTypeTime;
    } else if ([keyboard isKindOfClass:[ATLTimesByDayKeyboardViewController class]]) {
        type = ATLKeyboardTypeTimesByDay;
    } else if ([keyboard isKindOfClass:[ATLDateKeyboardViewController class]]) {
        type = ATLKeyboardTypeDate;
    } else if ([keyboard isKindOfClass:[ATLLocationKeyboardViewController class]]) {
        type = ATLKeyboardTypeLocation;
    }
    _keyboardType = type;
}

- (void)_updateMessages:(BOOL)forceAllUpdates {
    NSMutableArray *messages = [[NSMutableArray alloc] init];
    NSMutableAttributedString *message = [[NSMutableAttributedString alloc] initWithString:@""];
    NSArray *dataArray = (NSArray *)[self templateDataSource][@"message"];
    for (int i = 0; i < dataArray.count; i += 2) {
        NSDictionary *dict1 = dataArray[i];
        NSMutableAttributedString *string1 = [[NSMutableAttributedString alloc] initWithString:dict1[@"text"]];
        [string1 addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"AvenirNext-Regular" size:16.0f] range: NSMakeRange(0, string1.length)];
        [string1 addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range: NSMakeRange(0, string1.length)];
        [message appendAttributedString:string1];

        NSDictionary *dict2 = dataArray[i+1];
        NSMutableAttributedString *string2;
        if ((i / 2) == _keyboardIndex && !forceAllUpdates) {
            string2 = [[NSMutableAttributedString alloc] initWithString:dict2[@"text"]];
            [string2 addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"AvenirNext-Regular" size:16.0f] range: NSMakeRange(0, string2.length)];
            [string2 addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithWhite:0.8f alpha:1.0f] range: NSMakeRange(0, string2.length)];
        } else {
            NSString *selectionString = ((i / 2) < _selections.count ? _selections[(i / 2)] : @"");
            string2 = [[NSMutableAttributedString alloc] initWithString:selectionString];
            [string2 addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"AvenirNext-Regular" size:16.0f] range: NSMakeRange(0, string2.length)];
            [string2 addAttribute:NSLinkAttributeName value:[NSString stringWithFormat:@"%i", (i / 2)] range: NSMakeRange(0, string2.length)];
        }

        [message appendAttributedString:string2];
        [messages addObject:[message copy]];
    }
    _keyboardMessages = messages;
    _message = _keyboardMessages[_keyboardIndex];
}

#pragma mark - ATLKeyboardDelegate

- (void)keyboard:(ATLKeyboardViewController *)keyboard didSelectCell:(UICollectionViewCell *)cell {
    if ([cell isKindOfClass:[ATLPillKeyboardCollectionViewCell class]]) {
        ATLPillKeyboardCollectionViewCell *pillCell = (ATLPillKeyboardCollectionViewCell *)cell;
        [_selections setObject:pillCell.labelText atIndexedSubscript:_keyboardIndex];
    }
    [self changePageInDirection:UIPageViewControllerNavigationDirectionForward];
}

- (void)presentLocationViewController:(UINavigationController *)controller {
    [self.flowDelegate presentLocationViewController:controller];
}

- (void)popUpCustomKeyboard {
    [self.flowDelegate popUpCustomKeyboard];
}


- (void)keyboard:(ATLKeyboardViewController *)keyboard withType:(ATLKeyboardType)type didUpdateSelection:(NSMutableArray *)selection {
    if (_keyboardType == type) {
        NSMutableString *string = [[NSMutableString alloc] init];
        for (int i = 0; i < selection.count; i++) {
            NSString *item = selection[i];
            [string appendString:item];
            if (i != selection.count - 1) {
                [string appendString:@", "];
            }
        }
        [_selections setObject:string atIndexedSubscript:_keyboardIndex];
        [self.flowDelegate keyboardFlowViewController:self didUpdateSelection:selection];
    }
    if (_keyboardType == ATLKeyboardTypeDate) {
        _dates = selection;
    }
}

@end
