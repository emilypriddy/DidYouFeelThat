//
//  QuakeRegisterVC.m
//  Did You Feel That?
//
//  Created by Emily Priddy on 6/10/15.
//  Copyright (c) 2015 Headstorm Studios. All rights reserved.
//

#import "QuakeRegisterVC.h"

#import <Parse/Parse.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import "DYFTConstants.h"
#import "DYFTConfigManager.h"
#import "NSDate+DateTools.h"

#import "AppDelegate.h"

@interface QuakeRegisterVC () <UIGestureRecognizerDelegate, FBSDKSharingDelegate>
@property (strong, nonatomic) NSDictionary *backLinkInfo;
@property (weak, nonatomic) UIView *backLinkView;
@property (weak, nonatomic) UILabel *backLinkLabel;
@property (strong, nonatomic) NSNumber *mercaliGuess;
@property (strong, nonatomic) NSNumber *richterGuess;
@property (strong, nonatomic) NSNumber *timeAgoGuess;
@property (strong, nonatomic) NSNumber *distanceGuess;
@property (strong, nonatomic) NSString *shareDescription;
@property (strong, nonatomic) NSDate *expirationDate;

@property (strong, nonatomic) UIAlertController *shareAlertController;
@end

@implementation QuakeRegisterVC
#define debug 1

#pragma mark -
#pragma mark Init

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
}

- (void)viewWillAppear:(BOOL)animated {
    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    [super viewWillAppear:animated];

    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (delegate.refererAppLink) {
        self.backLinkInfo = delegate.refererAppLink;
        [self _showBackLink];
    }
    delegate.refererAppLink = nil;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (void)setShareAlertController:(UIAlertController *)shareAlertController {
    if (![_shareAlertController isEqual:shareAlertController]) {
        _shareAlertController = shareAlertController;
    }
}

#pragma mark -
#pragma mark UINavigationBar-based actions

- (IBAction)cancelQuakeRegistration:(id)sender {
    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)registerQuake:(id)sender {
    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));


    // Data prep:
    // Get user's current location
    CLLocation *currentLocation = [self.dataSource currentLocationForRegisterQuakeViewController:self];
    CLLocationCoordinate2D currentCoordinate = currentLocation.coordinate;

    // Create a PFGeoPoint using the user's location
    PFGeoPoint *currentPoint = [PFGeoPoint geoPointWithLatitude:currentCoordinate.latitude
                                                      longitude:currentCoordinate.longitude];

    // Get the currently logged in PFUser
    PFUser *user = [PFUser currentUser];

    // Get the user's installation
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];


    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;

//    _mercaliGuess = [NSNumber numberWithInteger: [self.mercaliField.text integerValue]];
//    _richterGuess = [f numberFromString:self.richterField.text];
//    _timeAgoGuess = [NSNumber numberWithInteger: [self.timeField.text integerValue]];
//    _distanceGuess = [NSNumber numberWithInteger: [self.distanceField.text integerValue]];
    NSDate *currentDate = [NSDate date];
    _expirationDate = [currentDate dateByAddingMinutes:60];

    self.shareDescription = [NSString stringWithFormat:@"Did You Feel That?"];


    // Stitch together a userEventObject and send this async to Parse
    // Create a PFObject using the UserEvent class and set the values we extracted above.
    PFObject *userEventObject = [PFObject objectWithClassName:DYFTUserEventClassKey];

    userEventObject[DYFTUserEventUserKey] = user;
    userEventObject[DYFTUserEventExpirationKey] = self.expirationDate;
    userEventObject[DYFTUserEventInstallationKey] = currentInstallation;
    userEventObject[DYFTUserEventUserLocationKey] = currentPoint;
