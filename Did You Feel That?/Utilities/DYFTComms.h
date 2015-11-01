//
//  DYFTComms.h
//  Did You Feel That?
//
//  Created by Emily Priddy on 7/14/15.
//  Copyright (c) 2015 Headstorm Studios. All rights reserved.
//

@import Foundation;

@protocol DYFTCommsDelegate <NSObject>
- (void)dyftCommsDidLogin:(BOOL)loggedIn;
@end

@interface DYFTComms : NSObject
+ (void)login:(id<DYFTCommsDelegate>)delegate;
@end
