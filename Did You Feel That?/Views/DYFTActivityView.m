//
//  DYFTActivityView.m
//  Did You Feel That?
//
//  Created by Emily Priddy on 6/10/15.
//  Copyright (c) 2015 Headstorm Studios. All rights reserved.
//

#import "DYFTActivityView.h"

static CGFloat const DYFTActivityViewLabelCenterXOffset = 5.0f;
static CGFloat const DYFTActivityViewActivityIndicatorRightInset = 10.0f;

@implementation DYFTActivityView

#pragma mark -
#pragma mark Init

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.7f];

        self.label = [[UILabel alloc] initWithFrame:CGRectZero];
        self.label.textColor = [UIColor whiteColor];
        self.label.backgroundColor = [UIColor clearColor];
        [self addSubview:self.label];

        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [self addSubview:self.activityIndicator];
    }
    return self;
}

#pragma mark -
#pragma mark UIView

- (void)layoutSubviews {
    [super layoutSubviews];

    CGRect bounds = self.bounds;

    CGRect labelFrame = CGRectZero;
    labelFrame.size = [self.label sizeThatFits:bounds.size];
    labelFrame.origin.x = CGRectGetMidX(bounds) - CGRectGetMidX(labelFrame) + DYFTActivityViewLabelCenterXOffset;
    labelFrame.origin.y = CGRectGetMidY(bounds) - CGRectGetMidY(labelFrame);
    self.label.frame = labelFrame;

    CGRect activityIndicatorFrame = self.activityIndicator.frame;
    activityIndicatorFrame.origin.x = CGRectGetMinX(labelFrame) - CGRectGetWidth(activityIndicatorFrame) - DYFTActivityViewActivityIndicatorRightInset;
    activityIndicatorFrame.origin.y = CGRectGetMidY(labelFrame) - floorf(CGRectGetHeight(activityIndicatorFrame) / 2.0f);
    self.activityIndicator.frame = activityIndicatorFrame;
}

#pragma mark -
#pragma mark Accessors

- (void)setLabel:(UILabel *)label {
    if (self.label != label) {
        [_label removeFromSuperview];
        _label = label;
        [self addSubview:_label];
        [self setNeedsLayout];
    }
}

@end
