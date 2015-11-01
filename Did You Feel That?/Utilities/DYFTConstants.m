//
//  DYFTConstants.m
//  Did You Feel That?
//
//  Created by Emily Priddy on 6/10/15.
//  Copyright (c) 2015 Headstorm Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DYFTConstants.h"
#ifndef Did_You_Feel_That__DYFTConstants_h
#define Did_You_Feel_That__DYFTConstants_h

//-------------------------------------------------------------------------------------------------------------------------------------------------
double DYFTFeetToMeters(double feet) {
    return feet * 0.3048;
}

double DYFTMetersToFeet(double meters) {
    return meters * 3.281;
}

double DYFTMetersToKilometers(double meters) {
    return meters / 1000.0;
}

double DYFTFeetToMiles(double feet) {
    return feet / 5280.0;
}

double DYFTMilesToFeet(double miles){
    return miles * 5280.0;
}

double DYFTMilesToKilometers(double miles) {
    return miles * 1.609344;
}

double DYFTKilometersToMiles(double kilometers) {
    return kilometers * 0.621371192;
}

// The radius of the earth (3,959 miles or 6,371 kilometers)

double const DYFTEarthRadiusMiles                                       = 3959.00;
double const DYFTEarthRadiusKilometers                                  = 6371.00;

NSTimeInterval const DYFTLocationUpdatesTimeInterval                    = 3600;// One hour

//-------------------------------------------------------------------------------------------------------------------------------------------------
double const DYFTDefaultFilterDistance                                  = 40336.0;//402336.0 Value in meters = 250 miles
double const DYFTAllQuakesMaximumSearchDistance                         = 1000.0;// in kilometers
double const DYFTFeltQuakesMaximumSearchDistance                        = 1000.0;// in kilometers
NSUInteger const DYFTAllQuakesSearchDefaultLimit                        = 50;// Query limit for pins & tableViewCells for All Quakes
NSUInteger const DYFTFeltQuakesSearchDefaultLimit                       = 50;// Query limit for pins & tableViewCells for Felt Quakes
NSUInteger const DYFTDefaultTab                                         = 1;

//-------------------------------------------------------------------------------------------------------------------------------------------------
NSString * const DYFTInstallationClassKey                               = @"_Installation";
NSString * const DYFTInstallationObjectIdKey                            = @"objectId";
NSString * const DYFTInstallationUserKey                                = @"user";
NSString * const DYFTInstallationChannelsKey                            = @"channels";
NSString * const DYFTInstallationBadgeKey                               = @"badge";
NSString * const DYFTInstallationDeviceTokenKey                         = @"deviceToken";
NSString * const DYFTInstallationRelatedUserEventsKey                   = @"relatedUserEvents";
NSString * const DYFTInstallationInstallationIdKey                      = @"installationId";
NSString * const DYFTInstallationLocationKey                            = @"location";
NSString * const DYFTInstallationMaxDistanceKey                         = @"maxDistance";
NSString * const DYFTInstallationMinMagnitudeKey                        = @"minMagnitude";
NSString * const DYFTInstallationNearbyQuakesKey                        = @"nearbyQuakes";

//-------------------------------------------------------------------------------------------------------------------------------------------------
NSString * const DYFTUserClassKey                                       = @"_User";
NSString * const DYFTUserObjectIdKey                                    = @"objectId";
NSString * const DYFTUserUsernameKey                                    = @"username";
NSString * const DYFTUserDisplayNameKey                                 = @"name";
NSString * const DYFTUserDisplayNameLowercaseKey                        = @"nameLower";
NSString * const DYFTUserPictureKey                                     = @"picture";
NSString * const DYFTUserThumbnailKey                                   = @"thumbnail";
NSString * const DYFTUserPasswordKey                                    = @"password";
NSString * const DYFTUserEmailKey                                       = @"email";
NSString * const DYFTUserFacebookIdKey                                  = @"fbId";

//-------------------------------------------------------------------------------------------------------------------------------------------------
NSString * const DYFTNotificationAppStarted                             = @"DYFTAppStarted";
NSString * const DYFTNotificationUserLoggedIn                           = @"DYFTUserLoggedIn";
NSString * const DYFTNotificationUserLoggedOut                          = @"DYFTUserLoggedOut";

