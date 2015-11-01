//
//  QuakeRegisterVC.h
//  Did You Feel That?
//
//  Created by Emily Priddy on 6/10/15.
//  Copyright (c) 2015 Headstorm Studios. All rights reserved.
//

@import UIKit;
@import CoreLocation;

@class QuakeRegisterVC;

@protocol QuakeRegisterViewControllerDataSource <NSObject>

- (CLLocation *)currentLocationForRegisterQuakeViewController:(QuakeRegisterVC *)controller;

@end

@interface QuakeRegisterVC : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, weak) id<QuakeRegisterViewControllerDataSource> dataSource;

@property (nonatomic, strong) IBOutlet UIBarButtonItem *registerQuakeButton;

- (IBAction)cancelQuakeRegistration:(id)sender;
- (IBAction)registerQuake:(id)sender;

@end
