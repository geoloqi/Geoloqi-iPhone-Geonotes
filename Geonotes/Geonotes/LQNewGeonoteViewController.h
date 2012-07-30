//
//  LQNewGeonoteViewController.h
//  Geonotes
//
//  Created by Aaron Parecki on 7/18/12.
//  Copyright (c) 2012 Geoloqi, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LQNewGeonoteMapViewController.h"

@interface LQNewGeonoteViewController : UIViewController <UITextViewDelegate> {
    LQNewGeonoteMapViewController *mapViewController;
}

@property (nonatomic, strong) IBOutlet UINavigationBar *navigationBar;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *cancelBarButton;
@property (nonatomic, strong) IBOutlet UITextView *geonoteTextView;
@property (nonatomic, strong) IBOutlet UIButton *pickOnMapButton;
@property (nonatomic, strong) IBOutlet UIButton *submitButton;
@property (nonatomic, strong) IBOutlet UILabel *locationLabel;

- (IBAction)cancelBarButtonWasTapped:(id)sender;
- (IBAction)pickOnMapButtonWasTapped:(id)sender;
- (IBAction)submitButtonWasTapped:(id)sender;

@end