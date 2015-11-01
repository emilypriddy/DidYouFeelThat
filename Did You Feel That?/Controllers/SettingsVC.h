//
//  SettingsVC.h
//  Did You Feel That?
//
//  Created by Emily Priddy on 6/10/15.
//  Copyright (c) 2015 Headstorm Studios. All rights reserved.
//
@import UIKit;

@class SettingsVC;

@protocol SettingsViewControllerDelegate <NSObject>

- (void)settingsViewControllerDidLogout:(SettingsVC *)controller;

@end

@interface SettingsVC : UIViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>

@property (nonatomic, weak) id<SettingsViewControllerDelegate> delegate;
@property (nonatomic, strong) IBOutlet UITableView *tableView;

@end
