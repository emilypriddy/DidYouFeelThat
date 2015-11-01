//
//  AllQuakesMapVC.h
//  Did You Feel That?
//
//  Similar to Parse Anywall's PAWWallViewController
//  Once user is logged in, this controller is displayed.
//  This controller displays nearby earthquakes
//  (felt AND not felt by user) in MKMapView.
//
//  This same screen also displays the child view controller
//  PAWWallPostsTableViewController.
//
//  This controller is used as the CLLocationManager's delegate.
//  Responsible for letting us know if the user's location changes.
//
//  Created by Emily Priddy on 6/10/15.
//  Copyright (c) 2015 Headstorm Studios. All rights reserved.
//

@import UIKit;
@import CoreLocation;
@import MapKit;
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import "DYFTNavigationController.h"

@class AllQuakesMapViewController;

@protocol QuakesViewControllerDelegate <NSObject>
- (void)quakesViewControllerWantsToPresentSettings:(AllQuakesMapViewController *)controller;
@end

@class Quake;

@interface AllQuakesMapViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) id<QuakesViewControllerDelegate>delegate;

@property (strong, nonatomic) IBOutlet MKMapView *mapView;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *currentLocation;;

@property (strong, nonatomic) NSMutableArray *feltByUserQuakes;
@property (strong, nonatomic) NSMutableArray *notFeltByUserQuakes;
@property (strong, nonatomic) DYFTNavigationController *navController;

- (IBAction)registerButtonSelected:(id)sender;

@end