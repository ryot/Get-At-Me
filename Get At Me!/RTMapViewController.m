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

@interface RTMapViewController () <MKMapViewDelegate, MFMessageComposeViewControllerDelegate, ADBannerViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *popupView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UISwitch *mapSnapSwitch;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *popupButton;
@property (weak, nonatomic) IBOutlet UILabel *includeMapSnapLabel;
@property (weak, nonatomic) IBOutlet UILabel *mapSnapDescriptionLabel;
@property (weak, nonatomic) IBOutlet RTResetCameraButton *resetCameraButton;
@property (weak, nonatomic) IBOutlet RTPerspectiveButton *perspectiveButton;
@property (strong, nonatomic) CLLocation *myCurrentLoc;
@property (strong, nonatomic) UIView *snapshot;
@property (nonatomic) BOOL firstZoomAnimationDone;

@end

@implementation RTMapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [UIViewController prepareInterstitialAds];
    self.interstitialPresentationPolicy = ADInterstitialPresentationPolicyManual;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActiveNotification) name:UIApplicationDidBecomeActiveNotification object:[UIApplication sharedApplication]];
    
    self.canDisplayBannerAds = YES; //this inserts an iad view container above self.view, so use self.originalContentView from now on instead of self.view
    
    //set user settings
    _mapSnapSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"mapSnapSwitchState"];
    if (_mapView.isPitchEnabled) {
        _perspectiveButton.toggled = [[NSUserDefaults standardUserDefaults] boolForKey:@"threeDeeButtonState"];
        [_perspectiveButton setNeedsDisplay];
    } else {
        _perspectiveButton.hidden = YES;
    }
    
    UIColor *themeColor = [UIColor colorWithRed:0.99 green:0.57 blue:0.15 alpha:1];
    _includeMapSnapLabel.textColor = themeColor;
    _mapSnapSwitch.tintColor = themeColor;
    _mapSnapSwitch.onTintColor = themeColor;
    
}

#pragma Visual presentation

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _snapshot = [_popupView snapshotViewAfterScreenUpdates:NO];
    _snapshot.frame = _popupView.frame;
    [self.originalContentView addSubview:_snapshot];
    [self.originalContentView bringSubviewToFront:_snapshot];
    _snapshot.hidden = YES;
    _popupView.hidden = YES;
    [self.originalContentView layoutIfNeeded];
}

- (IBAction)cameraButtonPressed:(id)sender {
    if (_popupView.isHidden) {
        [self popupShow];
    } else {
        [self popupHide];
    }
}

-(void)popupShow
{
    _popupButton.enabled = NO;
    _snapshot.hidden = NO;
    if (self.isDisplayingBannerAd) {
        _snapshot.frame = POPUP_HIDE_FRAME_AD_SHOW;
    } else {
        _snapshot.frame = POPUP_HIDE_FRAME_AD_HIDE;
    }
    [self.originalContentView bringSubviewToFront:_snapshot];
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
        if (self.isDisplayingBannerAd) {
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
    MKMapCamera *newCam = MKMapCamera_2D_DEFAULT;
    if (sender.selectedSegmentIndex == 0) {
        _mapView.showsPointsOfInterest = YES;
        _mapView.mapType = MKMapTypeStandard;
        if (_mapView.isPitchEnabled && _perspectiveButton.toggled) {
            newCam = MKMapCamera_3D_DEFAULT;
        }
        if (_mapView.isPitchEnabled) {
            _perspectiveButton.frame = CGRectMake(340, _perspectiveButton.frame.origin.y, _perspectiveButton.frame.size.width, _perspectiveButton.frame.size.height);
            _perspectiveButton.hidden = NO;
        }
        [UIView animateWithDuration:1.0 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            _mapView.camera = newCam;
            if (_mapView.isPitchEnabled) {
                _perspectiveButton.frame = CGRectMake(260, _perspectiveButton.frame.origin.y, _perspectiveButton.frame.size.width, _perspectiveButton.frame.size.height);
            }
        } completion:^(BOOL finished) {
            sender.enabled = YES;
            _resetCameraButton.enabled = YES;
        }];
    } else if (sender.selectedSegmentIndex == 1) {
        [UIView animateWithDuration:1.0 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            _mapView.camera = newCam;
            if (_mapView.isPitchEnabled) {
                _perspectiveButton.frame = CGRectMake(340, _perspectiveButton.frame.origin.y, _perspectiveButton.frame.size.width, _perspectiveButton.frame.size.height);
            }
        } completion:^(BOOL finished) {
            _mapView.showsPointsOfInterest = NO;
            _mapView.mapType = MKMapTypeHybrid;
            sender.enabled = YES;
            _resetCameraButton.enabled = YES;
            if (_mapView.isPitchEnabled) {
                _perspectiveButton.hidden = YES;
            }
        }];
    }
}

