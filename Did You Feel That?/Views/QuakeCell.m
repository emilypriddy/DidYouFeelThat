//
//  QuakeCell.m
//  Did You Feel That?
//
//  Created by Emily Priddy on 6/17/15.
//  Copyright (c) 2015 Headstorm Studios. All rights reserved.
//

#import "QuakeCell.h"
#import "Quake.h"
#import "NSDate+DateTools.h"
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import <PureLayout/PureLayout.h>
#import "AppDelegate.h"

CGFloat const DYFTQuakeTableViewCellLabelsFontSize = 15.0f;

@interface QuakeCell ()
{
    UIImageView *_backgroundImageView;
}

@property (nonatomic, assign, readwrite) QuakeCellStyle quakeCellStyle;
@property (nonatomic, assign) BOOL didSetupConstraints;
@end

@implementation QuakeCell
#define debug 0

#pragma mark - Init

+ (CGSize)sizeThatFits:(CGSize)boundingSize forQuake:(Quake *)quake {
    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));

    CGRect bounds = CGRectMake(0.0f, 0.0f, boundingSize.width, boundingSize.height);
    boundingSize = bounds.size;



    CGSize size = CGSizeZero;
    size.width = boundingSize.width;
    size.height = 75.0f;

    return size;
}

- (instancetype)initWithQuakeCellStyle:(QuakeCellStyle)style
                       reuseIdentifier:(NSString *)reuseIdentifier {
    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));

    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {

        UIFontDescriptor *helveticaBaseFont = [UIFontDescriptor fontDescriptorWithFontAttributes:
                                               @{UIFontDescriptorFamilyAttribute:@"HelveticaNeue"}];
        UIFont *magnitudeFont = [UIFont fontWithDescriptor:helveticaBaseFont size:22];
        UIFont *placeFont = [UIFont fontWithDescriptor:helveticaBaseFont size:14];
        UIFont *detailFont = [UIFont fontWithDescriptor:helveticaBaseFont size:11];

        self.magnitudeLabel = [UILabel new];
        self.magnitudeLabel.font = magnitudeFont;
        self.magnitudeLabel.textColor = [UIColor colorWithRed:0.729 green:0.125 blue:0.145 alpha:1.000];
        [self.contentView addSubview:self.magnitudeLabel];

        self.placeLabel = [UILabel new];
        self.placeLabel.numberOfLines = 0;
        self.placeLabel.font = placeFont;
        self.placeLabel.textColor = [UIColor blackColor];
        [self.contentView addSubview:self.placeLabel];

        self.timeLabel = [UILabel new];
        self.timeLabel.font = detailFont;
        self.timeLabel.textColor = [UIColor colorWithWhite:0.298 alpha:1.000];
        [self.contentView addSubview:self.timeLabel];

        self.typeLabel = [UILabel new];
        self.typeLabel.font = detailFont;
        self.typeLabel.textColor = [UIColor colorWithWhite:0.298 alpha:1.000];
        [self.contentView addSubview:self.typeLabel];

        self.agoLabel = [UILabel new];
        self.agoLabel.font = detailFont;
        self.agoLabel.textColor = [UIColor colorWithWhite:0.298 alpha:1.000];
        [self.contentView addSubview:self.agoLabel];

        self.dateLabel = [UILabel new];
        self.dateLabel.font = detailFont;
        self.dateLabel.textColor = [UIColor colorWithWhite:0.298 alpha:1.000];
        [self.contentView addSubview:self.dateLabel];

        self.launchButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [self.launchButton addTarget:self action:@selector(launchQuakeChannelVC) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.launchButton];

        [self setNeedsUpdateConstraints];
    }
    return self;
}

- (void)layoutSubviews {
    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));

    [super layoutSubviews];

    if (!self.didSetupConstraints) {

        self.contentView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame),75.0f);

        [self.magnitudeLabel sizeToFit];
        [self.magnitudeLabel autoSetDimension:ALDimensionHeight toSize:50.0f];
        [self.magnitudeLabel autoSetDimension:ALDimensionWidth toSize:59.0f];
        [self.magnitudeLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:5];
        [self.magnitudeLabel autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:10];

        [self.placeLabel sizeToFit];
        [self.placeLabel autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self.magnitudeLabel];
        [self.placeLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:5];
        [self.placeLabel autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:10];
        [self.placeLabel autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:self.magnitudeLabel withOffset:5.0f];

        [self.timeLabel sizeToFit];
        [self.timeLabel autoSetDimension:ALDimensionHeight toSize:12.0f];
        [self.timeLabel autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:10];
        [self.timeLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.magnitudeLabel withOffset:2.0f];

        [self.typeLabel sizeToFit];
        [self.typeLabel autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self.timeLabel];
        [self.typeLabel autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:10];
        [self.typeLabel autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:self.timeLabel withOffset:5.0f];
        [self.typeLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.placeLabel withOffset:2.0f];

        [self.agoLabel sizeToFit];
        [self.agoLabel autoSetDimension:ALDimensionHeight toSize:12.0f];
        [self.agoLabel autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:10];
        [self.agoLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.timeLabel withOffset:2.0f];
        [self.agoLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:5];

        [self.dateLabel sizeToFit];
        [self.dateLabel autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self.agoLabel];
        [self.dateLabel autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:10];
        [self.dateLabel autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:self.agoLabel withOffset:5.0f];
        [self.dateLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.typeLabel withOffset:2.0f];
        [self.dateLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:5];

        [self.launchButton autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 0, 0, 0)];

        self.didSetupConstraints = YES;
    }
}

