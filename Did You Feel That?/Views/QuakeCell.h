//
//  QuakeCell.h
//  Did You Feel That?
//
//  Created by Emily Priddy on 6/17/15.
//  Copyright (c) 2015 Headstorm Studios. All rights reserved.
//

@import UIKit;

extern CGFloat const DYFTQuakeTableViewCellLabelsFontSize;

typedef NS_ENUM(uint8_t, QuakeCellStyle)
{
    QuakeCellStyleFelt = 1,
    QuakeCellStyleNotFelt
};

@class Quake;

@interface QuakeCell : UITableViewCell

@property (strong, nonatomic) Quake *quake;

@property (strong, nonatomic) UILabel *magnitudeLabel;
@property (strong, nonatomic) UILabel *placeLabel;
@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) UILabel *typeLabel;
@property (strong, nonatomic) UILabel *agoLabel;
@property (strong, nonatomic) UILabel *dateLabel;
@property (strong, nonatomic) UIButton *launchButton;

@property (nonatomic, assign, readonly) QuakeCellStyle quakeCellStyle;

+ (CGSize)sizeThatFits:(CGSize)boundingSize forQuake:(Quake *)quake;

- (instancetype)initWithQuakeCellStyle:(QuakeCellStyle)style
                       reuseIdentifier:(NSString *)reuseIdentifier;

- (void)updateFromQuake:(Quake *)quake;
//- (void)launchQuakeChannelVC;

@end
