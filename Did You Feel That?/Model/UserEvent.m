//
//  UserEvent.m
//  Did You Feel That?
//
//  Created by Emily Priddy on 6/24/15.
//  Copyright (c) 2015 Headstorm Studios. All rights reserved.
//

#import "UserEvent.h"
#import "DYFTConstants.h"
#import "NSDate+DateTools.h"
#import "Quake.h"

@interface UserEvent()

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@property (nonatomic, copy  ) NSString               *title;
@property (nonatomic, copy  ) NSString               *subtitle;
@property (nonatomic, copy  ) NSDate                 *createdAtDate;

@property (nonatomic, strong) PFObject               *object;
@property (nonatomic, strong) PFUser                 *user;
@property (nonatomic, strong) Quake                  *relatedQuake;
//@property (nonatomic, assign) MKPinAnnotationColor   pinColor;

@end

@implementation UserEvent
#define debug 0

#pragma mark - Init

/*
- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate
                             title:(NSString *)title
                          subtitle:(NSString *)subtitle
                     createdAtDate:(NSDate *)createdAtDate
                     distanceGuess:(NSNumber *)distanceGuess
                      mercaliGuess:(NSNumber *)mercaliGuess
                      richterGuess:(NSNumber *)richterGuess
                      timeAgoGuess:(NSNumber *)timeAgoGuess
                          objectId:(NSString *)objectId {

    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));

    self = [super init];
    if (self) {
        self.coordinate = coordinate;
        self.title = title;
        self.subtitle = subtitle;
        self.createdAtDate = createdAtDate;
        self.date = createdAtDate;
        self.dateString = [createdAtDate formattedDateWithStyle:NSDateFormatterMediumStyle timeZone:[NSTimeZone systemTimeZone]];
        self.time = [self formatHour:[createdAtDate hourWithCalendar:[NSCalendar currentCalendar]] minute:[createdAtDate minuteWithCalendar:[NSCalendar currentCalendar]]];
        self.distanceGuess = distanceGuess;
        self.mercaliGuess = mercaliGuess;
        self.richterGuess = richterGuess;
        self.timeAgoGuess = timeAgoGuess;
        self.objectId = objectId;
    }
    return self;
}
 */

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate
                             title:(NSString *)title
                          subtitle:(NSString *)subtitle
                     createdAtDate:(NSDate *)createdAtDate
                          objectId:(NSString *)objectId {

    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));

    self = [super init];
    if (self) {
        self.coordinate = coordinate;
        self.title = title;
        self.subtitle = subtitle;
        self.createdAtDate = createdAtDate;
        self.date = createdAtDate;
        self.dateString = [createdAtDate formattedDateWithStyle:NSDateFormatterMediumStyle timeZone:[NSTimeZone systemTimeZone]];
        self.time = [self formatHour:[createdAtDate hourWithCalendar:[NSCalendar currentCalendar]] minute:[createdAtDate minuteWithCalendar:[NSCalendar currentCalendar]]];
        self.objectId = objectId;
    }
    return self;
}

- (NSString *)formatHour:(NSInteger)hour minute:(NSInteger)minute {
    NSString *hourString, *minuteString, *fullDateString;
    NSString *pm = @"pm";
    NSString *am = @"am";

    if (minute < 10) {
        minuteString = [NSString stringWithFormat:@"0%ld", (long)minute];
    } else {
        minuteString = [NSString stringWithFormat:@"%ld", (long)minute];
    }

    if (hour <= 12) {
        hourString = [NSString stringWithFormat:@"%ld", (long)hour];
        fullDateString = [NSString stringWithFormat:@"%@:%@ %@", hourString, minuteString, am];
    } else {
        hour = hour - 12;
        hourString = [NSString stringWithFormat:@"%ld", (long)hour];
        fullDateString = [NSString stringWithFormat:@"%@:%@ %@", hourString, minuteString, pm];
    }

    return fullDateString;
}

- (instancetype)initWithPFObject:(PFObject *)object {
    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));

    self = [super init];

    PFGeoPoint *geoPoint = object[DYFTUserEventUserLocationKey];
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude);

    NSDate *createdAtDate = object[DYFTUserEventCreatedAtKey];
//    NSNumber *distanceGuess = object[DYFTUserEventDistanceGuessKey];
//    NSNumber *mercaliGuess = object[DYFTUserEventMercaliGuessKey];
//    NSNumber *richterGuess = object[DYFTUserEventRichterGuessKey];
//    NSNumber *timeAgoGuess = object[DYFTUserEventTimeAgoGuessKey];
    NSString *objectId = object[DYFTUserEventObjectIdKey];

//    NSString *dateString = [self.createdAtDate formattedDateWithStyle:NSDateFormatterMediumStyle timeZone:[NSTimeZone systemTimeZone]];
//    NSString *time = [self formatHour:[self.createdAtDate hourWithCalendar:[NSCalendar currentCalendar]] minute:[self.createdAtDate minuteWithCalendar:[NSCalendar currentCalendar]]];
//
    NSString *title = @"DYFT?";
    NSString *subtitle = self.dateString;

    self = [self initWithCoordinate:coordinate title:title subtitle:subtitle createdAtDate:createdAtDate objectId:objectId];
//    self = [self initWithCoordinate:coordinate title:title subtitle:subtitle createdAtDate:createdAtDate distanceGuess:distanceGuess mercaliGuess:mercaliGuess richterGuess:richterGuess timeAgoGuess:timeAgoGuess objectId:objectId];

    if (self) {
        self.object = object;
    }
    return self;
}

#pragma mark - Equal

- (BOOL)isEqual:(id)other {
    if (![other isKindOfClass:[UserEvent class]]) {
        return NO;
    }

    UserEvent *userEvent = (UserEvent *)other;

    if (userEvent.object && self.object) {
        // We have a PFObject inside the Quake, use that instead.
        return [userEvent.object.objectId isEqualToString:self.object.objectId];
    }

    // Fallback to properties
    return ([userEvent.title isEqualToString:self.title] &&
            [userEvent.subtitle isEqualToString:self.subtitle] &&
            userEvent.coordinate.latitude == self.coordinate.latitude &&
            userEvent.coordinate.longitude == self.coordinate.longitude);
}

#pragma mark - Accessors

- (void)setTitleAndSubtitle:(BOOL)eventFound {
    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));


    if (eventFound) {
        self.title = @"DYFT? Match Found!";
        self.subtitle = self.dateString;
        self.color = [UIColor colorWithRed:0.984 green:0.235 blue:0.110 alpha:1.000];
    } else {
        self.title = @"DYFT?";
        self.subtitle = self.dateString;
        self.color = [UIColor colorWithRed:0.114 green:0.682 blue:0.925 alpha:1.000];
    }
}

@end

