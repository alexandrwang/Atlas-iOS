//
//  ATLKeyboardViewController.h
//  Pods
//
//  Created by Jesse Chand on 5/21/16.
//
//

#import <UIKit/UIKit.h>
#import "ATLKeyboardDelegate.h"

@interface ATLKeyboardViewController : UIViewController

@property (nonatomic, weak) id<ATLKeyboardDelegate> delegate;
@property (nonatomic) NSMutableArray *selection;

@end