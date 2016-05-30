//
//  ATLLocationKeyboardViewController.m
//  Pods
//
//  Created by Jesse Chand on 5/7/16.
//
//

#import <MapKit/MapKit.h>
#import "ATLLocationKeyboardViewController.h"
#import "ATLMessagingUtilities.h"
#import "CMAddressTableViewController.h"
#import "CMAddressSearchViewController.h"

@interface ATLLocationKeyboardViewController () < MKMapViewDelegate,
                                                  CLLocationManagerDelegate, CMAddressSearchDelegate >
@end

const CGFloat kPaddingHorizontal = 14.0f;
const CGFloat kBarHeight = 36.0f;

@implementation ATLLocationKeyboardViewController {
    MKMapView *_mapView;
    UIView *_addressBar;
//    UILabel *_addressLabel;
    UIButton *_locationButton;
    CLLocation *_initialLocation;
    CLLocationManager *_locationManager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self startLocationManager];

    // Add our UI components.
    _mapView = [[MKMapView alloc] init];
    _mapView.showsUserLocation = YES;
    _mapView.delegate = self;
    _mapView.tintColor = [UIColor colorWithRed:0.329 green:0.725 blue:0.882 alpha:1];
    [self.view addSubview:_mapView];

    [self _centerToUserLocation];

    _addressBar = [[UIView alloc] init];
    _addressBar.backgroundColor = [UIColor whiteColor];
    _addressBar.layer.cornerRadius = kBarHeight / 2.0f;
    _addressBar.layer.shadowColor = [UIColor blackColor].CGColor;
    _addressBar.layer.shadowRadius = 2.0f;
    _addressBar.clipsToBounds = YES;
    
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(addressTapped:)];
    [_addressBar addGestureRecognizer:singleFingerTap];
    
    [self.view addSubview:_addressBar];

    _addressLabel = [[UILabel alloc] init];
    _addressLabel.text = @"Select Location";
    _addressLabel.textColor = [UIColor grayColor];
    _addressLabel.font = [UIFont fontWithName:@"AvenirNext-Medium" size:17.0f];
    [self.view addSubview:_addressLabel];

    NSBundle *resourcesBundle = ATLResourcesBundle();
    _locationButton = [[UIButton alloc] init];
    [_locationButton setImage:[UIImage imageNamed:@"location_dark" inBundle:resourcesBundle compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [_locationButton addTarget:self action:@selector(_centerToUserLocation) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_locationButton];
}

//The event handling method
- (void)addressTapped:(UITapGestureRecognizer *)recognizer {
    CGPoint location = [recognizer locationInView:[recognizer.view superview]];
    
    CMAddressSearchViewController *atvc = [[CMAddressSearchViewController alloc] init];
    
    
    atvc.delegate = self;
    
    
    UINavigationController *navigationController =
    [[UINavigationController alloc] initWithRootViewController:atvc];
    
    
    [self.delegate presentLocationViewController:navigationController];
}

- (void)setSelectedAddress:(NSString*)address {
    
    _addressLabel.text = address;
    self.selection = [[NSMutableArray alloc] initWithArray:@[ _addressLabel.text ]];
    [self.delegate keyboard:self withType:ATLKeyboardTypeLocation didUpdateSelection:self.selection];
    [self.delegate popUpCustomKeyboard];
    
}


- (void)viewDidLayoutSubviews {
    // Layout our UI.
    _mapView.frame = self.view.bounds;
    _addressBar.frame = CGRectMake(kPaddingHorizontal,
                                   self.view.bounds.size.height - kPaddingHorizontal - kBarHeight,
                                   self.view.bounds.size.width - kPaddingHorizontal * 3 - kBarHeight,
                                   kBarHeight);
    _addressLabel.frame = CGRectMake(kPaddingHorizontal * 2,
                                     self.view.bounds.size.height - kPaddingHorizontal - kBarHeight,
                                     self.view.bounds.size.width - kPaddingHorizontal * 3 - kBarHeight - 15,
                                     kBarHeight);
    _locationButton.frame = CGRectMake(self.view.bounds.size.width - kPaddingHorizontal - kBarHeight,
                                       self.view.bounds.size.height - kPaddingHorizontal - kBarHeight,
                                       kBarHeight, kBarHeight);
}

- (void)_centerToUserLocation {
    MKCoordinateRegion region;
    region.center = _mapView.userLocation.coordinate;
    MKCoordinateSpan span;
    span.latitudeDelta  = 1;
    span.longitudeDelta = 1;
    region.span = span;
    [_mapView setRegion:region animated:YES];

    CLGeocoder *geocoder = [[CLGeocoder alloc]init];

    [geocoder reverseGeocodeLocation:_mapView.userLocation.location
                   completionHandler:^(NSArray *placemarks, NSError *error) {
                       if (!error) {
                           CLPlacemark *placemark = [placemarks objectAtIndex:0];
                           _addressLabel.text = placemark.name;
                           _addressLabel.textColor = [UIColor blackColor];
                           self.selection = [[NSMutableArray alloc] initWithArray:@[ _addressLabel.text ]];
                           [self.delegate keyboard:self withType:ATLKeyboardTypeLocation didUpdateSelection:self.selection];
                       }
                   }
     ];
}

#pragma mark - MKMapViewDelegate

- (void)startLocationManager {
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.distanceFilter = kCLDistanceFilterNone;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [_locationManager startUpdatingLocation];
    // TODO: test whether it is iOS 8+
    [_locationManager requestWhenInUseAuthorization];
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    if (!_initialLocation) {
        _initialLocation = userLocation.location;
        [self _centerToUserLocation];
    }
}

@end
