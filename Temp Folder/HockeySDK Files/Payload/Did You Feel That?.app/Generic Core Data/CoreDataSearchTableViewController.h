//
//  CoreDataSearchTableViewController.h
//  MIOApp
//
//  Created by Emily Priddy on 6/6/14.
//  Copyright (c) 2014 Headstorm Studios. All rights reserved.
//

@import UIKit;
#import "CoreDataHelper.h"

@interface CoreDataSearchTableViewController : UITableViewController <NSFetchedResultsControllerDelegate, UISearchBarDelegate, UISearchDisplayDelegate>

@property (strong, nonatomic) NSFetchedResultsController *frc;
@property (strong, nonatomic) NSFetchedResultsController *searchFRC;
@property (strong, nonatomic) UISearchDisplayController *searchDC;
- (void)performFetch;
- (NSFetchedResultsController *)frcFromTV:(UITableView *)tableView;
- (UITableView *)TVFromFRC:(NSFetchedResultsController *)frc;
- (void)reloadSearchFRCForPredicate:(NSPredicate *)predicate
                         withEntity:(NSString *)entity
                          inContext:(NSManagedObjectContext *)context
                withSortDescriptors:(NSArray *)sortDescriptors
             withSectionNameKeyPath:(NSString *)sectionNameKeyPath;
- (void)configureSearch;
@end
