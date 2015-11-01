//
//  Quake.m
//  Did You Feel That?
//
//  Created by Emily Priddy on 6/10/15.
//  Copyright (c) 2015 Headstorm Studios. All rights reserved.
//


#import "Quake.h"
#import "DYFTConstants.h"
#import "NSDate+DateTools.h"


@interface Quake ()

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, copy) NSDate *quakeDate;

@property (nonatomic, strong) PFObject *object;
//@property (nonatomic, assign) MKPinAnnotationColor pinColor;

@end

@implementation Quake
#define debug 0

//@dynamic appFelt;
//@dynamic appNotFelt;
//@dynamic channel;
//@dynamic createdAt;
//@dynamic date;
//@dynamic dateString;
//@dynamic detailURL;
//@dynamic didFeel;
//@dynamic didRespond;
//@dynamic distance;
//@dynamic latitude;
//@dynamic longitude;
//@dynamic magnitude;
//@dynamic place;
//@dynamic time;
//@dynamic quakeTitle;
//@dynamic type;
//@dynamic updatedAt;
//@dynamic userCreated;
//@dynamic usgsFelt;
//@dynamic usgsId;


//- (CLLocationCoordinate2D)coordinate {
//    return CLLocationCoordinate2DMake([self.latitude doubleValue], [self.longitude doubleValue]);
//}

//- (NSString *)formatDate:(NSDate *)theDate {
//    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));

//    static NSDateFormatter *formatter = nil;
//    if (formatter == nil) {
//        formatter = [[NSDateFormatter alloc] init];
//        [formatter setDateStyle:NSDateFormatterMediumStyle];
//        [formatter setTimeStyle:NSDateFormatterShortStyle];
//    }
//    return [formatter stringFromDate:theDate];
//}


#pragma mark - Init

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
                            usgsID:(NSString *)usgsID {

    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    self = [super init];
    if (self) {
        self.coordinate = coordinate;
        self.title = title;
        self.subtitle = subtitle;
        self.date = quakeDate;
        self.dateString = [quakeDate formattedDateWithStyle:NSDateFormatterMediumStyle timeZone:[NSTimeZone systemTimeZone]];
        self.magnitude = magnitude;
        self.time = [self formatHour:[quakeDate hourWithCalendar:[NSCalendar currentCalendar]] minute:[quakeDate minuteWithCalendar:[NSCalendar currentCalendar]]];
//        self.time = [NSString stringWithFormat:@"%ld:%ld", (long)[quakeDate hourWithCalendar:[NSCalendar currentCalendar]], (long)[quakeDate minuteWithCalendar:[NSCalendar currentCalendar]]];
//        NSLog(@"quake.time = %@", self.time);
        self.place = place;
        self.appFelt = appFelt;
        self.appNotFelt = appNotFelt;
        self.channel = channel;
        self.detailURL = detailURL;
        self.eventType = eventType;
        self.usgsFelt = usgsFelt;
        self.usgsId = usgsID;
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
    PFGeoPoint *geoPoint = object[DYFTQuakesLocationKey];
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude);
    NSString *title = object[DYFTQuakesTitleKey];

    NSNumber *felt = object[DYFTQuakesFeltKey];
    if ([felt isKindOfClass:[NSNull class]]) {
        felt = @0;
    } else {
        felt = [NSNumber numberWithInteger:[object[DYFTQuakesFeltKey] integerValue]];
    }

    NSString *feltString = [NSString stringWithFormat:@"%@", felt];
    NSString *magnitudeString = [NSString stringWithFormat:@"%@", object[DYFTQuakesMagnitudeKey]];
    NSNumber *magnitude = object[DYFTQuakesMagnitudeKey];
    NSNumber *time = object[DYFTQuakesTimeKey];
    NSString *place = object[DYFTQuakesPlaceKey];
    NSNumber *appFelt = object[DYFTQuakesAppFeltKey];
    NSNumber *appNotFelt = object[DYFTQuakesAppNotFeltKey];
    NSString *channel = object[DYFTQuakesPubNubChannelKey];
    NSString *detailURL = object[DYFTQuakesDetailURLKey];
    NSString *eventType = object[DYFTQuakesEventTypeKey];
    NSNumber *usgsFelt = object[DYFTQuakesFeltKey];
    NSString *usgsID = object[DYFTQuakesUSGSIdKey];

    NSString *subtitle = ([felt isEqualToNumber:[NSNumber numberWithInt:0]] || [felt isKindOfClass:[NSNull class]]) ? magnitudeString : feltString;
    NSDate *quakeDate = object[DYFTQuakesTimestampKey];

//    self = [self initWithCoordinate:coordinate andTitle:title andSubtitle:subtitle andQuakeDate:quakeDate];
    self = [self initWithCoordinate:coordinate title:title subtitle:subtitle quakeDate:quakeDate magnitude:magnitude time:time place:place appFelt:appFelt appNotFelt:appNotFelt channel:channel detailURL:detailURL eventType:eventType usgsFelt:usgsFelt usgsID:usgsID];
    if (self) {
        self.object = object;
    }
    return self;
}

#pragma mark - Equal

- (BOOL)isEqual:(id)other {
    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    if (![other isKindOfClass:[Quake class]]) {
        return NO;
    }

    Quake *quake = (Quake *)other;

    if (quake.object && self.object) {
        // We have a PFObject inside the Quake, use that instead.
        return [quake.object.objectId isEqualToString:self.object.objectId];
    }

    // Fallback to properties
    return ([quake.title isEqualToString:self.title] &&
            [quake.subtitle isEqualToString:self.subtitle] &&
            quake.coordinate.latitude == self.coordinate.latitude &&
            quake.coordinate.longitude == self.coordinate.longitude);
}

#pragma mark - Accessors

- (void)setTitleAndSubtitleUserFeltQuake:(BOOL)felt {
    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));

    NSString *feltString = @"0";
    NSString *notFeltString = @"0";

    if ([self.object objectForKey:DYFTQuakesAppFeltKey]) {
        feltString = [NSString stringWithFormat:@"%@", self.object[DYFTQuakesAppFeltKey]];
    }
    if ([self.object objectForKey:DYFTQuakesAppNotFeltKey]) {
        notFeltString = [NSString stringWithFormat:@"%@", self.object[DYFTQuakesAppNotFeltKey]];
    }

    if (felt) {
        self.title = self.object[DYFTQuakesTitleKey];
        self.subtitle = [NSString stringWithFormat:@"Felt by %@ DYFT users", feltString];
        self.color = [UIColor colorWithRed:29.0/255.0 green:174.0/255.0 blue:236.0/255.0 alpha:1.0];

    } else {
        self.title = self.object[DYFTQuakesTitleKey];
        self.subtitle = [NSString stringWithFormat:@"Not felt by %@ DYFT users", notFeltString];
        self.color = [UIColor colorWithRed:251.0/255.0 green:60.0/255.0 blue:28.0/255.0 alpha:1.0];
    }
}

@end
