//
//  DYFTComms.m
//  Did You Feel That?
//
//  Created by Emily Priddy on 7/14/15.
//  Copyright (c) 2015 Headstorm Studios. All rights reserved.
//

#import "DYFTComms.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <Parse/Parse.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>

@implementation DYFTComms

+ (void)login:(id<DYFTCommsDelegate>)delegate
{
    #pragma mark - FIX ERROR DUE TO UPDATES FROM HERE:
    /*
    [PFFacebookUtils logInWithPermissions:nil block:^(PFUser *user, NSError *error) {
        if (!user) {
            if (!error) {
                NSLog(@"The user cancelled the Facebook login.");
            } else {
                NSLog(@"An error occurred: %@", error.localizedDescription);
            }

            // Callback - login failed
            if ([delegate respondsToSelector:@selector(dyftCommsDidLogin:)]) {
                [delegate dyftCommsDidLogin:NO];
            }
        } else {
            if (user.isNew) {
                NSLog(@"User signed up and logged in through Facebook!");
            } else {
                NSLog(@"User logged in through Facebook!");
            }

            // Callback - login successful

            [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                if (!error) {
                    NSDictionary<FBGraphUser> *me = (NSDictionary<FBGraphUser> *)result;
                    // Store the Facebook Id
                    [[PFUser currentUser] setObject:me.objectID forKey:@"fbId"];
                    [[PFUser currentUser] saveInBackground];
                }
                if ([delegate respondsToSelector:@selector(dyftCommsDidLogin:)]) {
                    [delegate dyftCommsDidLogin:YES];
                }
            }];
        }
    }];

    */
    #pragma mark TO HERE -
}

@end
