//
//  utilities.m
//  Did You Feel That?
//
//  Created by Emily Priddy on 9/3/15.
//  Copyright (c) 2015 Headstorm Studios. All rights reserved.
//

#import "utilities.h"
#import "WelcomeViewController.h"
#import "DYFTNavigationController.h"

#define debug 1
//-------------------------------------------------------------------------------------------------------------------------------------------------
void LoginUser(id target)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    if (debug==1) NSLog(@"Running utilities.m LoginUser:");
    DYFTNavigationController *navigationController = [[DYFTNavigationController alloc] initWithRootViewController:[[WelcomeViewController alloc] init]];
    [target presentViewController:navigationController animated:YES completion:nil];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
void PostNotification(NSString *notification)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    if (debug==1) NSLog(@"Running utilities.m PostNotification:");
    [[NSNotificationCenter defaultCenter] postNotificationName:notification object:nil];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
NSString* TimeElapsed(NSTimeInterval seconds)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    if (debug==1) NSLog(@"Running utilities.m TimeElapsed:");
    NSString *elapsed;
    if (seconds < 60)
    {
        elapsed = @"Just now";
    }
    else if (seconds < 60 * 60)
    {
        int minutes = (int) (seconds / 60);
        elapsed = [NSString stringWithFormat:@"%d %@", minutes, (minutes > 1) ? @"mins" : @"min"];
    }
    else if (seconds < 24 * 60 * 60)
    {
        int hours = (int) (seconds / (60 * 60));
        elapsed = [NSString stringWithFormat:@"%d %@", hours, (hours > 1) ? @"hours" : @"hour"];
    }
    else
    {
        int days = (int) (seconds / (24 * 60 * 60));
        elapsed = [NSString stringWithFormat:@"%d %@", days, (days > 1) ? @"days" : @"day"];
    }
    return elapsed;
}
