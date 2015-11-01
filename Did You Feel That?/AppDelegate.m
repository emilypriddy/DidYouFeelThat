//
//  AppDelegate.m
//  Did You Feel That?
//
//  Created by Emily Priddy on 6/10/15.
//  Copyright (c) 2015 Headstorm Studios. All rights reserved.
//

#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <Fabric/Fabric.h>
#import <TwitterKit/TwitterKit.h>

@import HockeySDK;

#import "DYFTConstants.h"
#import "utilities.h"
#import "DYFTConfigManager.h"

#import "AppDelegate.h"
#import "SetupViewController.h"
#import "AllQuakesMapViewController.h"
#import "UserLoginVC.h"

#import "AllQuakesContainerViewController.h"


@interface AppDelegate () <QuakesViewControllerDelegate, SetupViewControllerDelegate>
@property (nonatomic, strong) NSData *devicePushToken;
@property (nonatomic, weak) AllQuakesContainerViewController *containerController;

@end

@implementation AppDelegate
#define debug 1

#pragma mark - init

// Ideas from FB Scrumptious app
+ (void)initialize {
    [FBSDKLoginButton class];
    [FBSDKProfilePictureView class];
    [FBSDKShareButton class];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));

//    [Parse enableLocalDatastore];
    [Parse setApplicationId:@"PHtDN2GzjO0QqaWFLZ59Gcx3424kgh0oTDuqnY0Y" clientKey:@"jTtjBPiul8Ry0iUecXL470nlT22poIH70I8LSGB8"];
    [PFFacebookUtils initializeFacebookWithApplicationLaunchOptions:launchOptions];

    // Track app open.
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];

    if (application.applicationIconBadgeNumber != 0) {
        application.applicationIconBadgeNumber = 0;
        [[PFInstallation currentInstallation] saveInBackground];
    }

    // Set the global tint on the navigation bar
    [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:0.098 green:0.165 blue:0.204 alpha:1.000]];

//    self.navigationController = [[UINavigationController alloc] initWithRootViewController:[[UIViewController alloc] init]];

    // If we have a cached user, we'll get it back here.
    if ([PFUser currentUser]) {
        // A user was cached, so go straight to the main view.
        // Present wall straight-away
        NSLog(@"Have a currentUser");
        [self presentQuakesViewControllerAnimated:NO];
    } else {
        // No cached user.
        // Go to the welcome screen and have them log in or create an account.
        NSLog(@"Do NOT have a currentUser");
        [self presentLoginViewController];
    }

    if (application.applicationState != UIApplicationStateBackground)
    {
        // Track an app open here if we launch with a push, unless
        // "content_available" was used to trigger a background push (introduced
        // in iOS 7). In that case, we skip tracking here to avoid double
        // counting the app-open.
        BOOL preBackgroundPush = ![application respondsToSelector:@selector(backgroundRefreshStatus)];
        BOOL oldPushHandlerOnly = ![self respondsToSelector:@selector(application:didReceiveRemoteNotification:fetchCompletionHandler:)];
        BOOL noPushPayload = ![launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (preBackgroundPush || oldPushHandlerOnly || noPushPayload)
        {
            [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
        }
    }

    [PFImageView class];

    PFACL *defaultACL = [PFACL ACL];
    // Enable public read access by default, with any newly created PFObjects belonging to the current user
    [defaultACL setPublicReadAccess:YES];
    [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];


    [[DYFTConfigManager sharedManager] fetchConfigIfNeeded];

    [self handlePush:launchOptions];

    [self registerApplicationForNotification:application];

    NSLog(@"app dir: %@", [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject]);

//    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
//    self.storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//
//
//
//    self.mainTabBarContorller = [self.storyboard instantiateViewControllerWithIdentifier:@"DYFTMainTabBarController"];
//
//    AllQuakesContainerViewController *allQuakesContainerViewController = [AllQuakesContainerViewController new];
//    DYFTNavigationController *dyftNavController = [[DYFTNavigationController alloc] initWithRootViewController:allQuakesContainerViewController];
//
//    NSMutableArray *viewControllers = (NSMutableArray *)self.mainTabBarContorller.viewControllers;
//    [viewControllers insertObject:dyftNavController atIndex:0];
//    self.mainTabBarContorller.viewControllers = viewControllers;



//    self.containerController = [self.storyboard instantiateViewControllerWithIdentifier:@"AllQuakesContainerViewController"];
//    UINavigationController *allQuakesNavController = [[UINavigationController alloc] initWithRootViewController:self.containerController];

//    [self.mainTabBarContorller.viewControllers arrayByAddingObject:allQuakesNavController];

//    self.window.rootViewController = self.mainTabBarContorller;
//    self.window.tintColor = [UIColor whiteColor];
//    [self.window makeKeyAndVisible];

    [Fabric with:@[[Twitter class]]];

    // Insert HockeyAppSDK code at the top of this method, but as the last third-party SDK code.
//    [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:@"78c44235ccab990da727d948944ddddc"];

    [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:@"3a1e212770f9a2db513a5d199c40eb90"];
    // Do some additional configuration if needed here
//    [[BITHockeyManager sharedHockeyManager] setDebugLogEnabled:YES];
    [[BITHockeyManager sharedHockeyManager] startManager];
    [[BITHockeyManager sharedHockeyManager].authenticator authenticateInstallation];

    [FBSDKProfile enableUpdatesOnAccessTokenChange:YES];
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                    didFinishLaunchingWithOptions:launchOptions];
}

