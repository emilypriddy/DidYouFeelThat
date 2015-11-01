//
//  AllQuakesMapVC.m
//  Did You Feel That?
//
//  Similar to Parse Anywall's PAWWallViewController 
//
//  Created by Emily Priddy on 6/10/15.
//  Copyright (c) 2015 Headstorm Studios. All rights reserved.
//

#import "AllQuakesMapViewController.h"

#import "DYFTConstants.h"
#import "Quake.h"
#import "QuakeRegisterVC.h"
#import "SetupViewController.h"
#import "UserLoginVC.h"
#import "AppDelegate.h"
#import "utilities.h"
#import "AllQuakesTableViewController.h"
#import "QuakeFiltersViewController.h"
#import <DTMHeatmap/DTMHeatmapRenderer.h>
#import <DTMHeatmap/DTMDiffHeatmap.h>

#import <CCHMapClusterController/CCHMapClusterController.h>

#define kDetailSegue @"tagDetail"

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

@interface AllQuakesMapViewController () <QuakeRegisterViewControllerDataSource, SetupViewControllerDelegate, AllQuakesTableViewControllerDataSource>

//@property (nonatomic, strong) MKCircle *circleOverlay;
@property (nonatomic, strong) NSMutableArray *annotations;
@property (nonatomic, assign) BOOL mapPinsPlaced;
@property (nonatomic, assign) BOOL mapPannedSinceLocationUpdate;

@property (nonatomic, strong) NSMutableArray *allQuakes;

@property (nonatomic, assign) BOOL deferringUpdates;

@property (strong, nonatomic) DTMHeatmap *heatmap;
@property (strong, nonatomic) DTMDiffHeatmap *diffHeatmap;
@property (strong, nonatomic) NSDictionary *quakeDictionary;
@property (strong, nonatomic) NSDictionary *firstDictionary;
@property (strong, nonatomic) NSDictionary *secondDictionary;
@property (strong, nonatomic) NSMutableDictionary *tempDict;
@property (strong, nonatomic) NSMutableDictionary *firstTempDict;
@property (strong, nonatomic) NSMutableDictionary *secondTempDict;
@property (strong, nonatomic) AppDelegate *appDelegate;

@property (strong, nonatomic) CCHMapClusterController *mapClusterController;
@property (strong, nonatomic) AllQuakesTableViewController *allQuakesTableViewController;
@end

@implementation AllQuakesMapViewController
#define debug 1

#pragma mark - UIViewController

- (void)viewDidLoad {
    if (debug == 1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));

    [super viewDidLoad];

    self.mapView.frame = self.view.bounds;
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.mapView.showsUserLocation = YES;
    self.mapView.delegate = self;

    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    self.title = @"Quakes Map";

    // Do any additional setup after loading the view from its nib.
    if (IS_OS_8_OR_LATER) {
        [self.locationManager requestAlwaysAuthorization];
    }

    //    if ([PFUser currentUser] != nil)
    //    {
    //        [self loadEventsTableViewController];
    //    }

//    [self loadQuakesTableViewController];

    // Create the AllQuakesTableViewController
    self.allQuakesTableViewController = [[AllQuakesTableViewController alloc] initWithStyle:UITableViewStylePlain];
    self.allQuakesTableViewController.dataSource = self;

    // Add the AllQuakesTableViewController as a child of AllQuakesMapViewController
    [self addChildViewController:self.allQuakesTableViewController];
    
#pragma mark - TODO: add this didMoveToParentViewController: method to appropriate method when we actually want to present the AllQuakesTableViewController
//    [self.allQuakesTableViewController didMoveToParentViewController:self];


    _annotations = [[NSMutableArray alloc] initWithCapacity:200];
    _allQuakes = [[NSMutableArray alloc] initWithCapacity:200];

    NSLog(@"currentUser = %@", [PFUser currentUser]);
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(distanceFilterDidChange:)
                                                 name:DYFTDistanceFilterDidChangeNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(quakeWasCreated:)
                                                 name:DYFTQuakeCreatedNotification
                                               object:nil];

    self.navController = [[DYFTNavigationController alloc] init];

    // Set nav bar items.
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"List View"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(listViewButtonSelected:)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Filter"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(filterButtonSelected:)];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];

    self.mapPannedSinceLocationUpdate = NO;

    self.deferringUpdates = NO;

    [self updateLocations];

    if ([_allQuakes count] > 0) {
        [self showLocations];
    }

    if ([PFUser currentUser] != nil) {
        [self fetchQuakeData];
        [self setupHeatmaps];
    }
    [self startStandardUpdates];
}

