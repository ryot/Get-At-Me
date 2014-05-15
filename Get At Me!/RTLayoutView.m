//
//  RTLayoutView.m
//  Get At Me!
//
//  Created by Ryo Tulman on 5/14/14.
//  Copyright (c) 2014 Ryo Tulman. All rights reserved.
//

#import "RTLayoutView.h"

@implementation RTLayoutView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    if (self.delegate) {
        [self.delegate layout];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