- (void)sendSavedUserPrefsToCloud {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSString *plistPath = [documentsPath stringByAppendingPathComponent:@"UserPrefs.plist"];

    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        // if not in documents, get property list from main bundle
        plistPath = [[NSBundle mainBundle] pathForResource:@"UserPrefs" ofType:@"plist"];
    }

    // read plist into memory as an NSData object
    NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
    NSString *errorDesc = nil;
    NSPropertyListFormat format;

    // convert static property list into dictionary object
    NSDictionary *rootDict = (NSDictionary *)[NSPropertyListSerialization propertyListFromData:plistXML mutabilityOption:NSPropertyListMutableContainersAndLeaves format:&format errorDescription:&errorDesc];
    if (!rootDict) {
        NSLog(@"Error reading plist: %@, format: %lu", errorDesc, (unsigned long)format);
    }

    NSLog(@"Read user prefs from plist: %@", rootDict);

    // assign values
    NSNumber *maxDistance = (NSNumber *)[rootDict objectForKey:@"maximumDistance"];
    NSNumber *minMagnitude = (NSNumber *)[rootDict objectForKey:@"minimumMagnitude"];
    NSArray *selectedStates = [NSArray arrayWithArray:[rootDict objectForKey:@"selectedStates"]];
    BOOL sendNearbyQuakesPush = [[rootDict objectForKey:@"nearbyQuakes"] boolValue];

    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setObject:maxDistance forKey:DYFTInstallationMaxDistanceKey];
    [currentInstallation setObject:[NSNumber numberWithBool:sendNearbyQuakesPush] forKey:DYFTInstallationNearbyQuakesKey];
    [currentInstallation setObject:minMagnitude forKey:DYFTInstallationMinMagnitudeKey];
//    [currentInstallation addUniqueObjectsFromArray:selectedStates forKey:DYFTInstallationChannelsKey];
    [currentInstallation setChannels:selectedStates];
    [currentInstallation saveInBackground];
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    if (debug == 1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    //    [[self cdh] saveContext];
    [self sendSavedUserPrefsToCloud];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
    if (debug == 1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));

    [[NSUserDefaults standardUserDefaults] synchronize];
    //    [[self cdh] saveContext];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    if (debug == 1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));

    NSLog(@"Calling Application Bundle ID: %@", sourceApplication);
    NSLog(@"URL scheme: %@", [url scheme]);
    NSLog(@"URL query: %@", [url query]);
    NSLog(@"URL path: %@", [url path]);

    if ([[url host] isEqualToString:@"earthquake"]) {
        NSLog(@"url host = earthquake");
    } else {
        NSLog(@"url host = %@", [url host]);
    }
    return YES;

    /*
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
     */

