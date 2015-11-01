//
//  PFUserSignUpViewController.m
//  Did You Feel That?
//
//  Created by Emily Priddy on 6/11/15.
//  Copyright (c) 2015 Headstorm Studios. All rights reserved.
//

#import "PFUserSignUpViewController.h"

@interface PFUserSignUpViewController ()
{
    UIImageView *fieldsBackground;
}
@end

@implementation PFUserSignUpViewController
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

    [self.signUpView setBackgroundColor:[UIColor whiteColor]];

    [self.signUpView setLogo:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]]];

    //Set the signUpButton background image

    UIImage *signUpButtonBackground =[UIImage imageNamed:@"buttonRegisterBackground"];
    [self.signUpView.signUpButton setBackgroundImage:signUpButtonBackground forState:UIControlStateNormal];
    [self.signUpView.signUpButton setBackgroundImage:signUpButtonBackground forState:UIControlStateHighlighted];

    //Set the background image for the UITextFields

    fieldsBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"inputFields3"]];
    [self.signUpView insertSubview:fieldsBackground atIndex:1];

    //Set text color for UITextFields

    self.signUpView.usernameField.textColor = [UIColor orangeColor];
    self.signUpView.passwordField.textColor = [UIColor orangeColor];
    self.signUpView.additionalField.textColor = [UIColor orangeColor];

    // Remove text shadow

    self.signUpView.usernameField.layer.shadowOpacity = 0.0f;
    self.signUpView.passwordField.layer.shadowOpacity = 0.0f;
    self.signUpView.additionalField.layer.shadowOpacity = 0.0f;
    self.signUpView.signUpButton.titleLabel.shadowOffset = CGSizeMake(0, 0);

    //Set textfield placeholders

    [self.signUpView.usernameField setPlaceholder:NSLocalizedString(@"Email",nil)];
    [self.signUpView.passwordField setPlaceholder:NSLocalizedString(@"Password",nil)];

    // Change "Additional" to be password confirmation
    [self.signUpView.additionalField setPlaceholder:NSLocalizedString(@"Confirm your password",nil)];

    self.signUpView.additionalField.secureTextEntry = YES;

}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {

    if (textField == self.signUpView.usernameField) {

        self.signUpView.emailField.text = textField.text;
    }

    return YES;
}


- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    float yOffset = [UIScreen mainScreen].bounds.size.height <= 480.0f ? 5.0f : 0.0f;

    CGRect fieldFrame = self.signUpView.usernameField.frame;

    [self.signUpView.dismissButton setFrame:CGRectMake(-20.0f, 10.0f, 87.5f, 45.5f)];
    [self.signUpView.logo setFrame:CGRectMake(66.5f, 70.0f, 187.0f, 58.5f)];
    [fieldsBackground setFrame:CGRectMake(35.0f, fieldFrame.origin.y + yOffset, 250.0f, 174.0f)];

    [self.signUpView.usernameField setFrame:CGRectMake(fieldFrame.origin.x + 5.0f,
                                                       fieldFrame.origin.y + yOffset + 10.0f,
                                                       fieldFrame.size.width - 10.0f,
                                                       fieldFrame.size.height)];
    yOffset += fieldFrame.size.height;

    [self.signUpView.passwordField setFrame:CGRectMake(fieldFrame.origin.x + 5.0f,
                                                       fieldFrame.origin.y + yOffset + 20.0f,
                                                       fieldFrame.size.width - 10.0f,
                                                       fieldFrame.size.height)];
    yOffset += fieldFrame.size.height;

    [self.signUpView.additionalField setFrame:CGRectMake(fieldFrame.origin.x + 5.0f,
                                                         fieldFrame.origin.y + yOffset+ 35.0f,
                                                         fieldFrame.size.width - 10.0f,
                                                         fieldFrame.size.height)];
    yOffset += fieldFrame.size.height;


    [self.signUpView.signUpButton setFrame:CGRectMake(60.0f, fieldFrame.origin.y + yOffset + fieldFrame.size.height + 40.0 , 200.0f, 30.0f)];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
