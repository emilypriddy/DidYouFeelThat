//
//  QuakeFiltersTableViewController.h
//  Did You Feel That?
//
//  Created by Emily Priddy on 9/18/15.
//  Copyright (c) 2015 Headstorm Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QuakeFiltersViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
