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
#import "RTPerspectiveButton.h"
#import "RTResetCameraButton.h"

@interface RTMapViewController () <MKMapViewDelegate, CLLocationManagerDelegate, MFMessageComposeViewControllerDelegate>

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
@property (nonatomic) BOOL mapIs3D;

#define POPUP_SHOW_FRAME CGRectMake(0, [[UIScreen mainScreen] bounds].size.height - 259, 230, 165)
#define POPUP_HIDE_FRAME CGRectMake(0, [[UIScreen mainScreen] bounds].size.height - 94, 1, 1)

@end

@implementation RTMapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _mapSnapSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"mapSnapSwitchState"];
    _perspectiveButton.toggled = [[NSUserDefaults standardUserDefaults] boolForKey:@"threeDimensionsButtonState"];
    
    if (_appleMapView.isPitchEnabled) {
        _mapIs3D = YES;
        _perspectiveButton.toggled = YES;
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
    
    [self.view bringSubviewToFront:_toolbar];
    
    _snapshot = [_popupView snapshotViewAfterScreenUpdates:YES];
    [self.view addSubview:_snapshot];
    [self.view bringSubviewToFront:_snapshot];
    _snapshot.frame = POPUP_HIDE_FRAME;
    _popupView.hidden = YES;
    _snapshot.hidden = YES;
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
    [self.view bringSubviewToFront:_snapshot];
    [UIView animateWithDuration:0.3 animations:^{
        _snapshot.frame = POPUP_SHOW_FRAME;
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
    _snapshot.frame = POPUP_SHOW_FRAME;
    [self.view addSubview:_snapshot];
    [self.view bringSubviewToFront:_snapshot];
    _popupView.hidden = YES;
    [UIView animateWithDuration:0.3 animations:^{
        _snapshot.frame = POPUP_HIDE_FRAME;
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
    MKMapCamera *newCam = [MKMapCamera cameraLookingAtCenterCoordinate:_myCurrentLoc.coordinate fromEyeCoordinate:_myCurrentLoc.coordinate eyeAltitude:2000];
    if (sender.selectedSegmentIndex == 0) {
        _appleMapView.mapType = MKMapTypeStandard;
        if (_appleMapView.isPitchEnabled && _mapIs3D) {
            newCam = [MKMapCamera cameraLookingAtCenterCoordinate:_myCurrentLoc.coordinate fromEyeCoordinate:CLLocationCoordinate2DMake(_myCurrentLoc.coordinate.latitude - 0.006, _myCurrentLoc.coordinate.longitude + 0.003) eyeAltitude:30];
        }
        _perspectiveButton.frame = CGRectMake(340, _perspectiveButton.frame.origin.y, _perspectiveButton.frame.size.width, _perspectiveButton.frame.size.height);
        _perspectiveButton.hidden = NO;
        [UIView animateWithDuration:1.0 animations:^{
            _appleMapView.camera = newCam;
            _perspectiveButton.frame = CGRectMake(260, _perspectiveButton.frame.origin.y, _perspectiveButton.frame.size.width, _perspectiveButton.frame.size.height);
        } completion:^(BOOL finished) {
            sender.enabled = YES;
            _resetCameraButton.enabled = YES;
        }];
    } else if (sender.selectedSegmentIndex == 1) {
        [UIView animateWithDuration:1.0 animations:^{
            _appleMapView.camera = newCam;
            _perspectiveButton.frame = CGRectMake(340, _perspectiveButton.frame.origin.y, _perspectiveButton.frame.size.width, _perspectiveButton.frame.size.height);
        } completion:^(BOOL finished) {
            _appleMapView.mapType = MKMapTypeHybrid;
            sender.enabled = YES;
            _resetCameraButton.enabled = YES;
            _perspectiveButton.hidden = YES;
        }];
    }
}

-(void)changeMapDimensionsWith3DState:(BOOL)newDimension
{
    if (_mapIs3D != newDimension) {
        _mapIs3D = newDimension;
        NSOperationQueue *queue = [NSOperationQueue new];
        if (_mapIs3D) {
            [UIView animateWithDuration:0.7 animations:^{
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
            [UIView animateWithDuration:0.7 animations:^{
                _appleMapView.camera = [MKMapCamera cameraLookingAtCenterCoordinate:_myCurrentLoc.coordinate fromEyeCoordinate:_myCurrentLoc.coordinate eyeAltitude:700];
            } completion:^(BOOL finished) {
                [queue addOperationWithBlock:^{
                    usleep(250000);
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        [UIView animateWithDuration:0.7 animations:^{
                            _appleMapView.camera = [MKMapCamera cameraLookingAtCenterCoordinate:_myCurrentLoc.coordinate fromEyeCoordinate:_myCurrentLoc.coordinate eyeAltitude:2000];
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
        if (![[self.view hitTest:[touch locationInView:self.view] withEvent:event] isEqual:_popupView] && !_popupView.isHidden) {
            [self popupHide];
            break;
        }
    }
}

- (IBAction)perspectiveButtonPressed:(id)sender {
    if (_mapIs3D) {
        _perspectiveButton.toggled = NO;
        [self changeMapDimensionsWith3DState:NO];
    } else {
        _perspectiveButton.toggled = YES;
        [self changeMapDimensionsWith3DState:YES];
    }
    [_perspectiveButton setNeedsDisplay];
    [UIView transitionWithView:_perspectiveButton duration:0.1 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [_perspectiveButton.layer displayIfNeeded];
    } completion:nil];
    [[NSUserDefaults standardUserDefaults] setBool:_perspectiveButton.toggled forKey:@"threeDimensionsButtonState"];
    [[NSUserDefaults standardUserDefaults] synchronize];

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
    [UIView transitionWithView:_resetCameraButton duration:0.1 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [_perspectiveButton.layer displayIfNeeded];
    } completion:^(BOOL finished) {
        _resetCameraButton.pressed = NO;
        [_resetCameraButton setNeedsDisplay];
        [UIView transitionWithView:_resetCameraButton duration:1.0 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
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
        [UIView animateWithDuration:duration animations:^{
            _appleMapView.camera = [MKMapCamera cameraLookingAtCenterCoordinate:_myCurrentLoc.coordinate fromEyeCoordinate:CLLocationCoordinate2DMake(_myCurrentLoc.coordinate.latitude - 0.006, _myCurrentLoc.coordinate.longitude + 0.003) eyeAltitude:30];
        } completion:^(BOOL finished) {
            if (completion) {
                _firstZoomAnimationDone = YES;
            }
        }];
    } else {
        [UIView animateWithDuration:duration animations:^{
            _appleMapView.camera = [MKMapCamera cameraLookingAtCenterCoordinate:_myCurrentLoc.coordinate fromEyeCoordinate:_myCurrentLoc.coordinate eyeAltitude:700];
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
    
    NSString *message = [NSString stringWithFormat:@"Get At Me!\nApple Maps (iOS): %@\n\nGoogle Maps App (Any): %@", appleMapsURL, googleMapsAppURL];
    
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
    [[NSUserDefaults standardUserDefaults] setBool:_mapSnapSwitch.isOn forKey:@"threeDimensionsButtonState"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [_locManager stopUpdatingLocation];
    [super viewWillDisappear:animated];
}

-(void)viewWillAppear:(BOOL)animated
{
    [_locManager startUpdatingLocation];
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
