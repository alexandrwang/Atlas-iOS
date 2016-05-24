//
//  ATLKeyboardDelegate.h
//  Pods
//
//  Created by Jesse Chand on 5/21/16.
//
//

#import "ATLMessagingUtilities.h"

#ifndef ATLKeyboardDelegate_h
#define ATLKeyboardDelegate_h

@import UIKit;

@class ATLKeyboardViewController;

@protocol ATLKeyboardDelegate

- (void)keyboard:(ATLKeyboardViewController *)keyboard didSelectCell:(UICollectionViewCell *)cell;
- (void)keyboard:(ATLKeyboardViewController *)keyboard withType:(ATLKeyboardType)type didUpdateSelection:(NSMutableArray *)selection;

@end

#endif /* ATLKeyboardDelegate_h */
