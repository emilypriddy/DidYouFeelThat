//
//  FeltMapVC.m
//  Did You Feel That?
//
//  Created by Emily Priddy on 6/20/15.
//  Copyright (c) 2015 Headstorm Studios. All rights reserved.
//

#import "FeltMapVC.h"

#import "DYFTConstants.h"
#import "UserEvent.h"

#define debug 1

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

@interface FeltMapVC ()
@property (strong, nonatomic) NSMutableArray *allEvents;
@property (strong, nonatomic) NSArray *allRelatedEvents;
@property (strong, nonatomic) Quake *quake;
@property (assign, nonatomic) BOOL mapPinsPlaced;
@property (assign, nonatomic) BOOL mapPannedSinceLocationUpdate;
@property (assign, nonatomic) BOOL deferringUpdates;
@end

@implementation FeltMapVC


- (void)viewDidLoad {
    if (debug == 1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    [super viewDidLoad];
    self.mapView.frame = self.view.bounds;
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.mapView.showsUserLocation = NO;
    self.mapView.delegate = self;

    self.title = @"Who Else Felt It?";

    // Do any additional setup after loading the view from its nib.
    if (IS_OS_8_OR_LATER) {
        [self.locationManager requestAlwaysAuthorization];
    }

    _allRelatedEvents = [[NSArray alloc] init];
    _allEvents = [[NSMutableArray alloc] initWithCapacity:500];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(eventWasCreated:)
                                                 name:DYFTQuakeCreatedNotification
                                               object:nil];

    self.mapPannedSinceLocationUpdate = NO;
    self.deferringUpdates = NO;

    [self updateLocations];

    if ([_allEvents count] > 0) {
        [self showLocations];
    }

//    [self startStandardUpdates];
}