- (void)viewDidAppear:(BOOL)animated {
    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));

    if ([PFUser currentUser] != nil)
    {

    }
    else LoginUser(self);
}

- (void)setupHeatmaps {
    if (debug == 1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    self.heatmap = [DTMHeatmap new];
    if (self.quakeDictionary) {
        [self.heatmap setData:self.quakeDictionary];
//        NSLog(@"self.quakeDictionary = %@", self.quakeDictionary);
    }
    [self.mapView addOverlay:self.heatmap];
}

- (void)fetchQuakeData {
    if (debug == 1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    self.tempDict = [NSMutableDictionary new];
    // Query #1 - Felt it query
    PFQuery *query = [PFQuery queryWithClassName:@"USGSQuakes"];
    [query whereKey:@"feltByUsers" equalTo:[PFUser currentUser]];
    NSLog(@"[query whereKey:@'feltByUsers' equalTo:[PFUser %@]]",[PFUser currentUser]);
    [query setLimit:1000];

    //[query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
    NSArray *results = [query findObjects];
    for (PFObject *object in results) {
        PFGeoPoint *geoPoint = object[DYFTQuakesLocationKey];
        CLLocationDegrees latitude = geoPoint.latitude;
        CLLocationDegrees longitude = geoPoint.longitude;

        double weight = [object[DYFTQuakesMagnitudeKey] doubleValue];
//        NSLog(@"weight = %f", weight);

        CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude
                                                          longitude:longitude];

        MKMapPoint point = MKMapPointForCoordinate(location.coordinate);
        NSValue *pointValue = [NSValue value:&point withObjCType:@encode(MKMapPoint)];
        self.tempDict[pointValue] = @(weight * 10);
//        NSLog(@"Found: %@", object[DYFTQuakesPlaceKey]);

    }
    self.quakeDictionary = [[NSDictionary alloc] initWithDictionary:self.tempDict];

    //}];
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    if (debug == 1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    return [[DTMHeatmapRenderer alloc] initWithOverlay:overlay];
}


- (void)viewWillAppear:(BOOL)animated {
    if (debug == 1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    [super viewWillAppear:animated];

    // TODO: Need to delete these queries OR the duplicate query in fetchQuakeData!
    if ([PFUser currentUser]) {
    // Query #1 - Felt it query
        PFQuery *query = [PFQuery queryWithClassName:@"USGSQuakes"];
        [query whereKey:@"feltByUsers" equalTo:[PFUser currentUser]];
        [query setLimit:1000];

        [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
            self.feltByUserQuakes = [[NSMutableArray alloc] init];
            for (PFObject *object in results) {
                Quake *quake = [[Quake alloc] initWithPFObject:object];
                [self.feltByUserQuakes addObject:quake];
            }
            //        NSLog(@"I have felt these quakes: %@", results);
        }];


        // Query #2 - Didn't feel it query
        PFQuery *notQuery = [PFQuery queryWithClassName:@"USGSQuakes"];
        [notQuery whereKey:@"notFeltByUsers" equalTo:[PFUser currentUser]];
        [notQuery setLimit:1000];

        [notQuery findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
            self.notFeltByUserQuakes = [[NSMutableArray alloc] init];
            for (PFObject *object in results) {
                Quake *quake = [[Quake alloc] initWithPFObject:object];
                [self.notFeltByUserQuakes addObject:quake];
            }
            //        NSLog(@"I have NOT felt these quakes: %@", results);
        }];
    }

    [self.navigationController setNavigationBarHidden:NO animated:animated];

    [self.locationManager startUpdatingLocation];
}

- (void)viewDidDisappear:(BOOL)animated {
    if (debug == 1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    [super viewDidDisappear:animated];

    //    [self.locationManager stopUpdatingLocation];
    //    [[NSNotificationCenter defaultCenter] removeObserver:self name:DYFTDistanceFilterDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DYFTQuakeCreatedNotification object:nil];

    [self startSignificantChangeUpdates];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if (debug == 1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {

    if (debug == 1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    return UIInterfaceOrientationPortrait;
}
- (UIStatusBarStyle)preferredStatusBarStyle {
    if (debug == 1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    return UIStatusBarStyleDefault;
}


#pragma mark - AllQuakesTableViewController

- (CLLocation *)currentLocationForAllQuakesTableViewController:(AllQuakesTableViewController *)controller {
    if (debug == 1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    // The data source's relevant method implementation simply returns the currentLocation property.
    NSLog(@"self.currentLocation = %@", self.currentLocation);
    return self.currentLocation; // type CLLocation
}


#pragma mark - RegisterQuakeViewController

- (CLLocation *)currentLocationForRegisterQuakeViewController:(QuakeRegisterVC *)controller {
    if (debug == 1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    // The data source's relevant method implementation simply returns the currentLocation property.
    NSLog(@"self.currentLocation = %@", self.currentLocation);
    return self.currentLocation; // type CLLocation
}


#pragma mark - NSNotificationCenter notification handlers

- (void)distanceFilterDidChange:(NSNotification *)note {
    if (debug == 1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    //    NSUInteger filterDistance = DYFTDefaultFilterDistance;
    CLLocationAccuracy filterDistance = [[note userInfo][kDYFTFilterDistanceKey] doubleValue];

    // If they panned the map since our last location update, don't recenter it.
    if (!self.mapPannedSinceLocationUpdate) {
        // Set the map's region centered on their location at 2x filterDistance
        MKCoordinateRegion newRegion = MKCoordinateRegionMakeWithDistance(self.currentLocation.coordinate, filterDistance * 2.0f, filterDistance * 2.0f);

        [self.mapView setRegion:newRegion animated:YES];
        self.mapPannedSinceLocationUpdate = NO;
    } else {
        // Just zoom to the new search radius (or maybe don't even do that?)
        MKCoordinateRegion currentRegion = self.mapView.region;
        MKCoordinateRegion newRegion = MKCoordinateRegionMakeWithDistance(currentRegion.center, filterDistance * 2.0f, filterDistance * 2.0f);

        BOOL oldMapPannedValue = self.mapPannedSinceLocationUpdate;
        [self.mapView setRegion:newRegion animated:YES];
        self.mapPannedSinceLocationUpdate = oldMapPannedValue;
    }
}

- (void)setCurrentLocation:(CLLocation *)currentLocation {
    if (debug == 1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));

    // 1. Draw or move the search radius display
    if (self.currentLocation == currentLocation) {
        return;
    }
    _currentLocation = currentLocation;

    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:DYFTCurrentLocationDidChangeNotification
                                                            object:nil
                                                          userInfo:@{ kDYFTLocationKey : currentLocation } ];
    });

    CLLocationAccuracy filterDistance = [[NSUserDefaults standardUserDefaults] doubleForKey:DYFTUserDefaultsFilterDistanceKey];

    // If they panned the map since our last location update, don't recenter it.
    if (!self.mapPannedSinceLocationUpdate) {
        // Set the map's region centered on their new location at 2x filterDistance
        //        MKCoordinateRegion newRegion = MKCoordinateRegionMakeWithDistance(self.currentLocation.coordinate, filterDistance * 2.0f, filterDistance * 2.0f);
        MKCoordinateRegion newRegion = MKCoordinateRegionMakeWithDistance(self.currentLocation.coordinate, filterDistance, filterDistance);
        NSLog(@"newRegion.center = %f, %f\n newRegion.span = %f, %f", newRegion.center.latitude, newRegion.center.longitude, newRegion.span.latitudeDelta, newRegion.span.longitudeDelta);

        BOOL oldMapPannedValue = self.mapPannedSinceLocationUpdate;
        //        [self.mapView setRegion:[self.mapView regionThatFits:newRegion]];
        [self.mapView setRegion:newRegion animated:YES];
        self.mapPannedSinceLocationUpdate = oldMapPannedValue;
    } // else do nothing.
}

- (void)quakeWasCreated:(NSNotification *)note {
    if (debug == 1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));

    CLLocationAccuracy filterDistance = [[NSUserDefaults standardUserDefaults] doubleForKey:DYFTUserDefaultsFilterDistanceKey];
//    [self queryForAllQuakesNearLocation:self.currentLocation withNearbyDistance:filterDistance];
}

#pragma mark - UINavigationBar-based actions

- (IBAction)listViewButtonSelected:(id)sender {
    if (debug == 1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    [self displayAllQuakesTableViewController];
}
- (IBAction)filterButtonSelected:(id)sender {
    if (debug == 1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    [self presentQuakeFiltersViewController];
}

- (void)displayAllQuakesTableViewController {
    if (debug == 1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    [self showViewController:self.allQuakesTableViewController sender:self];
    [self.allQuakesTableViewController didMoveToParentViewController:self];
}
- (void)presentQuakeFiltersViewController {
    if (debug == 1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));

    QuakeFiltersViewController *filtersViewController = [[QuakeFiltersViewController alloc] initWithNibName:nil bundle:nil];
    [self presentViewController:filtersViewController animated:YES completion:nil];
}

#pragma mark -
#pragma mark CLLocationManagerDelegate methods and helpers

- (CLLocationManager *)locationManager {
    if (debug == 1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));

    if (_locationManager == nil) {
        _locationManager = [[CLLocationManager alloc] init];

        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;

        // Set a movement threshold for new events.
        _locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters;
    }
    return _locationManager;
}

- (void)startStandardUpdates {
    if (debug == 1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));

    [self.locationManager startUpdatingLocation];

    CLLocation *currentLocation = self.locationManager.location;
    if (currentLocation) {
        self.currentLocation = currentLocation;
    }
}

- (void)startSignificantChangeUpdates {
    if (debug == 1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    if (self.locationManager == nil) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
    }
    [self.locationManager startMonitoringSignificantLocationChanges];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (debug == 1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    NSLog(@"%s", __PRETTY_FUNCTION__);
    switch (status) {
        case kCLAuthorizationStatusAuthorizedAlways:
        {
            NSLog(@"kCLAuthorizationStatusAuthorizedAlways");
            // Re-enable the post button if it was disabled before.
            self.navigationItem.rightBarButtonItem.enabled = YES;
            [self.locationManager startUpdatingLocation];
        }
            break;
        case kCLAuthorizationStatusDenied:
            NSLog(@"kCLAuthorizationStatusDenied");
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Did You Feel That? can’t access your current location.\n\nTo view nearby events such as earthquakes or find out what caused you to just say 'Did You Feel That?' at your current location, turn on access for DYFT? to your location in the Settings app under Location Services." message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alertView show];
            // Disable the post button.
            self.navigationItem.rightBarButtonItem.enabled = NO;
        }
            break;
        case kCLAuthorizationStatusNotDetermined:
        {
            NSLog(@"kCLAuthorizationStatusNotDetermined");
        }
            break;
        case kCLAuthorizationStatusRestricted:
        {
            NSLog(@"kCLAuthorizationStatusRestricted");
        }
            break;
        default:break;
    }
}

//// The CoreLocation object CLLocationManager has a delegate method that is called
//// when the location changes. This is where we will post the notification.
//- (void)locationManager:(CLLocationManager *)manager
//    didUpdateToLocation:(CLLocation *)newLocation
//           fromLocation:(CLLocation *)oldLocation {
//    NSLog(@"%s", __PRETTY_FUNCTION__);
//
//    self.currentLocation = newLocation;
//}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    if (debug == 1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    // Add code here to send the user's current location to Parse.

    // Defer updates until the set amount of time has passed (currently one hour).
    if (!self.deferringUpdates) {
        [self.locationManager allowDeferredLocationUpdatesUntilTraveled:CLLocationDistanceMax timeout:DYFTLocationUpdatesTimeInterval];

        self.deferringUpdates = YES;

        [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error){
            if (!error) {
                NSLog(@"geoPointForCurrentLocationInBackground !error");
                [[PFInstallation currentInstallation] setObject:geoPoint forKey:@"location"];
                [[PFInstallation currentInstallation] saveInBackground];
                CLLocation *newLocation = [[CLLocation alloc] initWithLatitude:geoPoint.latitude longitude:geoPoint.longitude];
                NSLog(@"newLocation = %@", newLocation);
                self.currentLocation = newLocation;
            }
        }];
    }
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
    if (debug == 1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSLog(@"Error: %@", [error description]);

    if (error.code == kCLErrorDenied) {
        [self.locationManager stopUpdatingLocation];
    } else if (error.code == kCLErrorLocationUnknown) {
        // todo: retry?
        // set a timer for five seconds to cycle location, and if it fails again, bail and tell the user.
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error retrieving location"
                                                        message:[error localizedDescription]
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"OK", nil];
        [alert show];
    }
}

#pragma mark -
#pragma mark MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    if (debug == 1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    id<MKAnnotation> annotation = [view annotation];
    if ([annotation isKindOfClass:[Quake class]]) {
        Quake *quake = [view annotation];
        NSLog(@"QuakeID: %@", quake.usgsId);
//        [self.quakesTableViewController highlightCellForQuake:quake];
    } else if ([annotation isKindOfClass:[MKUserLocation class]]) {
        // Center the map on the user's current location:
        CLLocationAccuracy filterDistance = [[NSUserDefaults standardUserDefaults] doubleForKey:DYFTUserDefaultsFilterDistanceKey];
        MKCoordinateRegion newRegion = MKCoordinateRegionMakeWithDistance(self.currentLocation.coordinate,
                                                                          filterDistance * 2.0f,
                                                                          filterDistance * 2.0f);

        [self.mapView setRegion:newRegion animated:YES];
        self.mapPannedSinceLocationUpdate = NO;
    }
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    if (debug == 1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    id<MKAnnotation> annotation = [view annotation];
    if ([annotation isKindOfClass:[Quake class]]) {
        Quake *quake = [view annotation];
//        [self.quakesTableViewController unhighlightCellForQuake:quake];
    }
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    if (debug == 1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    self.mapPannedSinceLocationUpdate = YES;
}

#pragma mark -
#pragma mark Fetch map pins
/*
- (void)queryForAllQuakesNearLocation:(CLLocation *)currentLocation withNearbyDistance:(CLLocationAccuracy)nearbyDistance {
    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    PFQuery *query = [PFQuery queryWithClassName:DYFTQuakesClassKey];

    if (currentLocation == nil) {
        NSLog(@"%s got a nil location!", __PRETTY_FUNCTION__);
    }

    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    //    if ([self.allEvents count] == 0) {
    //        NSLog(@"self.allEvents count == 0");
    //        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    //    }

    // Query for posts sort of kind of near our current location.
    PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude:currentLocation.coordinate.latitude longitude:currentLocation.coordinate.longitude];
    NSLog(@"my location is currently %@", point);

    // whereKey: [key for field in our PFObject that represents a PFGeoPoint]    nearGeoPoint: [a location that will be used as the origin of the radius]    withinKilometers: [the distance of the radius]

    //    [query whereKey:DYFTQuakesLocationKey nearGeoPoint:point withinKilometers:DYFTEventsMaximumSearchDistance];
    //[query includeKey:DYFTQuakesAppFeltKey];
    query.limit = DYFTAllQuakesSearchDefaultLimit;

    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"error in geo query!"); // todo why is this ever happening?
        } else {
            // We need to make new quake objects from objects,
            // and update allQuakes and the map to reflect this new array.
            // But we don't want to remove all annotations from the mapview blindly,
            // so let's do some work to figure out what's new and what needs removing.

            // 1. Find genuinely new quakes (those we did not already have)

            // In this array we'll store the quakes returned by the query
            NSMutableArray *newQuakes = [[NSMutableArray alloc] initWithCapacity:DYFTAllQuakesSearchDefaultLimit];

            // In this array we'll store the newly received quakes (cache the objects we make for the search in step 2:)
            NSMutableArray *allNewQuakes = [[NSMutableArray alloc] initWithCapacity:[objects count]];

            // Loop thru all returned PFObjects
            for (PFObject *object in objects) {
                Quake *newQuake = [[Quake alloc] initWithPFObject:object];
                [allNewQuakes addObject:newQuake];

                // Now we check if we already had this quake
                if (![_allQuakes containsObject:newQuake]) {
                    // If we did not already have this quake
                    [newQuakes addObject:newQuake];
                }
            }
            // newQuakes now contains our new objects.

            // 2. Find quakes in allQuakes to remove (those we have but that we did not get from this query).
            NSMutableArray *quakesToRemove = [[NSMutableArray alloc] initWithCapacity:DYFTAllQuakesSearchDefaultLimit];
            for (Quake *currentQuake in _allQuakes) {
                if (![allNewQuakes containsObject:currentQuake]) {
                    [quakesToRemove addObject:currentQuake];
                }
            }
            // quakesToRemove has objects that didn't come in with our new results.

            // 3. Configure our new quakes; these are about to go onto the map.
            for (Quake *newQuake in newQuakes) {
                CLLocation *objectLocation = [[CLLocation alloc] initWithLatitude:newQuake.coordinate.latitude
                                                                        longitude:newQuake.coordinate.longitude];

                //CLLocationDistance distanceFromCurrent = [currentLocation distanceFromLocation:objectLocation];
                [newQuake setTitleAndSubtitleUserFeltEvent:[self.feltByUserEvents containsObject:newQuake] ? YES : NO];
                //                [newQuake setTitleAndSubtitleOutsideDistance:( distanceFromCurrent > nearbyDistance ? YES : NO )];
                // Animate all pins after the initial load:
                newQuake.animatesDrop = self.mapPinsPlaced;
            }

            // At this point, allNewQuakes contains a new list of quake objects.
            // We should add everything in newQuakes to the map, remove everything in quakesToRemove,
            // and add newQuakes to _allQuakes.
            [self.mapView removeAnnotations:quakesToRemove];
            [self.mapView addAnnotations:newQuakes];

            [_allQuakes addObjectsFromArray:newQuakes];
            [_allQuakes removeObjectsInArray:quakesToRemove];

            self.mapPinsPlaced = YES;
        }
    }];
}


// When we update the search filter distance, we need to update our pins' titles to match.
- (void)updateQuakesForLocation:(CLLocation *)currentLocation withNearbyDistance:(CLLocationAccuracy) nearbyDistance {
    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    for (Quake *quake in _allQuakes) {
        CLLocation *objectLocation = [[CLLocation alloc] initWithLatitude:quake.coordinate.latitude
                                                                longitude:quake.coordinate.longitude];

        // if this event is outside the filter distance, don't show the regular callout.
        CLLocationDistance distanceFromCurrent = [currentLocation distanceFromLocation:objectLocation];
        if (distanceFromCurrent > nearbyDistance) { // Outside search radius
            [quake setTitleAndSubtitleUserFeltEvent:YES];
            [(MKPinAnnotationView *)[self.mapView viewForAnnotation:quake] setPinColor:quake.pinColor];
        } else {
            [quake setTitleAndSubtitleUserFeltEvent:YES]; // Inside search radius
            [(MKPinAnnotationView *)[self.mapView viewForAnnotation:quake] setPinColor:quake.pinColor];
        }
    }
}
*/

#pragma mark Delegate

- (void)setupViewController:(SetupViewController *)controller didFinishSetupWithInfo:(NSDictionary *)setupInfo {
    if (debug == 1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
}
- (void)setupViewControllerDidLogout:(SetupViewController *)controller {
    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    [controller dismissViewControllerAnimated:YES completion:nil];
    [self.appDelegate presentLoginViewController];
}


#pragma mark -
#pragma mark LoginViewController

- (void)presentLoginViewController {
    if (debug == 1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    // This method instantiates and sets the PAWLoginViewController as the root of the navigation controller.
    // Go to the welcome screen and have them log in or create an account.
    UserLoginVC *viewController = [[UserLoginVC alloc] initWithNibName:nil bundle:nil];
    viewController.modalPresentationStyle = UIModalPresentationPageSheet;
    [self presentViewController:viewController animated:YES completion:nil];
    
}

#pragma mark Delegate

- (void)loginViewControllerDidLogin:(UserLoginVC *)controller {
    if (debug == 1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    [controller dismissViewControllerAnimated:YES completion:nil];
}


- (void)updateLocations
{
    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));

    PFQuery *quakesQuery = [PFQuery queryWithClassName:DYFTQuakesClassKey];

    [quakesQuery whereKey:DYFTQuakesStateKey equalTo:@"Oklahoma"];
    [quakesQuery addDescendingOrder:@"createdAt"];
    quakesQuery.limit = 500;

    [quakesQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %lu quake events.", (unsigned long)objects.count);
            NSLog(@"Object is %@ and %@", [objects objectAtIndex:0],[objects objectAtIndex:1]);

            NSMutableArray *newQuakes = [[NSMutableArray alloc] initWithCapacity:500];
            NSMutableArray *allNewQuakes = [[NSMutableArray alloc] initWithCapacity:[objects count]];

            for (PFObject *object in objects) {
                Quake *newQuake = [[Quake alloc] initWithPFObject:object];
                [allNewQuakes addObject:newQuake];
                if (![_allQuakes containsObject:newQuake]) {
                    [newQuakes addObject:newQuake];
                }
            }

            NSMutableArray *quakesToRemove = [[NSMutableArray alloc] initWithCapacity:500];
            for (Quake *currentQuake in _allQuakes) {
                if (![allNewQuakes containsObject:currentQuake]) {
                    [quakesToRemove addObject:currentQuake];
                }
            }

            for (Quake *newQuake in newQuakes) {
                //                CLLocation *eventLocation = [[CLLocation alloc] initWithLatitude:newEvent.coordinate.latitude
                //                                                                       longitude:newEvent.coordinate.longitude];

                [newQuake setTitleAndSubtitleUserFeltQuake:[self.feltByUserQuakes containsObject:newQuake] ? YES : NO];
            }
            [self.mapView removeAnnotations:quakesToRemove];
            [self.mapView addAnnotations:newQuakes];

            [_allQuakes addObjectsFromArray:newQuakes];
            [_allQuakes removeObjectsInArray:quakesToRemove];
        }
    }];
}


- (void)showLocations
{
    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    MKCoordinateRegion region = [self regionForAnnotations:_allQuakes];

    [self.mapView setRegion:region animated:YES];
}

- (MKCoordinateRegion)regionForAnnotations:(NSArray *)annotations
{
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
            topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.coordinate.latitude);
            topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.coordinate.longitude);
            bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotation.coordinate.latitude);
            bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, annotation.coordinate.longitude);
        }

        const double extraSpace = 1.1;

        region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) / 2.0;
        region.center.longitude = topLeftCoord.longitude - (topLeftCoord.longitude - bottomRightCoord.longitude) / 2.0;

        region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * extraSpace;
        region.span.longitudeDelta = fabs(topLeftCoord.longitude - bottomRightCoord.longitude) * extraSpace;
    }
    return [self.mapView regionThatFits:region];
}

#pragma mark - DELEGATE: MKMapView

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
//    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));

    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }

    static NSString *identifier = @"Location";

    if ([annotation isKindOfClass:[Quake class]]) {

        MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (!annotationView) {
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        } else {
            annotationView.annotation = annotation;
        }
        annotationView.enabled = YES;
        annotationView.canShowCallout = YES;
        annotationView.animatesDrop = [((Quake *)annotation) animatesDrop];
//        annotationView.pinColor = [(Quake *)annotation pinColor];
        annotationView.tintColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
//        NSLog(@"QuakeID: %@", [((Quake *)annotation) usgsId]);
        return annotationView;
    }
    return nil;
}

@end
