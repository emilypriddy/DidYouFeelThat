//
//  HeatMapViewController.m
//  Did You Feel That?
//
//  Created by Emily Priddy on 7/9/15.
//  Copyright (c) 2015 Headstorm Studios. All rights reserved.
//

#import "HeatMapViewController.h"
#import "DYFTConstants.h"
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import <DTMHeatmap/DTMHeatmapRenderer.h>
#import <DTMHeatmap/DTMDiffHeatmap.h>
#import "NSDate+DateTools.h"

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

#define debug 1

@interface HeatMapViewController ()

@property (strong, nonatomic) NSDate *todayDate;
@property (strong, nonatomic) NSDate *oneMonthAgoDate;
@property (strong, nonatomic) NSDate *twoMonthsAgoDate;
@property (strong, nonatomic) NSDate *threeMonthsAgoDate;
@property (strong, nonatomic) NSDate *fourMonthsAgoDate;

@property (strong, nonatomic) DTMHeatmap *heatmap;
@property (strong, nonatomic) DTMDiffHeatmap *diffHeatmap;
@property (strong, nonatomic) NSDictionary *currentMonthDict;
@property (strong, nonatomic) NSDictionary *oneMonthAgoDict;
@property (strong, nonatomic) NSDictionary *twoMonthsAgoDict;
@property (strong, nonatomic) NSMutableDictionary *tempDict;
@property (strong, nonatomic) NSMutableDictionary *firstTempDict;
@property (strong, nonatomic) NSMutableDictionary *secondTempDict;

@property (strong, nonatomic) PFQuery *currentMonthQuery;
@property (strong, nonatomic) PFQuery *oneMonthAgoQuery;
@property (strong, nonatomic) PFQuery *twoMonthsAgoQuery;


@end

@implementation HeatMapViewController

