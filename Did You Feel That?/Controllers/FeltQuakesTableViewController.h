//
//  FeltTableVC.h
//  Did You Feel That?
//
//  Created by Emily Priddy on 6/24/15.
//  Copyright (c) 2015 Headstorm Studios. All rights reserved.
//

@import UIKit;
#import <ParseUI/PFQueryTableViewController.h>

#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>

#import "AllQuakesMapViewController.h"


@interface FeltQuakesTableViewController : PFQueryTableViewController

- (IBAction)launchFeltMapVC:(id)sender;

@end
