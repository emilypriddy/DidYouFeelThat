//
//  UserCreateNewVC.m
//  Did You Feel That?
//
//  Created by Emily Priddy on 6/10/15.
//  Copyright (c) 2015 Headstorm Studios. All rights reserved.
//



#import <Parse/Parse.h>
#import "ProgressHUD.h"

#import "DYFTConstants.h"
#import "pushnotification.h"

#import "UserCreateNewVC.h"

@interface UserCreateNewVC ()

@property (strong, nonatomic) IBOutlet UITableViewCell *cellName;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellPassword;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellEmail;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellButton;

@property (strong, nonatomic) IBOutlet UITextField *fieldName;
@property (strong, nonatomic) IBOutlet UITextField *fieldPassword;
@property (strong, nonatomic) IBOutlet UITextField *fieldEmail;

@end

@implementation UserCreateNewVC

@synthesize cellName, cellPassword, cellEmail, cellButton;
@synthesize fieldName, fieldPassword, fieldEmail;

#define debug 1

#pragma mark - UIViewController

- (void)viewDidLoad {
    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    self.title = @"Register";
    // For dismissing keyboard
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [fieldName becomeFirstResponder];
}

- (void)dismissKeyboard {
    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    [self.view endEditing:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - IBActions

- (IBAction)actionRegister:(id)sender {
    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));

    NSString *name = fieldName.text;
    NSString *password = fieldPassword.text;
    NSString *email = [fieldEmail.text lowercaseString];

    if ([name length] == 0) { [ProgressHUD showError:@"Name must be set."]; return; }
    if ([password length] == 0) { [ProgressHUD showError:@"Password must be set."]; return; }
    if ([email length] == 0) { [ProgressHUD showError:@"Email must be set."]; return; }

    [ProgressHUD show:@"Please wait..." Interaction:NO];

    PFUser *user = [PFUser user];
    user.username = [email lowercaseString];
    user.password = password;
    user.email = email;
    user[DYFTUserEmailKey] = email;
    user[DYFTUserDisplayNameKey] = name;
    user[DYFTUserDisplayNameLowercaseKey] = [name lowercaseString];
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (error == nil)
         {
             ParsePushUserAssign();
             [ProgressHUD showSuccess:@"Success."];
             [self dismissViewControllerAnimated:YES completion:nil];
         }
         else [ProgressHUD showError:error.userInfo[@"error"]];
     }];
}

#pragma mark - UITableView data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) return cellName;
    if (indexPath.row == 1) return cellPassword;
    if (indexPath.row == 2) return cellEmail;
    if (indexPath.row == 3) return cellButton;
    return nil;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == fieldName) {
        [fieldPassword becomeFirstResponder];
    }
    if (textField == fieldPassword) {
        [fieldEmail becomeFirstResponder];
    }
    if (textField == fieldEmail) {
        [self actionRegister:nil];
    }
    return YES;
}



- (IBAction)closeButtonPressed:(id)sender {
    [self dismissKeyboard];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
