//
//  MapViewController.h
//  Did You Feel That?
//
//  Created by Emily Priddy on 8/25/15.
//  Copyright (c) 2015 Headstorm Studios. All rights reserved.
//

@import UIKit;
@import CoreLocation;
@import MapKit;
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>

@class Quake;

@interface MapViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *currentLocation;
@property (strong, nonatomic) UINavigationController *navController;
@property (strong, nonatomic) NSMutableArray *feltByUserQuakes;
@property (strong, nonatomic) NSMutableArray *notFeltByUserQuakes;

@end
