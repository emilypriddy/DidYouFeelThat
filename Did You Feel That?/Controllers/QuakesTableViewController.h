//
//  QuakesTableViewController.h
//  Did You Feel That?
//
//  Created by Emily Priddy on 9/22/15.
//  Copyright (c) 2015 Headstorm Studios. All rights reserved.
//

@import UIKit;
#import "PFQueryTableViewController.h"

#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>

#import "QuakesMapViewController.h"

@class QuakesTableViewController;

@protocol QuakesTableViewControllerDataSource <NSObject>

- (CLLocation *)currentLocationForQuakesTableViewController:(QuakesTableViewController *)controller;

@end

@interface QuakesTableViewController : PFQueryTableViewController

@property (weak, nonatomic) id<QuakesTableViewControllerDataSource> dataSource;

@property (strong, nonatomic) CLLocation *currentLocation;

- (void)setCurrentLocation:(CLLocation *)currentLocation;

@end

