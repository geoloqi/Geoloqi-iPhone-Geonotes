//
//  LQSettingsViewController.h
//  Geonotes
//
//  Created by Aaron Parecki on 7/7/12.
//  Copyright (c) 2012 Geoloqi, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Geoloqi.h"

@interface LQSettingsViewController : UIViewController <UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate>
{
    NSArray *sectionHeaders;
}

@property (strong) IBOutlet UISwitch *locationTracking;

- (IBAction)locationTrackingWasSwitched:(UISwitch *)sender;

@end