//
//  FeltTableVC.m
//  Did You Feel That?
//
//  Created by Emily Priddy on 6/24/15.
//  Copyright (c) 2015 Headstorm Studios. All rights reserved.
//

#import "FeltQuakesTableViewController.h"

#import "DYFTConstants.h"
#import "QuakeCell.h"
#import "AppDelegate.h"
#import "NSDate+DateTools.h"
#import "Quake.h"
#import "FeltMapVC.h"

#import "FeltQuakesTableViewController.h"


@interface FeltQuakesTableViewController ()
@property (strong, nonatomic) UIButton *noDataButton;
@property (strong, nonatomic) UIStoryboard *sb;
@end

@implementation FeltQuakesTableViewController
#define debug 0

#pragma mark - Init

- (instancetype)initWithStyle:(UITableViewStyle)style {
    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    self = [super initWithStyle:style];
    if (self) {
        self.parseClassName = @"USGSQuakes";
        self.textKey = DYFTQuakesTitleKey;
        self.pullToRefreshEnabled = YES;
        self.paginationEnabled = YES;
        self.objectsPerPage = DYFTFeltQuakesSearchDefaultLimit;

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventWasCreated:) name:DYFTQuakeCreatedNotification object:nil];
    }
    return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    [super viewDidLoad];
    self.tableView.separatorColor = self.view.backgroundColor;
    self.refreshControl.tintColor = [UIColor colorWithRed:118.0f/255.0f green:117.0f/255.0f blue:46.0f/255.0f alpha:1.0f];

    // Set up a view for empty content.
    self.noDataButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.noDataButton setTintColor:[UIColor colorWithRed:118.0f/255.0f green:117.0f/255.0f blue:46.0f/255.0f alpha:1.0f]];
    [self.noDataButton setTitle:@"Pull down to refresh." forState:UIControlStateNormal];
    self.noDataButton.hidden = YES;
    [self.view addSubview:self.noDataButton];
    _sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    [super viewDidDisappear:animated];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:DYFTQuakeCreatedNotification object:nil];
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

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

#pragma mark - PFQueryTableViewController

- (void)objectsWillLoad {
    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    [super objectsWillLoad];

    // This method is called before a PFQuery is fired to get more objects.
}

- (void)objectsDidLoad:(nullable NSError *)error {
    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    [super objectsDidLoad:error];

    self.noDataButton.hidden = ([self.objects count] != 0);
}

- (PFQuery *)queryForTable {
    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));

    PFQuery *query = [PFQuery queryWithClassName:@"USGSQuakes"];
    PFUser *user = [PFUser currentUser];
    [query whereKey:@"feltByUsers" containedIn:@[user]];
    [query addDescendingOrder:@"createdAt"];

    return query;
}

- (QuakeCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath * __nonnull)indexPath object:(nullable PFObject *)object {
    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    static NSString *reusableIdentifier = @"quakeCell";

    Quake *quake = [[Quake alloc] initWithPFObject:object];
    QuakeCell *cell = (QuakeCell *)[tableView dequeueReusableCellWithIdentifier:reusableIdentifier];

    if (!cell) {
        cell = [[QuakeCell alloc] initWithQuakeCellStyle:QuakeCellStyleFelt reuseIdentifier:reusableIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    }

    cell.launchButton.tag = indexPath.row;
    [cell.launchButton addTarget:self action:@selector(launchFeltMapVC:) forControlEvents:UIControlEventTouchUpInside];

    [cell updateFromQuake:quake];

    return cell;
}

- (QuakeCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath * __nonnull)indexPath {
    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    QuakeCell *cell = (QuakeCell *)[super tableView:tableView cellForNextPageAtIndexPath:indexPath];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = self.view.backgroundColor;
}

#pragma mark - Notifications

- (void)eventWasCreated:(NSNotification *)note {
    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    [self loadObjects];
}

#pragma mark - Navigation
// prepareForSegue:sender: is not called because launchFeltMapVC is used instead.
/*- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));

    FeltMapVC *mapVC = (FeltMapVC *)segue.destinationViewController;

    if ([segue.identifier isEqualToString:@"showMap"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        PFObject *object = [self objectAtIndexPath:indexPath];

        mapVC.quakeID = object.objectId;
    }
}*/

- (IBAction)launchFeltMapVC:(id)sender {
    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    UIButton *button = (UIButton *)sender;

    FeltMapVC *mapVC = [_sb instantiateViewControllerWithIdentifier:@"feltMapVC"];
    PFObject *object = [self.objects objectAtIndex:button.tag];

    mapVC.quakeID = object.objectId;
    mapVC.quakeObject = object;
    [self.navigationController pushViewController:mapVC animated:YES];
}
@end
