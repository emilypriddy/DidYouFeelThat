//
//  AppDelegate.h
//  Did You Feel That?
//
//  WORKING APP! 8/25/15
//
//  Created by Emily Priddy on 6/10/15.
//  Copyright (c) 2015 Headstorm Studios. All rights reserved.
//

@import UIKit;
@import Foundation;
@import CoreLocation;
#import "DYFTMainTabBarController.h"


@interface AppDelegate : UIResponder <UIApplicationDelegate, UINavigationControllerDelegate, UITabBarControllerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) NSDictionary *refererAppLink;

@property (nonatomic, strong) DYFTMainTabBarController *mainTabBarContorller;
@property (nonatomic, strong) UINavigationController *navigationController;

@property (strong, nonatomic, readonly) NSData *devicePushToken;

@property (copy, nonatomic) void (^remoteNotificationCompletionHandler)(UIBackgroundFetchResult);

@property (nonatomic, strong) UIStoryboard *storyboard;

- (void)presentLoginViewController;
- (void)presentSettingsViewController;

@end