#pragma mark - Layout

- (void)updateFromQuake:(Quake *)quake {

    NSAttributedString *magAttrString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", quake.magnitude]];
//    NSLog(@"Quake Magnitude = %@", quake.magnitude);
//    NSLog(@"Quake = %@", quake);
    self.quake = quake;
    self.magnitudeLabel.attributedText = magAttrString;
    self.timeLabel.text = quake.time;
    self.agoLabel.text = quake.date.timeAgoSinceNow;
    self.placeLabel.text = quake.place;
    self.dateLabel.text = [NSString stringWithFormat:@"Date: %@", quake.dateString];
    self.typeLabel.text = quake.eventType;

    [self setNeedsLayout];
}

//- (void)launchQuakeChannelVC {
//    if (debug==1) NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
//
//    QuakeChannelVC *channelVC = [[QuakeChannelVC alloc] init];
//
//
//    Quake *channelQuake = self.quake;
//
//    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//
//    appDelegate.pubnubConfig = [PNConfiguration configurationForOrigin:@"pubsub.pubnub.com"
//                                                            publishKey:@"pub-c-4fd8c17f-482b-4a3f-bd5d-1f326d809f0a"
//                                                          subscribeKey:@"sub-c-3f98a0c2-e6e3-11e4-a30c-0619f8945a4f"
//                                                             secretKey:@"sec-c-NjBlMzU3OTQtNWJhZi00NDUyLWE3YTItNzRkNjdmZGIwNWFk"];
//
//    NSString *clientIdentifier = [[PFUser currentUser] username];
//
//    [PubNub setClientIdentifier:clientIdentifier];
//
//
//    NSLog(@"%@", appDelegate.pubnubConfig);
//    [PubNub setConfiguration:appDelegate.pubnubConfig];
//
//    [PubNub connectWithSuccessBlock:^(NSString *origin) {
//
//        NSLog(@"{BLOCK} PubNub client connected to: %@", origin);
//    }
//     // In case of error you always can pull out error code and
//     // identify what is happened and what you can do
//     // (additional information is stored inside error's
//     // localizedDescription, localizedFailureReason and
//     // localizedRecoverySuggestion)
//                         errorBlock:^(PNError *connectionError) {
//                             //                                 BOOL isControlsEnabled = connectionError.code != kPNClientConnectionFailedOnInternetFailureError;
//                             //
//                             //                                 // Enable controls so user will be able to try again
//                             //                                 ((UIButton *) sender).enabled = isControlsEnabled;
//                             //
//                             //                                 if (connectionError.code == kPNClientConnectionFailedOnInternetFailureError) {
//                             //                                     NSLog(@"Connection will be established as soon as internet connection will be restored");
//                             //                                 }
//                             //
//                             //                                 UIAlertView *connectionErrorAlert = [UIAlertView new];
//                             //                                 connectionErrorAlert.title = [NSString stringWithFormat:@"%@(%@)",
//                             //                                                               [connectionError localizedDescription],
//                             //                                                               NSStringFromClass([self class])];
//                             //                                 connectionErrorAlert.message = [NSString stringWithFormat:@"Reason:\n%@\n\nSuggestion:\n%@",
//                             //                                                                 [connectionError localizedFailureReason],
//                             //                                                                 [connectionError localizedRecoverySuggestion]];
//                             //                                 [connectionErrorAlert addButtonWithTitle:@"OK"];
//                             //
//                             //                                 [connectionErrorAlert show];
//                         }];
//
//    appDelegate.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
//
//    channelVC.sCustomUuid = clientIdentifier;
//    channelVC.sSecret = @"sec-c-NjBlMzU3OTQtNWJhZi00NDUyLWE3YTItNzRkNjdmZGIwNWFk";
//    channelVC.currentChannel = [PNChannel channelWithName:channelQuake.usgsId];
//    channelVC.channelQuake = channelQuake;
//
//    appDelegate.window.rootViewController = channelVC;
//    [appDelegate.window makeKeyAndVisible];
//}


@end
