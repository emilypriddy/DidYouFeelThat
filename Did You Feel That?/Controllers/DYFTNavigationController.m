//
//  DYFTNavigationController.m
//  Did You Feel That?
//
//  Created by Emily Priddy on 8/24/15.
//  Copyright (c) 2015 Headstorm Studios. All rights reserved.
//

#import "DYFTNavigationController.h"
#import "QuakesMapViewController.h"
#import "QuakesTableViewController.h"

#define debug 1

@interface DYFTNavigationController ()

@end

@implementation DYFTNavigationController

- (void)viewDidLoad {
    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    [super viewDidLoad];
    self.navigationBar.tintColor = [UIColor whiteColor];
//    self.navigationBar.backgroundColor = [UIColor blackColor];
    self.navigationBar.translucent = NO;
    self.navigationBar.barTintColor = [UIColor blackColor];
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;


    double delay = 0.2;

    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delay * 2 * NSEC_PER_SEC);

    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if ([self.topViewController isKindOfClass:[QuakesMapViewController class]]) {
            NSLog(@"Inside %@, topViewController is a QuakesMapViewController", self);
            

        } else {
            NSLog(@"Inside %@, topViewController is a %@", self, [self.topViewController class]);
            
        }
    });
    // Do any additional setup after loading the view.
}


- (void)didReceiveMemoryWarning {
    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