//-------------------------------------------------------------------------------------------------------------------------------------------------
NSString * const DYFTQuakesClassKey                                     = @"USGSQuakes";
NSString * const DYFTQuakesObjectIdKey                                  = @"objectId";
NSString * const DYFTQuakesUSGSIdKey                                    = @"usgsId";
NSString * const DYFTQuakesMagnitudeKey                                 = @"mag";
NSString * const DYFTQuakesDepthKey                                     = @"depth";
NSString * const DYFTQuakesEventTypeKey                                 = @"eventType";
NSString * const DYFTQuakesTimeKey                                      = @"time";
NSString * const DYFTQuakesTimestampKey                                 = @"timestamp";
NSString * const DYFTQuakesCreatedAtKey                                 = @"createdAt";
NSString * const DYFTQuakesMonthKey                                     = @"month";
NSString * const DYFTQuakesTitleKey                                     = @"title";
NSString * const DYFTQuakesDetailURLKey                                 = @"detailURL";
NSString * const DYFTQuakesLatitudeKey                                  = @"latitude";
NSString * const DYFTQuakesLongitudeKey                                 = @"longitude";
NSString * const DYFTQuakesPlaceKey                                     = @"place";
NSString * const DYFTQuakesUSGSCodeKey                                  = @"usgsCode";
NSString * const DYFTQuakesTZKey                                        = @"tz";
NSString * const DYFTQuakesUpdatedKey                                   = @"updated";
NSString * const DYFTQuakesCDIKey                                       = @"cdi";
NSString * const DYFTQuakesFeltKey                                      = @"felt";
NSString * const DYFTQuakesCountryKey                                   = @"country";
NSString * const DYFTQuakesStateKey                                     = @"state";
NSString * const DYFTQuakesLocationKey                                  = @"location";
NSString * const DYFTQuakesAppFeltKey                                   = @"appFelt";
NSString * const DYFTQuakesAppNotFeltKey                                = @"appNotFelt";
NSString * const DYFTQuakesPubNubChannelKey                             = @"pubnubChannel";
NSString * const DYFTQuakesRelatedUserEventsKey                         = @"relatedUserEvents";

NSString * const DYFTQuakesPushedToUsersKey                             = @"pushedToUsers";
NSString * const DYFTQuakesFeltByUsersKey                               = @"feltByUsers";
NSString * const DYFTQuakesNotFeltByUsersKey                            = @"notFeltByUsers";


//-------------------------------------------------------------------------------------------------------------------------------------------------
NSString * const DYFTUserEventClassKey                                  = @"UserEvent";
NSString * const DYFTUserEventObjectIdKey                               = @"objectId";
NSString * const DYFTUserEventUserKey                                   = @"user";
NSString * const DYFTUserEventInstallationKey                           = @"installation";
NSString * const DYFTUserEventCreatedAtKey                              = @"createdAt";
NSString * const DYFTUserEventUserLocationKey                           = @"userLocation";
NSString * const DYFTUserEventExpirationKey                             = @"expirationDate";
NSString * const DYFTUserEventMercaliGuessKey                           = @"mercaliGuess";
NSString * const DYFTUserEventRichterGuessKey                           = @"richterGuess";
NSString * const DYFTUserEventTimeAgoGuessKey                           = @"timeAgoGuess";
NSString * const DYFTUserEventDistanceGuessKey                          = @"distanceGuess";
NSString * const DYFTUserEventPossibleRelatedEventsKey                  = @"possibleRelatedEvents";
NSString * const DYFTUserEventRelatedQuakeKey                           = @"relatedQuake";
NSString * const DYFTUserEventRelatedQuakeIdKey                         = @"relatedQuakeId";
NSString * const DYFTUserEventRelatedGroupEventKey                      = @"relatedGroupEvent";
NSString * const DYFTUserEventEventFoundKey                             = @"eventFound";

//-------------------------------------------------------------------------------------------------------------------------------------------------
NSString * const DYFTGroupEventClassKey                                 = @"GroupEvent";
NSString * const DYFTGroupEventObjectIdKey                              = @"objectId";
NSString * const DYFTGroupEventCreatedAtKey                             = @"createdAt";
NSString * const DYFTGroupEventEventTitleKey                            = @"eventTitle";
NSString * const DYFTGroupEventRelatedQuakeKey                          = @"relatedQuake";
NSString * const DYFTGroupEventRelatedUserEventsKey                     = @"relatedUserEvents";


