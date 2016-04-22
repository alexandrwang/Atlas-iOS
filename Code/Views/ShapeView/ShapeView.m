//
//  ShapeView.m
//  Ava
//
//  Created by Devin Doty on 4/22/16.
//  Copyright © 2016 Layer, Inc. All rights reserved.
//

#import "ShapeView.h"

@implementation ShapeView

+ (Class)layerClass {
    return [CAShapeLayer class];
}

- (CAShapeLayer *)shapeLayer {
    return (CAShapeLayer *)self.layer;
}

@end