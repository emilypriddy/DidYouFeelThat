//
//  SetupViewController.m
//  Did You Feel That?
//
//  Created by Emily Priddy on 7/16/15.
//  Copyright (c) 2015 Headstorm Studios. All rights reserved.
//

#import "SetupViewController.h"
#import <Parse/Parse.h>
#import "DYFTConstants.h"
#import "DYFTConfigManager.h"

NSString * const kSetupInfoKeyDistanceFilter = @"SetupInfoKeyDistanceFilter";
NSString * const kSetupInfoKeySelectedStates = @"SetupInfoKeySelectedStates";
NSString * const kSetupInfoKeyMagnitudeFilter = @"SetupInfoKeyMagnitudeFilter";

//static NSString * const kMagnitudeNameKey = @"MagnitudeNameKey";
//static NSString * const kMagnitudeValueKey = @"MagnitudeValueKey";


@interface SetupViewController ()

@property (nonatomic, strong) NSMutableDictionary *setupInfo;
@property (nonatomic, strong) NSArray *stateOptions;

@property (nonatomic, strong) NSMutableIndexSet *selectedIndexes;
@property (nonatomic, strong) NSNumber *selectedMagnitude;
@property (nonatomic, strong) NSNumber *selectedDistance;
@property (nonatomic, assign) CLLocationAccuracy filterDistance;
@property (nonatomic, strong) NSMutableArray *selectedStates;
@property (nonatomic, assign) NSNumber *sendNearbyQuakesPush;

@end

#define debug 1

@implementation SetupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSString *plistPath = [documentsPath stringByAppendingPathComponent:@"UserPrefs.plist"];

    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        // if not in documents, get property list from main bundle
        plistPath = [[NSBundle mainBundle] pathForResource:@"UserPrefs" ofType:@"plist"];
    }

    // read plist into memory as an NSData object
    NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
    //NSString *errorDesc = nil;
    NSError *errorDesc = nil;
    NSPropertyListFormat format;

    // convert static property list into dictionary object
    NSDictionary *rootDict = (NSDictionary *)[NSPropertyListSerialization propertyListWithData:plistXML options:NSPropertyListMutableContainersAndLeaves format:&format error:&errorDesc];
    if (!rootDict) {
        NSLog(@"Error reading plist: %@, format: %lu", errorDesc, (unsigned long)format);
    }

    NSLog(@"Read user prefs from plist: %@", rootDict);

    // assign values
    self.selectedDistance = [rootDict objectForKey:@"maximumDistance"];
    self.selectedMagnitude = [rootDict objectForKey:@"minimumMagnitude"];
    self.selectedStates = [NSMutableArray arrayWithArray:[rootDict objectForKey:@"selectedStates"]];
    self.sendNearbyQuakesPush = [rootDict objectForKey:@"nearbyQuakes"];

    // display values
    self.magnitudeTextField.text = [NSString stringWithFormat:@"%@", self.selectedMagnitude];
    self.distanceTextField.text = [NSString stringWithFormat:@"%@", self.selectedDistance];
    self.textView.text = [self.selectedStates componentsJoinedByString:@"\n"];

