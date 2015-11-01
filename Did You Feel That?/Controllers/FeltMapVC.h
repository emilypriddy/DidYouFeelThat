//
//  FeltMapVC.h
//  Did You Feel That?
//
//  Created by Emily Priddy on 6/20/15.
//  Copyright (c) 2015 Headstorm Studios. All rights reserved.
//

@import UIKit;
@import MapKit;
@import CoreLocation;
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>

@interface FeltMapVC : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) NSString *quakeID;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *currentLocation;

@property (strong, nonatomic) PFObject *quakeObject;

@property (strong, nonatomic) NSMutableArray *userLocations;
@end
