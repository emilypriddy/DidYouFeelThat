//
//  DYFTShareUtility.h
//  Did You Feel That?
//
//  Created by Emily Priddy on 10/29/15.
//  Copyright © 2015 Headstorm Studios. All rights reserved.
//

@import Foundation;
@import UIKit;
#import <FBSDKShareKit/FBSDKShareKit.h>
#import "UserEvent.h"

@protocol DYFTShareUtilityDelegate;

@interface DYFTShareUtility : NSObject <FBSDKSharingDelegate>

@property (weak, nonatomic) UIViewController<DYFTShareUtilityDelegate> *delegate;

- (instancetype)initWithUserEvent:(UserEvent *)userEvent;

- (void)start;


@end
