//
//  UserProfileViewController.m
//  Did You Feel That?
//
//  Created by Emily Priddy on 6/11/15.
//  Copyright (c) 2015 Headstorm Studios. All rights reserved.
//


#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import <TwitterKit/TwitterKit.h>

#import "ProgressHUD.h"
#import "DYFTConstants.h"
#import "images.h"
#import "camera.h"
#import "pushnotification.h"
#import "utilities.h"

#import "UserProfileViewController.h"
#define debug 1

@interface UserProfileViewController ()
@property (strong, nonatomic) IBOutlet UIView *viewHeader;
@property (strong, nonatomic) IBOutlet PFImageView *imageUser;

@property (strong, nonatomic) IBOutlet UITableViewCell *cellName;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellButton;

@property (strong, nonatomic) IBOutlet UITextField *fieldName;
@end

@implementation UserProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad {
    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    [super viewDidLoad];
    self.title = @"Profile Settings";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Log out" style:UIBarButtonItemStylePlain target:self action:@selector(actionLogout)];
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)]];
    self.tableView.tableHeaderView = self.viewHeader;
    self.imageUser.layer.cornerRadius = self.imageUser.frame.size.width / 2;
    self.imageUser.layer.masksToBounds = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    [super viewDidAppear:animated];
    if ([PFUser currentUser] != nil) {
        [self loadUser];
    }
    else LoginUser(self);
}

- (void)dismissKeyboard {
    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    [self.view endEditing:YES];
}

- (void)loadUser {
    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));

    PFUser *user = [PFUser currentUser];
    [self.imageUser setFile:user[DYFTUserPictureKey]];
    [self.imageUser loadInBackground];

    self.fieldName.text = user[DYFTUserDisplayNameKey];
}

- (void)saveUser {
    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    NSString *displayName = self.fieldName.text;
    if ([displayName length] != 0)
    {
        PFUser *user = [PFUser currentUser];
        user[DYFTUserDisplayNameKey] = displayName;
        user[DYFTUserDisplayNameLowercaseKey] = [displayName lowercaseString];
        [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
         {
             if (error == nil)
             {
                 [ProgressHUD showSuccess:@"Saved."];
             }
             else [ProgressHUD showError:@"Network error."];
         }];
    }
    else [ProgressHUD showError:@"Name field must be set."];
}

#pragma mark - User actions

- (void)actionCleanup {
    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    self.imageUser.image = [UIImage imageNamed:@"profile_blank"];
    self.fieldName.text = nil;
}

- (void)actionLogout {
    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil
                                               otherButtonTitles:@"Log out", nil];
    [action showFromTabBar:[[self tabBarController] tabBar]];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    if (buttonIndex != actionSheet.cancelButtonIndex)
    {
        [PFUser logOut];
        ParsePushUserResign();
        [Digits.sharedInstance logOut];

        PostNotification(DYFTUserLoggedOutNotification);
        [self actionCleanup];
        LoginUser(self);
    }
}

- (IBAction)actionPhoto:(id)sender {
    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    ShouldStartPhotoLibrary(self, YES);
}

- (IBAction)actionSave:(id)sender {
    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    [self dismissKeyboard];
    [self saveUser];
}


#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    UIImage *image = info[UIImagePickerControllerEditedImage];

    UIImage *picture = ResizeImage(image, 280, 280);
    UIImage *thumbnail = ResizeImage(image, 60, 60);

    self.imageUser.image = picture;

    PFFile *filePicture = [PFFile fileWithName:@"picture.jpg" data:UIImageJPEGRepresentation(picture, 0.6)];
    [filePicture saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (error != nil) [ProgressHUD showError:@"Network error."];
     }];

    PFFile *fileThumbnail = [PFFile fileWithName:@"thumbnail.jpg" data:UIImageJPEGRepresentation(thumbnail, 0.6)];
    [fileThumbnail saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (error != nil) [ProgressHUD showError:@"Network error."];
     }];

    PFUser *user = [PFUser currentUser];
    user[DYFTUserPictureKey] = filePicture;
    user[DYFTUserThumbnailKey] = fileThumbnail;
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (error != nil) [ProgressHUD showError:@"Network error."];
     }];

    [picker dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Table view data source


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    if (indexPath.section == 0) return self.cellName;
    if (indexPath.section == 1) return self.cellButton;
    return nil;
}

@end
