//
//  DYFTTabBarController.m
//  Did You Feel That?
//
//  Created by Emily Priddy on 8/24/15.
//  Copyright (c) 2015 Headstorm Studios. All rights reserved.
//

#import "BaseTabBarController.h"

@interface BaseTabBarController ()

@end

@implementation BaseTabBarController

// Create a view controller and setup it's tab bar item with a title and image
-(UIViewController*) viewControllerWithTabTitle:(NSString*) title image:(UIImage*)image
{
    UIViewController *viewController = [[UIViewController alloc] init];
    viewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:title image:image tag:0];
    return viewController;
}

// Create a custom UIButton and add it to the center of our tab bar
-(void) addCenterButtonWithImage:(UIImage*)buttonImage highlightImage:(UIImage*)highlightImage
{
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    button.frame = CGRectMake(0.0, 0.0, buttonImage.size.width, buttonImage.size.height);
    [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [button setBackgroundImage:highlightImage forState:UIControlStateHighlighted];

    CGFloat heightDifference = buttonImage.size.height - self.tabBar.frame.size.height;
    NSLog(@"buttonImage.size.height = %f", buttonImage.size.height);
    NSLog(@"self.tabBar.frame.size.height = %f", self.tabBar.frame.size.height);
    NSLog(@"heightDifference = %f", heightDifference);
    if (heightDifference < 0) {
        button.center = self.tabBar.center;
        NSLog(@"button.center = self.tabBar.center == %fx%f = %fx%f", button.center.x, button.center.y, self.tabBar.center.x, self.tabBar.center.y);
    }
    else
    {
        CGPoint center = self.tabBar.center;
        center.y = center.y - heightDifference/2.0;
        button.center = center;
        NSLog(@"button.center = center == %fx%f = %fx%f", button.center.x, button.center.y, center.x, center.y);
    }
    
    [self.view addSubview:button];
}


@end
