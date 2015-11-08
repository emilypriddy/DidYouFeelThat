//
//  DYFTEarthquakeRouteHandler.m
//  Did You Feel That?
//
//  Created by Emily Priddy on 11/1/15.
//  Copyright © 2015 Headstorm Studios. All rights reserved.
//

#import "DYFTEarthquakeRouteHandler.h"
#import "DYFTQuakeDetailViewController.h"


@implementation DYFTEarthquakeRouteHandler

- (UIViewController <DPLTargetViewController> *)targetViewController {
    NSLog(@"%s", __PRETTY_FUNCTION__);

    UIStoryboard *storyboard = [UIApplication sharedApplication].keyWindow.rootViewController.storyboard;

    return [storyboard instantiateViewControllerWithIdentifier:@"detail"];
}

@end
