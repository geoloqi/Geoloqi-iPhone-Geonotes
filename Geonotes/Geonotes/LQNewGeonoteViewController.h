//
//  LQNewGeonoteViewController.h
//  Geonotes
//
//  Created by Aaron Parecki on 7/18/12.
//  Copyright (c) 2012 Geoloqi, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LQNewGeonoteMapViewController.h"

#define kLQGeonoteTotalCharacterCount 140

@interface LQNewGeonoteViewController : UIViewController <UITextViewDelegate, UITableViewDataSource, UITableViewDelegate> {
    LQNewGeonoteMapViewController *mapViewController;
    UILabel *characterCount;
    CLLocation *geonoteLocation;
    NSString *geonoteLocationDescription;
}

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UITextView *geonoteTextView;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *cancelButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *saveButton;

- (IBAction)cancelButtonWasTapped:(id)sender;
- (IBAction)saveButtonWasTapped:(id)sender;

@end