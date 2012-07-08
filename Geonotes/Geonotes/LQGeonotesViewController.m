//
//  LQSecondViewController.m
//  Geonotes
//
//  Created by Aaron Parecki on 7/7/12.
//  Copyright (c) 2012 Geoloqi, Inc. All rights reserved.
//

#import "LQGeonotesViewController.h"

@interface LQGeonotesViewController ()

@end

@implementation LQGeonotesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Geonotes", @"Geonotes");
        self.tabBarItem.image = [UIImage imageNamed:@"geonote"];
    }
    return self;
}
							
- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"Geonotes View Loaded");

    [self.tableView setBackgroundColor:[UIColor colorWithWhite:249.0/255.0 alpha:1.0]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
