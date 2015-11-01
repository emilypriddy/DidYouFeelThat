//
//  DYFTConstants.h
//  Did You Feel That?
//
//  Created by Emily Priddy on 6/10/15.
//  Copyright (c) 2015 Headstorm Studios. All rights reserved.
//

typedef enum {
    DYFTHomeTabBarItemIndex     = 0,
    DYFTMyEventsTabBarItemIndex = 1,
    DYFTEventsTabBarItemIndex   = 2,
    DYFTSettingsTabBarItemIndex = 3
} DYFTTabBarControllerViewControllerIndex;

extern double DYFTFeetToMeters(double feet);
extern double DYFTMetersToFeet(double meters);
extern double DYFTMetersToKilometers(double meters);
extern double DYFTFeetToMiles(double feet);
extern double DYFTMilesToFeet(double miles);
extern double DYFTMilesToKilometers(double miles);
extern double DYFTKilometersToMiles(double kilometers);

extern double const DYFTEarthRadiusMiles;
extern double const DYFTEarthRadiusKilometers;

extern NSTimeInterval const DYFTLocationUpdatesTimeInterval;


extern double const DYFTDefaultFilterDistance;
extern double const DYFTAllQuakesMaximumSearchDistance;
extern double const DYFTFeltQuakesMaximumSearchDistance;


extern NSUInteger const DYFTAllQuakesSearchDefaultLimit;
extern NSUInteger const DYFTFeltQuakesSearchDefaultLimit;
extern NSUInteger const DYFTDefaultTab;

// ****************************************************************************
// Parse API key constants:
// ****************************************************************************

#pragma mark PARSE API CONSTANTS:

#pragma mark Installation Class
// Class key
extern NSString *const DYFTInstallationClassKey;  //Class name

// Field keys
extern NSString *const DYFTInstallationObjectIdKey;  //String
extern NSString *const DYFTInstallationUserKey;  //Pointer to User Class
extern NSString *const DYFTInstallationChannelsKey; //Array
extern NSString *const DYFTInstallationBadgeKey; //Number
extern NSString *const DYFTInstallationDeviceTokenKey;  //String
extern NSString *const DYFTInstallationRelatedUserEventsKey;  //Relation to UserEvents Class objects
extern NSString *const DYFTInstallationInstallationIdKey; //String
extern NSString *const DYFTInstallationLocationKey;  //GeoPoint
extern NSString *const DYFTInstallationMaxDistanceKey;  //Number
extern NSString *const DYFTInstallationMinMagnitudeKey; //Number
extern NSString *const DYFTInstallationNearbyQuakesKey;  //Boolean


#pragma mark User Class
// Class key
extern NSString *const DYFTUserClassKey;  //Class name

// Field keys
extern NSString *const DYFTUserObjectIdKey;  //String
extern NSString *const DYFTUserUsernameKey;  //String (Lowercase copy of DYFTUserEmailKey)
extern NSString *const DYFTUserDisplayNameKey; //String
extern NSString *const DYFTUserDisplayNameLowercaseKey;  //String
extern NSString *const DYFTUserPictureKey;  //File
extern NSString *const DYFTUserThumbnailKey;  //File
extern NSString *const DYFTUserPasswordKey;  //String
extern NSString *const DYFTUserEmailKey;  //String
extern NSString *const DYFTUserFacebookIdKey;  //String


#pragma mark USGSQuakes Class
// Class key
extern NSString *const DYFTQuakesClassKey;

// Field keys
extern NSString *const DYFTQuakesObjectIdKey;
extern NSString *const DYFTQuakesUSGSIdKey;
extern NSString *const DYFTQuakesMagnitudeKey;
extern NSString *const DYFTQuakesDepthKey;
extern NSString *const DYFTQuakesEventTypeKey;
extern NSString *const DYFTQuakesTimestampKey;
extern NSString *const DYFTQuakesCreatedAtKey;
extern NSString *const DYFTQuakesTimeKey;
extern NSString *const DYFTQuakesMonthKey;
extern NSString *const DYFTQuakesTitleKey;
extern NSString *const DYFTQuakesDetailURLKey;
extern NSString *const DYFTQuakesLatitudeKey;
extern NSString *const DYFTQuakesLongitudeKey;
extern NSString *const DYFTQuakesPlaceKey;
extern NSString *const DYFTQuakesUSGSCodeKey;
extern NSString *const DYFTQuakesTZKey;
extern NSString *const DYFTQuakesUpdatedKey;
extern NSString *const DYFTQuakesCDIKey;
extern NSString *const DYFTQuakesFeltKey;
extern NSString *const DYFTQuakesCountryKey;
extern NSString *const DYFTQuakesStateKey;
extern NSString *const DYFTQuakesLocationKey;
extern NSString *const DYFTQuakesAppFeltKey;
extern NSString *const DYFTQuakesAppNotFeltKey;
extern NSString *const DYFTQuakesPushedToUsersKey;
extern NSString *const DYFTQuakesFeltByUsersKey;
extern NSString *const DYFTQuakesNotFeltByUsersKey;
extern NSString *const DYFTQuakesPubNubChannelKey;
extern NSString *const DYFTQuakesRelatedUserEventsKey;

