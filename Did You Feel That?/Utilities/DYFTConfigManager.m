//
//  DYFTConfigManager.m
//  Did You Feel That?
//
//  Created by Emily Priddy on 6/10/15.
//  Copyright (c) 2015 Headstorm Studios. All rights reserved.
//

#import "DYFTConfigManager.h"
#import <Parse/PFConfig.h>

@interface DYFTConfigManager ()
@property (strong, nonatomic) PFConfig *config;
@property (strong, nonatomic) NSDate *configLastFetchedDate;
@end

@implementation DYFTConfigManager

#pragma mark - Init

+ (instancetype)sharedManager {
    static DYFTConfigManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(fetchConfigIfNeeded)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];
    }
    return self;
}

#pragma mark - Dealloc

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -
#pragma mark Fetch

- (void)fetchConfigIfNeeded {
    static const NSTimeInterval configRefreshInterval = 60.0 * 60.0; // 1 hour

    if (self.config == nil ||
        self.configLastFetchedDate == nil ||
        [self.configLastFetchedDate timeIntervalSinceNow] * -1.0 > configRefreshInterval) {
        // Set the config to the cached version and start fetching new config
        self.config = [PFConfig currentConfig];

        // Set the date to current and use it as a flag that config fetch is in progress
        self.configLastFetchedDate = [NSDate date];

        [PFConfig getConfigInBackgroundWithBlock:^(PFConfig *config, NSError *error) {
            if (error == nil) {
                // Yay, config was fetched
                self.config = config;
                self.configLastFetchedDate = [NSDate date];
            } else {
                // Remove the flag to indicate that we should refetch the config once again
                self.configLastFetchedDate = nil;
            }
        }];
    }
}

#pragma mark - Parameters

- (NSArray *)filterDistanceOptions {
    NSMutableArray *distanceOptions = [self.config[@"availableFilterDistances"] mutableCopy];
    if (!distanceOptions) {
        // No config value, fall back to the defaults
        distanceOptions = [@[ @(250.0), @(2000.0), @(5000.0), @(10000.0), @(25000.0), @(50000.0), @(100000.0), @(250000.0) ] mutableCopy];
    }
    return [distanceOptions copy];
}

- (NSUInteger)postMaxCharacterCount {
    NSNumber *number = self.config[@"postMaxCharacterCount"];
    if (number == nil) {
        // No config value, fall back to the defaults
        return 140;
    }
    return [number unsignedIntegerValue];
}

@end
