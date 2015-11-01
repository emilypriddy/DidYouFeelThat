//
//  AllQuakesContainerViewController.h
//  Did You Feel That?
//
//  Created by Emily Priddy on 9/21/15.
//  Copyright (c) 2015 Headstorm Studios. All rights reserved.
//

@import UIKit;
@import CoreLocation;

@class AllQuakesContainerViewController;

@protocol AllQuakesContainerViewControllerDataSource <NSObject>
- (CLLocation *)currentLocationForAllQuakesContainerViewController:(AllQuakesContainerViewController *)controller;
@end

@interface AllQuakesContainerViewController : UIViewController
@property (weak, nonatomic) id<AllQuakesContainerViewControllerDataSource> dataSource;
@property (strong, nonatomic) UINavigationController *navController;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *currentLocation;

- (IBAction)switchView:(id)sender;

@end
