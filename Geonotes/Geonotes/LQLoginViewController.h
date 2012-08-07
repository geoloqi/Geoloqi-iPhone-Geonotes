//
//  LQLoginViewController.h
//  Geonotes
//
//  Created by Kenichi Nakamura on 7/19/12.
//  Copyright (c) 2012 Geoloqi, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LQSettingsViewController.h"
#import "LQButtonTableViewCell.h"

@interface LQLoginViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate> {
    
    LQButtonTableViewCell *buttonTableViewCell;
}

@property (nonatomic, strong) IBOutlet UITableView *settingsTableView;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UITextField *emailAddressField;
@property (nonatomic, strong) IBOutlet UITextField *passwordField;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicator;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andSettingsTableView:(UITableView *)settingsTableView;

- (void)resetFields;

@end
