//
//  LQSetupAccountViewController.h
//  Geonotes
//
//  Created by Kenichi Nakamura on 7/19/12.
//  Copyright (c) 2012 Geoloqi, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LQButtonTableViewCell.h"

@interface LQSetupAccountViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate> {
    
    LQButtonTableViewCell *buttonTableViewCell;
}

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UITextField *emailAddressField;

- (void)resetField;

@end
