//
//  AllQuakesTableVC.m
//  Did You Feel That?
//
//  Created by Emily Priddy on 9/18/15.
//  Copyright (c) 2015 Headstorm Studios. All rights reserved.
//

#import "AllQuakesTableViewController.h"

#import "DYFTConstants.h"
#import "QuakeCell.h"
#import "NSDate+DateTools.h"
#import "Quake.h"

#define debug 1

static NSUInteger const DYFTAllQuakesTableViewMainSection = 0;

@interface AllQuakesTableViewController ()

@property (strong, nonatomic) UIButton *noDataButton;

@end

@implementation AllQuakesTableViewController

#pragma mark - Init

- (instancetype)initWithStyle:(UITableViewStyle)style {
    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    self = [super initWithStyle:style];
    if (self) {
        // The className to query on
        self.parseClassName = DYFTQuakesClassKey;

        // The key of the PFObject to display in the label of the default cell style
        self.textKey = DYFTQuakesTitleKey;

        // Whether the built-in pagination is enabled
        self.paginationEnabled = YES;

        // The number of objects to show per page
        self.objectsPerPage = DYFTAllQuakesSearchDefaultLimit;

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(distanceFilterDidChange:) name:DYFTDistanceFilterDidChangeNotification object:nil];

        // The view controller requests to be an observer of the
        // notification DYFTCurrentLocationDidChangeNotification.
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationDidChange:) name:DYFTCurrentLocationDidChangeNotification object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(quakeWasCreated:) name:DYFTQuakeCreatedNotification object:nil];
    }
    return self;
}

#pragma mark -
#pragma mark Dealloc

- (void)dealloc {
    // As good programmers, we always remember to clean up everything by removing
    // ourselves from the list of observers using the dealloc method.
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DYFTDistanceFilterDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DYFTCurrentLocationDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DYFTQuakeCreatedNotification object:nil];
}


- (void)viewDidLoad {
    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    [super viewDidLoad];
    NSLog(@"AllQuakesTableViewController");

    self.tableView.separatorColor = self.view.backgroundColor;
    self.refreshControl.tintColor = [UIColor colorWithRed:118.0f/255.0f green:117.0f/255.0f blue:117.0f/255.0f alpha:1.0f];

    [self.navigationItem setHidesBackButton:YES animated:NO];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Map View"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(hideAllQuakesTableViewController)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Filter"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(filterButtonSelected:)];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];


    // Set up a view for empty content
    self.noDataButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.noDataButton setTintColor:[UIColor colorWithWhite:0.008 alpha:1.000]];
    [self.noDataButton setTitle:@"No earthquakes found that match your criteria. Try adjusting the search filters." forState:UIControlStateNormal];
    [self.noDataButton addTarget:self.parentViewController
                          action:@selector(filterButtonSelected:)
                forControlEvents:UIControlEventTouchUpInside];
    self.noDataButton.hidden = YES;
    [self.view addSubview:self.noDataButton];

}

- (void)viewDidLayoutSubviews {
    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    [super viewDidLayoutSubviews];

    const CGRect bounds = self.view.bounds;

    CGRect noDataButtonFrame = CGRectZero;
    noDataButtonFrame.size = [self.noDataButton sizeThatFits:bounds.size];
    noDataButtonFrame.origin.x = CGRectGetMidX(bounds) - CGRectGetMidX(noDataButtonFrame);
    noDataButtonFrame.origin.y = 20.0f;
    self.noDataButton.frame = noDataButtonFrame;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

#pragma mark -
#pragma mark PFQueryTableViewController

- (void)objectsWillLoad {
    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    [super objectsWillLoad];

    // This method is called before a PFQuery is fired to get more objects
}

- (void)objectsDidLoad:(NSError *)error {
    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    [super objectsDidLoad:error];

    self.noDataButton.hidden = ([self.objects count] != 0);
}

// Override to customize what kind of query to perform on the class. The default is to query for
// all objects ordered by createdAt descending.
- (PFQuery *)queryForTable {
    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];

    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    if ([self.objects count] == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }

    // Query for quakes near our current location.

    // Get our current location:
    CLLocation *currentLocation = [self.dataSource currentLocationForAllQuakesTableViewController:self];
    CLLocationAccuracy filterDistance = [[NSUserDefaults standardUserDefaults] doubleForKey:DYFTUserDefaultsFilterDistanceKey];

    // And set the query to look by location
    PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude:currentLocation.coordinate.latitude
                                               longitude:currentLocation.coordinate.longitude];
    [query whereKey:DYFTQuakesLocationKey nearGeoPoint:point withinKilometers:DYFTMetersToKilometers(filterDistance)];
//    [query includeKey:DYFTQuakesFeltByUsersKey];
    [query addDescendingOrder:@"createdAt"];

    return query;
}

// Override to customize the look of a cell representing an object. The default is to display
// a UITableViewCellStyleDefault style cell with the label being the first key in the object.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    static NSString *reusableIdentifier = @"quakeCell";

    Quake *quake = [[Quake alloc] initWithPFObject:object];
    QuakeCell *cell = (QuakeCell *)[tableView dequeueReusableCellWithIdentifier:reusableIdentifier];

    if (!cell) {
        cell = [[QuakeCell alloc] initWithQuakeCellStyle:QuakeCellStyleNotFelt reuseIdentifier:reusableIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    }

    cell.launchButton.tag = indexPath.row;
    [cell.launchButton addTarget:self action:@selector(launchQuakeDetailsVC:) forControlEvents:UIControlEventTouchUpInside];

    [cell updateFromQuake:quake];

    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath {
    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    QuakeCell *cell = (QuakeCell *)[super tableView:tableView cellForNextPageAtIndexPath:indexPath];
    cell.textLabel.font = [cell.textLabel.font fontWithSize:DYFTQuakeTableViewCellLabelsFontSize];
    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    cell.backgroundColor = self.view.backgroundColor;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 75.0;
}

#pragma mark -
#pragma mark Notifications

- (void)distanceFilterDidChange:(NSNotification *)note {
    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    [self loadObjects];
}

// When the DYFTCurrentLocationDidChangeNotification is posted,
// the selector specified in the addObserver: method is called
// and we can update the display.
- (void)locationDidChange:(NSNotification *)note {
    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    // Update the table with the new points.
    [self loadObjects];
}

- (void)quakeWasCreated:(NSNotification *)note {
    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    [self loadObjects];
}

- (IBAction)launchQuakeDetailsVC:(id)sender {
    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));

}

#pragma mark - UINavigationBar-based actions

- (IBAction)filterButtonSelected:(id)sender {
    if (debug == 1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    [self presentQuakeFiltersViewController];
}

- (void)hideAllQuakesTableViewController {
    if (debug == 1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
//    [self showViewController:self.allQuakesTableViewController sender:self];
//    [self.allQuakesTableViewController didMoveToParentViewController:self];
}
- (void)presentQuakeFiltersViewController {
    if (debug == 1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));

//    QuakeFiltersViewController *filtersViewController = [[QuakeFiltersViewController alloc] initWithNibName:nil bundle:nil];
//    [self presentViewController:filtersViewController animated:YES completion:nil];
}


@end
