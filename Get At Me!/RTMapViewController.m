//
//  RTMapViewController.m
//  Get At Me!
//
//  Created by Ryo Tulman on 4/8/14.
//  Copyright (c) 2014 Ryo Tulman. All rights reserved.
//

#import "RTMapViewController.h"
#import <MapKit/MapKit.h>
#import <MessageUI/MessageUI.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <iAd/iAd.h>
#import "RTPerspectiveButton.h"
#import "RTResetCameraButton.h"

@interface RTMapViewController () <MKMapViewDelegate, CLLocationManagerDelegate, MFMessageComposeViewControllerDelegate, ADBannerViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *popupView;
@property (strong, nonatomic) UIView *snapshot;
@property (nonatomic) BOOL firstZoomAnimationDone;
@property (weak, nonatomic) IBOutlet MKMapView *appleMapView;
@property (nonatomic, strong) CLLocationManager *locManager;
@property (nonatomic, strong) CLLocation *myCurrentLoc;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UISwitch *mapSnapSwitch;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *popupButton;
@property (weak, nonatomic) IBOutlet UILabel *includeMapSnapLabel;
@property (weak, nonatomic) IBOutlet UILabel *mapSnapDescriptionLabel;
@property (weak, nonatomic) IBOutlet RTResetCameraButton *resetCameraButton;
@property (weak, nonatomic) IBOutlet RTPerspectiveButton *perspectiveButton;
@property (weak, nonatomic) IBOutlet ADBannerView *iAdBanner;
@property (nonatomic) BOOL mapIs3D;
@property (nonatomic) BOOL adBannerUp;

#define POPUP_SHOW_FRAME_AD_SHOW CGRectMake(0, [[UIScreen mainScreen] bounds].size.height - 259.0, 230, 165)
#define POPUP_HIDE_FRAME_AD_SHOW CGRectMake(0, [[UIScreen mainScreen] bounds].size.height - 94.0, 1, 1)
#define POPUP_SHOW_FRAME_AD_HIDE CGRectMake(0, [[UIScreen mainScreen] bounds].size.height - 209.0, 230, 165)
#define POPUP_HIDE_FRAME_AD_HIDE CGRectMake(0, [[UIScreen mainScreen] bounds].size.height - 44.0, 1, 1)

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


@end

@implementation RTMapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"%f", [[UIScreen mainScreen] bounds].size.height );
    
    self.canDisplayBannerAds = YES; //this inserts an iad view container above self.view, so use self.originalContentView from now on instead of self.view
    
    //set user settings
    _mapSnapSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"mapSnapSwitchState"];
    if (_appleMapView.isPitchEnabled) {
        _mapIs3D = YES;
        _perspectiveButton.toggled = [[NSUserDefaults standardUserDefaults] boolForKey:@"threeDeeButtonState"];
        [_perspectiveButton setNeedsDisplay];
    } else {
        _mapIs3D = NO;
        _perspectiveButton.hidden = YES;
    }
    
    UIColor *themeColor = [UIColor colorWithRed:0.99 green:0.57 blue:0.15 alpha:1];
    _includeMapSnapLabel.textColor = themeColor;
    _mapSnapSwitch.tintColor = themeColor;
    _mapSnapSwitch.onTintColor = themeColor;
    
    //configure map view
    _myCurrentLoc = [CLLocation new];
    
    //configure location manager
    _locManager = [CLLocationManager new];
    _locManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    _locManager.delegate = self;
    [_locManager startUpdatingLocation];
    
    //configure views for pre-ad load state - ad banner and everything else will move up onto screen when banner ad loads
    _iAdBanner.frame = AD_OFFSCREEN;
    _appleMapView.frame = APPLE_MAP_AD_HIDE;
    _perspectiveButton.frame = PERSPECTIVE_BUTTON_AD_HIDE;
    _resetCameraButton.frame = RESET_CAMERA_BUTTON_AD_HIDE;
    _toolbar.frame = TOOLBAR_AD_HIDE;
    _popupView.frame = POPUP_SHOW_FRAME_AD_HIDE;
    [self.view setNeedsLayout];

    _snapshot = [_popupView snapshotViewAfterScreenUpdates:YES];
    _snapshot.frame = _popupView.frame;
    [self.originalContentView addSubview:_snapshot];
    [self.originalContentView bringSubviewToFront:_snapshot];
    _snapshot.frame = POPUP_HIDE_FRAME_AD_HIDE;
    _popupView.hidden = YES;
    _snapshot.hidden = YES;
    [self.originalContentView layoutIfNeeded];
}

#pragma Visual presentation

