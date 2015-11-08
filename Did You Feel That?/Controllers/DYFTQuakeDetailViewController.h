//
//  DYFTQuakeDetailViewController.h
//  Did You Feel That?
//
//  Created by Emily Priddy on 11/3/15.
//  Copyright © 2015 Headstorm Studios. All rights reserved.
//

@import UIKit;
@import MapKit;
@import CoreLocation;
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import <DeepLinkKit/DPLTargetViewControllerProtocol.h>

@class Quake;

@interface DYFTQuakeDetailViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate, DPLTargetViewController>

@property (strong, nonatomic) Quake *quake;

@end
