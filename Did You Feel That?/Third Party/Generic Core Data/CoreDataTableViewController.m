//
//  CoreDataTableViewController.m
//  MIOApp
//
//  Created by Emily Priddy on 8/3/14.
//  Copyright (c) 2014 Headstorm Studios. All rights reserved.
//

#import "CoreDataTableViewController.h"

@interface CoreDataTableViewController ()

@end

@implementation CoreDataTableViewController

#pragma mark - FETCHING
- (void)performFetch
{
   if (self.frc) {
      [self.frc.managedObjectContext performBlockAndWait:^{
         NSError *error = nil;
         if (![self.frc performFetch:&error]) {
            // TODO: Implement proper error handling
         }
         [self.tableView reloadData];
      }];
   } else {
      // TODO: Implement proper error handling
   }
}

#pragma mark - DATASOURCE: UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
   return 1;
}

#pragma mark - DELEGATE: NSFetchedResultsController
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
   [self.tableView beginUpdates];
}
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
   [self.tableView endUpdates];
}


@end
