//
//  GradientView.m
//  Ava
//
//  Created by Devin Doty on 4/22/16.
//  Copyright © 2016 Layer, Inc. All rights reserved.
//

#import "GradientView.h"

@implementation GradientView

+ (Class)layerClass {
    return [CAGradientLayer class];
}

- (CAGradientLayer *)gradientLayer {
    return (CAGradientLayer *)self.layer;
}

@end