//
//  QuakeCellContentView.m
//  Did You Feel That?
//
//  Created by Emily Priddy on 6/18/15.
//  Copyright (c) 2015 Headstorm Studios. All rights reserved.
//

#import "QuakeCellContentView.h"
#import "Quake.h"
#import "NSDate+DateTools.h"
#import <PureLayout/PureLayout.h>

@implementation QuakeCellContentView

- (instancetype)init {
    if (self = [super init]) {

        UIFontDescriptor *helveticaBaseFont = [UIFontDescriptor fontDescriptorWithFontAttributes:
                                               @{UIFontDescriptorFamilyAttribute:@"HelveticaNeue"}];
        UIFont *magnitudeFont = [UIFont fontWithDescriptor:helveticaBaseFont size:16];
        UIFont *placeFont = [UIFont fontWithDescriptor:helveticaBaseFont size:14];
        UIFont *detailFont = [UIFont fontWithDescriptor:helveticaBaseFont size:11];

        self.magnitudeLabel = [UILabel new];
        self.magnitudeLabel.font = magnitudeFont;
        self.magnitudeLabel.textColor = [UIColor colorWithRed:0.729 green:0.125 blue:0.145 alpha:1.000];
        [self addSubview:self.magnitudeLabel];

        self.placeLabel = [UILabel new];
        self.placeLabel.font = placeFont;
        self.placeLabel.textColor = [UIColor blackColor];
        [self addSubview:self.placeLabel];

        self.timeLabel = [UILabel new];
        self.timeLabel.font = detailFont;
        self.timeLabel.textColor = [UIColor colorWithWhite:0.298 alpha:1.000];
        [self addSubview:self.timeLabel];

        self.typeLabel = [UILabel new];
        self.typeLabel.font = detailFont;
        self.typeLabel.textColor = [UIColor colorWithWhite:0.298 alpha:1.000];
        [self addSubview:self.typeLabel];

        self.agoLabel = [UILabel new];
        self.agoLabel.font = detailFont;
        self.agoLabel.textColor = [UIColor colorWithWhite:0.298 alpha:1.000];
        [self addSubview:self.agoLabel];

        self.dateLabel = [UILabel new];
        self.dateLabel.font = detailFont;
        self.dateLabel.textColor = [UIColor colorWithWhite:0.298 alpha:1.000];
        [self addSubview:self.dateLabel];

    }
    return self;
}


@end
