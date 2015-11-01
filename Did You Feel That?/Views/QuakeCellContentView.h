//
//  QuakeCellContentView.h
//  Did You Feel That?
//
//  Created by Emily Priddy on 6/18/15.
//  Copyright (c) 2015 Headstorm Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Quake;

@interface QuakeCellContentView : UIView

@property (strong, nonatomic) UILabel *magnitudeLabel;
@property (strong, nonatomic) UILabel *placeLabel;
@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) UILabel *typeLabel;
@property (strong, nonatomic) UILabel *agoLabel;
@property (strong, nonatomic) UILabel *dateLabel;

- (void)updateFromQuake:(Quake *)quake;

- (instancetype)init;

@end
