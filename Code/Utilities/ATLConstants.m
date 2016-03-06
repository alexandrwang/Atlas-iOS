//
//  ATLUIConstants.m
//  Atlas
//
//  Created by Kevin Coleman on 6/17/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


NSString *const ATLConversationName = @"ATLConversationName";

UIColor *ATLBlueColor()
{
    return [UIColor colorWithRed:33.0f/255.0f green:170.0f/255.0f blue:225.0f/255.0f alpha:1.0];
}

UIColor *ATLDarkGrayColor()
{
    return [UIColor colorWithRed:148.0/255.0 green:148.0/255.0 blue:148.0/255.0 alpha:1.0];
}

UIColor *ATLGrayColor()
{
    return [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0];
}

UIColor *ATLLightGrayColor()
{
    return [UIColor colorWithRed:240.0f/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:1.0];
}

UIColor *ATLAddressBarGray()
{
    return [UIColor colorWithRed:248.0f/255.0f green:248.0f/255.0f blue:248.0f/255.0f alpha:1.0];
}

UIColor *ATLRedColor()
{
    return [UIColor colorWithRed:240.0f/255.0f green:80.0f/255.0f blue:100.0f/255.0f alpha:1.0];
}

UIFont *ATLLightFont(CGFloat size)
{
    return [UIFont fontWithName:@"HelveticaNeue-Light" size:size];
}

UIFont *ATLMediumFont(CGFloat size)
{
    return [UIFont fontWithName:@"HelveticaNeue" size:size];
}

UIFont *ATLBoldFont(CGFloat size)
{
    return [UIFont fontWithName:@"HelveticaNeue-Medium" size:size];
}

CAGradientLayer *AVAGradient()
{
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.colors = [NSArray arrayWithObjects:(id)[UIColorFromRGB(0x0F86DE) CGColor], (id)[UIColorFromRGB(0x0AA5D5) CGColor], nil];
    return gradient;
    
}

