//
//  DYFTConfigManager.h
//  Did You Feel That?
//
//  Acts as a proxy to PFConfig to manage app
//  parameters that are configured remotely.
//
//  Created by Emily Priddy on 6/10/15.
//  Copyright (c) 2015 Headstorm Studios. All rights reserved.
//

@import UIKit;

@interface DYFTConfigManager : NSObject

+ (instancetype)sharedManager;

- (void)fetchConfigIfNeeded;
- (NSArray *)filterDistanceOptions;
- (NSUInteger)postMaxCharacterCount;
@end
