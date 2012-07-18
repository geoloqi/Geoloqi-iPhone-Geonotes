//
//  LQSettingsViewController.h
//  Geonotes
//
//  Created by Aaron Parecki on 7/7/12.
//  Copyright (c) 2012 Geoloqi, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Geoloqi.h"
/*
#import "LQSettingsActionSheetDelegate.h"

static NSString *const LQAllowPublicGeonotesUserDefaultsKey = @"com.geoloqi.LQAllowPublicGeonotes";
*/

@interface LQSettingsViewController : UIViewController <UIAlertViewDelegate, UITableViewDataSource>
{
    /*
    UITextField *currentTextField;
    BOOL keyboadIsShown;
    LQSettingsActionSheetDelegate *actionDelegate;
    */
}

// @property (nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong) IBOutlet UISwitch *locationTracking;
// @property (strong) IBOutlet UISwitch *allowPublicGeonotes;

/*
@property (strong) IBOutlet UIButton *publicGeonoteURL;
@property (strong) IBOutlet UILabel *publicGeonoteURLLabel;

@property (strong) IBOutlet UILabel *usernameLabel;
@property (strong) IBOutlet UITextField *username;
@property (strong) IBOutlet UIButton *saveUsername;
@property (strong) IBOutlet UIActivityIndicatorView *savingIndicator;
*/

- (IBAction)locationTrackingWasSwitched:(UISwitch *)sender;
/*
- (IBAction)allowPublicGeonotesWasSwitched:(UISwitch *)sender;
- (IBAction)saveUsernameWasTapped:(UIButton *)sender;

- (IBAction)publicGeonoteURLWasTapped:(UIButton *)sender;
*/
@end