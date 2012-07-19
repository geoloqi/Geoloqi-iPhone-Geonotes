//
//  LQAppDelegate.h
//  Geonotes
//
//  Created by Aaron Parecki on 7/7/12.
//  Copyright (c) 2012 Geoloqi, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LQActivityViewController.h"
#import "LQGeonotesViewController.h"
#import "LQNewGeonoteViewController.h"
#import "LQLayersViewController.h"
#import "LQSettingsViewController.h"

static NSString *LQActivityListCollectionName = @"LQActivityListCollection";
static NSString *LQLayerListCollectionName = @"LQLayerListCollection";

@interface LQAppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UITabBarController *tabBarController;

@property (strong, nonatomic) LQActivityViewController *activityViewController;

- (IBAction)newGeonoteButtonWasTapped:(UIButton *)sender;

+ (NSString *)cacheDatabasePathForCategory:(NSString *)category;

@end
