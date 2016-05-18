//
//  SpecialistKeyboardCollectionViewCell.m
//  Pods
//
//  Created by Lucy Guo on 4/23/16.
//
//

#import "ATLPillKeyboardCollectionViewCell.h"

@interface ATLPillKeyboardCollectionViewCell ()

@property (strong, nonatomic) UILabel *stringLabel;

@end

@implementation ATLPillKeyboardCollectionViewCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    self.backgroundColor = [UIColor whiteColor];

    
    _stringLabel = [[UILabel alloc] init];
    _stringLabel.textColor = [UIColor colorWithRed:0.33 green:0.73 blue:0.88 alpha:1.0];;
    _stringLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:16];
    _stringLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _stringLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:_stringLabel];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[_stringLabel]-15-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_stringLabel)]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[_stringLabel]-8-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_stringLabel)]];
    
    return self;
}

-(void)drawRect:(CGRect)rect {
    
    // inset by half line width to avoid cropping where line touches frame edges
    CGRect insetRect = CGRectInset(rect, 2.5, 2.5);
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:insetRect cornerRadius:rect.size.height/2.0];
    
    // white background
    [[UIColor whiteColor] setFill];
    [path fill];
    
    // outline
    [[UIColor colorWithRed:0.33 green:0.73 blue:0.88 alpha:1.0] setStroke];
    [path stroke];
}

-(void)setLabelText:(NSString *)labelText {
    self.stringLabel.text = labelText;
}

@end
