//
//  DYFTMainTabBarController.m
//  Did You Feel That?
//
//  Created by Emily Priddy on 8/24/15.
//  Copyright (c) 2015 Headstorm Studios. All rights reserved.
//

#import "DYFTMainTabBarController.h"
#import "QuakeRegisterVC.h"
#import "Quake.h"
#import "DYFTConstants.h"
#import "AllQuakesMapViewController.h"
#import "AppDelegate.h"

#define debug 1

@interface DYFTMainTabBarController () <QuakeRegisterViewControllerDataSource>

@end

@implementation DYFTMainTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - RegisterQuakeViewController

- (void)presentRegisterQuakeViewController {
    if (debug == 1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    // This VC adopts the DYFTRegisterEventViewControllerDataSource protocol
    // and registers as a data source before presenting the DYFTRegisterEventViewController.
    QuakeRegisterVC *viewController = [[QuakeRegisterVC alloc] initWithNibName:nil bundle:nil];
    viewController.dataSource = self.quakesVC;
    [self.navigationController presentViewController:viewController animated:YES completion:nil];
}

- (CLLocation *)currentLocationForRegisterQuakeViewController:(QuakeRegisterVC *)controller {
    if (debug == 1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    // The data source's relevant method implementation simply returns the currentLocation property.
    NSLog(@"self.quakesVC.currentLocation = %@", self.quakesVC.currentLocation);
    return self.quakesVC.currentLocation; // type CLLocation
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
