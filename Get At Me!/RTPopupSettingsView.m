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
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //// Color Declarations
    UIColor* color4 = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 0.96];
    
    //// Shadow Declarations
    UIColor* shadow = [UIColor.blackColor colorWithAlphaComponent: 0.3];
    CGSize shadowOffset = CGSizeMake(-2.1, 4.1);
    CGFloat shadowBlurRadius = 5;
    
    //// Rounded Rectangle Drawing
    UIBezierPath* roundedRectanglePath = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(7, 3, 221, 155) cornerRadius: 20];
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, shadowOffset, shadowBlurRadius, [shadow CGColor]);
    [color4 setFill];
    [roundedRectanglePath fill];
    CGContextRestoreGState(context);
}

@end
