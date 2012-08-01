//
//  LQNewGeonoteViewController.h
//  Geonotes
//
//  Created by Aaron Parecki on 7/18/12.
//  Copyright (c) 2012 Geoloqi, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LQGeonote.h"
#import "LQNewGeonoteMapViewController.h"

#define kLQGeonoteTotalCharacterCount 140

@interface LQNewGeonoteViewController : UIViewController <UITextViewDelegate, UITableViewDataSource, UITableViewDelegate, LQGeonoteDelegate, UIActionSheetDelegate> {
    LQNewGeonoteMapViewController *mapViewController;
    UILabel *characterCount;
    NSString *geonoteLocationDescription;
}

@property (nonatomic, strong) LQGeonote *geonote;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UITextView *geonoteTextView;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *cancelButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *saveButton;

- (IBAction)cancelButtonWasTapped:(id)sender;
- (IBAction)saveButtonWasTapped:(id)sender;

@end