//    UIBarButtonItem *settingsItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"gear"] style:UIBarButtonItemStylePlain target:self action:@selector(showSettingsViewController)];
//    UIBarButtonItem *searchItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"search"] style:UIBarButtonItemStylePlain target:self action:@selector(showSearchViewController)];

    self.profileVC = [[UserProfileViewController alloc] init];

    UIImage *userProfileImage = [[UIImage imageNamed:@"edit_user"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *userProfileItem = [[UIBarButtonItem alloc] initWithImage:userProfileImage style:UIBarButtonItemStylePlain target:self action:@selector(showUserProfileViewController)];
    self.navigationItem.rightBarButtonItems = [self.navigationItem.rightBarButtonItems arrayByAddingObject:userProfileItem];

//    UIImage *searchImage = [[UIImage imageNamed:@"search"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//    UIBarButtonItem *searchItem = [[UIBarButtonItem alloc] initWithImage:searchImage style:UIBarButtonItemStylePlain target:self action:@selector(showSearchViewController)];
//
//    self.navigationItem.rightBarButtonItems = [self.navigationItem.rightBarButtonItems arrayByAddingObject:searchItem];



}

- (void)showSearchViewController {
    NSLog(@"showSearchViewController was called");
}
- (void)showUserProfileViewController {
    NSLog(@"showUserProfileViewController was called");
    [self.navigationController pushViewController:self.profileVC animated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

}

- (IBAction)statesBtnClicked:(id)sender {
    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    float paddingTopBottom = 20.0f;
    float paddingLeftRight = 20.0f;

    CGPoint point = CGPointMake(paddingLeftRight, (self.navigationController.navigationBar.frame.size.height + paddingTopBottom) + paddingTopBottom);
    CGSize size = CGSizeMake((self.view.frame.size.width - (paddingLeftRight * 2)), self.view.frame.size.height - ((self.navigationController.navigationBar.frame.size.height + paddingTopBottom) + (paddingTopBottom * 2)));

    LPPopupListView *listView = [[LPPopupListView alloc] initWithTitle:@"List View" list:[self list] selectedIndexes:self.selectedIndexes point:point size:size multipleSelection:YES];
    listView.delegate = self;

    [listView showInView:self.view animated:YES];
}

- (IBAction)saveUserPrefs:(id)sender {
    // get paths from root directory
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    // get documents path
    NSString *documentsPath = [paths objectAtIndex:0];
    // get the path to our UserPrefs/plist file
    NSString *plistPath = [documentsPath stringByAppendingPathComponent:@"UserPrefs.plist"];

    // set the variables to the values in the text fields
    self.selectedMagnitude = [NSNumber numberWithDouble:[self.magnitudeTextField.text doubleValue]];;
    self.selectedDistance = [NSNumber numberWithDouble:[self.distanceTextField.text doubleValue]];

    if (self.selectedDistance > 0) {
        self.sendNearbyQuakesPush = @1;
    } else {
        self.sendNearbyQuakesPush = @0;
    }
    
    NSArray *statesArray = [self.textView.text componentsSeparatedByString:@"\n"];

    // if one of the items in the selectedStates array is actually an empty string, remove it before saving to plist
    self.selectedStates = [NSMutableArray arrayWithArray:statesArray];
    for (NSString *i in self.selectedStates) {
        if (i.length <= 1) {
            [self.selectedStates removeObject:i];
        }
    }

    // create dictionary with values in UITextFields & UITextView
    NSDictionary *plistDict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:self.selectedDistance, self.selectedMagnitude, self.selectedStates, self.sendNearbyQuakesPush, nil] forKeys:[NSArray arrayWithObjects:@"maximumDistance", @"minimumMagnitude", @"selectedStates", @"nearbyQuakes", nil]];

    NSString *error = nil;
    // create NSData from dictionary
    NSData *plistData = [NSPropertyListSerialization dataFromPropertyList:plistDict format:NSPropertyListXMLFormat_v1_0 errorDescription:&error];

    // check if plistData exists
    if (plistData) {
        // write plistData to our UserPrefs.plist file
        [plistData writeToFile:plistPath atomically:YES];
    }
    else
    {
        NSLog(@"Error in saveUserPrefs: %@", error);
    }


    if ([self.delegate respondsToSelector:@selector(setupViewController:didFinishSetupWithInfo:)]) {
        [self.delegate setupViewController:self didFinishSetupWithInfo:self.setupInfo];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)textFieldReturn:(id)textField {
    [textField resignFirstResponder];
}

#pragma mark - LPPopupListViewDelegate

- (void)popupListView:(LPPopupListView *)popupListView didSelectIndex:(NSInteger)index
{
    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    NSLog(@"popUpListView - didSelectedIndex: %ld", (long)index);
}

- (void)popupListViewDidHide:(LPPopupListView *)popUpListView selectedIndexes:(NSIndexSet *)selectedIndexes
{
    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    NSLog(@"popupListViewDidHide - selectedIndexes: %@", selectedIndexes.description);

    self.selectedIndexes = [[NSMutableIndexSet alloc] initWithIndexSet:selectedIndexes];

    self.textView.text = @"";
    [selectedIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        self.textView.text = [self.textView.text stringByAppendingFormat:@"%@\n", [[self list] objectAtIndex:idx]];
    }];
}

#pragma mark - Array List


- (NSArray *)list {
    self.stateOptions = @[@"Alabama", @"Alaska", @"Arizona", @"Arkansas", @"California", @"Colorado", @"Connecticut", @"Deleware", @"Georgia", @"Florida", @"Hawaii", @"Idaho", @"Illinois", @"Indiana", @"Iowa", @"Kansas", @"Kentucky", @"Louisiana", @"Maine", @"Maryland", @"Massachusetts", @"Michigan", @"Minnesota", @"Mississippi", @"Missouri", @"Montana", @"Nebraska", @"Nevada", @"New Hampshire", @"New Jersey", @"New Mexico", @"New York", @"North Carolina", @"North Dakota", @"Ohio", @"Oklahoma", @"Oregon", @"Pennsylvania", @"Rhode Island", @"South Carolina", @"South Dakota", @"Tennessee", @"Texas", @"Utah", @"Vermont", @"Virginia", @"Washington", @"West Virginia", @"Wisconsin", @"Wyoming"];
    return self.stateOptions;
}

@end
