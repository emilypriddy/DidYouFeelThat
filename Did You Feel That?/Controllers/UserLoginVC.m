//
//  UserLoginVC.m
//  Did You Feel That?
//
//  Created by Emily Priddy on 6/10/15.
//  Copyright (c) 2015 Headstorm Studios. All rights reserved.
//

#import "UserLoginVC.h"

#import <Parse/Parse.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

#import "ProgressHUD.h"

#import "DYFTConstants.h"
#import "pushnotification.h"

#define debug 1


@interface UserLoginVC()

@property (strong, nonatomic) IBOutlet UITableViewCell *cellEmail;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellPassword;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellButton;

@property (strong, nonatomic) IBOutlet UITextField *fieldEmail;
@property (strong, nonatomic) IBOutlet UITextField *fieldPassword;

@end


@implementation UserLoginVC

@synthesize cellEmail, cellPassword, cellButton;
@synthesize fieldEmail, fieldPassword;

- (void)viewDidLoad {
    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    [super viewDidLoad];
    self.title = @"Login";

    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)]];
}

- (void)viewDidAppear:(BOOL)animated {
    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    [super viewDidAppear:animated];
    [fieldEmail becomeFirstResponder];
}

- (void)dismissKeyboard {
    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    [self.view endEditing:YES];
}

#pragma mark - User actions

- (IBAction)actionLogin:(id)sender {
    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    NSString *email = [fieldEmail.text lowercaseString];
    NSString *password = fieldPassword.text;

    if ([email length] == 0)	{ [ProgressHUD showError:@"Email must be set."]; return; }
    if ([password length] == 0)	{ [ProgressHUD showError:@"Password must be set."]; return; }

    [ProgressHUD show:@"Signing in..." Interaction:NO];
    [PFUser logInWithUsernameInBackground:email password:password block:^(PFUser *user, NSError *error)
     {
         if (user != nil)
         {
             ParsePushUserAssign();
             [ProgressHUD showSuccess:[NSString stringWithFormat:@"Welcome back %@!", user[DYFTUserUsernameKey]]];
             [self dismissViewControllerAnimated:YES completion:nil];
         }
         else [ProgressHUD showError:error.userInfo[@"error"]];
     }];
}

#pragma mark - UITableView data source


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    if (indexPath.row == 0) return cellEmail;
    if (indexPath.row == 1) return cellPassword;
    if (indexPath.row == 2) return cellButton;
    return nil;
}

#pragma mark - UITextField delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    if (textField == fieldEmail)
    {
        [fieldPassword becomeFirstResponder];
    }
    if (textField == fieldPassword)
    {
        [self actionLogin:nil];
    }
    return YES;
}

@end
