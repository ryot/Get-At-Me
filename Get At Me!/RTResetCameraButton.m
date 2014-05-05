//
//  RTResetCameraButton.m
//  Get At Me!
//
//  Created by Ryo Tulman on 5/2/14.
//  Copyright (c) 2014 Ryo Tulman. All rights reserved.
//

#import "RTResetCameraButton.h"

@implementation RTResetCameraButton

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
    UIColor* color = [UIColor colorWithRed: 0.114 green: 0.705 blue: 1 alpha: 1];
    UIColor* color2 = [UIColor colorWithRed: 0 green: 0.438 blue: 0.657 alpha: 1];
    UIColor* color6 = [UIColor colorWithRed: 1 green: 0.781 blue: 0.343 alpha: 1];
    UIColor* color8 = [UIColor colorWithRed: 1 green: 0.933 blue: 0.8 alpha: 1];
    
    //// Gradient Declarations
    NSArray* gradientColors = [NSArray arrayWithObjects:
                               (id)color2.CGColor,
                               (id)[UIColor colorWithRed: 0.057 green: 0.571 blue: 0.829 alpha: 1].CGColor,
                               (id)color.CGColor, nil];
    CGFloat gradientLocations[] = {0, 0.46, 0.92};
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)gradientColors, gradientLocations);
    NSArray* gradient2Colors = [NSArray arrayWithObjects:
                                (id)color6.CGColor,
                                (id)[UIColor colorWithRed: 1 green: 0.857 blue: 0.571 alpha: 1].CGColor,
                                (id)color8.CGColor, nil];
    CGFloat gradient2Locations[] = {0, 0.32, 0.81};
    CGGradientRef gradient2 = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)gradient2Colors, gradient2Locations);
    
    //// Shadow Declarations
    UIColor* shadow2 = [[UIColor blackColor] colorWithAlphaComponent: 0.35];
    CGSize shadow2Offset = CGSizeMake(2.1, 2.1);
    CGFloat shadow2BlurRadius = 6;
    
    //// Group
    {
        //// Rounded Rectangle Drawing
        UIBezierPath* roundedRectanglePath = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(2.5, 2.5, 44, 44) cornerRadius: 8];
        CGContextSaveGState(context);
        CGContextSetShadowWithColor(context, shadow2Offset, shadow2BlurRadius, shadow2.CGColor);
        CGContextBeginTransparencyLayer(context, NULL);
        [roundedRectanglePath addClip];
        CGContextDrawLinearGradient(context, gradient2, CGPointMake(44.16, 44.16), CGPointMake(4.84, 4.84), 0);
        CGContextEndTransparencyLayer(context);
        CGContextRestoreGState(context);
        
        //// Bezier Drawing
        UIBezierPath* bezierPath = [UIBezierPath bezierPath];
        [bezierPath moveToPoint: CGPointMake(27.5, 41.5)];
        [bezierPath addLineToPoint: CGPointMake(9.5, 9.5)];
        [bezierPath addLineToPoint: CGPointMake(40.5, 27.5)];
        [bezierPath addLineToPoint: CGPointMake(27.5, 27.5)];
        [bezierPath addLineToPoint: CGPointMake(27.5, 41.5)];
        [bezierPath closePath];
        CGContextSaveGState(context);
        CGContextSetShadowWithColor(context, shadow2Offset, shadow2BlurRadius, shadow2.CGColor);
        CGContextBeginTransparencyLayer(context, NULL);
        [bezierPath addClip];
        CGContextDrawLinearGradient(context, gradient, CGPointMake(34.25, 34.75), CGPointMake(9.25, 9.75), 0);
        CGContextEndTransparencyLayer(context);
        CGContextRestoreGState(context);
        
    }
    //// Cleanup
    CGGradientRelease(gradient);
    CGGradientRelease(gradient2);
    CGColorSpaceRelease(colorSpace);
}

@end
