//
//  RTPerspectiveButton.m
//  Get At Me!
//
//  Created by Ryo Tulman on 5/6/14.
//  Copyright (c) 2014 Ryo Tulman. All rights reserved.
//

#import "RTPerspectiveButton.h"

@implementation RTPerspectiveButton

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
    if (_toggled) {
        //// General Declarations
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        //// Color Declarations
        UIColor* color9 = [UIColor colorWithRed: 1 green: 0.5 blue: 0 alpha: 1];
        UIColor* color10 = [UIColor colorWithRed: 1 green: 0.956 blue: 0.914 alpha: 0.95];
        UIColor *themeColor = [UIColor colorWithRed:0.99 green:0.57 blue:0.15 alpha:1];
        
        //// Shadow Declarations
        UIColor* shadow2 = [UIColor.blackColor colorWithAlphaComponent: 0.3];
        CGSize shadow2Offset = CGSizeMake(2.1, 2.1);
        CGFloat shadow2BlurRadius = 4;
        
        //// Rounded Rectangle Drawing
        CGRect roundedRectangleRect = CGRectMake(2.5, 2.5, 44, 44);
        UIBezierPath* roundedRectanglePath = [UIBezierPath bezierPathWithRoundedRect: roundedRectangleRect cornerRadius: 8];
        [color10 setFill];
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
        {
            NSString* textContent = @"3D";
            NSMutableParagraphStyle* roundedRectangleStyle = NSMutableParagraphStyle.defaultParagraphStyle.mutableCopy;
            roundedRectangleStyle.alignment = NSTextAlignmentCenter;
            
            NSDictionary* roundedRectangleFontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"AvenirNext-Bold" size: 23], NSForegroundColorAttributeName: color9, NSParagraphStyleAttributeName: roundedRectangleStyle};
            
            [textContent drawInRect: CGRectOffset(roundedRectangleRect, 0, (CGRectGetHeight(roundedRectangleRect) - [textContent boundingRectWithSize: roundedRectangleRect.size options: NSStringDrawingUsesLineFragmentOrigin attributes: roundedRectangleFontAttributes context: nil].size.height) / 2) withAttributes: roundedRectangleFontAttributes];
        }
    } else {
        //// General Declarations
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        //// Color Declarations
        UIColor* color7 = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 0.95];
        UIColor* color9 = [UIColor colorWithRed: 0.99 green: 0.57 blue: 0.15 alpha: 1];
        
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
            
            
            
            //// Text Drawing
            CGRect textRect = CGRectMake(7, 8, 35, 33);
            {
                NSString* textContent = @"3D";
                NSMutableParagraphStyle* textStyle = NSMutableParagraphStyle.defaultParagraphStyle.mutableCopy;
                textStyle.alignment = NSTextAlignmentCenter;
                
                NSDictionary* textFontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"AvenirNext-Bold" size: 23], NSForegroundColorAttributeName: color9, NSParagraphStyleAttributeName: textStyle};
                
                [textContent drawInRect: CGRectOffset(textRect, 0, (CGRectGetHeight(textRect) - [textContent boundingRectWithSize: textRect.size options: NSStringDrawingUsesLineFragmentOrigin attributes: textFontAttributes context: nil].size.height) / 2) withAttributes: textFontAttributes];
            }
        }
    }
}


@end
