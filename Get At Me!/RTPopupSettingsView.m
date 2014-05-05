//
//  RTPopupSettingsView.m
//  Get At Me!
//
//  Created by Ryo Tulman on 5/2/14.
//  Copyright (c) 2014 Ryo Tulman. All rights reserved.
//

#import "RTPopupSettingsView.h"

@implementation RTPopupSettingsView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    //// General Declarations
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //// Color Declarations
    UIColor* color2 = [UIColor colorWithRed: 1 green: 0.933 blue: 0.8 alpha: 1];
    UIColor* color = [UIColor colorWithRed: 1 green: 0.857 blue: 0.571 alpha: 1];
    
    //// Gradient Declarations
    NSArray* gradientColors = [NSArray arrayWithObjects:
                               (id)color.CGColor,
                               (id)[UIColor colorWithRed: 1 green: 0.895 blue: 0.686 alpha: 1].CGColor,
                               (id)color2.CGColor, nil];
    CGFloat gradientLocations[] = {0, 0.5, 1};
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)gradientColors, gradientLocations);
    
    //// Shadow Declarations
    UIColor* shadow = [[UIColor blackColor] colorWithAlphaComponent: 0.3];
    CGSize shadowOffset = CGSizeMake(-2.1, 2.1);
    CGFloat shadowBlurRadius = 8;
    
    //// Rounded Rectangle Drawing
    UIBezierPath* roundedRectanglePath = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(7, 3, 221, 155) cornerRadius: 20];
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, shadowOffset, shadowBlurRadius, shadow.CGColor);
    CGContextBeginTransparencyLayer(context, NULL);
    [roundedRectanglePath addClip];
    CGContextDrawLinearGradient(context, gradient, CGPointMake(29.36, 168.64), CGPointMake(205.64, -7.64), 0);
    CGContextEndTransparencyLayer(context);
    CGContextRestoreGState(context);
    
    //// Cleanup
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
}

@end