//    BOOL urlWasHandled =
//    [FBAppCall handleOpenURL:url
//           sourceApplication:sourceApplication
//             fallbackHandler:
//     ^(FBAppCall *call) {
//         // Parse the incoming URL to look for a target_url parameter
//         NSString *query = [url query];
//         NSDictionary *params = [self parseURLParams:query];
//         // Check if target URL exists
//         NSString *appLinkDataString = [params valueForKey:@"al_applink_data"];
//         if (appLinkDataString) {
//             NSError *error = nil;
//             NSDictionary *applinkData =
//             [NSJSONSerialization JSONObjectWithData:[appLinkDataString dataUsingEncoding:NSUTF8StringEncoding]
//                                             options:0
//                                               error:&error];
//             if (!error &&
//                 [applinkData isKindOfClass:[NSDictionary class]] &&
//                 applinkData[@"target_url"]) {
//                 self.refererAppLink = applinkData[@"referer_app_link"];
//                 NSString *targetURLString = applinkData[@"target_url"];
//                 // Show the incoming link in an alert
//                 // Your code to direct the user to the
//                 // appropriate flow within your app goes here
//                 [[[UIAlertView alloc] initWithTitle:@"Received link:"
//                                             message:targetURLString
//                                            delegate:nil
//                                   cancelButtonTitle:@"OK"
//                                   otherButtonTitles:nil] show];
//             }
//         }
//     }];
//
//    return urlWasHandled;

}

// A function for parsing URL parameters
- (NSDictionary*)parseURLParams:(NSString *)query {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val = [[kv objectAtIndex:1]
                         stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [params setObject:val forKey:[kv objectAtIndex:0]];
    }
    return params;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    if (debug == 1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));

    [FBSDKAppEvents activateApp];
//    [self cdh];
//    [self demo];

    // Clear badge and update installation, required for auto-incrementing badges.
    if (application.applicationIconBadgeNumber != 0) {
        application.applicationIconBadgeNumber = 0;
        [[PFInstallation currentInstallation] saveInBackground];
    }

    // Clears out all notifications from Notification Center.
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    application.applicationIconBadgeNumber = 1;
    application.applicationIconBadgeNumber = 0;

    // Do the following if you use Mobile App Engagement Ads to get the deferred
    // app link after your app is installed.
    [FBSDKAppLinkUtility fetchDeferredAppLink:^(NSURL *url, NSError *error) {
        if (error) {
            NSLog(@"Received error while fetching deferred app link %@", error);
        }
        if (url) {
            [[UIApplication sharedApplication] openURL:url];
        }
    }];
}

