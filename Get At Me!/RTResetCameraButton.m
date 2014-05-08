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
    if (_pressed) {
        //// General Declarations
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        //// Color Declarations
        UIColor* color = [UIColor colorWithRed: 1 green: 0.956 blue: 0.914 alpha: 0.95];
        UIColor* gradient4Color = [UIColor colorWithRed: 1 green: 0.46 blue: 0 alpha: 1];
        UIColor *themeColor = [UIColor colorWithRed:0.99 green:0.57 blue:0.15 alpha:1];
        
        //// Shadow Declarations
        UIColor* shadow2 = [UIColor.blackColor colorWithAlphaComponent: 0.25];
        CGSize shadow2Offset = CGSizeMake(1.1, 1.1);
        CGFloat shadow2BlurRadius = 3;
        
        //// Group
        {
            //// Rounded Rectangle Drawing
            UIBezierPath* roundedRectanglePath = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(2.5, 2.5, 44, 44) cornerRadius: 8];
            [color setFill];
            [roundedRectanglePath fill];
            
            ////// Rounded Rectangle Inner Shadow
            CGContextSaveGState(context);
            UIRectClip(roundedRectanglePath.bounds);
            CGContextSetShadowWithColor(context, CGSizeZero, 0, NULL);
            
            CGContextSetAlpha(context, CGColorGetAlpha([shadow2 CGColor]));
            CGContextBeginTransparencyLayer(context, NULL);
            {
                UIColor* opaqueShadow = [shadow2 colorWithAlphaComponent: 1];
                CGContextSetShadowWithColor(context, shadow2Offset, shadow2BlurRadius, [opaqueShadow CGColor]);
                CGContextSetBlendMode(context, kCGBlendModeSourceOut);
                CGContextBeginTransparencyLayer(context, NULL);
                
                [opaqueShadow setFill];
                [roundedRectanglePath fill];
                
                CGContextEndTransparencyLayer(context);
            }
            CGContextEndTransparencyLayer(context);
            CGContextRestoreGState(context);
            
            [themeColor setStroke];
            roundedRectanglePath.lineWidth = 1;
            [roundedRectanglePath stroke];
            
            
            
            //// Bezier Drawing
            UIBezierPath* bezierPath = UIBezierPath.bezierPath;
            [bezierPath moveToPoint: CGPointMake(27.5, 41.5)];
            [bezierPath addLineToPoint: CGPointMake(9.5, 9.5)];
            [bezierPath addLineToPoint: CGPointMake(40.5, 27.5)];
            [bezierPath addLineToPoint: CGPointMake(27.5, 27.5)];
            [bezierPath addLineToPoint: CGPointMake(27.5, 41.5)];
            [bezierPath closePath];
            [gradient4Color setFill];
            [bezierPath fill];
        }

    } else {
        //// General Declarations
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        //// Color Declarations
        UIColor* gradient4Color = [UIColor colorWithRed: 1 green: 0.46 blue: 0 alpha: 1];
        UIColor* gradient4Color2 = [UIColor colorWithRed: 1 green: 0.696 blue: 0.114 alpha: 1];
        UIColor* color7 = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 0.95];
        
        //// Gradient Declarations
        CGFloat gradient4Locations[] = {0, 0.44, 1};
        CGGradientRef gradient4 = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)@[(id)gradient4Color.CGColor, (id)[UIColor colorWithRed: 1 green: 0.578 blue: 0.057 alpha: 1].CGColor, (id)gradient4Color2.CGColor], gradient4Locations);
        
        //// Shadow Declarations
        UIColor* shadow2 = [UIColor.blackColor colorWithAlphaComponent: 0.3];
        CGSize shadow2Offset = CGSizeMake(2.1, 2.1);
        CGFloat shadow2BlurRadius = 5;
        
        //// Group
        {
            //// Rounded Rectangle Drawing
            UIBezierPath* roundedRectanglePath = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(2.5, 2.5, 44, 44) cornerRadius: 8];
            CGContextSaveGState(context);
            CGContextSetShadowWithColor(context, shadow2Offset, shadow2BlurRadius, [shadow2 CGColor]);
            [color7 setFill];
            [roundedRectanglePath fill];
            CGContextRestoreGState(context);
            
            //// Bezier Drawing
            UIBezierPath* bezierPath = UIBezierPath.bezierPath;
            [bezierPath moveToPoint: CGPointMake(27.5, 41.5)];
            [bezierPath addLineToPoint: CGPointMake(9.5, 9.5)];
            [bezierPath addLineToPoint: CGPointMake(40.5, 27.5)];
            [bezierPath addLineToPoint: CGPointMake(27.5, 27.5)];
            [bezierPath addLineToPoint: CGPointMake(27.5, 41.5)];
            [bezierPath closePath];
            CGContextSaveGState(context);
            CGContextBeginTransparencyLayer(context, NULL);
            [bezierPath addClip];
            CGContextDrawLinearGradient(context, gradient4, CGPointMake(34.25, 34.75), CGPointMake(9.25, 9.75), 0);
            CGContextEndTransparencyLayer(context);
            CGContextRestoreGState(context);
        }
        
        //// Cleanup
        CGGradientRelease(gradient4);
        CGColorSpaceRelease(colorSpace);
    }
}

@end
