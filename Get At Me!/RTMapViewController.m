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

#define POPUP_SHOW_FRAME CGRectMake(0, [[UIScreen mainScreen] bounds].size.height - 259, 230, 165)
#define POPUP_HIDE_FRAME CGRectMake(0, [[UIScreen mainScreen] bounds].size.height - 94, 1, 1)

@end

@implementation RTMapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //configure map view
    _myCurrentLoc = [CLLocation new];
    
    //configure location manager
    _locManager = [CLLocationManager new];
    _locManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    _locManager.delegate = self;
    [_locManager startUpdatingLocation];
    
    [self.view bringSubviewToFront:_toolbar];
    
    _snapshot = [_popupView snapshotViewAfterScreenUpdates:NO];
    _snapshot.frame = _popupView.frame;
    [self.view addSubview:_snapshot];
    [self.view bringSubviewToFront:_snapshot];
    _snapshot.frame = POPUP_HIDE_FRAME;
    _popupView.hidden = YES;
    _snapshot.hidden = YES;
}

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
    _snapshot.frame = _popupView.frame;
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
    if (sender.selectedSegmentIndex == 0) {
        _appleMapView.mapType = MKMapTypeStandard;
        [UIView animateWithDuration:0.8 animations:^{
            _appleMapView.camera = [MKMapCamera cameraLookingAtCenterCoordinate:_myCurrentLoc.coordinate fromEyeCoordinate:CLLocationCoordinate2DMake(_myCurrentLoc.coordinate.latitude - 0.006, _myCurrentLoc.coordinate.longitude + 0.003) eyeAltitude:30];
        } completion:^(BOOL finished) {
            sender.enabled = YES;
        }];
    } else if (sender.selectedSegmentIndex == 1) {
        MKMapCamera *newCam = [self simulateMapCameraUponChangeToHybrid];
        [UIView animateWithDuration:1.0 animations:^{
            _appleMapView.camera = newCam;
        } completion:^(BOOL finished) {
            _appleMapView.mapType = MKMapTypeHybrid;
            sender.enabled = YES;
        }];
    }
}

-(MKMapCamera *)simulateMapCameraUponChangeToHybrid
{
    //create clean copy of current camera
    MKMapCamera *currentCam = [MKMapCamera camera];
    currentCam.centerCoordinate = _appleMapView.camera.centerCoordinate;
    currentCam.heading = _appleMapView.camera.heading;
    currentCam.pitch = _appleMapView.camera.pitch;
    currentCam.altitude = _appleMapView.camera.altitude;
    
    //create dummy map view copy, then mutate - heading, pitch, altitude changes are the critical component
    MKMapView *dummyMapView = [[MKMapView alloc] initWithFrame:_appleMapView.frame];
    dummyMapView.mapType = MKMapTypeStandard;
    dummyMapView.camera = currentCam;
    dummyMapView.mapType = MKMapTypeHybrid;
    dummyMapView.camera = [MKMapCamera cameraLookingAtCenterCoordinate:_myCurrentLoc.coordinate fromEyeCoordinate:CLLocationCoordinate2DMake(_myCurrentLoc.coordinate.latitude - 0.006, _myCurrentLoc.coordinate.longitude + 0.003) eyeAltitude:30];
    
    return dummyMapView.camera;
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
    CLLocation *currentMapCenterLoc = [[CLLocation alloc] initWithLatitude:_appleMapView.centerCoordinate.latitude longitude:_appleMapView.centerCoordinate.longitude];
    double distanceToSnap = [_myCurrentLoc distanceFromLocation:currentMapCenterLoc];
    double animateDuration = (log(distanceToSnap))/9;
    [self resetMapCameraWithDuration:animateDuration completion:nil];
}

-(void)resetMapCameraWithDuration:(CGFloat)duration completion:(void (^)(void))completion
{
    [UIView animateWithDuration:duration animations:^{
        _appleMapView.camera = [MKMapCamera cameraLookingAtCenterCoordinate:_myCurrentLoc.coordinate fromEyeCoordinate:CLLocationCoordinate2DMake(_myCurrentLoc.coordinate.latitude - 0.006, _myCurrentLoc.coordinate.longitude + 0.003) eyeAltitude:30];
    } completion:^(BOOL finished) {
        if (completion) {
            _firstZoomAnimationDone = YES;
        }
    }];
}

#pragma Location Sending

- (IBAction)getAtMePressed:(id)sender {
    if(![MFMessageComposeViewController canSendText]) {
        UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your device doesn't support SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
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
    
    NSString *message = [NSString stringWithFormat:@"Get At Me!\n\nApple Maps (iOS): %@\n\nGoogle Maps App (Any): %@", appleMapsURL, googleMapsAppURL];
    
    [_locManager stopUpdatingLocation];
    
    MFMessageComposeViewController *messageController = [MFMessageComposeViewController new];
    messageController.messageComposeDelegate = self;
    messageController.subject = @"Come At Me!";
    messageController.body = message;
    //snapshot map view in case receiver doesn't have a smartphone/dataplan.
    if (_mapSnapSwitch.isOn && [MFMessageComposeViewController canSendAttachments]) {
        UIGraphicsBeginImageContext(_appleMapView.frame.size);
        [_appleMapView drawViewHierarchyInRect:_appleMapView.frame afterScreenUpdates:NO];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [messageController addAttachmentData:UIImageJPEGRepresentation(image, 0.5) typeIdentifier:(__bridge NSString *)kUTTypeJPEG filename:@"MapSnap.jpeg"]; //~30kb, still very legible
    }
    
    // Present message view controller on screen
    [self presentViewController:messageController animated:YES completion:nil];
}

-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [controller dismissViewControllerAnimated:YES completion:^{
        [_locManager startUpdatingLocation];
        if (result == MFMailComposeResultFailed) {
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your SMS failed to send! Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