- (void)viewDidLoad {
    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    [super viewDidLoad];
    self.mapView.frame = self.view.bounds;
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = NO;

    if (IS_OS_8_OR_LATER) {
        [self.locationManager requestAlwaysAuthorization];
    }

    self.todayDate = [NSDate date];
    self.oneMonthAgoDate = [self.todayDate dateBySubtractingMonths:1];
    self.twoMonthsAgoDate = [self.todayDate dateBySubtractingMonths:2];
    self.threeMonthsAgoDate = [self.todayDate dateBySubtractingMonths:3];
    self.fourMonthsAgoDate = [self.todayDate dateBySubtractingMonths:4];

    NSLog(@"self.todayDate = %@", self.todayDate);
    NSLog(@"self.oneMonthAgoDate = %@", self.oneMonthAgoDate);
    NSLog(@"self.twoMonthsAgoDate = %@", self.twoMonthsAgoDate);
    NSLog(@"self.threeMonthsAgoDate = %@", self.threeMonthsAgoDate);
    NSLog(@"self.fourMonthsAgoDate = %@", self.fourMonthsAgoDate);

    // whereKey:DYFTQuakesTimestampKey greaterThanOrEqualTo:someDate
    // -- This returns results that occured on or later than the someDate date
    // whereKey:DYFTQuakesTimestampKey lessThanOrEqualTo:someDate
    // -- This returns results that occured on or earlier than the someDate date

    // TODO: Change these queries to query the "state" key instead of the "place" key (get rid of REGEX!!!)
    self.currentMonthQuery = [PFQuery queryWithClassName:DYFTQuakesClassKey];
    [self.currentMonthQuery whereKey:DYFTQuakesPlaceKey containsString:@"Oklahoma"];
    [self.currentMonthQuery whereKey:DYFTQuakesTimestampKey greaterThanOrEqualTo:self.oneMonthAgoDate];
    [self.currentMonthQuery orderByDescending:DYFTQuakesTimestampKey];
    [self.currentMonthQuery selectKeys:@[DYFTQuakesPlaceKey, DYFTQuakesTimestampKey, DYFTQuakesLocationKey, DYFTQuakesTitleKey]];
    [self.currentMonthQuery setLimit:1000];

    self.oneMonthAgoQuery = [PFQuery queryWithClassName:DYFTQuakesClassKey];
    [self.oneMonthAgoQuery whereKey:DYFTQuakesTimestampKey lessThan:self.oneMonthAgoDate];
    [self.oneMonthAgoQuery whereKey:DYFTQuakesTimestampKey greaterThanOrEqualTo:self.twoMonthsAgoDate];
    [self.oneMonthAgoQuery whereKey:DYFTQuakesPlaceKey containsString:@"Oklahoma"];
    [self.oneMonthAgoQuery orderByDescending:DYFTQuakesTimestampKey];
    [self.oneMonthAgoQuery selectKeys:@[DYFTQuakesPlaceKey, DYFTQuakesTimestampKey, DYFTQuakesLocationKey, DYFTQuakesTitleKey]];
    [self.oneMonthAgoQuery setLimit:1000];

    self.twoMonthsAgoQuery = [PFQuery queryWithClassName:DYFTQuakesClassKey];
    [self.twoMonthsAgoQuery whereKey:DYFTQuakesTimestampKey lessThan:self.twoMonthsAgoDate];
    [self.twoMonthsAgoQuery whereKey:DYFTQuakesTimestampKey greaterThanOrEqualTo:self.threeMonthsAgoDate];
    [self.twoMonthsAgoQuery whereKey:DYFTQuakesPlaceKey containsString:@"Oklahoma"];
    [self.twoMonthsAgoQuery orderByDescending:DYFTQuakesTimestampKey];
    [self.twoMonthsAgoQuery selectKeys:@[DYFTQuakesPlaceKey, DYFTQuakesTimestampKey, DYFTQuakesLocationKey, DYFTQuakesTitleKey]];
    [self.twoMonthsAgoQuery setLimit:1000];

    if (!self.currentMonthDict) {
        self.currentMonthDict = [self fetchQuakeDataWithQuery:self.currentMonthQuery];
        NSLog(@"self.currentMonthDict.count = %lu", (unsigned long)self.currentMonthDict.count);
        NSLog(@"self.currentMonthDict keys = %@", [self.currentMonthDict keyEnumerator]);
    }
    if (!self.oneMonthAgoDict) {
        self.oneMonthAgoDict = [self fetchQuakeDataWithQuery:self.oneMonthAgoQuery];
        NSLog(@"self.oneMonthAgoDict.count = %lu", (unsigned long)self.oneMonthAgoDict.count);
    }
    if (!self.twoMonthsAgoDict) {
        self.twoMonthsAgoDict = [self fetchQuakeDataWithQuery:self.twoMonthsAgoQuery];
        NSLog(@"self.twoMonthsAgoDict.count = %lu", (unsigned long)self.twoMonthsAgoDict.count);
    }
    [self setupHeatmaps];
}

- (NSDate *)pastMonthQuery:(NSInteger)number {
    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));

    NSDate *date = [NSDate date];
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [NSDateComponents new];
    components.month = -number;
    NSDate *returnDate = [cal dateByAddingComponents:components toDate:date options:0];

    NSLog(@"number = %ld --- returnDate = %@", (long)number, returnDate);
    return returnDate;
}

/*
- (void)setupHeatmaps {
    // Set map region

    self.mapView.region = MKCoordinateRegionMake(self.mapView.userLocation.coordinate, MKCoordinateSpanMake(10.0, 10.0));

    self.heatmap = [DTMHeatmap new];
    if (self.quakeDictionary) {
        [self.heatmap setData:self.quakeDictionary];
        NSLog(@"self.quakeDictionary = %@", self.quakeDictionary);
    }
    [self.mapView addOverlay:self.heatmap];
}
*/
- (void)setupHeatmaps {
    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    // Set map region
    self.mapView.region = MKCoordinateRegionMake(self.mapView.userLocation.coordinate, MKCoordinateSpanMake(10.0, 10.0));

        self.heatmap = [DTMHeatmap new];
        [self.heatmap setData:self.currentMonthDict];
        [self.mapView addOverlay:self.heatmap];

        self.diffHeatmap = [DTMDiffHeatmap new];
        [self.diffHeatmap setBeforeData:self.twoMonthsAgoDict
                              afterData:self.oneMonthAgoDict];
}

