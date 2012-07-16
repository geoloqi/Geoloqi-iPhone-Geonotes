//
//  LQSettingsViewController.h
//  Geonotes
//
//  Created by Aaron Parecki on 7/7/12.
//  Copyright (c) 2012 Geoloqi, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Geoloqi.h"

static NSString *const LQAllowPublicGeonotesUserDefaultsKey = @"com.geoloqi.LQAllowPublicGeonotes";
static NSString *const LQGeoloqiDomainName = @"geoloqi.com";

@interface LQSettingsViewController : UIViewController <UIAlertViewDelegate>
{
    UITextField *currentTextField;
    BOOL keyboadIsShown;
}

@property (nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong) IBOutlet UISwitch *locationTracking;
@property (strong) IBOutlet UISwitch *allowPublicGeonotes;

@property (strong) IBOutlet UILabel *publicGeonoteURL;
@property (strong) IBOutlet UILabel *publicGeonoteURLLabel;
@property (strong) IBOutlet UIButton *publicGeonoteURLButton;

@property (strong) IBOutlet UILabel *usernameLabel;
@property (strong) IBOutlet UITextField *username;
@property (strong) IBOutlet UIButton *saveUsername;
@property (strong) IBOutlet UIActivityIndicatorView *savingIndicator;

- (IBAction)locationTrackingWasSwitched:(UISwitch *)sender;
- (IBAction)allowPublicGeonotesWasSwitched:(UISwitch *)sender;
- (IBAction)saveUsernameWasTapped:(UIButton *)sender;

- (IBAction)publicGeonoteURLButtonWasTapped:(UIButton *)sender;

@end