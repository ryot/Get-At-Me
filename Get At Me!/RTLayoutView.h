//
//  RTLayoutView.h
//  Get At Me!
//
//  Created by Ryo Tulman on 5/14/14.
//  Copyright (c) 2014 Ryo Tulman. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RTLayoutViewDelegate <NSObject>

-(void)layout;

@end

@interface RTLayoutView : UIView

@property (nonatomic, weak) id<RTLayoutViewDelegate> delegate;

@end
