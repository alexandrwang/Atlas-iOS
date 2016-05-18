//
//  ATLButton.m
//  Pods
//
//  Created by Jesse Chand on 5/7/16.
//
//

#import "ATLButton.h"

@implementation ATLButton

- (instancetype)init {
    if (self = [super init]) {
        [self setTitleColor:[UIColor colorWithRed:0.33 green:0.73 blue:0.88 alpha:1.0] forState:UIControlStateNormal];
        self.titleLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:16];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return self;
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

@end