-(void)applicationDidBecomeActiveNotification
{
    if (_firstZoomAnimationDone) {
        [self snapToCurrentLocationPressed:nil];
    }
}

-(void)changeMapDimensionsWith3DState:(BOOL)newState
{
    if (_perspectiveButton.toggled != newState) {
        _perspectiveButton.toggled = newState;
        NSOperationQueue *queue = [NSOperationQueue new];
        if (_perspectiveButton.toggled) {
            [UIView animateWithDuration:0.6 animations:^{
                _mapView.camera = [MKMapCamera cameraLookingAtCenterCoordinate:_myCurrentLoc.coordinate fromEyeCoordinate:_myCurrentLoc.coordinate eyeAltitude:700];
            } completion:^(BOOL finished) {
                [queue addOperationWithBlock:^{
                    usleep(240000);
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        [UIView animateWithDuration:0.6 animations:^{
                            _mapView.camera = MKMapCamera_3D_DEFAULT;
                        }];
                    }];
                }];
            }];
        } else {
            [UIView animateWithDuration:0.6 animations:^{
                _mapView.camera = [MKMapCamera cameraLookingAtCenterCoordinate:_myCurrentLoc.coordinate fromEyeCoordinate:_myCurrentLoc.coordinate eyeAltitude:700];
            } completion:^(BOOL finished) {
                [queue addOperationWithBlock:^{
                    usleep(240000);
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        [UIView animateWithDuration:0.6 animations:^{
                            _mapView.camera = MKMapCamera_2D_DEFAULT;
                        }];
                    }];
                }];
            }];
        }
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!_popupView.isHidden) {
        for (UITouch *touch in touches) {
            if (![[self.originalContentView hitTest:[touch locationInView:self.originalContentView] withEvent:event] isEqual:_popupView]) {
                [self popupHide];
                break;
            }
        }
    }
}

- (IBAction)perspectiveButtonPressed:(id)sender {
    if (!_popupView.isHidden) {
        [self popupHide];
    }
    if (_perspectiveButton.toggled) {
        [self changeMapDimensionsWith3DState:NO];
    } else {
        [self changeMapDimensionsWith3DState:YES];
    }
    [_perspectiveButton setNeedsDisplay];
    [UIView transitionWithView:_perspectiveButton duration:0.185 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [_perspectiveButton.layer displayIfNeeded];
    } completion:^(BOOL finished) {
        [[NSUserDefaults standardUserDefaults] setBool:_perspectiveButton.toggled forKey:@"threeDeeButtonState"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }];
}

#pragma Location updating

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    _myCurrentLoc = userLocation.location;
    //reset camera to updated position
    if (!_firstZoomAnimationDone) {
        [self resetMapCameraWithDuration:2.4];
    }
}

-(void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
    NSLog(@"%@", error);
}

- (IBAction)snapToCurrentLocationPressed:(id)sender
{
    if (!_popupView.isHidden) {
        [self popupHide];
    }
    _resetCameraButton.pressed = YES;
    [_resetCameraButton setNeedsDisplay];
    [UIView transitionWithView:_resetCameraButton duration:0.17 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [_perspectiveButton.layer displayIfNeeded];
    } completion:^(BOOL finished) {
        _resetCameraButton.pressed = NO;
        [_resetCameraButton setNeedsDisplay];
        [UIView transitionWithView:_resetCameraButton duration:0.85 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            [_perspectiveButton.layer displayIfNeeded];
        } completion:nil];
    }];
    CLLocation *currentMapCenterLoc = [[CLLocation alloc] initWithCoordinate:_mapView.camera.centerCoordinate altitude:_mapView.camera.altitude horizontalAccuracy:0 verticalAccuracy:0 timestamp:[NSDate date]];
    double coordinateDifference = (double)([_myCurrentLoc distanceFromLocation:currentMapCenterLoc]);
    double altitudeDifference = abs(_myCurrentLoc.altitude - currentMapCenterLoc.altitude);
    double distanceToSnap = coordinateDifference + altitudeDifference;
    double animateDuration = log(distanceToSnap/300.0);
    if (animateDuration < 0.1) {
        animateDuration = 0.1;
    } else if (animateDuration > 1.5) {
        animateDuration = 1.5;
    }
    [self resetMapCameraWithDuration:animateDuration];
}