#pragma mark UserEvent Class
// Class key
extern NSString *const DYFTUserEventClassKey;

// Field keys
extern NSString *const DYFTUserEventObjectIdKey;
extern NSString *const DYFTUserEventUserKey;
extern NSString *const DYFTUserEventInstallationKey;
extern NSString *const DYFTUserEventCreatedAtKey;
extern NSString *const DYFTUserEventUserLocationKey;
extern NSString *const DYFTUserEventExpirationKey;
extern NSString *const DYFTUserEventMercaliGuessKey;
extern NSString *const DYFTUserEventRichterGuessKey;
extern NSString *const DYFTUserEventTimeAgoGuessKey;
extern NSString *const DYFTUserEventDistanceGuessKey;
extern NSString *const DYFTUserEventEventFoundKey;
extern NSString *const DYFTUserEventRelatedQuakeKey;
extern NSString *const DYFTUserEventRelatedQuakeIdKey;
extern NSString *const DYFTUserEventPossibleRelatedEventsKey; // This is a Relation to other UserEvent objects.
extern NSString *const DYFTUserEventRelatedGroupEventKey; // This is a Pointer to a GroupEvent object. If everything works as hoped, a UserEvent will be matched to a GroupEvent, which will correspond with a USGSQuakes object.

#pragma mark GroupEvent Class
// Class key
extern NSString *const DYFTGroupEventClassKey;

// Field keys
extern NSString *const DYFTGroupEventObjectIdKey;
extern NSString *const DYFTGroupEventCreatedAtKey;
extern NSString *const DYFTGroupEventEventTitleKey;
extern NSString *const DYFTGroupEventRelatedQuakeKey; // This is a Pointer to a USGSQuakes object.
extern NSString *const DYFTGroupEventRelatedUserEventsKey; // This is a Relation to all of the UserEvent objects that belong to this EventGroup object.


// Event Type Values
extern NSString *const kDYFTEventTypeEarthquake;
extern NSString *const kDYFTEventTypeAcousticNoise;
extern NSString *const kDYFTEventTypeAnthropogenicEvent;
extern NSString *const kDYFTEventTypeChemicalExplosion;
extern NSString *const kDYFTEventTypeExplosion;
extern NSString *const kDYFTEventTypeLandslide;
extern NSString *const kDYFTEventTypeMineCollapse;
extern NSString *const kDYFTEventTypeMiningExplosion;
extern NSString *const kDYFTEventTypeNotReported;
extern NSString *const kDYFTEventTypeNuclearExplosion;
extern NSString *const kDYFTEventTypeOtherEvent;
extern NSString *const kDYFTEventTypeQuarry;
extern NSString *const kDYFTEventTypeQuarryBlast;
extern NSString *const kDYFTEventTypeRockBurst;
extern NSString *const kDYFTEventTypeSonicboom;
extern NSString *const kDYFTEventTypeSonicBoom;


// ****************************************************************************
// NSNotification userInfo keys:
// ****************************************************************************
#pragma mark - NSNotification userInfo Keys
extern NSString *const kDYFTFilterDistanceKey;
extern NSString *const kDYFTLocationKey;


// ****************************************************************************
// Notification names:
// ****************************************************************************
#pragma mark - NSNotification names
// All five of these notifications are observed by the AllQuakesTableViewController & FeltQuakesTableViewController.
// The AllQuakesViewController & FeltQuakesViewController do not need the DYFTCurrentLocationDidChangeNotification.

// DYFTDistanceFilterDidChangeNotification sent when the search radius distance is changed.
extern NSString *const DYFTDistanceFilterDidChangeNotification;
extern NSString *const DYFTDateFilterDidChangeNotification;
extern NSString *const DYFTMagnitudeFilterDidChangeNotification;

// DYFTCurrentLocationDidChangeNotification is sent when a user changes location.
extern NSString *const DYFTCurrentLocationDidChangeNotification;

// DYFTQuakeCreatedNotification is sent when the server pushes out a new event.
extern NSString *const DYFTQuakeCreatedNotification;


extern NSString *const DYFTAppStartedNotifiction;
extern NSString *const DYFTUserLoggedInNotification;
extern NSString *const DYFTUserLoggedOutNotification;
extern NSString *const DYFTAppDelegateApplicationDidReceiveRemoteNotification;
extern NSString *const DYFTUtilityUserSubscribingChangedNotification;

// ****************************************************************************
// Notification Settings, Categories, and Actions:
// ****************************************************************************

#pragma mark - UIUserNotificationSettings, UIUserNotificationCategories, UIUserNotificationActions
extern NSString *const DYFTUserNotificationNewEventCategory;
extern NSString *const DYFTUserNotificationNewEventFeltItAction;
extern NSString *const DYFTUserNotificationNewEventDidntFeelItAction;


// ****************************************************************************
// UI strings:
// ****************************************************************************
extern NSString *const kDYFTWallCantViewPost;


// ****************************************************************************
// NSUserDefaults
// ****************************************************************************
extern NSString *const DYFTUserDefaultsFilterDistanceKey;
extern NSString *const DYFTUserDefaultsMinimumMagnitudeKey;
extern NSString *const DYFTUserDefaultsStatesToWatchKey;

typedef double DYFTLocationAccuracy;

