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
@property (nonatomic) BOOL firstZoomAnimationDone;
@property (weak, nonatomic) IBOutlet MKMapView *appleMapView;
@property (nonatomic, strong) CLLocationManager *locManager;
@property (nonatomic, strong) CLLocation *myCurrentLoc;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) NSArray *reverseGeocodeResults;
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
    _appleMapView.showsBuildings = YES;
    _appleMapView.showsPointsOfInterest = YES;
    _appleMapView.showsUserLocation = YES;
    
    //configure location manager
    _locManager = [CLLocationManager new];
    _locManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    _locManager.delegate = self;
    [_locManager startUpdatingLocation];
    
    [self.view bringSubviewToFront:_toolbar];
    _popupView.alpha = 0.0;
    _popupView.hidden = YES;
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
    _popupView.hidden = NO;
    _popupView.frame = POPUP_HIDE_FRAME;
    [UIView animateWithDuration:0.3 animations:^{
        _popupView.frame = POPUP_SHOW_FRAME;
        _popupView.alpha = 1.0;
    } completion:^(BOOL finished) {
        _popupButton.enabled = YES;
    }];
}

-(void)popupHide
{
    _popupButton.enabled = NO;
    [UIView animateWithDuration:0.3 animations:^{
        _popupView.frame = POPUP_HIDE_FRAME;
        _popupView.alpha = 0.0;
    } completion:^(BOOL finished) {
        _popupView.hidden = YES;
        _popupButton.enabled = YES;
    }];
}

- (IBAction)mapTypeChanged:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 0) {
        _appleMapView.mapType = MKMapTypeStandard;
        if (!_firstZoomAnimationDone) {
            return;
        }
        [UIView animateWithDuration:0.6 animations:^{
            _appleMapView.camera = [MKMapCamera cameraLookingAtCenterCoordinate:_appleMapView.centerCoordinate fromEyeCoordinate:CLLocationCoordinate2DMake(_appleMapView.centerCoordinate.latitude - 0.006, _appleMapView.centerCoordinate.longitude + 0.003) eyeAltitude:30];
        }];
    } else if (sender.selectedSegmentIndex == 1) {
        if (!_firstZoomAnimationDone) {
            _appleMapView.mapType = MKMapTypeHybrid;
            return;
        }
        [UIView animateWithDuration:0.0 animations:^{
            //_appleMapView.camera = [MKMapCamera cameraLookingAtCenterCoordinate:_appleMapView.centerCoordinate fromEyeCoordinate:_appleMapView.centerCoordinate eyeAltitude:30];
        } completion:^(BOOL finished) {
            _appleMapView.mapType = MKMapTypeHybrid;
        }];
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches) {
        if (CGRectContainsPoint(_appleMapView.frame, [touch locationInView:self.view]) && !_popupView.isHidden && _popupButton.isEnabled) {
            if (!CGRectContainsPoint(_popupView.frame, [touch locationInView:self.view])) {
                [self popupHide];
                break;
            }
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
    if (_firstZoomAnimationDone) {
        CLLocation *currentMapCenterLoc = [[CLLocation alloc] initWithLatitude:_appleMapView.centerCoordinate.latitude longitude:_appleMapView.centerCoordinate.longitude];
        double distanceToSnap = [_myCurrentLoc distanceFromLocation:currentMapCenterLoc];
        double animateDuration = (log(distanceToSnap))/9;
        [self resetMapCameraWithDuration:animateDuration completion:nil];
    }
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