/* -application:didRegisterForRemoteNotificationsWithDeviceToken:
 Called if registration for push notifications with Parse is successful.
 Need to implement this method and use it to inform Parse about this new device.
 */
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)newDeviceToken
{
    if (debug == 1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    NSLog(@"My device token is: %@", newDeviceToken);
    self.devicePushToken = newDeviceToken;

    [PFPush storeDeviceToken:newDeviceToken];

    if (application.applicationIconBadgeNumber != 0) {
        application.applicationIconBadgeNumber = 0;
    }

    // Store the deviceToken in the current Installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];

    if ([PFUser currentUser]) {
        currentInstallation[@"user"] = [PFUser currentUser];
    }
    [currentInstallation setDeviceTokenFromData:newDeviceToken];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    if (error.code == 3010) {
        NSLog(@"Push notifications are not supported in the iOS Simulator.");
    } else {
        // show some alert or otherwise handle the failure to register.
        NSLog(@"application:didFailToRegisterForRemoteNotificationsWithError: %@", error);
    }
}

// When a push notification is received while the app is NOT in the foreground, it is displayed in the iOS Notification Center.
// If a push notification is received while the app IS active, it is up to the app to handle it. To do so, we can implement the
// -application:didReceiveRemoteNotification: method in the app delegate.
// In this app's case, we simply ask Parse to handle it for us. Parse will create a modal alert and display the push notification's content.
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    if (debug == 1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    [[NSNotificationCenter defaultCenter] postNotificationName:DYFTAppDelegateApplicationDidReceiveRemoteNotification object:nil userInfo:userInfo];

    NSString *message = nil;

    id alert = [userInfo objectForKey:@"aps"];
    if ([alert isKindOfClass:[NSString class]]) {
        message = alert;
    } else if ([alert isKindOfClass:[NSDictionary class]]) {
        message = [alert objectForKey:@"alert"];
    }

    if (alert) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"PubNub Message"
                                                            message:message
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"OK" , nil];
        [alertView show];
    }


    if (([UIApplication sharedApplication].applicationState != UIApplicationStateActive) || (application.applicationState == UIApplicationStateInactive)) {
        // Track app opens due to a push notification being acknowledged while the app wasn't active.
        [PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
    }
//        if ([PFUser currentUser]) {
//            if ([self.tabBarController viewControllers].count > PAPActivityTabBarItemIndex) {
//                UITabBarItem *tabBarItem = [[self.tabBarController.viewControllers objectAtIndex:PAPActivityTabBarItemIndex] tabBarItem];
//    
//                NSString *currentBadgeValue = tabBarItem.badgeValue;
//    
//                if (currentBadgeValue && currentBadgeValue.length > 0) {
//                    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
//                    NSNumber *badgeValue = [numberFormatter numberFromString:currentBadgeValue];
//                    NSNumber *newBadgeValue = [NSNumber numberWithInt:[badgeValue intValue] + 1];
//                    tabBarItem.badgeValue = [numberFormatter stringFromNumber:newBadgeValue];
//                } else {
//                    tabBarItem.badgeValue = @"1";
//                }
//            }
//        }

    [PFPush handlePush:userInfo];
}


#pragma mark - UIUserNotifications - Registering
#pragma mark

- (void)registerApplicationForNotification:(UIApplication *)application {
    if (debug == 1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIMutableUserNotificationAction *yesAction = [[UIMutableUserNotificationAction alloc] init];
        [yesAction setActivationMode:UIUserNotificationActivationModeBackground];
        [yesAction setTitle:@"Felt It!"];
        [yesAction setIdentifier:DYFTUserNotificationNewEventFeltItAction];
        [yesAction setDestructive:NO];
        [yesAction setAuthenticationRequired:NO];

        UIMutableUserNotificationAction *noAction = [[UIMutableUserNotificationAction alloc] init];
        [noAction setActivationMode:UIUserNotificationActivationModeBackground];
        [noAction setTitle:@"Didn't Feel It."];
        [noAction setIdentifier:DYFTUserNotificationNewEventDidntFeelItAction];
        [noAction setDestructive:NO];
        [noAction setAuthenticationRequired:NO];

        UIMutableUserNotificationCategory *newEventCategory = [[UIMutableUserNotificationCategory alloc] init];
        [newEventCategory setIdentifier:DYFTUserNotificationNewEventCategory];
        [newEventCategory setActions:@[yesAction, noAction]
                          forContext:UIUserNotificationActionContextDefault];

        NSSet *categories = [NSSet setWithObject:newEventCategory];
        UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound);

        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                                 categories:categories];
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
    }
    else {
        UIRemoteNotificationType type = (UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound);
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:type];
    }
}

