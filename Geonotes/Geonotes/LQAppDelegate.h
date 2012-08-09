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

//#define kLQUsingAnonymouslyBannerOriginX  10
//#define kLQUsingAnonymouslyBannerOriginY  10
#define kLQUsingAnonymouslyBannerHeight   44
//#define kLQUsingAnonymouslyBannerWidth    300

#define kLQAnonymousBannerBackgroundRed   (232.0 / 255.0)
#define kLQAnonymousBannerBackgroundGreen (136.0 / 255.0)
#define kLQAnonymousBannerBackgroundBlue  ( 70.0 / 255.0)

#define kLQAnonymousBannerBackgroundAlpha 1.0

static NSString *LQActivityListCollectionName = @"LQActivityListCollection";
static NSString *LQLayerListCollectionName = @"LQLayerListCollection";
static NSString *LQGeonoteListCollectionName = @"LQGeonoteListCollection";

@interface LQAppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate>
{
    LQActivityViewController *activityViewController;
    
    UINavigationController *newGeonoteNavController;
    LQGeonotesViewController *geonotesViewController;
    UINavigationController *geonotesNavController;
    
    LQLayersViewController *layersViewController;
    LQSettingsViewController *settingsViewController;
    UINavigationController *settingsNavController;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UITabBarController *tabBarController;

- (IBAction)newGeonoteButtonWasTapped:(UIButton *)sender;
- (void)refreshAllSubTableViews;

- (void)selectSetupAccountView;
- (void)addUsingAnonymouslyBannerToView:(UIView *)view withTableView:(UITableView *)tableView;

+ (NSString *)cacheDatabasePathForCategory:(NSString *)category;

+ (void)registerForPushNotificationsIfNotYetRegistered;

@end
