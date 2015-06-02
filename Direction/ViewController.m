//
//  ViewController.m
//  Direction
//
//  Created by Pradip on 6/1/15.
//  Copyright (c) 2015 Pradip. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <AddressBook/AddressBook.h>

@interface ViewController () <CLLocationManagerDelegate>

@property (strong, nonatomic) IBOutlet UIButton *btnGetLocation;
@property (strong, nonatomic) IBOutlet UILabel *lblLatitude;
@property (strong, nonatomic) IBOutlet UILabel *lblLongitude;
@property (strong, nonatomic) IBOutlet UILabel *lblAddress;
@property (strong, nonatomic) IBOutlet UITextView *lblToAddress;
@property (strong, nonatomic) IBOutlet UIButton *btnGetDistance;
@property (strong, nonatomic) IBOutlet UILabel *lblDistance;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *startLocation;
@property (strong, nonatomic) CLLocation *toLocation;

- (IBAction)btnGetLocationTouched:(id)sender;
- (IBAction)btnGetDistanceTouched:(id)sender;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:[[NSString alloc]
                                    initWithFormat:@"Madison Avenue New York, NY 10017"]
                 completionHandler:^(NSArray *placemarks, NSError *error) {
                     if (error) {
                         NSLog(@"Geocode failed with error: %@", error);
                         return;
                     }
                     if(placemarks && placemarks.count > 0) {
                         CLPlacemark *placemark = placemarks[0];
                         CLLocation *location = placemark.location;
                         _startLocation = location;
                     }
                 }];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnGetLocationTouched:(id)sender {
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    _locationManager.delegate = self;
    if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
    {
        [_locationManager requestWhenInUseAuthorization];
    }
    [_locationManager startUpdatingLocation];
}



-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *newLocation = [locations lastObject];
    NSString *currentLatitude = [[NSString alloc]
                                 initWithFormat:@"Latitude = %+.6f",
                                 newLocation.coordinate.latitude];
    self.lblLatitude.text = currentLatitude;
    
    NSString *currentLongitude = [[NSString alloc]
                                  initWithFormat:@"Longitude = %+.6f",
                                  newLocation.coordinate.longitude];
    self.lblLongitude.text = currentLongitude;
    
    _startLocation = newLocation;
    [self ReverseGeocode:newLocation];
}

-(void)locationManager:(CLLocationManager *)manager
      didFailWithError:(NSError *)error
{
}

- (IBAction)btnGetDistanceTouched:(id)sender {
    [self Geocode];
}

- (void) Geocode {
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:self.lblToAddress.text
                 completionHandler:^(NSArray *placemarks, NSError *error) {
                     if (error) {
                         NSLog(@"Geocode failed with error: %@", error);
                         return;
                     }
                     if(placemarks && placemarks.count > 0) {
                         CLPlacemark *placemark = placemarks[0];
                         CLLocation *location = placemark.location;
                         _toLocation = location;
                         
                         CLLocationDistance distanceBetween = [_toLocation
                                                               distanceFromLocation:_startLocation];
                         
                         _lblDistance.text = [[NSString alloc]
                                              initWithFormat:@"%f miles",
                                              0.000621371 * distanceBetween];
                     }
                 }];
}

- (void) ReverseGeocode: (CLLocation *)newLocation {
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:newLocation
                   completionHandler:^(NSArray *placemarks,
                                       NSError *error) {
                       if (error) {
                           NSLog(@"Geocode failed with error: %@", error);
                           return;
                       }
                       if (placemarks && placemarks.count > 0) {
                           CLPlacemark *placemark = placemarks[0];
                           NSDictionary *addressDictionary = placemark.addressDictionary;
                           NSString *address = [addressDictionary objectForKey: (NSString *)kABPersonAddressStreetKey];
                           NSString *city = [addressDictionary objectForKey: (NSString *)kABPersonAddressCityKey];
                           NSString *state = [addressDictionary objectForKey: (NSString *)kABPersonAddressStateKey];
                           NSString *zip = [addressDictionary objectForKey: (NSString *)kABPersonAddressZIPKey];
                           self.lblAddress.text = [NSString localizedStringWithFormat: @"%@ %@ %@ %@", address,city, state, zip];
                       }
                   }];
}


@end
