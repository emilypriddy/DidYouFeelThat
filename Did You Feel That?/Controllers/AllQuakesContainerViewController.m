//
//  AllQuakesContainerViewController.m
//  Did You Feel That?
//
//  Created by Emily Priddy on 9/21/15.
//  Copyright (c) 2015 Headstorm Studios. All rights reserved.
//

#import "AllQuakesContainerViewController.h"
#import "QuakesMapViewController.h"
#import "QuakesTableViewController.h"
#import "UIView+FLKAutoLayout.h"
@import QuartzCore;

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
#define debug 1

@interface AllQuakesContainerViewController ()

@property (strong, nonatomic) IBOutlet UIBarButtonItem *switchViewButton;

@property (strong, nonatomic) UIView *viewContainer;

@property (strong, nonatomic) QuakesMapViewController *mapViewController;
@property (strong, nonatomic) QuakesTableViewController *tableViewController;

@end

@implementation AllQuakesContainerViewController

- (void)loadView {
    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));

    UIView *view = [UIView new];
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    view.backgroundColor = [UIColor darkGrayColor];

    self.viewContainer = [UIView new];
    [self.viewContainer setTranslatesAutoresizingMaskIntoConstraints:NO];
    [view addSubview:self.viewContainer];

    [self.viewContainer constrainWidthToView:view predicate:nil];
    [self.viewContainer constrainHeightToView:view predicate:nil];
    [self.viewContainer alignTopEdgeWithView:view predicate:nil];
    [self.viewContainer alignCenterXWithView:view predicate:nil];


    self.view = view;
}

- (void)viewDidLoad {
    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));

    [self.navigationItem setTitle:@"Quakes"];
    
    // Setup controllers
    _mapViewController = [QuakesMapViewController new];
//    DYFTNavigationController *mapNavController = [[DYFTNavigationController alloc] initWithRootViewController:_mapViewController];
//    [self addChildViewController:mapNavController];
//
//    [self.viewContainer addSubview:mapNavController.visibleViewController.view];
//    [mapNavController.visibleViewController didMoveToParentViewController:self];

    [self addChildViewController:_mapViewController];
    [self.viewContainer addSubview:_mapViewController.view];
    [_mapViewController didMoveToParentViewController:self];
    [_mapViewController addObserver:self
                         forKeyPath:@"currentLocation"
                            options:NSKeyValueObservingOptionNew
                            context:NULL];

    _tableViewController = [QuakesTableViewController new];
//    DYFTNavigationController *tableNavController = [[DYFTNavigationController alloc] initWithRootViewController:_tableViewController];


    // Initialize controllers with a default location
    self.currentLocation = [self.dataSource currentLocationForAllQuakesContainerViewController:self];

//
    if (_mapViewController.parentViewController == self) {
        NSLog(@"Inside %@, _mapViewController is being shown", self);

        [self.navigationItem setTitle:@"Quakes Map"];
//        self.navController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"List View"
//                                                                                 style:UIBarButtonItemStylePlain
//                                                                                target:self
//                                                                                action:@selector(switchViewButtonSelected:)];
    } else if(_tableViewController.parentViewController == self) {
        NSLog(@"Inside %@, _tableViewController is being shown", self);

        [self.navigationItem setTitle:@"Quakes List"];
//        self.navController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Map View"
//                                                                                               style:UIBarButtonItemStylePlain
//                                                                                              target:self
//                                                                                              action:@selector(switchViewButtonSelected:)];
    } else {
        NSLog(@"Inside %@, default is being shown", self);
        [self.navigationItem setTitle:@"Quakes?"];
    }

    self.navController.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
//    self.navController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Filter"
//                                                                              style:UIBarButtonItemStylePlain
//                                                                             target:self
//                                                                             action:@selector(filterButtonSelected:)];
    self.navController.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
}

- (IBAction)switchView:(id)sender {
    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));

    UIViewAnimationOptions direction = UIViewAnimationOptionTransitionFlipFromRight;
    if (_mapViewController.parentViewController == self) {
        NSLog(@"_mapViewController.parentViewController.parentViewController == self");
        [self flipFromViewController:_mapViewController toViewController:_tableViewController withDirection:direction andDelay:0.0];

    } else {
        NSLog(@"!_mapViewController.parentViewController == self");
        direction = UIViewAnimationOptionTransitionFlipFromLeft;

        [self flipFromViewController:_tableViewController toViewController:_mapViewController withDirection:direction andDelay:0.0];
    }
}

- (void)switchViewButtonSelected:(id)sender {
    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));

    UIViewAnimationOptions direction = UIViewAnimationOptionTransitionFlipFromRight;
    if (_mapViewController.parentViewController == self) {
        [self flipFromViewController:_mapViewController toViewController:_tableViewController withDirection:direction andDelay:0.0];
    } else {
        direction = UIViewAnimationOptionTransitionFlipFromLeft;
        [self flipFromViewController:_tableViewController toViewController:_mapViewController withDirection:direction andDelay:0.0];
    }
}

- (void)flipFromViewController:(UIViewController *)fromController toViewController:(UIViewController *)toController withDirection:(UIViewAnimationOptions)direction andDelay:(double)delay {
    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));

    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC);

    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){

        toController.view.frame = fromController.view.frame;
        [self addChildViewController:toController];
        [fromController willMoveToParentViewController:nil];

        [self transitionFromViewController:fromController
                          toViewController:toController
                                  duration:0.2
                                   options:direction | UIViewAnimationOptionCurveEaseIn
                                animations:nil
                                completion:^(BOOL finished) {
                                    [toController didMoveToParentViewController:self];
                                    [fromController removeFromParentViewController];
                                }];
    });
}

#pragma mark KVO observer

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));

    if ([keyPath isEqualToString:@"currentLocation"]) {

        id oppositeController = nil;

        if ([object isEqual:_mapViewController])
            oppositeController = (QuakesTableViewController*)_tableViewController;
        else
            oppositeController = (QuakesMapViewController *)_mapViewController;

        CLLocation *newLocation = [change objectForKey:@"new"];
        [oppositeController setCurrentLocation:newLocation];
    }
}



@end
