//
//  PFUserLoginViewController.m
//  Did You Feel That?
//
//  Created by Emily Priddy on 6/11/15.
//  Copyright (c) 2015 Headstorm Studios. All rights reserved.
//

#import "PFUserLoginViewController.h"

@interface PFUserLoginViewController ()
{
    UIImageView *textfieldsBackground;
}
@end

@implementation PFUserLoginViewController
#define debug 1

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    [super viewDidLoad];

    [self.logInView setBackgroundColor:[UIColor whiteColor]];

    [self.logInView setLogo:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]]];

    [self.logInView.logInButton setBackgroundImage:[UIImage imageNamed:@"buttonLoginBackground"] forState:UIControlStateNormal];

    [self.logInView.logInButton setBackgroundImage:[UIImage imageNamed:@"buttonLoginBackground"] forState:UIControlStateHighlighted];


    [self.logInView.logInButton setTitle:NSLocalizedString(@"Log In",nil) forState:UIControlStateNormal];

    [self.logInView.logInButton setTitle:NSLocalizedString(@"Log In",nil) forState:UIControlStateHighlighted];

    [self.logInView.signUpButton setBackgroundImage:[UIImage imageNamed:@"buttonRegisterBackground"] forState:UIControlStateNormal];

    [self.logInView.signUpButton setBackgroundImage:[UIImage imageNamed:@"buttonRegisterBackground"] forState:UIControlStateHighlighted];

    [self.logInView.signUpButton setTitle:NSLocalizedString(@"Register",nil) forState:UIControlStateNormal];

    [self.logInView.signUpButton setTitle:NSLocalizedString(@"Register",nil) forState:UIControlStateHighlighted];

    [self.logInView.passwordForgottenButton setBackgroundImage:[UIImage imageNamed:@"forgot"] forState:UIControlStateNormal];


    [self.logInView.usernameField setTextColor:[UIColor orangeColor]];
    [self.logInView.passwordField setTextColor:[UIColor orangeColor]];

    [self.logInView.usernameField setPlaceholder:@"Your email"];
    [self.logInView.passwordField setPlaceholder:@"A complicated password"];

    textfieldsBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"inputFields.png"]];

    [self.logInView addSubview:textfieldsBackground];

    [self.logInView sendSubviewToBack:textfieldsBackground];

    self.logInView.usernameField.layer.shadowOpacity = 0.0f;

    self.logInView.passwordField.layer.shadowOpacity = 0.0f;

    self.logInView.logInButton.titleLabel.shadowOffset = CGSizeMake(0, 0);
    self.logInView.signUpButton.titleLabel.shadowOffset = CGSizeMake(0, 0);
}


- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    // Set frame for elements
    float screenHeigt = [[UIScreen mainScreen] bounds].size.height;

    float inputFiledY = screenHeigt <= 480.0f ? 115.0f : 200.0f;
    [textfieldsBackground setFrame:CGRectMake(35.0f, inputFiledY, 250.0f, 100.0f)];


    float yTop = screenHeigt <= 480.0f ? 248.0f : 320.0f;

    [self.logInView.logInButton setFrame:CGRectMake(60.0f, yTop, 200,30)];

    [self.logInView.signUpButton setFrame:CGRectMake(60.0f, yTop + 80.0f, 200.0f, 30.0f)];

    [self.logInView.facebookButton setFrame:CGRectMake(60.0f, yTop + 150.0f, 200.0f, 30.0f)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