- (NSDictionary *)fetchQuakeDataWithQuery:(PFQuery *)query {
    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    NSMutableDictionary *tempDict = [NSMutableDictionary new];
    // Query #1 - Felt it query
//    PFQuery *query = [PFQuery queryWithClassName:@"USGSQuakes"];
//    [query whereKey:@"feltByUsers" equalTo:[PFUser currentUser]];
//    [query setLimit:1000];

//    [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
    NSArray *results = [query findObjects];

    for (PFObject *object in results) {
        PFGeoPoint *geoPoint = object[DYFTQuakesLocationKey];
        CLLocationDegrees latitude = geoPoint.latitude;
        CLLocationDegrees longitude = geoPoint.longitude;

//            double weight = [object[DYFTQuakesMagnitudeKey] doubleValue];
        double weight = 1;

        CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude
                                                          longitude:longitude];

        MKMapPoint point = MKMapPointForCoordinate(location.coordinate);
        NSValue *pointValue = [NSValue value:&point withObjCType:@encode(MKMapPoint)];
        tempDict[pointValue] = @(weight);
//        NSLog(@"TITLE: %@ DATE: %@", object[DYFTQuakesTitleKey], object[DYFTQuakesTimestampKey]);

    }
//    dictionary = [[NSDictionary alloc] initWithDictionary:tempDict];
//    }];
//    NSLog(@"Found results: %lu", (unsigned long)results.count);
    return tempDict;
}

// Currently the fetchQuakeData method is not being used and can be deleted.
- (void)fetchQuakeData {
    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    self.tempDict = [NSMutableDictionary new];
    // Query #1 - Felt it query
    PFQuery *query = [PFQuery queryWithClassName:@"USGSQuakes"];
    [query whereKey:@"feltByUsers" equalTo:[PFUser currentUser]];
    [query setLimit:1000];

    //[query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
    NSArray *results = [query findObjects];
        for (PFObject *object in results) {
            PFGeoPoint *geoPoint = object[DYFTQuakesLocationKey];
            CLLocationDegrees latitude = geoPoint.latitude;
            CLLocationDegrees longitude = geoPoint.longitude;

//            double weight = [object[DYFTQuakesMagnitudeKey] doubleValue];
            double weight = 1;

            CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude
                                                              longitude:longitude];

            MKMapPoint point = MKMapPointForCoordinate(location.coordinate);
            NSValue *pointValue = [NSValue value:&point withObjCType:@encode(MKMapPoint)];
            self.tempDict[pointValue] = @(weight);
            NSLog(@"Found: %@", object[DYFTQuakesPlaceKey]);

        }
        self.currentMonthDict = [[NSDictionary alloc] initWithDictionary:self.tempDict];

    //}];
}

- (IBAction)segmentedControlValueChanged:(UISegmentedControl *)sender {
    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    switch (sender.selectedSegmentIndex) {
        case 0:
            [self.mapView removeOverlay:self.diffHeatmap];
            [self.heatmap setData:self.currentMonthDict];
            [self.mapView addOverlay:self.heatmap];
            break;
        case 1:
            [self.mapView removeOverlay:self.diffHeatmap];
            [self.heatmap setData:self.oneMonthAgoDict];
            [self.mapView addOverlay:self.heatmap];
            break;
        case 2:
            [self.mapView removeOverlay:self.diffHeatmap];
            [self.heatmap setData:self.twoMonthsAgoDict];
            [self.mapView addOverlay:self.heatmap];
            break;
        case 3:
            [self.mapView removeOverlay:self.heatmap];
            [self.mapView addOverlay:self.diffHeatmap];
            break;
    }
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    return [[DTMHeatmapRenderer alloc] initWithOverlay:overlay];
}

- (void)didReceiveMemoryWarning {
    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    id<MKAnnotation> annotation = [view annotation];
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return;
    }
    NSLog(@"Quake: %@", [view annotation]);
}



@end