- (IBAction)cameraButtonPressed:(id)sender {
    if (_popupView.hidden) {
        [self popupShow];
    } else {
        [self popupHide];
    }
}

-(void)popupShow
{
    _popupButton.enabled = NO;
    _snapshot.hidden = NO;
    //[self.originalContentView bringSubviewToFront:_snapshot];
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _snapshot.frame = _popupView.frame;
    } completion:^(BOOL finished) {
        if (finished) {
            _popupView.hidden = NO;
            _snapshot.hidden = YES;
            _popupButton.enabled = YES;
        }
    }];
}

-(void)popupHide
{
    _popupButton.enabled = NO;
    _snapshot = [_popupView snapshotViewAfterScreenUpdates:NO];
    _snapshot.frame = _popupView.frame;
    [self.originalContentView addSubview:_snapshot];
    [self.originalContentView bringSubviewToFront:_snapshot];
    [self.originalContentView bringSubviewToFront:_toolbar];
    _popupView.hidden = YES;
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        if (_adBannerUp) {
            _snapshot.frame = POPUP_HIDE_FRAME_AD_SHOW;
        } else {
            _snapshot.frame = POPUP_HIDE_FRAME_AD_HIDE;
        }
    } completion:^(BOOL finished) {
        if (finished) {
            _snapshot.hidden = YES;
            _popupButton.enabled = YES;
        }
    }];
}

- (IBAction)mapTypeChanged:(UISegmentedControl *)sender {
    sender.enabled = NO;
    _resetCameraButton.enabled = NO;
    if (!_popupView.hidden) {
        [self popupHide];
    }
    MKMapCamera *newCam = [MKMapCamera cameraLookingAtCenterCoordinate:_myCurrentLoc.coordinate fromEyeCoordinate:_myCurrentLoc.coordinate eyeAltitude:1800];
    if (sender.selectedSegmentIndex == 0) {
        _appleMapView.mapType = MKMapTypeStandard;
        if (_appleMapView.isPitchEnabled && _mapIs3D) {
            newCam = [MKMapCamera cameraLookingAtCenterCoordinate:_myCurrentLoc.coordinate fromEyeCoordinate:CLLocationCoordinate2DMake(_myCurrentLoc.coordinate.latitude - 0.006, _myCurrentLoc.coordinate.longitude + 0.003) eyeAltitude:30];
        }
        if (_appleMapView.isPitchEnabled) {
            _perspectiveButton.frame = CGRectMake(340, _perspectiveButton.frame.origin.y, _perspectiveButton.frame.size.width, _perspectiveButton.frame.size.height);
            _perspectiveButton.hidden = NO;
        }
        [UIView animateWithDuration:1.0 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            _appleMapView.camera = newCam;
            if (_appleMapView.isPitchEnabled) {
                _perspectiveButton.frame = CGRectMake(260, _perspectiveButton.frame.origin.y, _perspectiveButton.frame.size.width, _perspectiveButton.frame.size.height);
            }
        } completion:^(BOOL finished) {
            sender.enabled = YES;
            _resetCameraButton.enabled = YES;
        }];
    } else if (sender.selectedSegmentIndex == 1) {
        [UIView animateWithDuration:1.0 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            _appleMapView.camera = newCam;
            if (_appleMapView.isPitchEnabled) {
                _perspectiveButton.frame = CGRectMake(340, _perspectiveButton.frame.origin.y, _perspectiveButton.frame.size.width, _perspectiveButton.frame.size.height);
            }
        } completion:^(BOOL finished) {
            _appleMapView.mapType = MKMapTypeHybrid;
            sender.enabled = YES;
            _resetCameraButton.enabled = YES;
            if (_appleMapView.isPitchEnabled) {
                _perspectiveButton.hidden = YES;
            }
        }];
    }
}

