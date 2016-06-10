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
    UIButton *_locationButton;
    CLLocation *_initialLocation;
    CLLocationManager *_locationManager;
    UIButton *_addressBarButton;
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
    
    _addressBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _addressBarButton.contentMode = UIViewContentModeCenter;
    _addressBarButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_addressBarButton setBackgroundColor:[UIColor whiteColor]];
    _addressBarButton.layer.cornerRadius = kBarHeight/2.0f;
    _addressBarButton.layer.shadowColor = [UIColor blackColor].CGColor;
    _addressBarButton.layer.shadowRadius = 2.0f;
    _addressBarButton.clipsToBounds = YES;
    [_addressBarButton addTarget:self action:@selector(addressTapped) forControlEvents:UIControlEventTouchUpInside];
    [_addressBarButton setTitle:@"Select Location" forState:UIControlStateNormal];
    [_addressBarButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [_addressBarButton.titleLabel setFont:[UIFont fontWithName:@"AvenirNext-Medium" size:17.0f]];
    [self.view addSubview:_addressBarButton];
    
    NSBundle *resourcesBundle = ATLResourcesBundle();
    _locationButton = [[UIButton alloc] init];
    [_locationButton setImage:[UIImage imageNamed:@"location_dark" inBundle:resourcesBundle compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [_locationButton addTarget:self action:@selector(_centerToUserLocation) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_locationButton];
}

//The event handling method
- (void)addressTapped {
    
    CMAddressSearchViewController *atvc = [[CMAddressSearchViewController alloc] init];
    
    
    atvc.delegate = self;
    
    
    UINavigationController *navigationController =
    [[UINavigationController alloc] initWithRootViewController:atvc];
    
    
    [self.delegate presentLocationViewController:navigationController];
}

- (void)setSelectedAddress:(NSString*)address {
    
    [_addressBarButton setTitle:address forState:UIControlStateNormal];
    self.selection = [[NSMutableArray alloc] initWithArray:@[ _addressBarButton.titleLabel.text ]];
    [self.delegate keyboard:self withType:ATLKeyboardTypeLocation didUpdateSelection:self.selection];
    [self.delegate popUpCustomKeyboard];
    [self _centerToSelectedAddress:address];
    
}

- (void)popUpCustomKeyboard {
    [self.delegate popUpCustomKeyboard];
}


- (void)viewDidLayoutSubviews {
    // Layout our UI.
    _mapView.frame = self.view.bounds;
    _addressBarButton.frame = CGRectMake(kPaddingHorizontal,
                                         self.view.bounds.size.height - kPaddingHorizontal - kBarHeight,
                                         self.view.bounds.size.width - kPaddingHorizontal * 3 - kBarHeight,
                                         kBarHeight);
    _addressBarButton.titleLabel.frame = CGRectMake(kPaddingHorizontal * 2,
                                                    self.view.bounds.size.height - kPaddingHorizontal - kBarHeight,
                                                    self.view.bounds.size.width - kPaddingHorizontal * 3 - kBarHeight - 15,
                                                    kBarHeight);
    _locationButton.frame = CGRectMake(self.view.bounds.size.width - kPaddingHorizontal - kBarHeight,
                                       self.view.bounds.size.height - kPaddingHorizontal - kBarHeight,
                                       kBarHeight, kBarHeight);
}

- (void)_centerToSelectedAddress:(NSString*)address {
    NSString *location = [address copy];
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:location
                 completionHandler:^(NSArray* placemarks, NSError* error){
                     if (placemarks && placemarks.count > 0) {
                         CLPlacemark *topResult = [placemarks objectAtIndex:0];
                         MKPlacemark *placemark = [[MKPlacemark alloc] initWithPlacemark:topResult];
                         
                         MKCoordinateRegion region = _mapView.region;
                         region.center = placemark.region.center;
                         region.span.longitudeDelta /= 8.0;
                         region.span.latitudeDelta /= 8.0;
                         
                         [_mapView setRegion:region animated:YES];
                         [_mapView addAnnotation:placemark];
                     }
                 }
     ];
}

- (void)_centerToUserLocation {
    MKCoordinateRegion region;
    region.center = _mapView.userLocation.coordinate;
    MKCoordinateSpan span;
    span.latitudeDelta  = 0.1;
    span.longitudeDelta = 0.1;
    region.span = span;
    [_mapView setRegion:region animated:YES];
    
    CLGeocoder *geocoder = [[CLGeocoder alloc]init];
    
    [geocoder reverseGeocodeLocation:_mapView.userLocation.location
                   completionHandler:^(NSArray *placemarks, NSError *error) {
                       if (!error) {
                           CLPlacemark *placemark = [placemarks objectAtIndex:0];
                           [_addressBarButton setTitle:[NSString stringWithFormat:@"%@, %@, %@", placemark.name, placemark.locality, placemark.administrativeArea] forState:UIControlStateNormal];
                           _addressBarButton.titleLabel.textColor = [UIColor blackColor];
                           self.selection = [[NSMutableArray alloc] initWithArray:@[ _addressBarButton.titleLabel.text ]];
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