-(void)resetMapCameraWithDuration:(CGFloat)duration
{
    if (_mapView.isPitchEnabled && _perspectiveButton.toggled && _mapView.mapType == MKMapTypeStandard) {
        [UIView animateWithDuration:duration animations:^{
            _mapView.camera = MKMapCamera_3D_DEFAULT;
        } completion:^(BOOL finished) {
            _firstZoomAnimationDone = YES;
        }];
    } else {
        [UIView animateWithDuration:duration animations:^{
            _mapView.camera = MKMapCamera_2D_DEFAULT;
        } completion:^(BOOL finished) {
            _firstZoomAnimationDone = YES;
        }];
    }
}

#pragma Location sending

- (IBAction)getAtMePressed:(id)sender {
    if (!_popupView.isHidden) {
        [self popupHide];
    }
    if(![MFMessageComposeViewController canSendText]) {
        UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Sorry!" message:@"Your device does not support SMS." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [warningAlert show];
        return;
    }
    
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
    
    NSString *message = [NSString stringWithFormat:@"Get At Me!\n\nApple Maps (Any Device): %@\n\nGoogle Maps (iOS App): %@", appleMapsURL, googleMapsAppURL];
    
    MFMessageComposeViewController *messageController = [MFMessageComposeViewController new];
    messageController.messageComposeDelegate = self;
    messageController.body = message;
    //snapshot map view if switch is toggled
    if (_mapSnapSwitch.isOn && [MFMessageComposeViewController canSendAttachments]) {
        MKMapSnapshotOptions *options = [MKMapSnapshotOptions new];
        options.region = _mapView.region;
        options.size = _mapView.frame.size;
        if (_mapView.mapType == MKMapTypeStandard) {
            options.scale = 1.0;
        } else {
            options.showsPointsOfInterest = NO;
            options.scale = 2.0;
        }
        options.mapType = _mapView.mapType;
        options.camera = _mapView.camera;
        MKMapSnapshotter *snapshotter = [[MKMapSnapshotter alloc] initWithOptions:options];
        [snapshotter startWithCompletionHandler:^(MKMapSnapshot *snapshot, NSError *error) {
            if (error) {
                NSLog(@"[Error] %@", error);
                return;
            }
            MKAnnotationView *pin = [[MKPinAnnotationView alloc] initWithAnnotation:nil reuseIdentifier:nil];
            
            UIImage *image = snapshot.image;
            UIGraphicsBeginImageContextWithOptions(image.size, YES, image.scale);
            {
                [image drawAtPoint:CGPointMake(0.0f, 0.0f)];
                CGPoint point = [snapshot pointForCoordinate:_mapView.userLocation.location.coordinate];
                point.x = point.x + pin.centerOffset.x - (pin.bounds.size.width / 2.0f);
                point.y = point.y + pin.centerOffset.y - (pin.bounds.size.height / 2.0f);
                [pin.image drawAtPoint:point];
                
                UIImage *compositeImage = UIGraphicsGetImageFromCurrentImageContext();
                NSData *imageData;
                if (_mapView.mapType == MKMapTypeStandard) {
                    imageData = UIImageJPEGRepresentation(compositeImage, 0.5);
                } else {
                    imageData = UIImageJPEGRepresentation(compositeImage, 0.5);
                }
                [messageController addAttachmentData:imageData typeIdentifier:(__bridge NSString *)kUTTypeJPEG filename:@"MapSnap.jpeg"];
            }
            UIGraphicsEndImageContext();
            self.canDisplayBannerAds = NO;

            [self presentViewController:messageController animated:YES completion:^{
                _mapView.showsUserLocation = NO;
            }];
        }];
    } else {
        // Present message view controller on screen (modal)
        self.canDisplayBannerAds = NO;

        [self presentViewController:messageController animated:YES completion:^{
            _mapView.showsUserLocation = NO;
        }];
    }
}

-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    _mapView.showsUserLocation = YES;
    [controller dismissViewControllerAnimated:YES completion:^{
        if (result == MFMailComposeResultFailed) {
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your SMS failed to send! Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
        } else {
            [self requestInterstitialAdPresentation];
        }
        self.canDisplayBannerAds = YES;
    }];
}
- (IBAction)mapSnapSwitchToggled:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:_mapSnapSwitch.isOn forKey:@"mapSnapSwitchState"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma iAd

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