- (void)viewWillAppear:(BOOL)animated {
    if (debug == 1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    [super viewWillAppear:animated];

//    if ([PFUser currentUser]) {
//        PFQuery *query = [PFQuery queryWithClassName:@"USGSQuakes"];
//        [query whereKey:@"feltByUsers" equalTo:[PFUser currentUser]];
//        [query whereKey:@"objectId" equalTo:_quakeObject.objectId];
//        [query setLimit:1000];
//
//        [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
//            self.userLocations = [[NSMutableArray alloc] init];
//            for (PFObject *object in results) {
//                Q
//            }
//        }];
//    }
//    [self.locationManager startUpdatingLocation];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:DYFTQuakeCreatedNotification object:nil];

//    [self startSignificantChangeUpdates];
}

//- (void)setCurrentLocation:(CLLocation *)currentLocation {
//    if (debug == 1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
//
//    // 1. Draw or move the search radius display
//    if (self.currentLocation == currentLocation) {
//        return;
//    }
//    _currentLocation = currentLocation;
//
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [[NSNotificationCenter defaultCenter] postNotificationName:DYFTCurrentLocationDidChangeNotification
//                                                            object:nil
//                                                          userInfo:@{ kDYFTLocationKey : currentLocation } ];
//    });
//}
//
//- (CLLocationManager *)locationManager {
//    if (debug == 1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
//
//    if (_locationManager == nil) {
//        _locationManager = [[CLLocationManager alloc] init];
//
//        _locationManager.delegate = self;
//        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
//
//        // Set a movement threshold for new events.
//        _locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters;
//    }
//    return _locationManager;
//}
//
//- (void)startStandardUpdates {
//    if (debug == 1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
//
//    [self.locationManager startUpdatingLocation];
//
//    CLLocation *currentLocation = self.locationManager.location;
//    if (currentLocation) {
//        self.currentLocation = currentLocation;
//    }
//}
//
//- (void)startSignificantChangeUpdates {
//    if (debug == 1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
//    if (self.locationManager == nil) {
//        self.locationManager = [[CLLocationManager alloc] init];
//        self.locationManager.delegate = self;
//    }
//    [self.locationManager startMonitoringSignificantLocationChanges];
//}
//
//- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
//    NSLog(@"%s", __PRETTY_FUNCTION__);
//    switch (status) {
//        case kCLAuthorizationStatusAuthorizedAlways:
//        {
//            NSLog(@"kCLAuthorizationStatusAuthorizedAlways");
//            // Re-enable the post button if it was disabled before.
//            self.navigationItem.rightBarButtonItem.enabled = YES;
//            [self.locationManager startUpdatingLocation];
//        }
//            break;
//        case kCLAuthorizationStatusDenied:
//            NSLog(@"kCLAuthorizationStatusDenied");
//        {
//            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Did You Feel That? can’t access your current location.\n\nTo view nearby events such as earthquakes or find out what caused you to just say 'Did You Feel That?' at your current location, turn on access for DYFT? to your location in the Settings app under Location Services." message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
//            [alertView show];
//            // Disable the post button.
//            self.navigationItem.rightBarButtonItem.enabled = NO;
//        }
//            break;
//        case kCLAuthorizationStatusNotDetermined:
//        {
//            NSLog(@"kCLAuthorizationStatusNotDetermined");
//        }
//            break;
//        case kCLAuthorizationStatusRestricted:
//        {
//            NSLog(@"kCLAuthorizationStatusRestricted");
//        }
//            break;
//        default:break;
//    }
//}
//
//- (void)locationManager:(CLLocationManager *)manager
//       didFailWithError:(NSError *)error {
//    NSLog(@"%s", __PRETTY_FUNCTION__);
//    NSLog(@"Error: %@", [error description]);
//
//    if (error.code == kCLErrorDenied) {
//        [self.locationManager stopUpdatingLocation];
//    } else if (error.code == kCLErrorLocationUnknown) {
//        // todo: retry?
//        // set a timer for five seconds to cycle location, and if it fails again, bail and tell the user.
//    } else {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error retrieving location"
//                                                        message:[error localizedDescription]
//                                                       delegate:nil
//                                              cancelButtonTitle:nil
//                                              otherButtonTitles:@"OK", nil];
//        [alert show];
//    }
//}

//- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
//    if (debug == 1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
//    id<MKAnnotation> annotation = [view annotation];
//    if ([annotation isKindOfClass:[UserEvent class]]) {
//        UserEvent *userEvent = [view annotation];
//        //        [self.quakesTableViewController highlightCellForQuake:quake];
//    } else if ([annotation isKindOfClass:[MKUserLocation class]]) {
//        // Center the map on the user's current location:
//        CLLocationAccuracy filterDistance = [[NSUserDefaults standardUserDefaults] doubleForKey:DYFTUserDefaultsFilterDistanceKey];
//        MKCoordinateRegion newRegion = MKCoordinateRegionMakeWithDistance(self.currentLocation.coordinate,
//                                                                          filterDistance * 2.0f,
//                                                                          filterDistance * 2.0f);
//
//        [self.mapView setRegion:newRegion animated:YES];
//        self.mapPannedSinceLocationUpdate = NO;
//    }
//}
//
//- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
//    if (debug == 1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
//    id<MKAnnotation> annotation = [view annotation];
//    if ([annotation isKindOfClass:[UserEvent class]]) {
//        UserEvent *userEvent = [view annotation];
//        //        [self.quakesTableViewController unhighlightCellForQuake:quake];
//    }
//}

//- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
//    if (debug == 1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
//    self.mapPannedSinceLocationUpdate = YES;
//}

//- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
//    if (debug == 1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
//    // Add code here to send the user's current location to Parse.
//
//    // Defer updates until the set amount of time has passed (currently one hour).
////    if (!self.deferringUpdates) {
//        [self.locationManager allowDeferredLocationUpdatesUntilTraveled:CLLocationDistanceMax timeout:DYFTLocationUpdatesTimeInterval];
//
//        self.deferringUpdates = YES;
//
//        [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error){
//            if (!error) {
//                [[PFUser currentUser] setObject:geoPoint forKey:@"location"];
//                [[PFUser currentUser] save];
//                CLLocation *newLocation = [[CLLocation alloc] initWithLatitude:geoPoint.latitude longitude:geoPoint.longitude];
//                self.currentLocation = newLocation;
//            }
//        }];
////    }
//}

- (void)updateLocations {
    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));

    PFRelation *relation = [_quakeObject relationForKey:DYFTQuakesRelatedUserEventsKey];
    PFQuery *query = [relation query];

    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
                        // The find succeeded.
            NSLog(@"# of results = %lu", (unsigned long)objects.count);
            NSMutableArray *newEvents = [[NSMutableArray alloc] initWithCapacity:500];
            NSMutableArray *allNewEvents = [[NSMutableArray alloc] initWithCapacity:[objects count]];

            for (PFObject *object in objects) {
                UserEvent *newEvent = [[UserEvent alloc] initWithPFObject:object];
                [allNewEvents addObject:newEvent];
                if (![_allEvents containsObject:newEvent]) {
                    [newEvents addObject:newEvent];
                }
            }

            NSMutableArray *eventsToRemove = [[NSMutableArray alloc] initWithCapacity:500];
            for (UserEvent *currentEvent in _allEvents) {
                if (![allNewEvents containsObject:currentEvent]) {
                    [eventsToRemove addObject:currentEvent];
                }
            }

            for (UserEvent *newEvent in newEvents) {
                [newEvent setTitleAndSubtitle:YES];
            }
            [self.mapView removeAnnotations:eventsToRemove];
            [self.mapView addAnnotations:newEvents];

            [_allEvents addObjectsFromArray:newEvents];
            [_allEvents removeObjectsInArray:eventsToRemove];

            }
        NSLog(@"_allEvents.count = %lu", (unsigned long)[_allEvents count]);
        if ([_allEvents count] > 0) {
            [self showLocations];

        }
    }];

}