//    userEventObject[DYFTUserEventMercaliGuessKey] = self.mercaliGuess;
//    userEventObject[DYFTUserEventRichterGuessKey] = self.richterGuess;
//    userEventObject[DYFTUserEventTimeAgoGuessKey] = self.timeAgoGuess;
//    userEventObject[DYFTUserEventDistanceGuessKey] = self.distanceGuess;

    // Use PFACL to restrict future modifications to this object.
    PFACL *readOnlyACL = [PFACL ACL];
    [readOnlyACL setPublicReadAccess:YES];
    [readOnlyACL setPublicWriteAccess:NO];
    userEventObject.ACL = readOnlyACL;

    [userEventObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {  // Failed to save, show an alert view with the error message.
            NSLog(@"Couldn't save!");
            NSLog(@"%@", error);

            UIAlertController *alertController = self.shareAlertController =
            [UIAlertController alertControllerWithTitle:[error userInfo][@"error"]
                                                message:nil
                                         preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction
                                           actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
                                           style:UIAlertActionStyleCancel
                                           handler:^(UIAlertAction *action) {
                                               NSLog(@"Cancel action");
                                           }];
            UIAlertAction *okAction = [UIAlertAction
                                       actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction *action) {
                                           NSLog(@"OK action");
                                       }];
            [alertController addAction:cancelAction];
            [alertController addAction:okAction];
            [[UIApplication sharedApplication].keyWindow.rootViewController.presentedViewController presentViewController:alertController animated:YES completion:nil];

            return;
        }
        if (succeeded) {  // Successfully saved, post a notification to tell other view controllers.

            NSLog(@"Successfully saved!");
            NSLog(@"%@", userEventObject);
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:DYFTQuakeCreatedNotification object:nil];
            });

            UIAlertController *alertController = [UIAlertController
                                                  alertControllerWithTitle:@"Share Earthquake To Facebook"
                                                  message:@"Do you want to share the earthquake you just registered with friends on Facebook?"
                                                  preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction
                                           actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
                                           style:UIAlertActionStyleCancel
                                           handler:^(UIAlertAction *action) {
                                               NSLog(@"Cancel action");
                                           }];
            UIAlertAction *okAction = [UIAlertAction
                                       actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction *action) {
                                           NSLog(@"OK action");
                                           [self getShareDialog];
                                       }];
            [alertController addAction:cancelAction];
            [alertController addAction:okAction];
            [[UIApplication sharedApplication].keyWindow.rootViewController.presentedViewController presentViewController:alertController animated:YES completion:nil];
        } else {
            NSLog(@"Failed to save.");
        }
    }];
    // Dismiss this view controller and return to the main view.
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)getShareDialog {

}

- (void)shareLinkWithShareDialog {
    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    // Check if the Facebook app is installed and we can present the share dialog
    /* - (instancetype)initWithLink:(NSURL *)link
name:(NSString *)name
caption:(NSString *)caption
description:(NSString *)description
picture:(NSURL *)picture; */
    NSURL *linkURL = [NSURL URLWithString:@"http://emilypriddy.com"];
    NSURL *pictureURL = [NSURL URLWithString:@"http://i.imgur.com/VIpMbnf.jpg"];
    NSString *nameString = @"Did You Feel That?";
    NSString *captionString = @"Get the Did You Feel That? app and see how many others felt it!";
    NSString *descriptionString = self.shareDescription;

#pragma mark - FIX ERROR DUE TO UPDATES FROM HERE:
    /*
    FBLinkShareParams *params = [[FBLinkShareParams alloc] initWithLink:linkURL
                                                                   name:nameString
                                                                caption:captionString
                                                            description:descriptionString
                                                                picture:pictureURL];
//    params.link = [NSURL URLWithString:@"dyft://"];

    // If the Facebook app is installed and we can present the share dialog
    if ([FBDialogs canPresentShareDialogWithParams:params]) {

        // Present share dialog
        [FBDialogs presentShareDialogWithLink:params.link
                                      handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                          if(error) {
                                              // An error occurred, we need to handle the error
                                              // See: https://developers.facebook.com/docs/ios/errors
                                              NSLog(@"Error publishing story: %@", error.description);
                                          } else {
                                              // Success
                                              NSLog(@"result %@", results);
                                          }
                                      }];

        // If the Facebook app is NOT installed and we can't present the share dialog
    } else {
        // FALLBACK: publish just a link using the Feed dialog

        // Put together the dialog parameters
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"Did You Feel That?", @"name",
                                       @"Get the Did You Feel That? app and see how many others felt it!" , @"caption",
                                       self.shareDescription, @"description",
                                       @"http://emilypriddy.com", @"link",
                                       @"http://i.imgur.com/VIpMbnf.jpg", @"picture",
                                       nil];

        // Show the feed dialog
        [FBWebDialogs presentFeedDialogModallyWithSession:nil
                                               parameters:params
                                                  handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                      if (error) {
                                                          // An error occurred, we need to handle the error
                                                          // See: https://developers.facebook.com/docs/ios/errors
                                                          NSLog(@"Error publishing story: %@", error.description);
                                                      } else {
                                                          if (result == FBWebDialogResultDialogNotCompleted) {
                                                              // User canceled.
                                                              NSLog(@"User cancelled.");
                                                          } else {
                                                              // Handle the publish feed callback
                                                              NSDictionary *urlParams = [self parseURLParams:[resultURL query]];

                                                              if (![urlParams valueForKey:@"post_id"]) {
                                                                  // User canceled.
                                                                  NSLog(@"User cancelled.");

                                                              } else {
                                                                  // User clicked the Share button
                                                                  NSString *result = [NSString stringWithFormat: @"Posted story, id: %@", [urlParams valueForKey:@"post_id"]];
                                                                  NSLog(@"result %@", result);
                                                              }
                                                          }
                                                      }
                                                  }];
    }
    */
#pragma mark TO HERE -
}