#pragma mark - UIUserNotifications - Responding To
#pragma mark

//- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void (^)())completionHandler {
//    if ([identifier isEqualToString:DYFTUserNotificationNewEventFeltItAction]) {
//        [self handleFeltItActionWithLocalNotification:notification];
//        NSLog(@"You said you felt it! (forLocalNotification)");
//    }
//    else if ([identifier isEqualToString:DYFTUserNotificationNewEventDidntFeelItAction]) {
//        NSLog(@"You felt nothing. (forLocalNotification)");
//    }
//    if (completionHandler) {
//        completionHandler();
//    }
//}

#pragma mark REMOTE NOTIFICATIONS
#pragma mark __ App in Foreground OR App in Background & User Tapped Default
- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo
fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{

    self.remoteNotificationCompletionHandler = completionHandler;

    NSLog(@"Remote Notification userInfo is %@", userInfo);

    NSNumber *contentID = userInfo[@"content-id"];
    NSLog(@"Content ID = %@", contentID);

    NSString *valueToSave = @"Silent";
    [[NSUserDefaults standardUserDefaults] setObject:valueToSave forKey:@"RemoteNotification"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    if (application.applicationState == UIApplicationStateInactive)
    {
        [PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
    }
    // Extract the notification data
    NSString *message = nil;

    id alert = [userInfo objectForKey:@"aps"];
    if ([alert isKindOfClass:[NSString class]]) {
        message = alert;
    } else if ([alert isKindOfClass:[NSDictionary class]]) {
        message = [alert objectForKey:@"alert"];
    }

    if (alert) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Pubnub Title"
                                                            message:message
                                                           delegate:self
                                                  cancelButtonTitle:@"Yeah PubNub!"
                                                  otherButtonTitles:@"Cool PubNub!" , nil];
        [alertView show];
    }

   NSLog(@"message = %@", message);

    completionHandler(UIBackgroundFetchResultNewData);
}

#pragma mark __ App in Background & User Tapped Custom Action Button

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)())completionHandler {
    if (debug == 1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    if ([identifier isEqualToString:DYFTUserNotificationNewEventFeltItAction]) {
        [self handleFeltItActionWithRemoteNotification:userInfo];
        NSLog(@"You said you felt it! (forRemoteNotification)");
    }
    else if ([identifier isEqualToString:DYFTUserNotificationNewEventDidntFeelItAction]) {
        [self handleDidntFeelItActionWithRemoteNotification:userInfo];
        NSLog(@"You felt nothing. (forRemoteNotification)");
    }
    if (completionHandler) {
        completionHandler();
    }
}

- (void)handleFeltItActionWithRemoteNotification:(NSDictionary *)notification {
    if (debug == 1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));

    NSDictionary *remoteNotificationPayload = notification;
    if (remoteNotificationPayload) {
        NSString *quakeID = remoteNotificationPayload[@"qid"];
        NSLog(@"quakeID = %@", quakeID);
        PFQuery *query = [PFQuery queryWithClassName:@"USGSQuakes"];
        [query whereKey:@"usgsId" equalTo:quakeID];
        // TODO: limit the keys returned to only the ones needed (appFelt, usgsId, feltByUsers
        // TODO: change this query to a single find() query since we only expect to find 1 object.
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
            if (!error){
                PFObject *object = objects[0];
                NSLog(@"Found quake with ID: %@ and magnitude: %@", quakeID, object[@"mag"]);
                [object incrementKey:@"appFelt"];
                PFRelation *feltItRelation = [object relationForKey:@"feltByUsers"];
                [feltItRelation addObject:[PFUser currentUser]];
                [object saveInBackground];
            }
            else {
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];

        PFUser *user = [PFUser currentUser];
        PFObject *userEvent = [PFObject objectWithClassName:@"UserEvent"];
        userEvent[@"user"] = user;

        [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
            if (!error) {
                // do something with the new geoPoint
                userEvent[@"userLocation"] = geoPoint;
                userEvent[@"eventFound"] = @YES;
            }
        }];

        [userEvent saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                // the object was saved!
            } else {
                // There was a problem, check error.description
            }
        }];

        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
        [currentInstallation addUniqueObject:quakeID forKey:@"channels"];
        [currentInstallation saveInBackground];

    }
    NSLog(@"inside handleFeltItActionWithRemoteNotification: notification contains: %@", notification.description);
}

