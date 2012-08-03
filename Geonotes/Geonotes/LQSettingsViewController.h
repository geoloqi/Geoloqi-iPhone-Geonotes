//
//  LQSettingsViewController.h
//  Geonotes
//
//  Created by Aaron Parecki on 7/7/12.
//  Copyright (c) 2012 Geoloqi, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Geoloqi.h"
#import "LQSetupAccountViewController.h"
#import "LQLoginViewController.h"
#import "LQPrivacyPolicyViewController.h"

static NSString *const LQDisplayNameUserDefaultsKey = @"com.geoloqi.geonotes.LQDisplayName";

@interface LQSettingsViewController : UIViewController <UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate>
{
    NSArray *sectionHeaders;
}

@property (nonatomic, strong) IBOutlet UISwitch *locationTracking;
@property (nonatomic, strong) IBOutlet UINavigationBar *navigationBar;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIViewController *setupAccountViewController;
@property (nonatomic, strong) IBOutlet UIViewController *loginViewController;
@property (nonatomic, strong) IBOutlet UIViewController *privacyPolicyViewController;

- (IBAction)locationTrackingWasSwitched:(UISwitch *)sender;

- (void)setupAccountCellWasTapped;

@end