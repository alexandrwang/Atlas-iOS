//
//  ATLTimesByDayKeyboardViewController.h
//  Pods
//
//  Created by Alexandr Wang on 5/28/16.
//
//

#import <UIKit/UIKit.h>
#import "ATLTimeKeyboardViewController.h"
#import "ATLKeyboardViewController.h"
#import "MBXPageViewController.h"

@import UIKit;

@interface ATLTimesByDayKeyboardViewController : ATLKeyboardViewController

@property (strong, nonatomic) NSMutableArray *dates;

- (void)setDates:(NSMutableArray *)dates;

@end