- (void)handleDidntFeelItActionWithRemoteNotification:(NSDictionary *)notification {
    if (debug == 1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    NSDictionary *remoteNotificationPayload = notification;
    if (remoteNotificationPayload) {
        NSString *quakeID = remoteNotificationPayload[@"qid"];
        NSLog(@"quakeID = %@", quakeID);
        PFQuery *query = [PFQuery queryWithClassName:@"USGSQuakes"];
        [query whereKey:@"usgsId" equalTo:quakeID];
        // TODO: limit the keys returned to only the ones needed (appFelt, usgsId, feltByUsers
        // TODO: change this query to a single find() query since we only expect to find 1 object.
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
            if (!error){
                PFObject *object = objects[0];
                NSLog(@"Found quake with ID: %@ and magnitude: %@", quakeID, object[@"mag"]);
                [object incrementKey:@"appNotFelt"];
                PFRelation *notFeltRelation = [object relationForKey:@"notFeltByUsers"];
                [notFeltRelation addObject:[PFUser currentUser]];
                [object saveInBackground];
            }
            else {
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
    }
    NSLog(@"inside handleDidntFeelItActionWithRemoteNotification: notification contains: %@", notification.description);
}

- (void)handlePush:(NSDictionary *)launchOptions {
    if (debug == 1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    // If the app was launched in response to a push notification, we'll handle the payload here
    NSDictionary *remoteNotificationPayload = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (remoteNotificationPayload) {
        NSLog(@"handlePush was called. remoteNotificationPayload contains: %@", remoteNotificationPayload.description);
    }
}

#pragma mark -
#pragma mark LoginViewController

- (void)presentLoginViewController {
    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    // This method instantiates and sets the UserLoginVC as the root of the navigation controller.
    // Go to the welcome screen and have them log in or create an account.
    UserLoginVC *viewController = [[UserLoginVC alloc] initWithNibName:nil bundle:nil];

    [self.navigationController setViewControllers:@[ viewController ] animated:NO];
}

#pragma mark Delegate

- (void)loginViewControllerDidLogin:(UserLoginVC *)controller {
    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    [self presentQuakesViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark EventsViewController

- (void)presentQuakesViewControllerAnimated:(BOOL)animated {
    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    // This method instantiates and sets the PAWWallViewController as the root of the navigation controller.
    AllQuakesMapViewController *quakesVC = [[AllQuakesMapViewController alloc] initWithNibName:nil bundle:nil];
//    quakesVC.delegate = self;

    [self.navigationController setViewControllers:@[quakesVC] animated:animated];
}

#pragma mark Delegate

- (void)quakesViewControllerWantsToPresentSettings:(AllQuakesMapViewController *)controller {
    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    [self presentSettingsViewController];
}

#pragma mark -
#pragma mark SettingsViewController

- (void)presentSettingsViewController {
    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    SetupViewController *setupVC = [[SetupViewController alloc] initWithNibName:nil bundle:nil];
    setupVC.delegate = self;
    setupVC.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self.navigationController presentViewController:setupVC animated:YES completion:nil];
}

#pragma mark Delegate
- (void)setupViewController:(SetupViewController *)controller didFinishSetupWithInfo:(NSDictionary *)setupInfo {

}

- (void)setupViewControllerDidLogout:(SetupViewController *)controller {
    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    [controller dismissViewControllerAnimated:YES completion:nil];
    [self presentLoginViewController];
}

@end