- (void)showLocations {
    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));

//    [self.mapView showAnnotations:_allEvents animated:YES];
    MKCoordinateRegion region = [self regionForAnnotations:_allEvents];
    [self.mapView setRegion:region animated:YES];

//    MKMapRect zoomRect = MKMapRectNull;
//    for (id <MKAnnotation> annotation in self.mapView.annotations)
//    {
//        MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
//        MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1);
//        if (MKMapRectIsNull(zoomRect)) {
//            zoomRect = pointRect;
//        } else {
//            zoomRect = MKMapRectUnion(zoomRect, pointRect);
//        }
//    }
//    [self.mapView setVisibleMapRect:zoomRect edgePadding:UIEdgeInsetsMake(10, 10, 10, 10) animated:YES];
//    [self.mapView setVisibleMapRect:zoomRect animated:YES];
}

- (MKCoordinateRegion)regionForAnnotations:(NSArray *)annotations {
    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));

    MKCoordinateRegion region;

    if ([annotations count] == 0) {
        region = MKCoordinateRegionMakeWithDistance(self.mapView.userLocation.coordinate, 1000, 1000);
    } else if ([annotations count] == 1) {
        id <MKAnnotation> annotation = [annotations lastObject];
        region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 1000, 1000);
    } else {
        CLLocationCoordinate2D topLeftCoord;
        topLeftCoord.latitude = -90;
        topLeftCoord.longitude = 180;

        CLLocationCoordinate2D bottomRightCoord;
        bottomRightCoord.latitude = 90;
        bottomRightCoord.longitude = -180;

        for (id <MKAnnotation> annotation in annotations) {
            topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.coordinate.latitude); // returns the bigger top left latitude
            topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.coordinate.longitude); // returns the smaller top left longitude
            bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotation.coordinate.latitude); // returns the smaller bottom right latitude
            bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, annotation.coordinate.longitude); // returns the bigger bottom right longitude
        }

        const double extraSpace = 1.1;

        region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) / 2.0;
        region.center.longitude = topLeftCoord.longitude - (topLeftCoord.longitude - bottomRightCoord.longitude) / 2.0;

        region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * extraSpace;
        region.span.longitudeDelta = fabs(topLeftCoord.longitude - bottomRightCoord.longitude) * extraSpace;
    }
    return [self.mapView regionThatFits:region];
}


#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));

    if (![annotation isKindOfClass:[UserEvent class]]) {
        return nil;
    }

    UserEvent *a = (UserEvent *)annotation;
    static NSString *defaultPinID = @"StandardIdentifier";

    ZSPinAnnotation *pinView = (ZSPinAnnotation *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:defaultPinID];
    if (pinView == nil) {
        pinView = [[ZSPinAnnotation alloc] initWithAnnotation:annotation reuseIdentifier:defaultPinID];
    }

    pinView.annotationType = ZSPinAnnotationTypeTagStroke;
    pinView.annotationColor = a.color;
    pinView.canShowCallout = YES;

    return pinView;


//    if ([annotation isKindOfClass:[MKUserLocation class]]) {
//        return nil;
//    }
//
//    static NSString *identifier = @"Location";
//
//    if ([annotation isKindOfClass:[UserEvent class]]) {
//        MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
//        if (!annotationView) {
//            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
//        } else {
//            annotationView.annotation = annotation;
//        }
//        annotationView.enabled = YES;
//        annotationView.canShowCallout = YES;
//        annotationView.animatesDrop = [((UserEvent *)annotation) animatesDrop];
//        annotationView.pinColor = [(UserEvent *)annotation pinColor];
//        annotationView.tintColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
//        return annotationView;
//    }
//    return nil;
}

@end
