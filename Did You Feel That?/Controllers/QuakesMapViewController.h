//
//  QuakesMapViewController.h
//  Did You Feel That?
//
//  Created by Emily Priddy on 9/22/15.
//  Copyright (c) 2015 Headstorm Studios. All rights reserved.
//

@import UIKit;
@import CoreLocation;
@import MapKit;
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import "DYFTNavigationController.h"

@class Quake;

@interface QuakesMapViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) IBOutlet MKMapView *mapView;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *currentLocation;

@property (strong, nonatomic) NSMutableArray *feltByUserQuakes;
@property (strong, nonatomic) NSMutableArray *notFeltByUserQuakes;
@property (strong, nonatomic) DYFTNavigationController *navController;

- (void)setCurrentLocation:(CLLocation *)currentLocation;

@end
