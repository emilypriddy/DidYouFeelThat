//
//  UserEvent.h
//  Did You Feel That?
//
//  Created by Emily Priddy on 6/24/15.
//  Copyright (c) 2015 Headstorm Studios. All rights reserved.
//

@import Foundation;
@import UIKit;
@import MapKit;
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import "ZSPinAnnotation.h"

@class Quake;

@interface UserEvent : NSObject <MKAnnotation>

@property (strong, nonatomic          ) NSNumber               *actualDistance;
@property (strong, nonatomic          ) NSString               *createdAt;
@property (strong, nonatomic          ) NSDate                 *date;
@property (strong, nonatomic          ) NSString               *dateString;
@property (strong, nonatomic          ) NSNumber               *distanceGuess;
@property (assign, nonatomic          ) BOOL                   eventFound;
@property (strong, nonatomic          ) NSNumber               *latitude;
@property (strong, nonatomic          ) NSNumber               *longitude;
@property (strong, nonatomic          ) NSNumber               *mercaliGuess;
@property (strong, nonatomic          ) NSString               *objectId;
@property (strong, nonatomic          ) NSNumber               *richterGuess;
@property (strong, nonatomic          ) NSString               *time;
@property (strong, nonatomic          ) NSNumber               *timeAgoGuess;

@property (nonatomic, assign, readonly) CLLocationCoordinate2D coordinate;

@property (nonatomic, copy, readonly  ) NSString               *title;
@property (nonatomic, copy, readonly  ) NSString               *subtitle;
@property (nonatomic, copy, readonly  ) NSDate                 *createdAtDate;

@property (nonatomic, strong, readonly) PFObject               *object;
@property (nonatomic, strong, readonly) Quake                  *relatedQuake;
@property (nonatomic, strong, readonly) PFUser                 *user;


@property (nonatomic, assign          ) BOOL                   animatesDrop;
@property (nonatomic, assign          ) BOOL                   bestGuess;
//@property (nonatomic, assign, readonly) MKPinAnnotationColor   pinColor;

/// The color of the annotation
@property (nonatomic, strong) UIColor *color;

/// The type of annotation to draw
@property (nonatomic) ZSPinAnnotationType type;

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate
                             title:(NSString *)title
                          subtitle:(NSString *)subtitle
                     createdAtDate:(NSDate *)createdAtDate
                          objectId:(NSString *)objectId;

//- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate
//                             title:(NSString *)title
//                          subtitle:(NSString *)subtitle
//                     createdAtDate:(NSDate *)createdAtDate
//                     distanceGuess:(NSNumber *)distanceGuess
//                      mercaliGuess:(NSNumber *)mercaliGuess
//                      richterGuess:(NSNumber *)richterGuess
//                      timeAgoGuess:(NSNumber *)timeAgoGuess
//                          objectId:(NSString *)objectId;

- (instancetype)initWithPFObject:(PFObject *)object;

- (void)setTitleAndSubtitle:(BOOL)eventFound;

@end
