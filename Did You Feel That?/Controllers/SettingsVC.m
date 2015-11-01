//
//  SettingsVC.m
//  Did You Feel That?
//
//  Created by Emily Priddy on 6/10/15.
//  Copyright (c) 2015 Headstorm Studios. All rights reserved.
//

#import "SettingsVC.h"
#import <Parse/Parse.h>

#import "DYFTConstants.h"
#import "DYFTConfigManager.h"

typedef NS_ENUM(uint8_t, SettingsTableViewSection)
{
    SettingsTableViewSectionDistance = 0,
    SettingsTableViewSectionLogout,

    SettingsTableViewNumberOfSections
};

static uint16_t const SettingsTableViewLogoutNumberOfRows = 1;

@interface SettingsVC ()
@property (nonatomic, strong) NSArray *distanceOptions;
@property (nonatomic, assign) CLLocationAccuracy filterDistance;
@end

@implementation SettingsVC

#define debug 1

#pragma mark -
#pragma mark Init

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _filterDistance = [[NSUserDefaults standardUserDefaults] doubleForKey:DYFTUserDefaultsFilterDistanceKey];
        [self loadAvailableDistanceOptions];
    }
    return self;
}

#pragma mark -
#pragma mark UIViewController

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

#pragma mark -
#pragma mark Accessors

- (void)setFilterDistance:(CLLocationAccuracy)filterDistance {
    if (self.filterDistance != filterDistance) {
        _filterDistance = filterDistance;

        [[NSUserDefaults standardUserDefaults] setDouble:filterDistance forKey:DYFTUserDefaultsFilterDistanceKey];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:DYFTDistanceFilterDidChangeNotification
                                                                object:nil
                                                              userInfo:@{ kDYFTFilterDistanceKey : @(filterDistance) }];
        });
    }
}

#pragma mark -
#pragma mark UINavigationBar-based actions

- (IBAction)done:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark Data

- (void)loadAvailableDistanceOptions {
    NSMutableArray *distanceOptions = [[[DYFTConfigManager sharedManager] filterDistanceOptions] mutableCopy];

    NSNumber *defaultFilterDistance = @(DYFTDefaultFilterDistance);
    if (![distanceOptions containsObject:defaultFilterDistance]) {
        [distanceOptions addObject:defaultFilterDistance];
    }

    [distanceOptions sortUsingSelector:@selector(compare:)];

    self.distanceOptions = [distanceOptions copy];
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return SettingsTableViewNumberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case SettingsTableViewSectionDistance:
            return [self.distanceOptions count];
            break;
        case SettingsTableViewSectionLogout:
            return SettingsTableViewLogoutNumberOfRows;
            break;
        case SettingsTableViewNumberOfSections:
            return 0;
            break;
    };

    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"SettingsTableView";
    if (indexPath.section == SettingsTableViewSectionDistance) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if ( cell == nil )
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }

        DYFTLocationAccuracy distance = [self.distanceOptions[indexPath.row] doubleValue];

        // Configure the cell.
        cell.textLabel.text = [NSString stringWithFormat:@"%d feet", (int)distance];
        cell.textLabel.textAlignment = NSTextAlignmentLeft;

        if (self.filterDistance == 0.0) {
            NSLog(@"We have a zero filter distance!");
        }

        if (fabs(DYFTFeetToMeters(distance) - self.filterDistance) < 0.001 ) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }

        return cell;
    } else if (indexPath.section == SettingsTableViewSectionLogout) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if ( cell == nil )
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }

        // Configure the cell.
        cell.textLabel.text = @"Log out of DYFT?";
        cell.textLabel.textAlignment = NSTextAlignmentCenter;

        return cell;
    }

    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case SettingsTableViewSectionDistance:
            return @"Search Distance";
            break;
        case SettingsTableViewSectionLogout:
        case SettingsTableViewNumberOfSections:
            return nil;
            break;
    }

    return nil;
}

#pragma mark -
#pragma mark UITableViewDelegate

// Called after the user changes the selection.
- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == SettingsTableViewSectionDistance) {
        [aTableView deselectRowAtIndexPath:indexPath animated:YES];

        // if we were already selected, bail and save some work.
        UITableViewCell *selectedCell = [aTableView cellForRowAtIndexPath:indexPath];
        if (selectedCell.accessoryType == UITableViewCellAccessoryCheckmark) {
            return;
        }

        // uncheck all visible cells.
        for (UITableViewCell *cell in [aTableView visibleCells]) {
            if (cell.accessoryType != UITableViewCellAccessoryNone) {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
        selectedCell.accessoryType = UITableViewCellAccessoryCheckmark;

        DYFTLocationAccuracy distanceForCellInFeet = [self.distanceOptions[indexPath.row] doubleValue];
        self.filterDistance = DYFTFeetToMeters(distanceForCellInFeet);
    } else if (indexPath.section == SettingsTableViewSectionLogout) {
        [aTableView deselectRowAtIndexPath:indexPath animated:YES];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Log out of DYFT?"
                                                            message:nil
                                                           delegate:self
                                                  cancelButtonTitle:@"Log out"
                                                  otherButtonTitles:@"Cancel", nil];
        [alertView show];
    }
}

#pragma mark -
#pragma mark UIAlertViewDelegate

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == alertView.cancelButtonIndex) {
        // Log out.
        [PFUser logOut];

        [self.delegate settingsViewControllerDidLogout:self];
    }
}

// Nil implementation to avoid the default UIAlertViewDelegate method, which says:
// "Called when we cancel a view (eg. the user clicks the Home button). This is not called when the user clicks the cancel button.
// If not defined in the delegate, we simulate a click in the cancel button"
// Since we have "Log out" at the cancel index (to get it out from the normal "Ok whatever get this dialog outta my face"
// position, we need to deal with the consequences of that.
- (void)alertViewCancel:(UIAlertView *)alertView {
    return;
}

@end
