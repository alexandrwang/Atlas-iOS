//
//  SpecialistKeyboardCollectionViewCell.h
//  Pods
//
//  Created by Lucy Guo on 4/23/16.
//
//

#import <UIKit/UIKit.h>

@interface ATLTimeKeyboardCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) UILabel *stringLabel;

- (void)markSelected:(BOOL)selected;

@end
