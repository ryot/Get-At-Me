//
//  RTConstants.h
//  Get At Me!
//
//  Created by Ryo Tulman on 5/9/14.
//  Copyright (c) 2014 Ryo Tulman. All rights reserved.
//

#define POPUP_SHOW_FRAME_AD_SHOW CGRectMake(0, [[UIScreen mainScreen] bounds].size.height - 259.0, 230, 165)
#define POPUP_HIDE_FRAME_AD_SHOW CGRectMake(15, [[UIScreen mainScreen] bounds].size.height - 94.0, 1, 1)
#define POPUP_SHOW_FRAME_AD_HIDE CGRectMake(0, [[UIScreen mainScreen] bounds].size.height - 209.0, 230, 165)
#define POPUP_HIDE_FRAME_AD_HIDE CGRectMake(15, [[UIScreen mainScreen] bounds].size.height - 44.0, 1, 1)
#define POPUP_FRAME_HIDDEN CGRectMake(0, _toolbar.frame.origin.y, 1, 1)

#define TOOLBAR_AD_HIDE CGRectMake(0, [[UIScreen mainScreen] bounds].size.height - 44.0, [[UIScreen mainScreen] bounds].size.width, 44)
#define TOOLBAR_AD_SHOW CGRectMake(0, [[UIScreen mainScreen] bounds].size.height - 94.0, [[UIScreen mainScreen] bounds].size.width, 44)

#define RESET_CAMERA_BUTTON_AD_SHOW CGRectMake([[UIScreen mainScreen] bounds].size.width - 58.0, [[UIScreen mainScreen] bounds].size.height - 152.0, 58, 58)
#define RESET_CAMERA_BUTTON_AD_HIDE CGRectMake([[UIScreen mainScreen] bounds].size.width - 58.0, [[UIScreen mainScreen] bounds].size.height - 102.0, 58, 58)

#define PERSPECTIVE_BUTTON_AD_SHOW CGRectMake([[UIScreen mainScreen] bounds].size.width - 58.0, [[UIScreen mainScreen] bounds].size.height - 210.0, 58, 58)
#define PERSPECTIVE_BUTTON_AD_HIDE CGRectMake([[UIScreen mainScreen] bounds].size.width - 58.0, [[UIScreen mainScreen] bounds].size.height - 160.0, 58, 58)

#define APPLE_MAP_AD_SHOW CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height - 94.0)
#define APPLE_MAP_AD_HIDE CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height - 44.0)

#define AD_OFFSCREEN CGRectMake(0, [[UIScreen mainScreen] bounds].size.height, 320, 50)
#define AD_ONSCREEN CGRectMake(0, [[UIScreen mainScreen] bounds].size.height - 50.0, 320, 50)

#define MKMapCamera_3D_DEFAULT [MKMapCamera cameraLookingAtCenterCoordinate:_myCurrentLoc.coordinate fromEyeCoordinate:CLLocationCoordinate2DMake(_myCurrentLoc.coordinate.latitude - 0.007, _myCurrentLoc.coordinate.longitude + 0.004) eyeAltitude:130]
#define MKMapCamera_2D_DEFAULT [MKMapCamera cameraLookingAtCenterCoordinate:_myCurrentLoc.coordinate fromEyeCoordinate:_myCurrentLoc.coordinate eyeAltitude:1500]
