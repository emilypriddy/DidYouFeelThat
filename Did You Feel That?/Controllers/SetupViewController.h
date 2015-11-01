//
//  SetupViewController.h
//  Did You Feel That?
//
//  Created by Emily Priddy on 7/16/15.
//  Copyright (c) 2015 Headstorm Studios. All rights reserved.
//

@import UIKit;
#import "LPPopupListView.h"
#import "DYFTNavigationController.h"
#import "UserProfileViewController.h"

// Keys for the dictionary provided to the delegate.
extern NSString * const kSetupInfoKeyDistanceFilter;
extern NSString * const kSetupInfoKeySelectedStates;
extern NSString * const kSetupInfoKeyMagnitudeFilter;

@class SetupViewController;

@protocol SetupViewControllerDelegate <NSObject>
@required
- (void)setupViewController:(SetupViewController *)controller didFinishSetupWithInfo:(NSDictionary *)setupInfo;
- (void)setupViewControllerDidLogout:(SetupViewController *)controller;
@end

#pragma mark -

@interface SetupViewController : UIViewController <LPPopupListViewDelegate>

@property (nonatomic, unsafe_unretained) id <SetupViewControllerDelegate> delegate;
@property (nonatomic, weak) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UITextField *magnitudeTextField;
@property (weak, nonatomic) IBOutlet UITextField *distanceTextField;
@property (strong, nonatomic) UserProfileViewController *profileVC;

- (IBAction)statesBtnClicked:(id)sender;
- (IBAction)saveUserPrefs:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)textFieldReturn:(id)textField;

@end
