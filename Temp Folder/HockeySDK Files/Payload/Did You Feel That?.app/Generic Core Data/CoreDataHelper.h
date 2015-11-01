//
//  CoreDataHelper.h
//  MIOApp
//
//  Created by Emily Priddy on 6/6/14.
//  Copyright (c) 2014 Headstorm Studios. All rights reserved.
//

@import Foundation;
@import CoreData;
#import "MigrationViewController.h"

@interface CoreDataHelper : NSObject

@property (nonatomic, readonly) NSManagedObjectContext       *context;
@property (nonatomic, readonly) NSManagedObjectModel         *model;
@property (nonatomic, readonly) NSPersistentStoreCoordinator *coordinator;
@property (nonatomic, readonly) NSPersistentStore            *store;

@property (nonatomic, retain) MigrationViewController *migrationVC;

- (void)setupCoreData;
- (void)saveContext;

@end
