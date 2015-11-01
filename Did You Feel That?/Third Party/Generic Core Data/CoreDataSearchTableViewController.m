//
//  CoreDataSearchTableViewController.m
//  MIOApp
//
//  Created by Emily Priddy on 6/6/14.
//  Copyright (c) 2014 Headstorm Studios. All rights reserved.
//

#import "CoreDataSearchTableViewController.h"

@interface CoreDataSearchTableViewController ()

@end

@implementation CoreDataSearchTableViewController

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
   return [[[self frcFromTV:tableView] sections] count];
}
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
   return [[[[self frcFromTV:tableView]sections] objectAtIndex:section] numberOfObjects];
}
- (NSInteger)tableView:(UITableView *)tableView
sectionForSectionIndexTitle:(NSString *)title
               atIndex:(NSInteger)index
{
   return [[self frcFromTV:tableView] sectionForSectionIndexTitle:title atIndex:index];
}
- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section
{
   return [[[[self frcFromTV:tableView] sections] objectAtIndex:section] name];
}
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
   return [[self frcFromTV:tableView] sectionIndexTitles];
}


#pragma mark - DELEGATE: NSFetchedResultsController
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
   [[self TVFromFRC:controller] beginUpdates];
}
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
   [[self TVFromFRC:controller] endUpdates];
}
- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type

{
   switch (type) {
      case NSFetchedResultsChangeInsert:
         [[self TVFromFRC:controller]
          insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
          withRowAnimation:UITableViewRowAnimationFade];
         break;
      case NSFetchedResultsChangeDelete:
         [[self TVFromFRC:controller]
          deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
          withRowAnimation:UITableViewRowAnimationFade];
         break;
   }
}
- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
   switch (type) {
      case NSFetchedResultsChangeInsert:
         [[self TVFromFRC:controller]
          insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
          withRowAnimation:UITableViewRowAnimationAutomatic];
         break;
      case NSFetchedResultsChangeDelete:
         [[self TVFromFRC:controller]
          deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
          withRowAnimation:UITableViewRowAnimationAutomatic];
         break;
      case NSFetchedResultsChangeUpdate:
         if (!newIndexPath) {
            [[self TVFromFRC:controller]
             reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
             withRowAnimation:UITableViewRowAnimationNone];
         }
         else {
            [[self TVFromFRC:controller]
             deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
             withRowAnimation:UITableViewRowAnimationNone];
            [[self TVFromFRC:controller]
             insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
             withRowAnimation:UITableViewRowAnimationNone];
         }
         break;
      case NSFetchedResultsChangeMove:
         [[self TVFromFRC:controller]
          deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
          withRowAnimation:UITableViewRowAnimationAutomatic];
         [[self TVFromFRC:controller]
          insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
          withRowAnimation:UITableViewRowAnimationAutomatic];
         break;
   }
}

#pragma mark - GENERAL
- (NSFetchedResultsController *)frcFromTV:(UITableView *)tableView
{
   /*
      If the given tableView is self.tableView return self.frc,
      otherwise self.searchFRC
   */
   return (tableView == self.tableView) ? self.frc : self.searchFRC;
}

- (UITableView *)TVFromFRC:(NSFetchedResultsController *)frc
{
   /*
      If the given fetched results controller is self.frc return self.tableView,
      otherwise self.searchDC.searchResultsTableView
   */
   return (frc == self.frc) ? self.tableView : self.searchDC.searchResultsTableView;
}

#pragma mark - DELEGATE: UISearchDisplayController
- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
   self.searchFRC.delegate = nil;
   self.searchFRC = nil;
}

#pragma mark - SEARCH
- (void)reloadSearchFRCForPredicate:(NSPredicate *)predicate
                         withEntity:(NSString *)entity
                          inContext:(NSManagedObjectContext *)context
                withSortDescriptors:(NSArray *)sortDescriptors
             withSectionNameKeyPath:(NSString *)sectionNameKeyPath
{
   NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:entity];
   request.sortDescriptors = sortDescriptors;
   request.predicate = predicate;
   request.fetchBatchSize = 15;

   self.searchFRC = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                        managedObjectContext:context
                                                          sectionNameKeyPath:sectionNameKeyPath
                                                                   cacheName:nil];
   self.searchFRC.delegate = self;

   [self.searchFRC.managedObjectContext performBlockAndWait:^{
      NSError *error;
      if (![self.searchFRC performFetch:&error]) {
         // TODO: Implement proper error handling
      }
   }];
}

- (void)configureSearch
{
   UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 50.0)];
   searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
   self.tableView.tableHeaderView = searchBar;

   self.searchDC = [[UISearchDisplayController alloc] initWithSearchBar:searchBar
                                                     contentsController:self];
   self.searchDC.delegate = self;
   self.searchDC.searchResultsDataSource = self;
   self.searchDC.searchResultsDelegate = self;
}
@end