//-------------------------------------------------------------------------------------------------------------------------------------------------
// Event Type Values
NSString * const kDYFTEventTypeEarthquake                               = @"earthquake";
NSString * const kDYFTEventTypeAcousticNoise                            = @"acoustic noise";
NSString * const kDYFTEventTypeAnthropogenicEvent                       = @"anthropogenic event";
NSString * const kDYFTEventTypeChemicalExplosion                        = @"chemical explosion";
NSString * const kDYFTEventTypeExplosion                                = @"explosion";
NSString * const kDYFTEventTypeLandslide                                = @"landslide";
NSString * const kDYFTEventTypeMineCollapse                             = @"mine collapse";
NSString * const kDYFTEventTypeMiningExplosion                          = @"mining explosion";
NSString * const kDYFTEventTypeNotReported                              = @"not reported";
NSString * const kDYFTEventTypeNuclearExplosion                         = @"nuclear explosion";
NSString * const kDYFTEventTypeOtherEvent                               = @"other event";
NSString * const kDYFTEventTypeQuarry                                   = @"quarry";
NSString * const kDYFTEventTypeQuarryBlast                              = @"quarry blast";
NSString * const kDYFTEventTypeRockBurst                                = @"rock burst";
NSString * const kDYFTEventTypeSonicboom                                = @"sonicboom";
NSString * const kDYFTEventTypeSonicBoom                                = @"sonic boom";

//-------------------------------------------------------------------------------------------------------------------------------------------------


// ****************************************************************************
// NSNotification userInfo keys:
// ****************************************************************************
NSString * const kDYFTFilterDistanceKey                                 = @"filterDistance";
NSString * const kDYFTLocationKey                                       = @"location";


// ****************************************************************************
// Notification names:
// ****************************************************************************

// All five of these notifications are observed by the AllQuakesTableViewController & FeltQuakesTableViewController.
// The AllQuakesViewController & FeltQuakesViewController do not need the DYFTCurrentLocationDidChangeNotification.

NSString * const DYFTDistanceFilterDidChangeNotification                = @"DYFTDistanceFilterDidChangeNotification";
NSString *const DYFTDateFilterDidChangeNotification                     = @"DYFTDateFilterDidChangeNotification";
NSString *const DYFTMagnitudeFilterDidChangeNotification                = @"DYFTMagnitudeFilterDidChangeNotification";

// PAWCurrentLocationDidChangeNotification is sent when a user changes location.
NSString * const DYFTCurrentLocationDidChangeNotification               = @"DYFTCurrentLocationDidChangeNotification";

// DYFTQuakeCreatedNotification is sent when the server pushes out a new event.
NSString * const DYFTQuakeCreatedNotification                           = @"DYFTQuakeCreatedNotification";

NSString * const DYFTAppStartedNotifiction                              = @"DYFTAppStartedNotification";
NSString * const DYFTUserLoggedInNotification                           = @"DYFTUserLoggedInNotification";
NSString * const DYFTUserLoggedOutNotification                          = @"DYFTUserLoggedOutNotification";
NSString * const DYFTAppDelegateApplicationDidReceiveRemoteNotification = @"DYFTAppDelegateApplicationDidReceiveRemoteNotification";
NSString * const DYFTUtilityUserSubscribingChangedNotification          = @"DYFTUtilityUserSubscribingChangedNotification";

#pragma mark - UIUserNotificationSettings, UIUserNotificationCategories, UIUserNotificationActions
NSString * const DYFTUserNotificationNewEventCategory                   = @"DidYouFeelItEventCategory";
NSString * const DYFTUserNotificationNewEventFeltItAction               = @"FeltItActionOne";
NSString * const DYFTUserNotificationNewEventDidntFeelItAction          = @"DidntFeelItActionTwo";


// ****************************************************************************
// UI strings:
// ****************************************************************************
NSString * const kDYFTWallCantViewPost                                  = @"Can’t view post! Get closer.";


// ****************************************************************************
// NSUserDefaults
// ****************************************************************************
NSString * const DYFTUserDefaultsFilterDistanceKey                      = @"filterDistance";
NSString * const DYFTUserDefaultsMinimumMagnitudeKey                    = @"minimumMagnitude";
NSString * const DYFTUserDefaultsStatesToWatchKey                       = @"statesToWatch";

typedef double DYFTLocationAccuracy;

#endif // Did_You_Feel_That__DYFTConstants_h
