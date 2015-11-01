//
//  Quake.h
//  Did You Feel That?
//
//  Created by Emily Priddy on 6/10/15.
//  Copyright (c) 2015 Headstorm Studios. All rights reserved.
//

@import UIKit;
//@import CoreData;
@import MapKit;
#import <Parse/Parse.h>
#import "ZSPinAnnotation.h"


@interface Quake : NSObject <MKAnnotation>

@property (nonatomic, strong) NSNumber     * appFelt;
@property (nonatomic, strong) NSNumber     * appNotFelt;
@property (nonatomic, strong) NSString     * channel;
@property (nonatomic, strong) NSString     * createdAt;
@property (nonatomic, strong) NSDate       * date;
@property (nonatomic, strong) NSString     * dateString;
@property (nonatomic, strong) NSString     * detailURL;
@property (nonatomic, strong) NSNumber     * didFeel;
@property (nonatomic, strong) NSNumber     * didRespond;
@property (nonatomic, strong) NSNumber     * distance;
@property (nonatomic, strong) NSNumber     * latitude;
@property (nonatomic, strong) NSNumber     * longitude;
@property (nonatomic, strong) NSNumber     * magnitude;
@property (nonatomic, strong) NSString     * place;
@property (nonatomic, strong) NSString     * time;
@property (nonatomic, strong) NSString     * quakeTitle;
@property (nonatomic, strong) NSString     * eventType;
@property (nonatomic, strong) NSString     * updatedAt;
@property (nonatomic, strong) NSNumber     * userCreated;
@property (nonatomic, strong) NSNumber     * usgsFelt;
@property (nonatomic, strong) NSString     * usgsId;

@property (nonatomic, assign, readonly) CLLocationCoordinate2D coordinate;

@property (nonatomic, copy, readonly) NSString *title;
@property (nonatomic, copy, readonly) NSString *subtitle;
@property (nonatomic, copy, readonly) NSDate *quakeDate;

@property (nonatomic, strong, readonly) PFObject *object;

@property (nonatomic, assign) BOOL animatesDrop;
@property (nonatomic, assign) BOOL feltIt;

/// The color of the annotation
@property (nonatomic, strong) UIColor *color;

/// The type of annotation to draw
@property (nonatomic) ZSPinAnnotationType type;

// Designated initializer.
- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate
                             title:(NSString *)title
                          subtitle:(NSString *)subtitle
                         quakeDate:(NSDate *)quakeDate
                         magnitude:(NSNumber *)magnitude
                              time:(NSNumber *)time
                             place:(NSString *)place
                           appFelt:(NSNumber *)appFelt
                        appNotFelt:(NSNumber *)appNotFelt
                           channel:(NSString *)channel
                         detailURL:(NSString *)detailURL
                              eventType:(NSString *)eventType
                          usgsFelt:(NSNumber *)usgsFelt
                            usgsID:(NSString *)usgsID;

- (instancetype)initWithPFObject:(PFObject *)object;

- (void)setTitleAndSubtitleUserFeltQuake:(BOOL)felt;

@end