-(void)changeMapDimensionsWith3DState:(BOOL)newDimension
{
    if (_mapIs3D != newDimension) {
        _mapIs3D = newDimension;
        NSOperationQueue *queue = [NSOperationQueue new];
        if (_mapIs3D) {
            [UIView animateWithDuration:0.7 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                _appleMapView.camera = [MKMapCamera cameraLookingAtCenterCoordinate:_myCurrentLoc.coordinate fromEyeCoordinate:_myCurrentLoc.coordinate eyeAltitude:700];
            } completion:^(BOOL finished) {
                [queue addOperationWithBlock:^{
                    usleep(250000);
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        [UIView animateWithDuration:0.7 animations:^{
                            _appleMapView.camera = [MKMapCamera cameraLookingAtCenterCoordinate:_myCurrentLoc.coordinate fromEyeCoordinate:CLLocationCoordinate2DMake(_myCurrentLoc.coordinate.latitude - 0.006, _myCurrentLoc.coordinate.longitude + 0.003) eyeAltitude:30];
                        }];
                    }];
                }];
            }];
        } else {
            [UIView animateWithDuration:0.7 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                _appleMapView.camera = [MKMapCamera cameraLookingAtCenterCoordinate:_myCurrentLoc.coordinate fromEyeCoordinate:_myCurrentLoc.coordinate eyeAltitude:700];
            } completion:^(BOOL finished) {
                [queue addOperationWithBlock:^{
                    usleep(250000);
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        [UIView animateWithDuration:0.7 animations:^{
                            _appleMapView.camera = [MKMapCamera cameraLookingAtCenterCoordinate:_myCurrentLoc.coordinate fromEyeCoordinate:_myCurrentLoc.coordinate eyeAltitude:1800];
                        }];
                    }];
                }];
            }];
        }
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches) {
        if (![[self.originalContentView hitTest:[touch locationInView:self.originalContentView] withEvent:event] isEqual:_popupView] && !_popupView.isHidden) {
            [self popupHide];
            break;
        }
    }
}

- (IBAction)perspectiveButtonPressed:(id)sender {
    if (_perspectiveButton.toggled) {
        _perspectiveButton.toggled = NO;
        [self changeMapDimensionsWith3DState:NO];
    } else {
        _perspectiveButton.toggled = YES;
        [self changeMapDimensionsWith3DState:YES];
    }
    [_perspectiveButton setNeedsDisplay];
    [UIView transitionWithView:_perspectiveButton duration:0.18 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [_perspectiveButton.layer displayIfNeeded];
    } completion:^(BOOL finished) {
        [[NSUserDefaults standardUserDefaults] setBool:_perspectiveButton.toggled forKey:@"threeDeeButtonState"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }];
}

#pragma Location updating

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    _myCurrentLoc = [locations lastObject];
    //reset camera to updated position
    if (!_firstZoomAnimationDone) {
        [self resetMapCameraWithDuration:3.0 completion:^{
            _firstZoomAnimationDone = YES;
        }];
    }
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"%@", error);
}

- (IBAction)snapToCurrentLocationPressed:(id)sender
{
    _resetCameraButton.pressed = YES;
    [_resetCameraButton setNeedsDisplay];
    [UIView transitionWithView:_resetCameraButton duration:0.15 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [_perspectiveButton.layer displayIfNeeded];
    } completion:^(BOOL finished) {
        _resetCameraButton.pressed = NO;
        [_resetCameraButton setNeedsDisplay];
        [UIView transitionWithView:_resetCameraButton duration:0.85 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            [_perspectiveButton.layer displayIfNeeded];
        } completion:nil];
    }];
    CLLocation *currentMapCenterLoc = [[CLLocation alloc] initWithCoordinate:_appleMapView.camera.centerCoordinate altitude:_appleMapView.camera.altitude horizontalAccuracy:0 verticalAccuracy:0 timestamp:[NSDate date]];
    double coordinateDifference = [_myCurrentLoc distanceFromLocation:currentMapCenterLoc];
    double altitudeDifference = abs(_myCurrentLoc.altitude - currentMapCenterLoc.altitude);
    double distanceToSnap = coordinateDifference + altitudeDifference;
    double animateDuration = (log(distanceToSnap))/9;
    [self resetMapCameraWithDuration:animateDuration completion:nil];
}

-(void)resetMapCameraWithDuration:(CGFloat)duration completion:(void (^)(void))completion
{
    if (_appleMapView.isPitchEnabled && _mapIs3D && _appleMapView.mapType != MKMapTypeHybrid) {
        [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            _appleMapView.camera = [MKMapCamera cameraLookingAtCenterCoordinate:_myCurrentLoc.coordinate fromEyeCoordinate:CLLocationCoordinate2DMake(_myCurrentLoc.coordinate.latitude - 0.006, _myCurrentLoc.coordinate.longitude + 0.003) eyeAltitude:30];
        } completion:^(BOOL finished) {
            if (completion) {
                _firstZoomAnimationDone = YES;
            }
        }];
    } else {
        [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            _appleMapView.camera = [MKMapCamera cameraLookingAtCenterCoordinate:_myCurrentLoc.coordinate fromEyeCoordinate:_myCurrentLoc.coordinate eyeAltitude:1800];
        } completion:^(BOOL finished) {
            if (completion) {
                _firstZoomAnimationDone = YES;
            }
        }];
    }
}

#pragma Location sending

