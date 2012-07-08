//
//  LQAppDelegate.h
//  Geonotes
//
//  Created by Aaron Parecki on 7/7/12.
//  Copyright (c) 2012 Geoloqi, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LQAppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UITabBarController *tabBarController;

- (IBAction)newGeonoteButtonWasTapped:(UIButton *)sender;

+ (NSString *)cacheDatabasePathForCategory:(NSString *)category;

@end