- (void)shareLinkWithAPICalls {
    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    // We will post on behalf of the user, these are the permissions we need:
    NSArray *permissionsNeeded = @[@"publish_actions"];

    #pragma mark - FIX ERROR DUE TO UPDATES FROM HERE:
    /*
    // Request the permissions the user currently has
    [FBRequestConnection startWithGraphPath:@"/me/permissions"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              if (!error){
                                  // Parse the list of existing permissions and extract them for easier use
                                  NSMutableArray *currentPermissions = [[NSMutableArray alloc] init];
                                  NSArray *returnedPermissions = (NSArray *)[result data];
                                  for (NSDictionary *perm in returnedPermissions) {
                                      if ([[perm objectForKey:@"status"] isEqualToString:@"granted"]) {
                                          [currentPermissions addObject:[perm objectForKey:@"permission"]];
                                      }
                                  }

                                  // Build the list of requested permissions by starting with the permissions
                                  // needed and then removing any current permissions
                                  NSLog(@"Needed: %@", permissionsNeeded);
                                  NSLog(@"Current: %@", currentPermissions);

                                  NSMutableArray *requestPermissions = [[NSMutableArray alloc] initWithArray:permissionsNeeded copyItems:YES];
                                  [requestPermissions removeObjectsInArray:currentPermissions];

                                  NSLog(@"Asking: %@", requestPermissions);

                                  // If we have permissions to request
                                  if ([requestPermissions count] > 0){
                                      // Ask for the missing permissions
                                      [FBSession.activeSession requestNewPublishPermissions:requestPermissions
                                                                            defaultAudience:FBSessionDefaultAudienceFriends
                                                                          completionHandler:^(FBSession *session, NSError *error) {
                                                                              if (!error) {
                                                                                  // Permission granted, we can request the user information
                                                                                  NSLog(@"No errors...permissions granted! Call -makeRequestToShareLink");
                                                                                  [self makeRequestToShareLink];
                                                                              } else {
                                                                                  // An error occurred, handle the error
                                                                                  // See our Handling Errors guide: https://developers.facebook.com/docs/ios/errors/
                                                                                  NSLog(@"Have active session, failed for another reason:\n%@\n%@\n%@\n%@\n%@\n%@", [error userInfo], [error fberrorUserMessage], [error localizedDescription], [error localizedFailureReason], [error localizedRecoveryOptions], [error localizedRecoverySuggestion]);
                                                                              }
                                                                          }];
                                  } else {
                                      // Permissions are present, we can request the user information
                                      NSLog(@"Permissions are present. Call -makeRequestToShareLink");
                                      [self makeRequestToShareLink];
                                  }
                              } else {
                                  // There was an error requesting the permission information
                                  // See our Handling Errors guide: https://developers.facebook.com/docs/ios/errors/
                                  NSLog(@"Error requesting the permission information:\n%@\n%@\n%@\n%@\n%@\n%@", [error userInfo], [error fberrorUserMessage], [error localizedDescription], [error localizedFailureReason], [error localizedRecoveryOptions], [error localizedRecoverySuggestion]);
                              }
                          }];
    */
    #pragma mark TO HERE -
}

