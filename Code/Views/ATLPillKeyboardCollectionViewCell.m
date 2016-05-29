//
//  SpecialistKeyboardCollectionViewCell.m
//  Pods
//
//  Created by Lucy Guo on 4/23/16.
//
//

#import "ATLPillKeyboardCollectionViewCell.h"
#import "ATLMessagingUtilities.h"

@interface ATLPillKeyboardCollectionViewCell ()

@property (strong, nonatomic) UILabel *stringLabel;

@end

@implementation ATLPillKeyboardCollectionViewCell {
    UIImageView *_imageView;
    NSArray *_horizontalConstraints;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    self.backgroundColor = [UIColor whiteColor];
    
    _stringLabel = [[UILabel alloc] init];
    _stringLabel.textColor = [UIColor colorWithRed:0.33 green:0.73 blue:0.88 alpha:1.0];;
    _stringLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:16];
    _stringLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _stringLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:_stringLabel];

    _imageView = [[UIImageView alloc] init];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:_imageView];

    _horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-50-[_stringLabel]-15-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_stringLabel)];

    [self.contentView addConstraints:_horizontalConstraints];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[_stringLabel]-8-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_stringLabel)]];
    return self;
}

- (void)layoutSubviews {
    _imageView.frame = CGRectMake(18, (self.bounds.size.height - 25) / 2, 25, 25);
    [_stringLabel sizeToFit];
}

- (void)drawRect:(CGRect)rect {
    
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

- (void)setLabelText:(NSString *)labelText {
    self.stringLabel.text = labelText;
    UIImage *image = [self _pillImage][labelText];
    _imageView.image = image;
//    [self.contentView removeConstraints:_horizontalConstraints];
//    _horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-55-[_stringLabel]-15-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_stringLabel)];
//    [self.contentView addConstraints:_horizontalConstraints];
    [self setNeedsLayout];
    [self setNeedsDisplay];
}

- (NSString *)labelText {
    return self.stringLabel.text;
}

- (NSDictionary *)_pillImage {
    NSBundle *resourcesBundle = ATLResourcesBundle();
    return @{ @"Primary Care"           : [UIImage imageNamed:@"doctor" inBundle:resourcesBundle compatibleWithTraitCollection:nil],
              @"Dentist"          : [UIImage imageNamed:@"dentist" inBundle:resourcesBundle compatibleWithTraitCollection:nil],
              @"Therapist"        : [UIImage imageNamed:@"therapist" inBundle:resourcesBundle compatibleWithTraitCollection:nil],
              @"Eye Doctor"      : [UIImage imageNamed:@"opt" inBundle:resourcesBundle compatibleWithTraitCollection:nil],
              @"Physical Therapist" : [UIImage imageNamed:@"pt" inBundle:resourcesBundle compatibleWithTraitCollection:nil],
              @"OB-GYN"           : [UIImage imageNamed:@"obgyn" inBundle:resourcesBundle compatibleWithTraitCollection:nil],
              @"Dermatologist"           : [UIImage imageNamed:@"dermatalogist" inBundle:resourcesBundle compatibleWithTraitCollection:nil],
              @"Ear, Nose, Throat"           : [UIImage imageNamed:@"earnosethroat" inBundle:resourcesBundle compatibleWithTraitCollection:nil],
              @"Psychiatrist"           : [UIImage imageNamed:@"psychiatrist" inBundle:resourcesBundle compatibleWithTraitCollection:nil],
              @"Orthopedic Surgeon"           : [UIImage imageNamed:@"orthopedicsurgeon" inBundle:resourcesBundle compatibleWithTraitCollection:nil],
              @"Massage Therapist"           : [UIImage imageNamed:@"massagetherapist" inBundle:resourcesBundle compatibleWithTraitCollection:nil],
              @"Other"           : [UIImage imageNamed:@"question" inBundle:resourcesBundle compatibleWithTraitCollection:nil]
              };
}

@end
