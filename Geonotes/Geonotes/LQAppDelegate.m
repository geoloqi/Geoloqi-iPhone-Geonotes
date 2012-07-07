//
//  LQAppDelegate.m
//  Geonotes
//
//  Created by Aaron Parecki on 7/7/12.
//  Copyright (c) 2012 Geoloqi, Inc. All rights reserved.
//

#import "LQAppDelegate.h"

#import "LQActivityViewController.h"
#import "LQGeonotesViewController.h"
#import "LQLayersViewController.h"
#import "LQSettingsViewController.h"

#import "Geoloqi.h"

@implementation LQAppDelegate

@synthesize window = _window;
@synthesize tabBarController = _tabBarController;

- (void)registerForPushNotifications {
    [LQSession registerForPushNotificationsWithCallback:^(NSData *deviceToken, NSError *error) {
        if(error){
            NSLog(@"Failed to register for push tokens: %@", error);
        } else {
            NSLog(@"Got a push token! %@", deviceToken);
        }
    }];
}

// This method is called by the Geonotes and Layers tabs when a new geonote is created or when a layer is subscribed to.
// The goal is to not prompt the user for push notifications until absolutely needed to avoid the double-popup problem on first launch.
// If the app has never launched before, then show the prompt.
- (void)registerForPushNotificationsIfNotYetRegistered {
	if(![[NSUserDefaults standardUserDefaults] boolForKey:@"hasRegisteredForPushNotifications"]){
        [self registerForPushNotifications];
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasRegisteredForPushNotifications"];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
	[LQSession setAPIKey:LQ_APIKey secret:LQ_APISecret];

    // Override point for customization after application launch.
    UIViewController *activityViewController = [[LQActivityViewController alloc] initWithNibName:@"LQActivityViewController" bundle:nil];
    UIViewController *geonotesViewController = [[LQGeonotesViewController alloc] initWithNibName:@"LQGeonotesViewController" bundle:nil];
    UIViewController *layersViewController = [[LQLayersViewController alloc] initWithNibName:@"LQLayersViewController" bundle:nil];
    UIViewController *settingsViewController = [[LQSettingsViewController alloc] initWithNibName:@"LQSettingsViewController" bundle:nil];
    self.tabBarController = [[UITabBarController alloc] init];
    self.tabBarController.viewControllers = [NSArray arrayWithObjects:activityViewController, geonotesViewController, layersViewController, settingsViewController, nil];
    self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];

    if(![LQSession savedSession]) {
		[LQSession createAnonymousUserAccountWithUserInfo:nil completion:^(LQSession *session, NSError *error) {
			//If we successfully created an anonymous session, tell the tracker to use it
			if (session) {
				NSLog(@"Created an anonymous user with access token: %@", session.accessToken);
				
				[[LQTracker sharedTracker] setSession:session]; // This saves the session so it will be restored on next app launch
				[[LQTracker sharedTracker] setProfile:LQTrackerProfileAdaptive]; // This will cause the location prompt to appear the first time
			} else {
				NSLog(@"Error creating an anonymous user: %@", error);
			}
		}];
    }

    // Tell the SDK the app finished launching so it can properly handle push notifications, etc
    [LQSession application:application didFinishLaunchingWithOptions:launchOptions];

    [self initUserDefaults];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;
{
	//For push notification support, we need to get the push token from UIApplication via this method.
	//If you like, you can be notified when the relevant web service call to the Geoloqi API succeeds.
    [LQSession registerDeviceToken:deviceToken withMode:LQPushNotificationModeLive];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error;
{
    [LQSession handleDidFailToRegisterForRemoteNotifications:error];
}

/**
 * This is called when a push notification is received if the app is running in the foreground. If the app was in the
 * background when the push was received, this will be run as soon as the app is brought to the foreground by tapping the notification.
 * The SDK will also call this method in application:didFinishLaunchingWithOptions: if the app was launched because of a push notification.
 */
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [LQSession handlePush:userInfo];
}


- (void)initUserDefaults {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults objectForKey:LQAllowPublicGeonotesUserDefaultsKey]) {
        LQSession *session = [LQSession savedSession];
        NSLog(@"calling 'account/privacy'...");
        [session runAPIRequest:[session requestWithMethod:@"GET" path:@"account/privacy" payload:nil]
                    completion:^(NSHTTPURLResponse *response, NSDictionary *responseDictionary, NSError *error) {
                        NSLog(@"public_geonotes response: %@", [responseDictionary objectForKey:@"public_geonotes"]);
                        [defaults setObject:[responseDictionary objectForKey:@"public_geonotes"] forKey:LQAllowPublicGeonotesUserDefaultsKey];
                    }
         ];
    }
    [defaults synchronize];
}

@end
