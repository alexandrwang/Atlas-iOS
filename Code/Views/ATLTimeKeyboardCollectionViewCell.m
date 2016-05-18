//
//  SpecialistKeyboardCollectionViewCell.m
//  Pods
//
//  Created by Lucy Guo on 4/23/16.
//
//

#import "ATLTimeKeyboardCollectionViewCell.h"
#import "ATLConstants.h"

@interface ATLTimeKeyboardCollectionViewCell ()

@property (strong, nonatomic) UILabel *stringLabel;

@end

@implementation ATLTimeKeyboardCollectionViewCell {
    BOOL _isSelected;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    self.backgroundColor = [UIColor colorWithRed:0.984 green:0.984 blue:0.984 alpha:1];

    _isSelected = NO;
    _stringLabel = [[UILabel alloc] init];
    _stringLabel.textColor = [UIColor colorWithWhite:0.4f alpha:1.0f];
    _stringLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:11.0f];
    _stringLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _stringLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:_stringLabel];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[_stringLabel]-15-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_stringLabel)]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[_stringLabel]-8-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_stringLabel)]];
    
    return self;
}

- (void)setLabelText:(NSString *)labelText {
    self.stringLabel.text = labelText;
}

- (void)select {
    _isSelected = !_isSelected;
    if (_isSelected) {
        self.backgroundColor = ATLBlueColor();
        _stringLabel.textColor = [UIColor whiteColor];
    } else {
        self.backgroundColor = [UIColor colorWithRed:0.984 green:0.984 blue:0.984 alpha:1];
        _stringLabel.textColor = [UIColor colorWithWhite:0.4f alpha:1.0f];
    }
}

@end
