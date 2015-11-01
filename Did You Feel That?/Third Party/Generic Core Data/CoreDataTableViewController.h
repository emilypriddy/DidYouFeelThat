//
//  CoreDataTableViewController.h
//  MIOApp
//
//  Created by Emily Priddy on 8/3/14.
//  Copyright (c) 2014 Headstorm Studios. All rights reserved.
//

@import UIKit;
#import "CoreDataHelper.h"

@interface CoreDataTableViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *frc;

- (void)performFetch;

@end
