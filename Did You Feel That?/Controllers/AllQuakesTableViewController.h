//
//  AllQuakesTableVC.h
//  Did You Feel That?
//
//  Created by Emily Priddy on 9/18/15.
//  Copyright (c) 2015 Headstorm Studios. All rights reserved.
//

@import UIKit;
#import "PFQueryTableViewController.h"

#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>

#import "AllQuakesMapViewController.h"

@class AllQuakesTableViewController;

@protocol AllQuakesTableViewControllerDataSource <NSObject>

- (CLLocation *)currentLocationForAllQuakesTableViewController:(AllQuakesTableViewController *)controller;

@end

@interface AllQuakesTableViewController : PFQueryTableViewController

@property (weak, nonatomic) id<AllQuakesTableViewControllerDataSource> dataSource;

@end