- (IBAction)getAtMePressed:(id)sender {
    if(![MFMessageComposeViewController canSendText]) {
        UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Sorry!" message:@"Your device does not support SMS." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [warningAlert show];
        return;
    }
    _popupView.hidden = YES;
    [self configureAndOpenMessageComposeView];
}

-(void)configureAndOpenMessageComposeView
{
    //create URLs
    NSString *appleMapsURLBase = @"maps.apple.com/?daddr=";
    NSString *appleMapsURLEnd = [NSString stringWithFormat:@"%g+%g", _myCurrentLoc.coordinate.latitude, _myCurrentLoc.coordinate.longitude];
    NSString *appleMapsURL = [appleMapsURLBase stringByAppendingString:appleMapsURLEnd];
    
    NSString *googleMapsAppURLBase = @"comgooglemaps://?daddr=";
    NSString *googleMapsAppURLEnd = [NSString stringWithFormat:@"%g+%g", _myCurrentLoc.coordinate.latitude, _myCurrentLoc.coordinate.longitude];
    NSString *googleMapsAppURL = [googleMapsAppURLBase stringByAppendingString:googleMapsAppURLEnd];
    
    NSString *message = [NSString stringWithFormat:@"Get At Me!\nApple Maps (iOS/Android): %@\n\nGoogle Maps (iOS): %@", appleMapsURL, googleMapsAppURL];
    
    MFMessageComposeViewController *messageController = [MFMessageComposeViewController new];
    messageController.messageComposeDelegate = self;
    messageController.subject = @"Get At Me!";
    messageController.body = message;
    //snapshot map view in case receiver doesn't have a smartphone/dataplan.
    if (_mapSnapSwitch.isOn && [MFMessageComposeViewController canSendAttachments]) {
        UIGraphicsBeginImageContext(_appleMapView.frame.size);
        [_appleMapView drawViewHierarchyInRect:_appleMapView.frame afterScreenUpdates:NO];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [messageController addAttachmentData:UIImageJPEGRepresentation(image, 0.5) typeIdentifier:(__bridge NSString *)kUTTypeJPEG filename:@"MapSnap.jpeg"]; //~30kb, still very legible
    }
    // Present message view controller on screen (modal)
    [self presentViewController:messageController animated:YES completion:nil];
}

-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [controller dismissViewControllerAnimated:YES completion:^{
        if (result == MFMailComposeResultFailed) {
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your SMS failed to send! Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
        }
    }];
}
- (IBAction)mapSnapSwitchToggled:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:_mapSnapSwitch.isOn forKey:@"mapSnapSwitchState"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [_locManager stopUpdatingLocation];
    [_iAdBanner removeFromSuperview];
    _iAdBanner.delegate = nil;
    [self.originalContentView layoutIfNeeded];
    [super viewWillDisappear:animated];
}

-(void)viewWillAppear:(BOOL)animated
{
    [_locManager startUpdatingLocation];
    [self.originalContentView addSubview:_iAdBanner];
    _iAdBanner.delegate = self;
    [self.originalContentView layoutIfNeeded];
    [super viewWillAppear:animated];
}

#pragma iAd

-(void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    NSLog(@"DID LOAD AD");
    if (!_adBannerUp) {
        [self showAd];
    }
}

-(void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    NSLog(@"DID FAIL TO RECEIVE AD %@", error);
    if (_adBannerUp) {
        [self hideAd];
    }
}

-(void)hideAd
{
    _adBannerUp = NO;
    [UIView animateWithDuration:0.6 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _iAdBanner.frame = AD_OFFSCREEN;
        _appleMapView.frame = APPLE_MAP_AD_HIDE;
        _toolbar.frame = TOOLBAR_AD_HIDE;
        _resetCameraButton.frame = RESET_CAMERA_BUTTON_AD_HIDE;
        _perspectiveButton.frame = PERSPECTIVE_BUTTON_AD_HIDE;
        _popupView.frame = POPUP_SHOW_FRAME_AD_HIDE;
    } completion:^(BOOL finished) {
        if (finished) {
            _adBannerUp = NO;
        }
    }];
}

-(void)showAd
{
    _adBannerUp = YES;
    [UIView animateWithDuration:0.6 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _iAdBanner.frame = AD_ONSCREEN;
        _appleMapView.frame = APPLE_MAP_AD_SHOW;
        _toolbar.frame = TOOLBAR_AD_SHOW;
        _resetCameraButton.frame = RESET_CAMERA_BUTTON_AD_SHOW;
        _perspectiveButton.frame = PERSPECTIVE_BUTTON_AD_SHOW;
        _popupView.frame = POPUP_SHOW_FRAME_AD_SHOW;
    } completion:^(BOOL finished) {
        if (finished) {
            _adBannerUp = YES;
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