- (void)makeRequestToShareLink {
    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    // NOTE: pre-filling fields associated with Facebook posts,
    // unless the user manually generated the content earlier in the workflow of your app,
    // can be against the Platform policies: https://developers.facebook.com/policy

    // Put together the dialog parameters
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   @"Did You Feel That?", @"name",
                                   @"Get the Did You Feel That? app!" , @"caption",
                                   self.shareDescription, @"description",
                                   @"http://emilypriddy.com", @"link",
                                   @"http://i.imgur.com/VIpMbnf.jpg", @"picture",
                                   nil];

    #pragma mark - FIX ERROR DUE TO UPDATES FROM HERE:
    /*
    // Make the request
    [FBRequestConnection startWithGraphPath:@"/me/feed"
                                 parameters:params
                                 HTTPMethod:@"POST"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              if (!error) {
                                  // Link posted successfully to Facebook
                                  NSLog(@"result: %@", result);
                              } else {
                                  // An error occurred, we need to handle the error
                                  // See: https://developers.facebook.com/docs/ios/errors
                                  NSLog(@"Error making the actual request using link: %@\n:\n%@\n%@\n%@\n%@\n%@\n%@", params[@"link"], [error userInfo], [error fberrorUserMessage], [error localizedDescription], [error localizedFailureReason], [error localizedRecoveryOptions], [error localizedRecoverySuggestion]);
                              }
                          }];

    */
    #pragma mark TO HERE -
}

//------------------------------------



//------------------------------------

// A function for parsing URL parameters returned by the Feed Dialog.
- (NSDictionary*)parseURLParams:(NSString *)query {
    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val =
        [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        params[kv[0]] = val;
    }
    return params;
}

//------------------------------------


//------------------Handling links back to app link launching app------------------

- (void) _showBackLink {
    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    if (nil == self.backLinkView) {
        // Set up the view
        UIView *backLinkView = [[UIView alloc] initWithFrame:
                                CGRectMake(0, 30, 320, 40)];
        backLinkView.backgroundColor = [UIColor darkGrayColor];
        UILabel *backLinkLabel = [[UILabel alloc] initWithFrame:
                                  CGRectMake(2, 2, 316, 36)];
        backLinkLabel.textColor = [UIColor whiteColor];
        backLinkLabel.textAlignment = NSTextAlignmentCenter;
        backLinkLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0f];
        [backLinkView addSubview:backLinkLabel];
        self.backLinkLabel = backLinkLabel;
        [self.view addSubview:backLinkView];
        self.backLinkView = backLinkView;
    }
    // Show the view
    self.backLinkView.hidden = NO;
    // Set up the back link label display
    self.backLinkLabel.text = [NSString
                               stringWithFormat:@"Touch to return to %@", self.backLinkInfo[@"app_name"]];
    // Set up so the view can be clicked
    UITapGestureRecognizer *tapGestureRecognizer =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(_returnToLaunchingApp:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [self.backLinkView addGestureRecognizer:tapGestureRecognizer];
    tapGestureRecognizer.delegate = self;
}

- (void)_returnToLaunchingApp:(id)sender {
    // Open the app corresponding to the back link
    NSURL *backLinkURL = [NSURL URLWithString:self.backLinkInfo[@"url"]];
    if ([[UIApplication sharedApplication] canOpenURL:backLinkURL]) {
        [[UIApplication sharedApplication] openURL:backLinkURL];
    }
    self.backLinkView.hidden = YES;
}
//------------------------------------



/*
#pragma mark -
#pragma mark UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    [self updateCharacterCountLabel];
    [self checkCharacterCount];
}

#pragma mark -
#pragma mark Accessors

- (void)setMaximumCharacterCount:(NSUInteger)maximumCharacterCount {
    if (self.maximumCharacterCount != maximumCharacterCount) {
        _maximumCharacterCount = maximumCharacterCount;

        [self updateCharacterCountLabel];
        [self checkCharacterCount];
    }
}

#pragma mark -
#pragma mark Private

- (void)updateCharacterCountLabel {
    NSUInteger count = [self.textView.text length];
    self.characterCountLabel.text = [NSString stringWithFormat:@"%lu/%lu",
                                     (unsigned long)count,
                                     (unsigned long)self.maximumCharacterCount];
    if (count > self.maximumCharacterCount || count == 0) {
        self.characterCountLabel.font = [UIFont boldSystemFontOfSize:self.characterCountLabel.font.pointSize];
    } else {
        self.characterCountLabel.font = [UIFont systemFontOfSize:self.characterCountLabel.font.pointSize];
    }
}

- (BOOL)checkCharacterCount {
    BOOL enabled = YES;
    return enabled;
        BOOL enabled = NO;
    
        NSUInteger count = [self.textView.text length];
        if (count > 0 && count < self.maximumCharacterCount) {
            enabled = YES;
        }
        
        self.registerEventButton.enabled = enabled;
        
        return enabled;
}
 */

@end
